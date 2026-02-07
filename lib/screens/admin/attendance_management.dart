import 'package:flutter/material.dart';
import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import '../../services/api_client.dart';
import '../../services/storage.dart';
import '../../routes/router.gr.dart';

@RoutePage()
class AttendanceManagementPage extends StatefulWidget {
  final String? activityId;

  const AttendanceManagementPage({super.key, this.activityId});

  @override
  State<AttendanceManagementPage> createState() => _AttendanceManagementPageState();
}

class _AttendanceManagementPageState extends State<AttendanceManagementPage> {
  final ApiClient _apiClient = ApiClient();
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _sittings = [];
  List<Map<String, dynamic>> _attendances = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load students
      final studentsResponse = await _apiClient.get<List<dynamic>>('/student');
      setState(() {
        _students = (studentsResponse as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      });

      // Load sittings for the activity
      // This would require a backend endpoint that gets sittings for an activity
      // For now, we'll load all sittings and filter on the UI side
      final sittingsResponse = await _apiClient.get<List<dynamic>>('/sitting');
      setState(() {
        _sittings = (sittingsResponse as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      });

      // Load attendances
      final attendancesResponse = await _apiClient.get<List<dynamic>>('/attendance');
      setState(() {
        _attendances = (attendancesResponse as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ في تحميل بيانات الحضور: ${e.toString()}'),
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

  Future<void> _recordAttendance(String studentId, String sittingId, bool present) async {
    try {
      await _apiClient.post<Map<String, dynamic>>(
        '/attendance',
        {
          'studentId': studentId,
          'sittingId': sittingId,
          'present': present,
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تسجيل الحضور بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _loadAttendanceData(); // Refresh the data
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
        title: const Text('إدارة الحضور'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAttendanceData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Attendance Table Header
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'جدول الحضور',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            if (_students.isEmpty || _sittings.isEmpty)
                              const Center(
                                child: Text(
                                  'لا توجد بيانات كافية لإظهار جدول الحضور',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            else
                              DataTable(
                                columnSpacing: 16,
                                horizontalMargin: 8,
                                headingRowHeight: 48,
                                dataRowHeight: 64,
                                columns: [
                                  const DataColumn(label: Text('الطالب')),
                                  ..._sittings.take(3).map((sitting) => 
                                    DataColumn(
                                      label: RotatedBox(
                                        quarterTurns: 1,
                                        child: Text(
                                          (sitting['date'] != null ? DateTime.tryParse(sitting['date'] as String) : null)
                                              ?.toString()
                                              .split(' ')[0] ?? 'غير محدد',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                rows: _students.map((student) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(student['name'] as String? ?? 'غير محدد')),
                                      ..._sittings.take(3).map((sitting) {
                                        // Find attendance for this student and sitting
                                        final attendance = _attendances.firstWhere(
                                          (att) => 
                                            att['student'] == student['_id'] && 
                                            att['sitting'] == sitting['_id'],
                                          orElse: () => <String, dynamic>{},
                                        );
                                        
                                        bool isPresent = attendance['present'] ?? false;
                                        bool hasAttendance = attendance.isNotEmpty;
                                        
                                        return DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Checkbox(
                                                value: isPresent,
                                                onChanged: (value) {
                                                  if (value != null) {
                                                    _recordAttendance(
                                                      student['_id'] as String,
                                                      sitting['_id'] as String,
                                                      value,
                                                    );
                                                  }
                                                },
                                              ),
                                              if (hasAttendance)
                                                const Icon(Icons.check_circle, color: Colors.green)
                                              else
                                                const Icon(Icons.pending_outlined, color: Colors.orange),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Actions
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إجراءات سريعة',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {
                                    // Take attendance for today
                                    _takeAttendanceForToday();
                                  },
                                  icon: const Icon(Icons.today),
                                  label: const Text('تسجيل حضور اليوم'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    // Generate attendance report
                                    _generateAttendanceReport();
                                  },
                                  icon: const Icon(Icons.bar_chart),
                                  label: const Text('تقرير الحضور'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _takeAttendanceForToday() async {
    // Implementation for taking attendance for today's sittings
    final todaySittings = _sittings.where((sitting) {
      final sittingDate = DateTime.parse(sitting['date'] as String);
      final today = DateTime.now();
      return sittingDate.year == today.year &&
          sittingDate.month == today.month &&
          sittingDate.day == today.day;
    }).toList();

    if (todaySittings.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا توجد جلسات مجدولة اليوم'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Navigate to daily attendance screen
    await context.router.push(
      DailyAttendanceRoute(
        sittings: todaySittings,
        students: _students,
      ),
    );
    _loadAttendanceData(); // Refresh after returning
  }

  Future<void> _generateAttendanceReport() async {
    // Navigate to report generation screen
    await context.router.push(
      ReportGenerationRoute(
        reportType: 'attendance',
        entityId: Storage.getJson('selectedEntity')?['_id'] as String?,
        activityId: widget.activityId,
      ),
    );
  }
}