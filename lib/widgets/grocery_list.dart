import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping/data/categories.dart';
import 'package:shopping/models/grocery_item.dart';
import 'package:shopping/widgets/grocery_item_details.dart';
import 'package:shopping/widgets/new_item.dart';
import "package:http/http.dart" as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
      "shoppinglist-89cbb-default-rtdb.firebaseio.com",
      "shopping-list.json",
    );

    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = "Failed to fetch data, please try again later.";
        });
        return;
      }

      if (response.body == "null") {
        setState(() {
          _groceryItems = [];
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];

      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == item.value["category"])
            .value;

        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value["name"],
            quantity: item.value["quantity"],
            category: category,
          ),
        );
      }
      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = "An error occurred, please try again later.";
      });
    }
  }

  void _updateItem(GroceryItem item) async {
    final updatedItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => GroceryItemDetails(
          id: item.id,
          name: item.name,
          categoryColor: item.category.color,
          quantity: item.quantity,
          categoryName: item.category,
        ),
      ),
    );

    if (updatedItem == null) {
      return;
    }

    final url = Uri.https(
      "shoppinglist-89cbb-default-rtdb.firebaseio.com",
      "shopping-list/${updatedItem.id}.json",
    );
    
    await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode(
        {
          "name": updatedItem.name,
          "quantity": updatedItem.quantity,
          "category": updatedItem.category.title,
        },
      ),
    );
    _loadItems();
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    if (newItem == null) {
      return;
    }

    final url = Uri.https(
      "shoppinglist-89cbb-default-rtdb.firebaseio.com",
      "shopping-list/${newItem.id}.json",
    );

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode(
        {
          "name": newItem.name,
          "quantity": newItem.quantity,
          "category": newItem.category.title,
        },
      ),
    );

    if (response.statusCode >= 400) {
      // Optionally handle error
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https(
      "shoppinglist-89cbb-default-rtdb.firebaseio.com",
      "shopping-list/${item.id}.json",
    );

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      content = Center(child: Text(_error!));
    } else if (_groceryItems.isEmpty) {
      content = const Center(child: Text('No items added yet...'));
    } else {
      content = Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ListView.builder(
          itemCount: _groceryItems.length,
          itemBuilder: (ctx, index) => Dismissible(
            onDismissed: (direction) {
              _removeItem(_groceryItems[index]);
            },
            key: ValueKey(_groceryItems[index].id),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
              child: ListTile(
                title: Text(
                  _groceryItems[index].name,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
                leading: Container(
                  width: 24,
                  height: 24,
                  color: _groceryItems[index].category.color,
                ),
                trailing: Text(
                  _groceryItems[index].quantity.toString(),
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
                onTap: () => _updateItem(_groceryItems[index]),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Groceries"),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
      backgroundColor: const Color.fromARGB(255, 71, 65, 65),
    );
  }
}
