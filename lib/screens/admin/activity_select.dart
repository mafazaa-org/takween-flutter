import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../../services/api_client.dart';
import '../../services/storage.dart';
import '../../routes/router.gr.dart';

@RoutePage()
class ActivitySelectPage extends StatefulWidget {
  const ActivitySelectPage({super.key});

  @override
  State<ActivitySelectPage> createState() => _ActivitySelectPageState();
}

class _ActivitySelectPageState extends State<ActivitySelectPage> {
  final ApiClient _apiClient = ApiClient();
  List<Map<String, dynamic>> _activities = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the selected entity from storage
      final selectedEntity = Storage.getJson('selectedEntity');
      if (selectedEntity == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('الرجاء اختيار كيان أولاً'),
              backgroundColor: Colors.orange,
            ),
          );
          // Navigate back to entity selection
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        }
        return;
      }

      final entityId = selectedEntity['_id'] as String?;
      if (entityId == null) {
        throw Exception('Selected entity has no ID');
      }

      final response = await _apiClient.get<dynamic>(
        '/activity',
        queryParameters: {'entity': entityId},
      );

      setState(() {
        if (response is List) {
          _activities = response.map((e) => e as Map<String, dynamic>).toList();
        } else if (response is Map<String, dynamic>) {
          _activities = [response];
        } else {
          _activities = [];
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ في تحميل الأنشطة: ${e.toString()}'),
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

  Future<void> _showAddEditDialog([Map<String, dynamic>? activity]) async {
    final nameController = TextEditingController(
      text: activity?['name'] as String? ?? '',
    );
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(activity == null ? 'إضافة نشاط جديد' : 'تعديل نشاط'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'اسم النشاط',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال اسم النشاط';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
            child: Text(activity == null ? 'إضافة' : 'حفظ'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final selectedEntity = Storage.getJson('selectedEntity');
        if (selectedEntity == null) {
          throw Exception('No entity selected');
        }
        
        final entityId = selectedEntity['_id'] as String?;
        if (entityId == null) {
          throw Exception('Selected entity has no ID');
        }

        if (activity == null) {
          await _apiClient.post<Map<String, dynamic>>(
            '/activity',
            {
              'name': nameController.text,
              'entity': entityId,
            },
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إضافة النشاط بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          await _apiClient.put<Map<String, dynamic>>(
            '/activity/${activity['_id']}',
            {'name': nameController.text},
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تحديث النشاط بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
        _loadActivities();
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

  Future<void> _selectActivity(Map<String, dynamic> activity) async {
    await Storage.setJson('selectedActivity', activity);
    if (mounted) {
      // Navigate to ActivityManagement to manage the selected activity
      context.router.replace(const ActivityManagementRoute());
    }
  }

  Future<void> _deleteActivity(Map<String, dynamic> activity) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف "${activity['name']}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiClient.delete<Map<String, dynamic>>(
          '/activity/${activity['_id']}',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف النشاط بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadActivities();
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
      appBar: AppBar(title: const Text('إدارة الأنشطة')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activities.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sports_soccer, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'لا توجد أنشطة',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة نشاط جديد'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadActivities,
              child: ListView.builder(
                itemCount: _activities.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final activity = _activities[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        activity['name'] as String? ?? 'بدون اسم',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: activity['_id'] != null
                          ? Text('ID: ${activity['_id']}')
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () => _selectActivity(activity),
                            tooltip: 'اختيار',
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showAddEditDialog(activity),
                            tooltip: 'تعديل',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteActivity(activity),
                            tooltip: 'حذف',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        tooltip: 'إضافة نشاط جديد',
        child: const Icon(Icons.add),
      ),
    );
  }
}
