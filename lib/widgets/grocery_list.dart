import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:grocery_list/data/categories.dart';
import 'package:grocery_list/models/grocery_item.dart';
import 'package:http/http.dart' as http;
import 'package:grocery_list/widgets/new_item.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var isLoading = true;
  late bool isDark;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  // Load items from Firebase
  Future<void> _loadItems() async {
    final url = Uri.https(
        'grocerylist-12706-default-rtdb.firebaseio.com', 'shopping-list.json');
    final response = await http.get(url);

    if (response.body == 'null') {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final List<GroceryItem> loadedItems = [];
    final Map<String, dynamic> listData = json.decode(response.body);

    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (element) => element.value.title == item.value['category'])
          .value;
      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }

    setState(() {
      _groceryItems = loadedItems;
      isLoading = false;
    });
  }

  // Add new item
  _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => const NewItem(),
      ),
    );

    if (newItem == null) {
      return;
    }

    // bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        'Item added Successfuly',
        style: TextStyle(
          color: isDark ? Colors.black : Colors.white,
        ),
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: isDark ? Colors.grey : Colors.grey[900],
    ));

    _loadItems();

    // Reload the list after adding the new item
  }

  // Edit existing item
  _editItem(GroceryItem item) async {
    final updatedItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => NewItem(item: item), // Pass the item to edit
      ),
    );

    if (updatedItem == null) {
      return;
    }

    // Perform a PUT request to update the item on the backend at its unique ID
    final url = Uri.https(
      'grocerylist-12706-default-rtdb.firebaseio.com',
      'shopping-list/${item.id}.json', // Reference the specific item's node
    );

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': updatedItem.name,
        'quantity': updatedItem.quantity,
        'category': updatedItem.category.title,
      }),
    );

    if (response.statusCode == 200) {
      // Update was successful, now reflect it locally
      setState(() {
        final index = _groceryItems.indexOf(item);
        _groceryItems[index] = updatedItem; // Update the existing item locally
      });

      // bool isDark =
      //     MediaQuery.of(context).platformBrightness == Brightness.dark;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Item Updated Successfuly',
          style: TextStyle(
            color: isDark ? Colors.black : Colors.white,
          ),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: isDark ? Colors.grey : Colors.grey[900],
      ));
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update item on the server.',
            style: TextStyle(
              color: isDark ? Colors.black : Colors.white,
            ),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: isDark ? Colors.grey : Colors.grey[900],
        ),
      );
    }
  }

  // Remove item from list and backend
  _removeItem(GroceryItem item) async {
    final url = Uri.https(
      'grocerylist-12706-default-rtdb.firebaseio.com',
      'shopping-list/${item.id}.json',
    );

    final response = await http.delete(url);

    if (response.statusCode == 200) {
      setState(() {
        _groceryItems.remove(item); // Remove from local state
      });
    } else {
      // Handle error
      // bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete item from the server.',
            style: TextStyle(
              color: isDark ? Colors.black : Colors.white,
            ),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: isDark ? Colors.grey : Colors.grey[900],
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        'Item deleted Successfully',
        style: TextStyle(
          color: isDark ? Colors.black : Colors.white,
        ),
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: isDark ? Colors.grey : Colors.grey[900],
    ));
    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    Widget content = Center(
      child: Text(
        'Nothing here',
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      ),
    );

    if (isLoading) {
      content = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: isDarkMode ? Colors.white : Colors.blue[700],
            ),
            const SizedBox(height: 20),
            Text(
              'Loading....',
              style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      );
    }

    if (_groceryItems.isNotEmpty) {
      content = LiquidPullToRefresh(
        color: isDarkMode ? Colors.grey[100] : Colors.grey[700],
        height: 100,
        showChildOpacityTransition: false,
        springAnimationDurationInMilliseconds: 1000,
        //borderWidth: 100,
        backgroundColor: isDarkMode ? Colors.grey : Colors.white,
        animSpeedFactor: 3,
        onRefresh: _loadItems,
        child: ListView.separated(
            itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Slidable(
                    endActionPane: ActionPane(
                      motion: const StretchMotion(),
                      children: [
                        SlidableAction(
                          borderRadius: BorderRadius.circular(10),
                          onPressed: (context) {
                            _editItem(_groceryItems[index]); // Edit the item
                          },
                          icon: Icons.edit,
                          backgroundColor: Colors.blueAccent,
                        ),
                        SlidableAction(
                          borderRadius: BorderRadius.circular(10),
                          onPressed: (context) {
                            _removeItem(
                                _groceryItems[index]); // Remove the item
                          },
                          icon: Icons.delete,
                          backgroundColor: Colors.redAccent,
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: _groceryItems[index].category.color),
                      ),
                      trailing: Text(
                        _groceryItems[index].quantity.toString(),
                        style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black),
                      ),
                      title: Text(
                        _groceryItems[index].name.toUpperCase(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black),
                      ),
                    ),
                  ),
                ),
            separatorBuilder: (context, index) => const SizedBox(height: 5),
            itemCount: _groceryItems.length),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'GROCERY LIST',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: content,
    );
  }
}
