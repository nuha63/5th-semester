// lib/grocery_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hello/main.dart' as globals; // Import global socket

class GroceryPage extends StatefulWidget {
  const GroceryPage({super.key});

  @override
  State<GroceryPage> createState() => _GroceryPageState();
}

class _GroceryPageState extends State<GroceryPage> {
  final TextEditingController _itemCtrl = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;
  final Box _localBox = Hive.box('kitchenCraftBox'); // Hive box for offline
  List<Map<String, dynamic>> _localItems = [];

  @override
  void initState() {
    super.initState();
    _loadLocalItems();
    globals.socket.on('groceryUpdate', (data) {
      setState(() {
        _localItems = List<Map<String, dynamic>>.from(data);
        _localBox.put('groceryItems', _localItems); // Cache update
      });
    });
  }

  void _loadLocalItems() {
    final cached = _localBox.get('groceryItems', defaultValue: []);
    final List<Map<String, dynamic>> normalized = [];
    try {
      for (final item in List.from(cached)) {
        if (item is Map) {
          final Map<String, dynamic> entry = {};
          item.forEach((k, v) {
            final key = k?.toString() ?? '';
            var value = v;
            // Normalize timestamp if stored as int/string
            if (key == 'timestamp') {
              if (v is int) {
                value = v; // milliseconds since epoch
              } else if (v is String) {
                final parsed = int.tryParse(v);
                value = parsed ?? DateTime.now().millisecondsSinceEpoch;
              }
            }
            entry[key] = value;
          });
          entry.putIfAbsent('item', () => '');
          entry.putIfAbsent('isPurchased', () => false);
          entry.putIfAbsent('timestamp', () => DateTime.now().millisecondsSinceEpoch);
          normalized.add(entry);
        }
      }
    } catch (_) {
      // ignore and start with empty list
    }
    setState(() => _localItems = normalized);
  }

  Future<void> _addItem(String item) async {
    final newItem = {
      'userId': user?.uid,
      'item': item.trim(),
      'isPurchased': false,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    _localItems.insert(0, newItem); // Add to local list
    _localBox.put('groceryItems', _localItems); // Cache locally
    setState(() {});

    try {
      // Online sync
      await FirebaseFirestore.instance.collection('grocery').add(newItem);
      globals.socket.emit('groceryUpdate', _localItems); // Real-time broadcast
    } catch (e) {
      print('Offline: $e - Will sync later');
    }
  }

  @override
  void dispose() {
    _itemCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _itemCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Add Grocery Item',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => _addItem(value),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _addItem(_itemCtrl.text),
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<Box>(
              valueListenable: Hive.box('kitchenCraftBox').listenable(),
              builder: (context, box, _) {
                // Normalize on every box change to avoid dynamic map casting issues
                final cached = box.get('groceryItems', defaultValue: []);
                final List<Map<String, dynamic>> normalized = [];
                try {
                  for (final item in List.from(cached)) {
                    if (item is Map) {
                      final Map<String, dynamic> entry = {};
                      item.forEach((k, v) {
                        final key = k?.toString() ?? '';
                        entry[key] = v;
                      });
                      entry.putIfAbsent('item', () => '');
                      entry.putIfAbsent('isPurchased', () => false);
                      entry.putIfAbsent('timestamp', () => DateTime.now().millisecondsSinceEpoch);
                      normalized.add(entry);
                    }
                  }
                } catch (_) {}
                _localItems = normalized;
                return ListView.builder(
                  itemCount: _localItems.length,
                  itemBuilder: (context, index) {
                    final item = _localItems[index];
                    return ListTile(
                      title: Text(item['item']),
                      trailing: Checkbox(
                        value: item['isPurchased'],
                        onChanged: (value) {
                          setState(() => item['isPurchased'] = value);
                          _localBox.put('groceryItems', _localItems);
                          // Emit update for real-time sync
                          globals.socket.emit('groceryUpdate', _localItems);
                        },
                      ),
                      onLongPress: () {
                        setState(() => _localItems.removeAt(index));
                        _localBox.put('groceryItems', _localItems);
                        globals.socket.emit('groceryUpdate', _localItems);
                      },
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