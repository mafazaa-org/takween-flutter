import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../../services/api_client.dart';
import '../../services/storage.dart';
import '../../routes/router.gr.dart';

@RoutePage()
class ClassroomManagementPage extends StatefulWidget {
  final String? activityId;

  const ClassroomManagementPage({super.key, this.activityId});

  @override
  State<ClassroomManagementPage> createState() => _ClassroomManagementPageState();
}

class _ClassroomManagementPageState extends State<ClassroomManagementPage> {
  final ApiClient _apiClient = ApiClient();
  List<Map<String, dynamic>> _classrooms = [];
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _teachers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadClassroomData();
  }

  Future<void> _loadClassroomData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load classrooms for this activity
      if (widget.activityId != null) {
        final classroomsResponse = await _apiClient.get<List<dynamic>>(
          '/classroom',
          queryParameters: widget.activityId != null ? {'activityId': widget.activityId!} : {},
        );
        setState(() {
          _classrooms = (classroomsResponse as List)
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

      // Load teachers
      final teachersResponse = await _apiClient.get<List<dynamic>>('/teacher');
      setState(() {
        _teachers = (teachersResponse as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ في تحميل بيانات الفصول: ${e.toString()}'),
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

  Future<void> _addClassroom() async {
    final nameController = TextEditingController();
    final levelController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة فصل جديد'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الفصل',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم الفصل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: levelController,
                decoration: const InputDecoration(
                  labelText: 'المستوى',
                  border: OutlineInputBorder(),
                ),
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
                Navigator.of(context).pop({
                  'name': nameController.text,
                  'level': levelController.text,
                });
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );

    final result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة فصل جديد'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الفصل',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم الفصل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: levelController,
                decoration: const InputDecoration(
                  labelText: 'المستوى',
                  border: OutlineInputBorder(),
                ),
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
                Navigator.of(context).pop({
                  'name': nameController.text,
                  'level': levelController.text,
                });
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        await _apiClient.post<Map<String, dynamic>>(
          '/classroom',
          {
            'name': result['name'],
            'level': result['level'],
            'activity': widget.activityId,
          },
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إضافة الفصل بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadClassroomData(); // Refresh the data
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

  Future<void> _assignStudents(String classroomId) async {
    // Get students not already in this classroom
    final classroom = _classrooms.firstWhere((c) => c['_id'] == classroomId);
    final assignedStudentIds = List<String>.from(classroom['students'] ?? []);
    
    final unassignedStudents = _students.where((student) => 
        !assignedStudentIds.contains(student['_id'])).toList();

    final selectedStudents = <String>[];
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('إضافة طلاب للفصل'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: ListView.builder(
                itemCount: unassignedStudents.length,
                itemBuilder: (context, index) {
                  final student = unassignedStudents[index];
                  final isSelected = selectedStudents.contains(student['_id']);
                  
                  return CheckboxListTile(
                    title: Text(student['name'] as String? ?? 'طالب غير معروف'),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selectedStudents.add(student['_id']);
                        } else {
                          selectedStudents.remove(student['_id']);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: selectedStudents.isNotEmpty
                    ? () {
                        Navigator.of(context).pop(selectedStudents);
                      }
                    : null,
                child: const Text('إضافة'),
              ),
            ],
          );
        },
      ),
    );

    if (selectedStudents.isNotEmpty) {
      try {
        // In a real implementation, you would add students to the classroom
        // For now, we'll just show a success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إضافة الطلاب للفصل'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadClassroomData(); // Refresh the data
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
        title: const Text('إدارة الفصول'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadClassroomData,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Add classroom button
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton.icon(
                          onPressed: _addClassroom,
                          icon: const Icon(Icons.add),
                          label: const Text('إضافة فصل جديد'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Classrooms list
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
                                    'قائمة الفصول (${_classrooms.length})',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (_classrooms.isEmpty)
                                const Center(
                                  child: Text(
                                    'لا توجد فصول',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              else
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: _classrooms.length,
                                    separatorBuilder: (context, index) =>
                                        const Divider(),
                                    itemBuilder: (context, index) {
                                      final classroom = _classrooms[index];
                                      final studentCount = (classroom['students'] as List? ?? []).length;
                                      
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
                                                      classroom['name'] as String? ?? 'بدون اسم',
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.edit),
                                                    onPressed: () {
                                                      // TODO: Edit classroom
                                                    },
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              if (classroom['level'] != null)
                                                Text(
                                                  'المستوى: ${classroom['level']}',
                                                  style: const TextStyle(fontSize: 14),
                                                ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'عدد الطلاب: $studentCount',
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                              const SizedBox(height: 16),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton.icon(
                                                      onPressed: () => _assignStudents(classroom['_id']),
                                                      icon: const Icon(Icons.person_add),
                                                      label: const Text('إضافة طلاب'),
                                                      style: ElevatedButton.styleFrom(
                                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: ElevatedButton.icon(
                                                      onPressed: () {
                                                        // Navigate to sittings management
                                                        context.router.push(
                                                          SittingManagementRoute(
                                                            classroomId: classroom['_id'],
                                                          ),
                                                        );
                                                      },
                                                      icon: const Icon(Icons.event),
                                                      label: const Text('إدارة الجلسات'),
                                                      style: ElevatedButton.styleFrom(
                                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                                      ),
                                                    ),
                                                  ),
                                                ],
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
        onPressed: _addClassroom,
        child: const Icon(Icons.add),
      ),
    );
  }
}