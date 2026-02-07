import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../../services/api_client.dart';
import '../../services/storage.dart';
import '../../routes/router.gr.dart';

@RoutePage()
class EvaluationManagementPage extends StatefulWidget {
  final String? activityId;

  const EvaluationManagementPage({super.key, this.activityId});

  @override
  State<EvaluationManagementPage> createState() => _EvaluationManagementPageState();
}

class _EvaluationManagementPageState extends State<EvaluationManagementPage> {
  final ApiClient _apiClient = ApiClient();
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _evaluations = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEvaluationData();
  }

  Future<void> _loadEvaluationData() async {
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

      // Load evaluations for this activity
      if (widget.activityId != null) {
        final evaluationsResponse = await _apiClient.get<List<dynamic>>(
          '/evaluation',
          queryParameters: widget.activityId != null ? {'activityId': widget.activityId!} : {},
        );
        setState(() {
          _evaluations = (evaluationsResponse as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ في تحميل بيانات التقييم: ${e.toString()}'),
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

  Future<void> _addEvaluation(String studentId) async {
    final scoreController = TextEditingController();
    final feedbackController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة تقييم'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: scoreController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'الدرجة (0-100)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الدرجة';
                  }
                  final score = double.tryParse(value);
                  if (score == null || score < 0 || score > 100) {
                    return 'الرجاء إدخال درجة صحيحة (0-100)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: feedbackController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات التقييم',
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
          '/evaluation',
          {
            'studentId': studentId,
            'activityId': widget.activityId,
            'score': double.parse(scoreController.text),
            'feedback': feedbackController.text,
          },
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إضافة التقييم بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadEvaluationData(); // Refresh the data
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
        title: const Text('نظام التقييم'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadEvaluationData,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Evaluation statistics
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إحصائيات التقييم',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatCard(
                                  'إجمالي التقييمات',
                                  _evaluations.length.toString(),
                                  Icons.insert_chart,
                                ),
                                _buildStatCard(
                                  'المعدل العام',
                                  _evaluations.isNotEmpty
                                      ? (_evaluations
                                              .map((e) => e['score'] as num)
                                              .reduce((a, b) => a + b) /
                                          _evaluations.length)
                                          .toStringAsFixed(1)
                                      : '0.0',
                                  Icons.trending_up,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Evaluation list
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
                                    'قائمة التقييمات',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (_evaluations.isEmpty)
                                const Center(
                                  child: Text(
                                    'لا توجد تقييمات',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              else
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: _evaluations.length,
                                    separatorBuilder: (context, index) =>
                                        const Divider(),
                                    itemBuilder: (context, index) {
                                      final evaluation = _evaluations[index];
                                      final student = _students.firstWhere(
                                        (s) => s['_id'] == evaluation['student'],
                                        orElse: () => <String, dynamic>{},
                                      );
                                      
                                      return ListTile(
                                        leading: CircleAvatar(
                                          child: Text(
                                            (student['name'] as String)
                                                    .substring(0, 1)
                                                    .toUpperCase(),
                                          ),
                                        ),
                                        title: Text(
                                          student['name'] as String? ?? 'طالب غير معروف',
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('الدرجة: ${evaluation['score']}'),
                                            if (evaluation['feedback'] != null)
                                              Text(
                                                'ملاحظات: ${evaluation['feedback']}',
                                                style: const TextStyle(fontSize: 12),
                                              ),
                                          ],
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () {
                                            // TODO: Edit evaluation
                                          },
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
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      width: 150,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, size: 30),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}