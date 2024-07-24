import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping/data/categories.dart';
import 'package:shopping/models/category.dart';
import 'package:http/http.dart' as http;
import 'package:shopping/models/grocery_item.dart';

// ignore: must_be_immutable
class GroceryItemDetails extends StatefulWidget {
  GroceryItemDetails({
    super.key,
    required this.id,
    required this.name,
    required this.categoryColor,
    required this.quantity,
    required this.categoryName,
  });

  final String id;
  String name;
  Color categoryColor;
  int quantity;
  Category categoryName;

  @override
  State<GroceryItemDetails> createState() => _GroceryItemDetailsState();
}

class _GroceryItemDetailsState extends State<GroceryItemDetails> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = "";
  var _enteredQuantity = 1;
  late Category _selectedCategory;
  String? _error;

  @override
  void initState() {
    super.initState();
    _enteredName = widget.name;
    _enteredQuantity = widget.quantity;
    _selectedCategory = widget.categoryName;
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final url = Uri.https(
        "shoppinglist-89cbb-default-rtdb.firebaseio.com",
        "shopping-list/${widget.id}.json",
      );
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(
          {
            "name": _enteredName,
            "quantity": _enteredQuantity,
            "category": _selectedCategory.title,
          },
        ),
      );

      if (response.statusCode >= 400) {
        setState(() {
          _error = "Failed to fetch data, please try again later.";
        });
      }

      Navigator.of(context).pop(
        GroceryItem(
          id: widget.id,
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _enteredName,
                        onSaved: (newValue) {
                          _enteredName = newValue!;
                        },
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _enteredQuantity.toString(),
                        keyboardType: TextInputType.number,
                        onSaved: (newValue) {
                          _enteredQuantity = int.tryParse(newValue!) ?? 1;
                        },
                        decoration:
                            const InputDecoration(labelText: 'Quantity'),
                      ),
                    ),
                  ],
                ),
              ),
              DropdownButtonFormField<Category>(
                value: _selectedCategory,
                items: [
                  for (final category in categories.entries)
                    DropdownMenuItem(
                      value: category.value,
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            color: category.value.color,
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Text(category.value.title),
                        ],
                      ),
                    )
                ],
                onChanged: (Category? value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              Padding(
                padding: const EdgeInsets.all(28.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: _saveItem,
                        child: const Text('Confirm'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
