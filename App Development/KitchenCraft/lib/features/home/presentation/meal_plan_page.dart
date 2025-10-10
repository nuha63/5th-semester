// lib/meal_plan_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
// socket import not required here; using globals.socket from main.dart
import 'package:table_calendar/table_calendar.dart';
import 'package:hello/main.dart' as globals; // Keep this import for socket usage

class MealPlanPage extends StatefulWidget {
  const MealPlanPage({super.key});

  @override
  State<MealPlanPage> createState() => _MealPlanPageState();
}

class _MealPlanPageState extends State<MealPlanPage> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  final User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController _recipeCtrl = TextEditingController();
  // Use Hive directly; initialized in main.dart
  final Box _localBox = Hive.box('kitchenCraftBox');
  List<Map<String, dynamic>> _localPlans = [];

  @override
  void initState() {
    super.initState();
    _loadLocalPlans();
    globals.socket.on('mealPlanUpdate', (data) { // Keep this line as is
      setState(() {
        _localPlans = List<Map<String, dynamic>>.from(data);
        _localBox.put('mealPlans', _localPlans);
      });
    });
  }

  void _loadLocalPlans() {
    final cached = _localBox.get('mealPlans', defaultValue: []);
    final List<Map<String, dynamic>> normalized = [];
    try {
      for (final entry in List.from(cached)) {
        if (entry is Map) {
          final Map<String, dynamic> map = {};
          entry.forEach((k, v) => map[k?.toString() ?? ''] = v);
          map.putIfAbsent('date', () => DateTime.now().millisecondsSinceEpoch);
          map.putIfAbsent('recipe', () => '');
          normalized.add(map);
        }
      }
    } catch (_) {}
    setState(() => _localPlans = normalized);
  }

  Future<void> _addMealPlan() async {
    if (_selectedDay != null && _recipeCtrl.text.isNotEmpty) {
      final newPlan = {
        'userId': user?.uid,
        'date': _selectedDay!.millisecondsSinceEpoch,
        'recipe': _recipeCtrl.text.trim(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      _localPlans.insert(0, newPlan);
      _localBox.put('mealPlans', _localPlans);
      setState(() {});
      _recipeCtrl.clear();

      try {
        await FirebaseFirestore.instance.collection('meal_plans').add(newPlan);
        globals.socket.emit('mealPlanUpdate', _localPlans);
      } catch (e) {
        print('Offline plan save: $e');
      }
    }
  }

  @override
  void dispose() {
    _recipeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() => _calendarFormat = format);
              }
            },
            onPageChanged: (focusedDay) => _focusedDay = focusedDay,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _recipeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Add Recipe to Selected Day',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addMealPlan, child: const Text('Add')),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<Box>(
              valueListenable: Hive.box('kitchenCraftBox').listenable(),
              builder: (context, box, _) {
                // Normalize cached plans to Map<String, dynamic>
                final raw = box.get('mealPlans', defaultValue: []);
                final List<Map<String, dynamic>> normalized = [];
                try {
                  for (final entry in List.from(raw)) {
                    if (entry is Map) {
                      final Map<String, dynamic> map = {};
                      entry.forEach((k, v) => map[k?.toString() ?? ''] = v);
                      map.putIfAbsent('date', () => DateTime.now().millisecondsSinceEpoch);
                      map.putIfAbsent('recipe', () => '');
                      normalized.add(map);
                    }
                  }
                } catch (_) {}
                _localPlans = normalized;
                final filtered = _localPlans.where((plan) {
                  final date = DateTime.fromMillisecondsSinceEpoch(plan['date']);
                  return isSameDay(_selectedDay, date);
                }).toList();
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final plan = filtered[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        title: Text(plan['recipe']),
                        subtitle: Text(DateTime.fromMillisecondsSinceEpoch(plan['date']).toString()),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() => _localPlans.remove(plan));
                            _localBox.put('mealPlans', _localPlans);
                            globals.socket.emit('mealPlanUpdate', _localPlans);
                          },
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