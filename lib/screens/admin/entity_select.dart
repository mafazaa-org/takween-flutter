import 'package:flutter/material.dart';
import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import '../../services/api_client.dart';
import '../../services/storage.dart';
import '../../routes/router.gr.dart';

@RoutePage()
class EntitySelectPage extends StatefulWidget {
  const EntitySelectPage({super.key});

  @override
  State<EntitySelectPage> createState() => _EntitySelectPageState();
}

class _EntitySelectPageState extends State<EntitySelectPage> {
  final ApiClient _apiClient = ApiClient();
  List<Map<String, dynamic>> _entities = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEntities();
  }

  Future<void> _loadEntities() async {
    setState(() {
      _isLoading = true;
    });

      final response = await _apiClient.get<dynamic>(
        '/entity',
      );
    try {
      setState(() {
        _entities = response as List<Map<String, dynamic>>;
       
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ في تحميل الكيانات: ${response.toString()}'),
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

  Future<void> _showAddEditDialog([Map<String, dynamic>? entity]) async {
    final nameController = TextEditingController(
      text: entity?['name'] as String? ?? '',
    );
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entity == null ? 'إضافة كيان جديد' : 'تعديل كيان'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'اسم الكيان',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال اسم الكيان';
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
            child: Text(entity == null ? 'إضافة' : 'حفظ'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        if (entity == null) {
          await _apiClient.post<Map<String, dynamic>>(
            '/entity',
           {
            'name': nameController.text,
          },
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إضافة الكيان بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          await _apiClient.put<Map<String, dynamic>>(
            '/entity/${entity['_id']}',
            {'name': nameController.text},
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تحديث الكيان بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
        _loadEntities();
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

  Future<void> _selectEntity(Map<String, dynamic> entity) async {
    await Storage.setJson('selectedEntity', entity);
    if (mounted) {
      final selectedActivity = Storage.getJson('selectedActivity');
      if (selectedActivity != null) {
        Navigator.of(context).pop();
      } else {
        context.router.push(const ActivitySelectRoute());
      }
    }
  }

  Future<void> _deleteEntity(Map<String, dynamic> entity) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف "${entity['name']}"؟'),
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
          '/entity/${entity['_id']}',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف الكيان بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadEntities();
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
      appBar: AppBar(title: const Text('إدارة الكيانات')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entities.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.business, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'لا توجد كيانات',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة كيان جديد'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadEntities,
              child: ListView.builder(
                itemCount: _entities.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final entity = _entities[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        entity['name'] as String? ?? 'بدون اسم',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: entity['_id'] != null
                          ? Text('ID: ${entity['_id']}')
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            onPressed: () => _selectEntity(entity),
                            tooltip: 'اختيار',
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showAddEditDialog(entity),
                            tooltip: 'تعديل',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteEntity(entity),
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
        child: const Icon(Icons.add),
        tooltip: 'إضافة كيان جديد',
      ),
    );
  }
}
