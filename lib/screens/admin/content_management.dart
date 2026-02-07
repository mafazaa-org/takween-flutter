import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/api_client.dart';
import '../../services/storage.dart';
import '../../routes/router.gr.dart';

@RoutePage()
class ContentManagementPage extends StatefulWidget {
  final String? activityId;

  const ContentManagementPage({super.key, this.activityId});

  @override
  State<ContentManagementPage> createState() => _ContentManagementPageState();
}

class _ContentManagementPageState extends State<ContentManagementPage> {
  final ApiClient _apiClient = ApiClient();
  List<Map<String, dynamic>> _contents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadContentData();
  }

  Future<void> _loadContentData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load content for this activity
      if (widget.activityId != null) {
        final contentResponse = await _apiClient.get<List<dynamic>>(
          '/content',
          queryParameters: widget.activityId != null ? {'activityId': widget.activityId!} : {},
        );
        setState(() {
          _contents = (contentResponse as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ في تحميل محتوى الدراسة: ${e.toString()}'),
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

  Future<void> _addContent() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    // For now, we'll skip the file picker and just collect content info
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة محتوى تعليمي'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان المحتوى',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال عنوان المحتوى';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'وصف المحتوى',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('سيتم إضافة محتوى تعليمي بدون ملف فعلي في هذا الإصدار'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );

    // Simulate adding content without actual file upload
    try {
      await _apiClient.post<Map<String, dynamic>>(
        '/content',
        {
          'title': titleController.text,
          'description': descriptionController.text,
          'contentType': 'document', // Default content type
          'activityId': widget.activityId,
          'fileName': titleController.text, // Using title as filename
          'fileSize': 0, // No actual file
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إضافة المحتوى التعليمي بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _loadContentData(); // Refresh the data
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
        title: const Text('نظام المحتوى التعليمي'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadContentData,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Add content button
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton.icon(
                          onPressed: _addContent,
                          icon: const Icon(Icons.add),
                          label: const Text('إضافة محتوى جديد'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Content list
                    Expanded(
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'قائمة المحتوى التعليمي',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (_contents.isEmpty)
                                const Center(
                                  child: Text(
                                    'لا يوجد محتوى تعليمي',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              else
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: _contents.length,
                                    separatorBuilder: (context, index) =>
                                        const Divider(),
                                    itemBuilder: (context, index) {
                                      final content = _contents[index];
                                      IconData icon;
                                      Color iconColor;
                                      
                                      switch (content['contentType']) {
                                        case 'pdf':
                                          icon = Icons.picture_as_pdf;
                                          iconColor = Colors.red;
                                          break;
                                        case 'video':
                                          icon = Icons.video_file;
                                          iconColor = Colors.blue;
                                          break;
                                        case 'audio':
                                          icon = Icons.audiotrack;
                                          iconColor = Colors.green;
                                          break;
                                        default:
                                          icon = Icons.insert_drive_file;
                                          iconColor = Colors.grey;
                                      }
                                      
                                      return Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: iconColor.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Icon(icon, color: iconColor),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      content['title'] as String? ?? 'عنوان غير معروف',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    if (content['description'] != null)
                                                      Text(
                                                        content['description'] as String,
                                                        style: const TextStyle(fontSize: 14),
                                                      ),
                                                    Text(
                                                      'النوع: ${content['contentType'] ?? 'غير محدد'}',
                                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.download),
                                                onPressed: () {
                                                  // Download content
                                                  _downloadContent(content['_id'] as String);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addContent,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _downloadContent(String contentId) async {
    // In a real implementation, this would download the actual file
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تنزيل المحتوى قيد التنفيذ'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }
}