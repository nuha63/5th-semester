// lib/recipe_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hello/main.dart' as globals;

class RecipePage extends StatefulWidget {
  const RecipePage({super.key});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _ingredientsCtrl = TextEditingController();
  final TextEditingController _categoryCtrl = TextEditingController();
  final TextEditingController _searchCtrl = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;
  // Use Hive directly; Hive is initialized in main.dart
  final Box _localBox = Hive.box('kitchenCraftBox');
  List<Map<String, dynamic>> _localRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadLocalRecipes();
    globals.socket.on('recipeUpdate', (data) {
      setState(() {
        _localRecipes = List<Map<String, dynamic>>.from(data);
        _localBox.put('recipes', _localRecipes);
      });
    });
  }

  void _loadLocalRecipes() {
    final cached = _localBox.get('recipes', defaultValue: []);
    final List<Map<String, dynamic>> normalized = [];
    try {
      for (final entry in List.from(cached)) {
        if (entry is Map) {
          final Map<String, dynamic> map = {};
          entry.forEach((k, v) => map[k?.toString() ?? ''] = v);
          map.putIfAbsent('name', () => '');
          map.putIfAbsent('ingredients', () => '');
          map.putIfAbsent('category', () => '');
          normalized.add(map);
        }
      }
    } catch (_) {}
    setState(() => _localRecipes = normalized);
  }

  Future<void> _addRecipe() async {
    if (_nameCtrl.text.isNotEmpty && _ingredientsCtrl.text.isNotEmpty) {
      final newRecipe = {
        'userId': user?.uid,
        'name': _nameCtrl.text.trim(),
        'ingredients': _ingredientsCtrl.text.trim(),
        'category': _categoryCtrl.text.trim(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      _localRecipes.insert(0, newRecipe);
      _localBox.put('recipes', _localRecipes);
      setState(() {});
      _nameCtrl.clear();
      _ingredientsCtrl.clear();
      _categoryCtrl.clear();

      try {
        await FirebaseFirestore.instance.collection('recipes').add(newRecipe);
        globals.socket.emit('recipeUpdate', _localRecipes);
      } catch (e) {
        print('Offline recipe save: $e');
      }
    }
  }

  void _addToGrocery(String ingredients) {
    // Parse ingredients and add to grocery (integrate with GroceryPage logic)
    final ingredientList = ingredients.split(',').map((i) => i.trim()).where((i) => i.isNotEmpty).toList();
    for (final ingredient in ingredientList) {
      // Emit to WebSocket for grocery sync (or call GroceryPage method)
      globals.socket.emit('addToGrocery', ingredient);
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added ingredients to grocery list!')));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ingredientsCtrl.dispose();
    _categoryCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Recipe Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _ingredientsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Ingredients (comma-separated)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _categoryCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Category (e.g., Breakfast)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _addRecipe,
                        child: const Text('Add Recipe'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _addToGrocery(_ingredientsCtrl.text),
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('Add to Grocery'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                labelText: 'Search by Name or Category',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<Box>(
              valueListenable: Hive.box('kitchenCraftBox').listenable(),
              builder: (context, box, _) {
                // Normalize cached entries to Map<String, dynamic>
                final raw = box.get('recipes', defaultValue: []);
                final List<Map<String, dynamic>> normalized = [];
                try {
                  for (final entry in List.from(raw)) {
                    if (entry is Map) {
                      final Map<String, dynamic> map = {};
                      entry.forEach((k, v) => map[k?.toString() ?? ''] = v);
                      map.putIfAbsent('name', () => '');
                      map.putIfAbsent('ingredients', () => '');
                      map.putIfAbsent('category', () => '');
                      normalized.add(map);
                    }
                  }
                } catch (_) {}
                _localRecipes = normalized;
                final filtered = _localRecipes.where((recipe) {
                  final name = recipe['name'] as String? ?? '';
                  final category = recipe['category'] as String? ?? '';
                  return name.toLowerCase().contains(_searchCtrl.text.toLowerCase()) ||
                         category.toLowerCase().contains(_searchCtrl.text.toLowerCase());
                }).toList();
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final recipe = filtered[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        title: Text(recipe['name']),
                        subtitle: Text('Category: ${recipe['category']}\nIngredients: ${recipe['ingredients']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.shopping_cart),
                              onPressed: () => _addToGrocery(recipe['ingredients']),
                              tooltip: 'Add to Grocery',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() => _localRecipes.remove(recipe));
                                _localBox.put('recipes', _localRecipes);
                                globals.socket.emit('recipeUpdate', _localRecipes);
                              },
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}