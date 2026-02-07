import 'package:flutter/material.dart';
import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import '../../services/api_client.dart';
import '../../services/storage.dart';
import '../../routes/router.gr.dart';

@RoutePage()
class ActivityManagementPage extends StatefulWidget {
  const ActivityManagementPage({super.key});

  @override
  State<ActivityManagementPage> createState() => _ActivityManagementPageState();
}

class _ActivityManagementPageState extends State<ActivityManagementPage> {
  final ApiClient _apiClient = ApiClient();
  List<Map<String, dynamic>> _classrooms = [];
  List<Map<String, dynamic>> _sittings = [];
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadActivityData();
  }

  Future<void> _loadActivityData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final selectedActivity = Storage.getJson('selectedActivity');
      if (selectedActivity == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لم يتم تحديد نشاط'),
              backgroundColor: Colors.red,
            ),
          );
          context.router.replace(const EntitySelectRoute());
        }
        return;
      }

      final activityId = selectedActivity['_id'] as String?;
      if (activityId == null) {
        throw Exception('Invalid activity ID');
      }

      // Load classrooms for this activity
      final classroomsResponse = await _apiClient.get<List<dynamic>>(
        '/classroom',
        queryParameters: {'activityId': activityId},
      );
      
      setState(() {
        _classrooms = (classroomsResponse as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      });

      // Load students for this activity (through classrooms)
      final studentsResponse = await _apiClient.get<List<dynamic>>('/student');
      setState(() {
        _students = (studentsResponse as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      });

      // Load sittings for this activity (through classrooms)
      // This would require a more complex query in the backend
      // For now, we'll load all sittings and filter on the UI side
      final sittingsResponse = await _apiClient.get<List<dynamic>>('/sitting');
      setState(() {
        _sittings = (sittingsResponse as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ في تحميل بيانات النشاط: ${e.toString()}'),
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

  Future<void> _createClassroom() async {
    final selectedActivity = Storage.getJson('selectedActivity');
    if (selectedActivity == null) return;

    final nameController = TextEditingController();
    final levelController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
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
            onPressed: () => Navigator.of(context).pop(false),
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

    if (result == true) {
      try {
        await _apiClient.post<Map<String, dynamic>>(
          '/classroom',
          {
            'name': nameController.text,
            'activity': selectedActivity['_id'],
            'level': levelController.text.isNotEmpty ? levelController.text : null,
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
        _loadActivityData(); // Refresh the data
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

  Future<void> _createSitting() async {
    final classroomIdController = TextEditingController();
    final dateController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Get available classrooms for this activity
    final availableClassrooms = _classrooms;

    if (availableClassrooms.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('الرجاء إضافة فصل أولاً'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    String? selectedClassroomId;
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('إضافة جلسة جديدة'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedClassroomId,
                    decoration: const InputDecoration(
                      labelText: 'اختر الفصل',
                      border: OutlineInputBorder(),
                    ),
                    items: availableClassrooms.map((classroom) {
                      return DropdownMenuItem(
                        value: classroom['_id'] as String?,
                        child: Text(classroom['name'] as String? ?? 'بدون اسم'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedClassroomId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: 'تاريخ الجلسة',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() {
                          selectedDate = date;
                          dateController.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
                onPressed: selectedClassroomId != null
                    ? () {
                        Navigator.of(context).pop(selectedDate);
                      }
                    : null,
                child: const Text('إضافة'),
              ),
            ],
          );
        },
      ),
    );

    if (selectedClassroomId != null) {
      try {
        await _apiClient.post<Map<String, dynamic>>(
          '/sitting',
          {
            'date': selectedDate.toIso8601String(),
            'classroom': selectedClassroomId,
          },
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إضافة الجلسة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadActivityData(); // Refresh the data
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

  Future<void> _manageAttendance() async {
    // Navigate to attendance management screen
    await context.router.push(
      AttendanceManagementRoute(
        activityId: Storage.getJson('selectedActivity')?['_id'] as String?,
      ),
    );
    _loadActivityData(); // Refresh data after returning
  }

  @override
  Widget build(BuildContext context) {
    final selectedActivity = Storage.getJson('selectedActivity');
    
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة النشاط: ${selectedActivity?['name'] ?? 'غير محدد'}'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'change_activity') {
                context.router.push(const ActivitySelectRoute());
              } else if (value == 'change_entity') {
                context.router.push(const EntitySelectRoute());
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'change_activity',
                child: Row(
                  children: [
                    Icon(Icons.sports_soccer, size: 20),
                    SizedBox(width: 8),
                    Text('تغيير النشاط'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'change_entity',
                child: Row(
                  children: [
                    Icon(Icons.business, size: 20),
                    SizedBox(width: 8),
                    Text('تغيير الكيان'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadActivityData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Activity Info Card
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'معلومات النشاط',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'الاسم: ${selectedActivity?['name'] ?? 'غير محدد'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'السعر: ${selectedActivity?['price'] ?? 0} ر.س',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Classrooms Section
                    Card(
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
                                  'الفصول (${_classrooms.length})',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: _createClassroom,
                                  tooltip: 'إضافة فصل',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (_classrooms.isEmpty)
                              const Center(
                                child: Text(
                                  'لا توجد فصول',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _classrooms.length,
                                separatorBuilder: (context, index) => const Divider(),
                                itemBuilder: (context, index) {
                                  final classroom = _classrooms[index];
                                  return ListTile(
                                    leading: const Icon(Icons.class_),
                                    title: Text(classroom['name'] as String? ?? 'بدون اسم'),
                                    subtitle: Text(
                                      classroom['level'] as String? ?? 'مستوى غير محدد',
                                    ),
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: () {
                                      // Navigate to classroom management
                                      context.router.push(
                                        ClassroomManagementRoute(
                                          activityId: Storage.getJson('selectedActivity')?['_id'] as String?,
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sittings Section
                    Card(
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
                                  'الجلسات (${_sittings.length})',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: _createSitting,
                                  tooltip: 'إضافة جلسة',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (_sittings.isEmpty)
                              const Center(
                                child: Text(
                                  'لا توجد جلسات',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _sittings.length,
                                separatorBuilder: (context, index) => const Divider(),
                                itemBuilder: (context, index) {
                                  final sitting = _sittings[index];
                                  return ListTile(
                                    leading: const Icon(Icons.event),
                                    title: const Text('جلسة'),
                                    subtitle: Text(
                                      'التاريخ: ${sitting['date'] != null ? DateTime.tryParse(sitting['date'] as String)?.toString() ?? 'غير محدد' : 'غير محدد'}',
                                    ),
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: () {
                                      // Navigate to sitting management
                                      // For now, we'll show a message since sitting management requires a classroom
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('الجلسات تدار ضمن الفصول'),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Attendance Management Button
                    ElevatedButton.icon(
                      onPressed: _manageAttendance,
                      icon: const Icon(Icons.how_to_reg),
                      label: const Text('إدارة الحضور'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Evaluations Management Button
                    ElevatedButton.icon(
                      onPressed: _manageEvaluations,
                      icon: const Icon(Icons.star),
                      label: const Text('نظام التقييم'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Homework Management Button
                    ElevatedButton.icon(
                      onPressed: _manageHomework,
                      icon: const Icon(Icons.book),
                      label: const Text('نظام الواجبات'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Content Management Button
                    ElevatedButton.icon(
                      onPressed: _manageContent,
                      icon: const Icon(Icons.library_books),
                      label: const Text('المحتوى التعليمي'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Communication Hub Button
                    ElevatedButton.icon(
                      onPressed: _manageCommunication,
                      icon: const Icon(Icons.chat),
                      label: const Text('نظام التواصل'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createClassroom,
        icon: const Icon(Icons.add),
        label: const Text('فصل جديد'),
      ),
    );
  }

  Future<void> _manageEvaluations() async {
    await context.router.push(
      EvaluationManagementRoute(
        activityId: Storage.getJson('selectedActivity')?['_id'] as String?,
      ),
    );
    // Refresh data after returning
  }

  Future<void> _manageHomework() async {
    await context.router.push(
      HomeworkManagementRoute(
        activityId: Storage.getJson('selectedActivity')?['_id'] as String?,
      ),
    );
    // Refresh data after returning
  }

  Future<void> _manageContent() async {
    await context.router.push(
      ContentManagementRoute(
        activityId: Storage.getJson('selectedActivity')?['_id'] as String?,
      ),
    );
    // Refresh data after returning
  }

  Future<void> _manageCommunication() async {
    await context.router.push(
      CommunicationHubRoute(
        activityId: Storage.getJson('selectedActivity')?['_id'] as String?,
      ),
    );
    // Refresh data after returning
  }
}