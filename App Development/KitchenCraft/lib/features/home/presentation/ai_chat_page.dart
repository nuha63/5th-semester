// lib/ai_chat_page.dart (or features/presentation/ai_chat_page.dart)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
// removed unused import

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _queryCtrl = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _loading = false;
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  late final GenerativeModel _model;
  // Don't access Hive.box synchronously at field init time; open the box when needed
  Box? _chatBox;
  String _streamedResponse = ''; // For streaming partial text

  // Simulated grocery list (replace with real data from GroceryPage, e.g., via Provider)
  final List<String> _groceryList = ['chicken', 'rice', 'tomatoes'];

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
    _loadHistory(); // Load cached history
  }

  Future<Box> _ensureBox() async {
    if (!Hive.isBoxOpen('chatHistoryBox')) {
      _chatBox = await Hive.openBox('chatHistoryBox');
    } else {
      _chatBox = Hive.box('chatHistoryBox');
    }
    return _chatBox!;
  }

  Future<void> _loadHistory() async {
    final box = await _ensureBox();
    final cachedHistory = box.get('chatHistory', defaultValue: []);
    final List<Map<String, dynamic>> normalized = [];
    try {
      for (final entry in List.from(cachedHistory)) {
        if (entry is Map) {
          final Map<String, dynamic> map = {};
          entry.forEach((k, v) => map[k?.toString() ?? ''] = v);
          // Ensure timestamp is DateTime when loaded
          final ts = map['timestamp'];
          if (ts is int) {
            map['timestamp'] = DateTime.fromMillisecondsSinceEpoch(ts);
          } else if (ts is String) {
            final parsed = int.tryParse(ts);
            map['timestamp'] = parsed != null ? DateTime.fromMillisecondsSinceEpoch(parsed) : DateTime.now();
          } else if (ts is DateTime) {
            // ok
          } else {
            map['timestamp'] = DateTime.now();
          }
          normalized.add(map);
        }
      }
    } catch (_) {}
    setState(() => _messages.addAll(normalized));
  }

  Future<void> _saveHistory() async {
    final box = await _ensureBox();
    await box.put('chatHistory', _messages);
  }

  Future<void> _sendQuery() async {
    final query = _queryCtrl.text.trim();
    if (query.isEmpty) return;

    final timestamp = DateTime.now();
    final userMsg = {'role': 'user', 'content': query, 'timestamp': timestamp};
    setState(() {
      _messages.add(userMsg);
      _loading = true;
      _streamedResponse = '';
    });
    _queryCtrl.clear();
    _saveHistory(); // Save immediately

  Map<String, dynamic>? aiMsg;
  try {
      // Append context for recipe-based suggestions
      final context = 'User has these ingredients: ${_groceryList.join(', ')}. Suggest based on this. Query: $query';
      final content = [Content.text(context)];

      // Use streaming for real-time responses
      final stream = _model.generateContentStream(content);
      // Pre-create the assistant message so catch/finally can update it
      aiMsg = {'role': 'assistant', 'content': '', 'timestamp': timestamp};
      setState(() => _messages.add(aiMsg!));

      await for (final chunk in stream) {
          final partial = chunk.text ?? '';
          setState(() {
            _streamedResponse += partial;
            aiMsg!['content'] = _streamedResponse;
          });
          await _saveHistory(); // Save partial updates
          await Future.delayed(const Duration(milliseconds: 50)); // Simulate typing delay
        }
    } catch (e) {
      String errorMessage = 'Error: An unexpected issue occurred';
      if (e.toString().contains('quota')) {
        errorMessage = 'Quota exceeded. Try again tomorrow.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Offline mode. Using mock response.';
      }

      // Ensure we have an assistant message to update; if not, create and add it.
      if (aiMsg == null) {
        aiMsg = {'role': 'assistant', 'content': errorMessage, 'timestamp': timestamp};
        setState(() => _messages.add(aiMsg!));
      } else {
        setState(() => aiMsg!['content'] = errorMessage);
      }
      await _saveHistory();
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Cooking Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () async {
              setState(() {
                _messages.clear();
              });
              final box = await _ensureBox();
              await box.put('chatHistory', []); // Clear history
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Chat-like bottom-up scroll
              itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[_messages.length - 1 - index];
                final isUser = msg['role'] == 'user';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Row(
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isUser) const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.smart_toy, color: Colors.white),
                      ),
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.green[100] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(msg['content']),
                              const SizedBox(height: 4),
                              Text(
                                TimeOfDay.fromDateTime(msg['timestamp']).format(context),
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isUser) const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_loading) const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.smart_toy, color: Colors.white),
                ),
                SizedBox(width: 8),
                Text('AI is typing...'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Ask for recipe ideas, tips, or substitutes',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.send),
                    ),
                    onSubmitted: (_) => _sendQuery(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _sendQuery, child: const Text('Send')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}