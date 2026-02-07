import 'package:flutter/material.dart';
import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import '../../services/api_client.dart';
import '../../routes/router.gr.dart';

@RoutePage()
class DailyAttendancePage extends StatefulWidget {
  final List<Map<String, dynamic>> sittings;
  final List<Map<String, dynamic>> students;

  const DailyAttendancePage({
    super.key,
    required this.sittings,
    required this.students,
  });

  @override
  State<DailyAttendancePage> createState() => _DailyAttendancePageState();
}

class _DailyAttendancePageState extends State<DailyAttendancePage> {
  final ApiClient _apiClient = ApiClient();
  Map<String, Map<String, bool>> _attendanceData = {};

  @override
  void initState() {
    super.initState();
    _initializeAttendanceData();
  }

  void _initializeAttendanceData() {
    // Initialize attendance data with default values
    for (final sitting in widget.sittings) {
      for (final student in widget.students) {
        final sittingId = sitting['_id'] as String?;
        final studentId = student['_id'] as String?;
        
        if (sittingId != null && studentId != null) {
          _attendanceData.putIfAbsent(sittingId, () => {});
          _attendanceData[sittingId]![studentId] = false; // Default to absent
        }
      }
    }
  }

  Future<void> _saveAttendance() async {
    try {
      bool hasErrors = false;
      
      for (final sittingEntry in _attendanceData.entries) {
        final sittingId = sittingEntry.key;
        for (final studentEntry in sittingEntry.value.entries) {
          final studentId = studentEntry.key;
          final present = studentEntry.value;
          
          try {
            await _apiClient.post<Map<String, dynamic>>(
              '/attendance',
              {
                'studentId': studentId,
                'sittingId': sittingId,
                'present': present,
              },
            );
          } catch (e) {
            hasErrors = true;
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('خطأ في تسجيل حضور الطالب: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      }
      
      if (!hasErrors) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حفظ الحضور بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate back to attendance management
          context.router.maybePop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء حفظ الحضور: ${e.toString()}'),
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
        title: const Text('تسجيل حضور اليوم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAttendance,
            tooltip: 'حفظ الحضور',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sittings info
            if (widget.sittings.isNotEmpty)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الجلسات اليوم',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      ...widget.sittings.map((sitting) {
                        final sittingDate = DateTime.tryParse(sitting['date'] as String? ?? '');
                        return ListTile(
                          leading: const Icon(Icons.event),
                          title: Text('جلسة'),
                          subtitle: Text(
                            sittingDate != null
                                ? '${sittingDate.day}/${sittingDate.month}/${sittingDate.year}'
                                : 'تاريخ غير محدد',
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),

            // Attendance table
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
                    if (widget.students.isEmpty || widget.sittings.isEmpty)
                      const Center(
                        child: Text(
                          'لا توجد بيانات كافية',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      DataTable(
                        columnSpacing: 16,
                        horizontalMargin: 8,
                        headingRowHeight: 48,
                        dataRowHeight: 48,
                        columns: [
                          const DataColumn(label: Text('الطالب')),
                          ...widget.sittings.map((sitting) => 
                            DataColumn(
                              label: RotatedBox(
                                quarterTurns: 1,
                                child: Text(
                                  'الحضور',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                        ],
                        rows: widget.students.map((student) {
                          return DataRow(
                            cells: [
                              DataCell(Text(student['name'] as String? ?? 'غير محدد')),
                              ...widget.sittings.map((sitting) {
                                final sittingId = sitting['_id'] as String?;
                                final studentId = student['_id'] as String?;
                                
                                if (sittingId == null || studentId == null) {
                                  return const DataCell(Text(''));
                                }
                                
                                final isPresent = _attendanceData[sittingId]?[studentId] ?? false;
                                
                                return DataCell(
                                  Switch(
                                    value: isPresent,
                                    onChanged: (value) {
                                      setState(() {
                                        _attendanceData[sittingId]![studentId] = value;
                                      });
                                    },
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveAttendance,
        icon: const Icon(Icons.save),
        label: const Text('حفظ'),
      ),
    );
  }
}