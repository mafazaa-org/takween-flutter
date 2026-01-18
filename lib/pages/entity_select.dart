import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../config/app_colors.dart';
import '../utils/api_client.dart';
import '../models/entity.dart';
import '../services/storage_service.dart';
import '../components/reactive_text_field.dart';
import '../components/submit_button.dart';
import '../utils/auth_guard.dart';
import 'activity_select.dart';
import 'phone_register.dart';

class EntitySelectPage extends StatefulWidget {
  const EntitySelectPage({super.key});

  @override
  State<EntitySelectPage> createState() => _EntitySelectPageState();
}

class _EntitySelectPageState extends State<EntitySelectPage> {
  final ApiClient _apiClient = ApiClient();
  List<Entity> _entities = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkAuthAndFetchEntities();
  }

  Future<void> _checkAuthAndFetchEntities() async {
    final isAuthenticated = await AuthGuard.checkAuth(context);
    if (isAuthenticated && mounted) {
      _fetchEntities();
    }
  }

  Future<void> _fetchEntities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiClient.get<List<dynamic>>('/entity');
      setState(() {
        _entities = response.map((json) => Entity.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleEntityTap(Entity entity) async {
    await StorageService.saveSelectedEntity(entity.id, entity.name);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ActivitySelectPage(entityId: entity.id),
        ),
      );
    }
  }

  Future<void> _handleAddEntity() async {
    await showDialog(
      context: context,
      builder: (context) => _AddEntityDialog(
        onEntityCreated: () {
          _fetchEntities();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر الكيان'),
        backgroundColor: AppColors.navyBlue,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await StorageService.clearAuth();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const PhoneRegisterPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleAddEntity,
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
                onPressed: _fetchEntities,
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

    if (_entities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: AppColors.gray),
              const SizedBox(height: 16),
              Text(
                'لا توجد كيانات',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'لم يتم العثور على أي كيانات متاحة',
                style: TextStyle(fontSize: 14, color: AppColors.gray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchEntities,
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
      onRefresh: _fetchEntities,
      color: AppColors.green,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _entities.length,
        itemBuilder: (context, index) {
          final entity = _entities[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(
                entity.name,
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
              onTap: () => _handleEntityTap(entity),
            ),
          );
        },
      ),
    );
  }
}

class _AddEntityDialog extends StatefulWidget {
  final VoidCallback onEntityCreated;

  const _AddEntityDialog({
    required this.onEntityCreated,
  });

  @override
  State<_AddEntityDialog> createState() => _AddEntityDialogState();
}

class _AddEntityDialogState extends State<_AddEntityDialog> {
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
      await _apiClient.post('/entity', body: {'name': name});
      
      if (mounted) {
        Navigator.of(context).pop();
        widget.onEntityCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إضافة الكيان بنجاح'),
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
                  ? 'فشل إضافة الكيان'
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
                'إضافة كيان جديد',
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
                label: 'اسم الكيان',
                hint: 'أدخل اسم الكيان',
                keyboardType: TextInputType.text,
                validationMessages: {
                  'required': (_) => 'اسم الكيان مطلوب',
                  'minLength': (_) => 'الاسم يجب أن يكون على الأقل 3 أحرف',
                  'maxLength': (_) => 'الاسم يجب أن يكون على الأكثر 50 حرف',
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
