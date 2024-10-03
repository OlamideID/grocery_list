import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:grocery_list/data/categories.dart';
import 'package:grocery_list/models/grocery_item.dart';
import 'package:grocery_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  late Future<List<GroceryItem>> _loadedItems;
  late bool isDark;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
  }

  @override
  void initState() {
    super.initState();
    _loadedItems = _loadItems();
  }

  // Load items from Firebase
  Future<List<GroceryItem>> _loadItems() async {
    final url = Uri.https(
        'grocerylist-12706-default-rtdb.firebaseio.com', 'shopping-list.json');
    final response = await http.get(url);

    if (response.statusCode >= 400) {
      throw Exception('Wahala dey');
    }
    if (response.body == 'null') {
      return [];
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
    });
    return loadedItems;
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

    // Send the new item to Firebase
    final url = Uri.https(
        'grocerylist-12706-default-rtdb.firebaseio.com', 'shopping-list.json');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': newItem.name,
        'quantity': newItem.quantity,
        'category': newItem.category.title,
      }),
    );

    // If successful, update the local state immediately
    if (response.statusCode == 200) {
      setState(() {
        _groceryItems.add(newItem); // Add new item to the local list
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Item added successfully',
          style: TextStyle(color: isDark ? Colors.black : Colors.white),
        ),
        backgroundColor: isDark ? Colors.grey : Colors.grey[900],
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Failed to add item',
          style: TextStyle(color: isDark ? Colors.black : Colors.white),
        ),
        backgroundColor: isDark ? Colors.grey : Colors.grey[900],
      ));
    }
  }

  // Edit existing item
  _editItem(GroceryItem item) async {
    final updatedItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => NewItem(item: item),
      ),
    );

    if (updatedItem == null) {
      return;
    }

    // Update item on Firebase
    final url = Uri.https(
      'grocerylist-12706-default-rtdb.firebaseio.com',
      'shopping-list/${item.id}.json',
    );
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': updatedItem.name,
        'quantity': updatedItem.quantity,
        'category': updatedItem.category.title,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        final index = _groceryItems.indexOf(item);
        _groceryItems[index] = updatedItem; // Update item in the local list
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Item updated successfully',
          style: TextStyle(color: isDark ? Colors.black : Colors.white),
        ),
        backgroundColor: isDark ? Colors.grey : Colors.grey[900],
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Failed to update item',
          style: TextStyle(color: isDark ? Colors.black : Colors.white),
        ),
        backgroundColor: isDark ? Colors.grey : Colors.grey[900],
      ));
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
        _groceryItems.remove(item); // Remove item from local list
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Item deleted successfully',
          style: TextStyle(color: isDark ? Colors.black : Colors.white),
        ),
        backgroundColor: isDark ? Colors.grey : Colors.grey[900],
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Failed to delete item',
          style: TextStyle(color: isDark ? Colors.black : Colors.white),
        ),
        backgroundColor: isDark ? Colors.grey : Colors.grey[900],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

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
      body: FutureBuilder(
        future: _loadedItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
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

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Something Went Wrong: ${snapshot.error.toString()}',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }
          if (snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Nothing here',
                style:
                    TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
            );
          }

          return LiquidPullToRefresh(
            color: isDarkMode ? Colors.grey[100] : Colors.grey[700],
            height: 100,
            showChildOpacityTransition: false,
            springAnimationDurationInMilliseconds: 1000,
            onRefresh: _loadItems,
            child: ListView.builder(
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
                                _editItem(snapshot.data![index]);
                              },
                              icon: Icons.edit,
                              backgroundColor: Colors.blueAccent,
                            ),
                            SlidableAction(
                              borderRadius: BorderRadius.circular(10),
                              onPressed: (context) {
                                _removeItem(snapshot.data![index]);
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
                              color: snapshot.data![index].category.color,
                            ),
                          ),
                          title: Text(
                            snapshot.data![index].name.toUpperCase(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    isDarkMode ? Colors.white : Colors.black),
                          ),
                          trailing: Text(
                            snapshot.data![index].quantity.toString(),
                            style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                    ),
                // separatorBuilder: (context, index) => const SizedBox(
                //       height: 5,
                //     ),
                itemCount: snapshot.data!.length),
          );
        },
      ),
    );
  }
}
