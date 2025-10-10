// lib/expense_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  String _category = 'Groceries';
  final List<String> _categories = ['Groceries', 'Utensils', 'Dining', 'Other'];
  final User? user = FirebaseAuth.instance.currentUser;

  Map<String, double> _getCategoryTotals(List<QueryDocumentSnapshot> docs) {
    final now = DateTime.now();
    return docs.fold<Map<String, double>>({}, (totals, doc) {
      final data = doc.data() as Map<String, dynamic>; // Explicit cast
      final date = (data['timestamp'] as Timestamp).toDate();
      if (date.month == now.month && date.year == now.year) {
        final cat = data['category'] as String;
        totals[cat] = (totals[cat] ?? 0) + (data['amount'] as num);
      }
      return totals;
    });
  }

  double _getMonthlyTotal(List<QueryDocumentSnapshot> docs) {
    final now = DateTime.now();
    return docs.fold(0.0, (sum, doc) {
      final data = doc.data() as Map<String, dynamic>; // Explicit cast
      final date = (data['timestamp'] as Timestamp).toDate();
      if (date.month == now.month && date.year == now.year) {
        return sum + (data['amount'] as num);
      }
      return sum;
    });
  }

  Future<void> _addExpense() async {
    if (_amountCtrl.text.isNotEmpty) {
      final amount = double.parse(_amountCtrl.text);
      await FirebaseFirestore.instance.collection('expenses').add({
        'userId': user?.uid,
        'amount': amount,
        'category': _category,
        'description': _descriptionCtrl.text.trim(),
        'timestamp': Timestamp.now(),
      });
      _amountCtrl.clear();
      _descriptionCtrl.clear();
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('expenses')
            .where('userId', isEqualTo: user?.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading expenses'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          final monthlyTotal = _getMonthlyTotal(docs);
          final categoryTotals = _getCategoryTotals(docs);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Monthly Total: \$${monthlyTotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: categoryTotals.entries.map((entry) {
                        return PieChartSectionData(
                          color: _getCategoryColor(entry.key),
                          value: entry.value,
                          title: '${entry.key}\n\$${entry.value.toStringAsFixed(0)}',
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _amountCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _category,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                        onChanged: (value) => setState(() => _category = value!),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descriptionCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Description (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _addExpense,
                        child: const Text('Log Expense'),
                        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Expense History',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), // Fix layout error
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>; // Explicit cast
                    final date = (data['timestamp'] as Timestamp).toDate();
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        title: Text('\$${data['amount']} - ${data['category']}'),
                        subtitle: Text(
                          '${data['description'] ?? 'No description'}\n${DateFormat('MMM dd, yyyy').format(date)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            FirebaseFirestore.instance.collection('expenses').doc(docs[index].id).delete();
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Groceries':
        return Colors.green;
      case 'Utensils':
        return Colors.blue;
      case 'Dining':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}