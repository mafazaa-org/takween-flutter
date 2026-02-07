import 'package:flutter/material.dart';
import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import '../../services/api_client.dart';
import '../../services/storage.dart';
import '../../routes/router.gr.dart';

@RoutePage()
class ReportGenerationPage extends StatefulWidget {
  final String reportType;
  final String? entityId;
  final String? activityId;

  const ReportGenerationPage({
    super.key,
    required this.reportType,
    this.entityId,
    this.activityId,
  });

  @override
  State<ReportGenerationPage> createState() => _ReportGenerationPageState();
}

class _ReportGenerationPageState extends State<ReportGenerationPage> {
  final ApiClient _apiClient = ApiClient();
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  bool _isLoading = false;
  Map<String, dynamic>? _reportData;

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _generateReport() async {
    if (widget.entityId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لم يتم تحديد كيان'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/report',
        {
          'type': widget.reportType,
          'entityId': widget.entityId,
          'activityId': widget.activityId,
          'startDate': _startDate.toIso8601String(),
          'endDate': _endDate.toIso8601String(),
          'period': 'custom',
        },
      );

      setState(() {
        _reportData = response;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء التقرير بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ في إنشاء التقرير: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء تقرير'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'معلمات التقرير',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    
                    // Report type
                    ListTile(
                      leading: const Icon(Icons.bar_chart),
                      title: const Text('نوع التقرير'),
                      subtitle: Text(_getReportTypeName(widget.reportType)),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Date range
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: const Text('من'),
                            subtitle: Text(
                              '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                            ),
                            onTap: _selectStartDate,
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: const Text('إلى'),
                            subtitle: Text(
                              '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                            ),
                            onTap: _selectEndDate,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Generate button
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _generateReport,
                      icon: _isLoading 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.bar_chart),
                      label: const Text('إنشاء التقرير'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Report results
            if (_reportData != null) ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نتائج التقرير',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      
                      // Display report data based on type
                      if (widget.reportType == 'attendance') ...[
                        _buildAttendanceReport(),
                      ] else ...[
                        Text(
                          'بيانات التقرير: ${_reportData.toString()}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceReport() {
    if (_reportData == null) return const SizedBox.shrink();
    
    final data = _reportData!['data'] as Map<String, dynamic>? ?? {};
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('إجمالي الحضور: ${data['totalAttendances'] ?? 0}'),
        Text('عدد الحاضرين: ${data['presentCount'] ?? 0}'),
        Text('عدد الغائبين: ${data['absentCount'] ?? 0}'),
        Text('نسبة الحضور: ${(data['attendanceRate'] ?? 0).toStringAsFixed(2)}%'),
        
        const SizedBox(height: 16),
        
        if (data['records'] != null && (data['records'] as List).isNotEmpty) ...[
          const Text(
            'تفاصيل الحضور:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...ListTile.divideTiles(
            context: context,
            tiles: (data['records'] as List).take(5).map((record) {
              return ListTile(
                title: Text('الطالب: ${record['studentId'] ?? 'غير محدد'}'),
                subtitle: Text('التاريخ: ${record['date'] ?? 'غير محدد'} - الحضور: ${record['present'] == true ? 'حاضر' : 'غائب'}'),
              );
            }),
          ).toList(),
        ],
      ],
    );
  }

  String _getReportTypeName(String type) {
    switch (type) {
      case 'attendance':
        return 'تقرير الحضور';
      case 'performance':
        return 'تقرير الأداء';
      case 'enrollment':
        return 'تقرير التسجيل';
      case 'activity':
        return 'تقرير النشاط';
      default:
        return 'تقرير مخصص';
    }
  }
}