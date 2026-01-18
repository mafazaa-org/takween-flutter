import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../config/app_colors.dart';
import '../utils/api_client.dart';
import '../models/activity.dart';
import '../services/storage_service.dart';
import '../components/reactive_text_field.dart';
import '../components/submit_button.dart';
import '../utils/auth_guard.dart';
import 'home.dart';

class ActivitySelectPage extends StatefulWidget {
  final int entityId;

  const ActivitySelectPage({
    super.key,
    required this.entityId,
  });

  @override
  State<ActivitySelectPage> createState() => _ActivitySelectPageState();
}

class _ActivitySelectPageState extends State<ActivitySelectPage> {
  final ApiClient _apiClient = ApiClient();
  List<Activity> _activities = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkAuthAndFetchActivities();
  }

  Future<void> _checkAuthAndFetchActivities() async {
    final isAuthenticated = await AuthGuard.checkAuth(context);
    if (isAuthenticated && mounted) {
      _fetchActivities();
    }
  }

  Future<void> _fetchActivities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiClient.get<List<dynamic>>(
        '/activity',
        queryParameters: {'entity': widget.entityId.toString()},
      );
      setState(() {
        _activities = response.map((json) => Activity.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleActivityTap(Activity activity) async {
    await StorageService.saveSelectedActivity(activity.id, activity.name);
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    }
  }

  Future<void> _handleAddActivity() async {
    await showDialog(
      context: context,
      builder: (context) => _AddActivityDialog(
        entityId: widget.entityId,
        onActivityCreated: () {
          _fetchActivities();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر النشاط'),
        backgroundColor: AppColors.navyBlue,
        foregroundColor: AppColors.white,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleAddActivity,
        backgroundColor: AppColors.green,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.green),
            const SizedBox(height: 16),
            Text(
              'جاري التحميل...',
              style: TextStyle(fontSize: 16, color: AppColors.gray),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'حدث خطأ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(fontSize: 14, color: AppColors.gray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchActivities,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_activities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: AppColors.gray),
              const SizedBox(height: 16),
              Text(
                'لا توجد أنشطة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'لم يتم العثور على أي أنشطة متاحة',
                style: TextStyle(fontSize: 14, color: AppColors.gray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchActivities,
                icon: const Icon(Icons.refresh),
                label: const Text('تحديث'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchActivities,
      color: AppColors.green,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _activities.length,
        itemBuilder: (context, index) {
          final activity = _activities[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(
                activity.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.green,
                size: 20,
              ),
              onTap: () => _handleActivityTap(activity),
            ),
          );
        },
      ),
    );
  }
}

class _AddActivityDialog extends StatefulWidget {
  final int entityId;
  final VoidCallback onActivityCreated;

  const _AddActivityDialog({
    required this.entityId,
    required this.onActivityCreated,
  });

  @override
  State<_AddActivityDialog> createState() => _AddActivityDialogState();
}

class _AddActivityDialogState extends State<_AddActivityDialog> {
  late final FormGroup form;
  bool _isLoading = false;
  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    form = FormGroup({
      'name': FormControl<String>(
        validators: [
          Validators.required,
          Validators.minLength(3),
          Validators.maxLength(50),
        ],
      ),
      'price': FormControl<String>(
        value: '0',
        validators: [
          Validators.required,
        ],
      ),
    });
  }

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!form.valid) {
      form.markAllAsTouched();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final name = form.control('name').value as String;
      final priceStr = form.control('price').value as String;
      final price = double.tryParse(priceStr) ?? 0.0;
      
      await _apiClient.post('/activity', body: {
        'name': name,
        'entity': widget.entityId.toString(),
        'price': price,
      });
      
      if (mounted) {
        Navigator.of(context).pop();
        widget.onActivityCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إضافة النشاط بنجاح'),
            backgroundColor: AppColors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('ApiException')
                  ? 'فشل إضافة النشاط'
                  : 'حدث خطأ غير متوقع',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ReactiveForm(
        formGroup: form,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'إضافة نشاط جديد',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppReactiveTextField(
                formControlName: 'name',
                label: 'اسم النشاط',
                hint: 'أدخل اسم النشاط',
                keyboardType: TextInputType.text,
                validationMessages: {
                  'required': (_) => 'اسم النشاط مطلوب',
                  'minLength': (_) => 'الاسم يجب أن يكون على الأقل 3 أحرف',
                  'maxLength': (_) => 'الاسم يجب أن يكون على الأكثر 50 حرف',
                },
              ),
              const SizedBox(height: 24),
              AppReactiveTextField(
                formControlName: 'price',
                label: 'السعر',
                hint: '0.0',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validationMessages: {
                  'required': (_) => 'السعر مطلوب',
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SubmitButton(
                      onPressed: _handleSubmit,
                      isLoading: _isLoading,
                      text: 'إضافة',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
