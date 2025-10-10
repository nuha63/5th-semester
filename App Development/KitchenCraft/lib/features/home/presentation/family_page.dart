// lib/family_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// using globals.socket from package import
import 'package:hello/main.dart' as globals;

class FamilyPage extends StatefulWidget {
  const FamilyPage({super.key});

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  final TextEditingController _groupCodeCtrl = TextEditingController();
  final TextEditingController _itemCtrl = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;
  // Use Hive directly; initialized in main.dart
  String? _familyId;
  List<String> _members = []; // Family members
  String _assignedMember = 'Unassigned';

  @override
  void initState() {
    super.initState();
    _getFamilyId();
    globals.socket.on('familyUpdate', (data) {
      setState(() {
        _members = List<String>.from(data['members']);
      });
    });
  }

  Future<void> _getFamilyId() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
    setState(() => _familyId = doc.data()?['familyId']);
    if (_familyId != null) {
      final familyDoc = await FirebaseFirestore.instance.collection('families').doc(_familyId).get();
      setState(() => _members = List<String>.from(familyDoc.data()?['members'] ?? []));
    }
  }

  Future<void> _createGroup() async {
    final groupDoc = await FirebaseFirestore.instance.collection('families').add({
      'members': [user?.uid],
      'createdAt': Timestamp.now(),
    });
    await FirebaseFirestore.instance.collection('users').doc(user?.uid).update({'familyId': groupDoc.id});
    setState(() => _familyId = groupDoc.id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Group created! Code: ${groupDoc.id}')));
  }

  Future<void> _joinGroup() async {
    final groupId = _groupCodeCtrl.text.trim();
    if (groupId.isNotEmpty) {
      final groupDoc = await FirebaseFirestore.instance.collection('families').doc(groupId).get();
      if (groupDoc.exists) {
        await FirebaseFirestore.instance.collection('families').doc(groupId).update({
          'members': FieldValue.arrayUnion([user?.uid]),
        });
        await FirebaseFirestore.instance.collection('users').doc(user?.uid).update({'familyId': groupId});
        setState(() => _familyId = groupId);
        _groupCodeCtrl.clear();
        final updatedDoc = await FirebaseFirestore.instance.collection('families').doc(groupId).get();
        setState(() => _members = List<String>.from(updatedDoc.data()?['members'] ?? []));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid group code')));
      }
    }
  }

  Future<void> _addSharedItem() async {
    if (_familyId != null && _itemCtrl.text.isNotEmpty) {
      final newItem = {
        'familyId': _familyId,
        'item': _itemCtrl.text.trim(),
        'assignedTo': _assignedMember,
        'isPurchased': false,
        'timestamp': Timestamp.now(),
      };
      await FirebaseFirestore.instance.collection('shared_grocery').add(newItem);
      _itemCtrl.clear();
      globals.socket.emit('familyUpdate', {'item': newItem});
    }
  }

  @override
  void dispose() {
    _groupCodeCtrl.dispose();
    _itemCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (_familyId == null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton(onPressed: _createGroup, child: const Text('Create Family Group')),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _groupCodeCtrl,
                    decoration: const InputDecoration(labelText: 'Enter Group Code to Join', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: _joinGroup, child: const Text('Join Group')),
                ],
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Family Group Code: $_familyId', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
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
                              subtitle: Text('Assigned to: ${data['assignedTo']}'),
                              trailing: Checkbox(
                                value: data['isPurchased'],
                                onChanged: (value) {
                                  FirebaseFirestore.instance.collection('shared_grocery').doc(docs[index].id).update({'isPurchased': value});
                                  globals.socket.emit('familyUpdate', {'item': data, 'isPurchased': value});
                                },
                              ),
                              onLongPress: () {
                                FirebaseFirestore.instance.collection('shared_grocery').doc(docs[index].id).delete();
                                globals.socket.emit('familyUpdate', {'delete': docs[index].id});
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}