// lib/shared_list_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hello/main.dart' as globals;

class SharedListPage extends StatefulWidget {
  const SharedListPage({super.key});

  @override
  State<SharedListPage> createState() => _SharedListPageState();
}

class _SharedListPageState extends State<SharedListPage> {
  final TextEditingController _itemCtrl = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;
  String? _familyId;
  List<String> _members = [];
  String _assignedMember = 'Unassigned';

  @override
  void initState() {
    super.initState();
    _getFamilyId();
  }

  Future<void> _getFamilyId() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
    setState(() => _familyId = doc.data()?['familyId']);
    if (_familyId != null) {
      final familyDoc = await FirebaseFirestore.instance.collection('families').doc(_familyId).get();
      setState(() => _members = List<String>.from(familyDoc.data()?['members'] ?? []));
    }
  }

  Future<void> _addSharedItem() async {
    if (_familyId != null && _itemCtrl.text.isNotEmpty) {
      final newItem = {
        'familyId': _familyId,
        'item': _itemCtrl.text.trim(),
        'assignedTo': _assignedMember,
        'isPurchased': false,
        'assignedBy': user?.uid,
        'timestamp': Timestamp.now(),
      };
      await FirebaseFirestore.instance.collection('shared_grocery').add(newItem);
      _itemCtrl.clear();
      globals.socket.emit('familyUpdate', newItem);
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
                    decoration: const InputDecoration(labelText: 'Add Shared Item', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _assignedMember,
                  items: ['Unassigned', ..._members].map((member) => DropdownMenuItem(value: member, child: Text(member))).toList(),
                  onChanged: (value) => setState(() => _assignedMember = value!),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addSharedItem, child: const Text('Add')),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('shared_grocery')
                  .where('familyId', isEqualTo: _familyId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Text('Error loading shared list');
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['item']),
                      subtitle: Text('Assigned to: ${data['assignedTo']} by ${data['assignedBy']}'),
                      trailing: Checkbox(
                        value: data['isPurchased'],
                        onChanged: (value) {
                          FirebaseFirestore.instance.collection('shared_grocery').doc(docs[index].id).update({'isPurchased': value});
                        },
                      ),
                      onLongPress: () {
                        FirebaseFirestore.instance.collection('shared_grocery').doc(docs[index].id).delete();
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