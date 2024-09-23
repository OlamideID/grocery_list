import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grocery_list/data/categories.dart';
import 'package:grocery_list/models/category.dart';
import 'package:grocery_list/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  final GroceryItem? item; // Optional item for editing

  const NewItem({super.key, this.item}); // Accept item in constructor

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  late String _enteredName;
  late int _enteredQuantity;
  late Category _selectedCategory;
  late bool _isSending = false;

  @override
  void initState() {
    super.initState();

    // Initialize fields with item's values or defaults if adding new item
    _enteredName = widget.item?.name ?? '';
    _enteredQuantity = widget.item?.quantity ?? 1;
    _selectedCategory = widget.item?.category ?? categories[Categories.other]!;
  }

  _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });

      final url = widget.item == null
          ? Uri.https('grocerylist-12706-default-rtdb.firebaseio.com',
              'shopping-list.json')
          : Uri.https('grocerylist-12706-default-rtdb.firebaseio.com',
              'shopping-list/${widget.item!.id}.json');

      // Use POST if creating a new item, otherwise PATCH for editing
      final response = widget.item == null
          ? await http.post(
              url,
              headers: {
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'name': _enteredName,
                'quantity': _enteredQuantity,
                'category': _selectedCategory.title,
              }),
            )
          : await http.patch(
              url,
              headers: {
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'name': _enteredName,
                'quantity': _enteredQuantity,
                'category': _selectedCategory.title,
              }),
            );

      if (response.statusCode == 200) {
        final Map<String, dynamic> resData =
            widget.item == null ? json.decode(response.body) : {};

        if (!context.mounted) {
          return;
        }

        Navigator.of(context).pop(GroceryItem(
          id: widget.item == null ? resData['name'] : widget.item!.id,
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.item == null ? 'Add an Item' : 'Edit Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _enteredName,
                style:
                    TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                maxLength: 50,
                decoration: const InputDecoration(label: Text('Name')),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 2 ||
                      value.trim().length > 50) {
                    return 'Wahala.....';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      initialValue: _enteredQuantity.toString(),
                      decoration: InputDecoration(
                          label: Text('Quantity',
                              style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black))),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Must be above Zero';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                      style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: categories.entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.value,
                          child: Row(
                            children: [
                              Container(
                                width: 15,
                                height: 15,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: entry.value.color,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                entry.value.title.toUpperCase(),
                                style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                          },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _isSending ? null : _saveItem,
                    child: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              color: Colors.white, // adjust color if needed
                            ),
                          )
                        : Text(
                            widget.item == null ? 'Add Item' : 'Save Changes'),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
