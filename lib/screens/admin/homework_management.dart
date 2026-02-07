import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../../services/api_client.dart';
import '../../services/storage.dart';
import '../../routes/router.gr.dart';

@RoutePage()
class HomeworkManagementPage extends StatefulWidget {
  final String? activityId;

  const HomeworkManagementPage({super.key, this.activityId});

  @override
  State<HomeworkManagementPage> createState() => _HomeworkManagementPageState();
}

class _HomeworkManagementPageState extends State<HomeworkManagementPage> {
  final ApiClient _apiClient = ApiClient();
  List<Map<String, dynamic>> _homeworks = [];
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHomeworkData();
  }

  Future<void> _loadHomeworkData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load homeworks for this activity
      if (widget.activityId != null) {
        final homeworkResponse = await _apiClient.get<List<dynamic>>(
          '/homework',
          queryParameters: widget.activityId != null ? {'activityId': widget.activityId!} : {},
        );
        setState(() {
          _homeworks = (homeworkResponse as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        });
      }

      // Load students
      final studentsResponse = await _apiClient.get<List<dynamic>>('/student');
      setState(() {
        _students = (studentsResponse as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ في تحميل بيانات الواجبات: ${e.toString()}'),
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

  Future<void> _addHomework() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('إضافة واجب جديد'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'عنوان الواجب',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال عنوان الواجب';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'وصف الواجب',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('تاريخ الاستحقاق'),
                    subtitle: Text(
                      '${dueDate.day}/${dueDate.month}/${dueDate.year}',
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: dueDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() {
                          dueDate = date;
                        });
                      }
                    },
                  ),
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
                    Navigator.of(context).pop(dueDate);
                  }
                },
                child: const Text('إضافة'),
              ),
            ],
          );
        },
      ),
    );

    if (dueDate != DateTime.now().add(const Duration(days: 7))) {
      try {
        await _apiClient.post<Map<String, dynamic>>(
          '/homework',
          {
            'title': titleController.text,
            'description': descriptionController.text,
            'dueDate': dueDate.toIso8601String(),
            'activityId': widget.activityId,
          },
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إضافة الواجب بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadHomeworkData(); // Refresh the data
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام الواجبات'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadHomeworkData,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Add homework button
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton.icon(
                          onPressed: _addHomework,
                          icon: const Icon(Icons.add),
                          label: const Text('إضافة واجب جديد'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Homework list
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
                                    'قائمة الواجبات',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (_homeworks.isEmpty)
                                const Center(
                                  child: Text(
                                    'لا توجد واجبات',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              else
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: _homeworks.length,
                                    separatorBuilder: (context, index) =>
                                        const Divider(),
                                    itemBuilder: (context, index) {
                                      final homework = _homeworks[index];
                                      final dueDate = DateTime.parse(homework['dueDate'] as String);
                                      final isOverdue = DateTime.now().isAfter(dueDate);
                                      
                                      return Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      homework['title'] as String? ?? 'عنوان غير معروف',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  if (isOverdue)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.red,
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: const Text(
                                                        'متأخر',
                                                        style: TextStyle(color: Colors.white, fontSize: 12),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              if (homework['description'] != null)
                                                Text(
                                                  homework['description'] as String,
                                                  style: const TextStyle(fontSize: 14),
                                                ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Icon(Icons.calendar_today, size: 16),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'تاريخ الاستحقاق: ${dueDate.day}/${dueDate.month}/${dueDate.year}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: isOverdue ? Colors.red : Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              ElevatedButton.icon(
                                                onPressed: () {
                                                  // Navigate to homework details
                                                  // Navigate to homework details - placeholder for now
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('تفاصيل الواجب قيد التطوير'),
                                                    ),
                                                  );
                                                },
                                                icon: const Icon(Icons.visibility),
                                                label: const Text('تفاصيل'),
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                ),
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
        onPressed: _addHomework,
        child: const Icon(Icons.add),
      ),
    );
  }
}