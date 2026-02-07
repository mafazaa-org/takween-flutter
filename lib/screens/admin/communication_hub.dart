import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../../services/api_client.dart';
import '../../services/storage.dart';
import '../../routes/router.gr.dart';

@RoutePage()
class CommunicationHubPage extends StatefulWidget {
  final String? activityId;

  const CommunicationHubPage({super.key, this.activityId});

  @override
  State<CommunicationHubPage> createState() => _CommunicationHubPageState();
}

class _CommunicationHubPageState extends State<CommunicationHubPage> {
  final ApiClient _apiClient = ApiClient();
  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCommunicationData();
  }

  Future<void> _loadCommunicationData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load messages for this activity
      if (widget.activityId != null) {
        final messagesResponse = await _apiClient.get<List<dynamic>>(
          '/message',
          queryParameters: widget.activityId != null ? {'activityId': widget.activityId!} : {},
        );
        setState(() {
          _messages = (messagesResponse as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        });
      }

      // Load users in this activity
      final usersResponse = await _apiClient.get<List<dynamic>>('/user');
      setState(() {
        _users = (usersResponse as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ في تحميل بيانات التواصل: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      await _apiClient.post<Map<String, dynamic>>(
        '/message',
        {
          'content': _messageController.text,
          'activityId': widget.activityId,
          'senderId': Storage.getJson('currentUser')?['_id'],
        },
      );
      
      _messageController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال الرسالة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _loadCommunicationData(); // Refresh the data
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام التواصل'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Messages list
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'المحادثات',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            if (_messages.isEmpty)
                              const Center(
                                child: Text(
                                  'لا توجد رسائل',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            else
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _messages.length,
                                  itemBuilder: (context, index) {
                                    final message = _messages[_messages.length - 1 - index]; // Reverse order
                                    final sender = _users.firstWhere(
                                      (u) => u['_id'] == message['sender'],
                                      orElse: () => <String, dynamic>{},
                                    );
                                    
                                    return ListTile(
                                      leading: CircleAvatar(
                                        child: Text(
                                          (sender['name'] as String)
                                                  .substring(0, 1)
                                                  .toUpperCase(),
                                        ),
                                      ),
                                      title: Text(sender['name'] as String? ?? 'مرسل غير معروف'),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(message['content'] as String? ?? ''),
                                          Text(
                                            DateTime.parse(message['createdAt'] as String)
                                                .toString()
                                                .split('.')[0],
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      isThreeLine: true,
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Message input
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'اكتب رسالتك...',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FloatingActionButton(
                          onPressed: _sendMessage,
                          child: const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}