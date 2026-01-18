import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../config/app_colors.dart';
import '../components/reactive_text_field.dart';
import '../components/submit_button.dart';
import '../components/auth_header.dart';
import '../utils/api_client.dart';
import '../utils/auth_guard.dart';
import 'entity_select.dart';

class StartingPointPage extends StatefulWidget {
  const StartingPointPage({super.key});

  @override
  State<StartingPointPage> createState() => _StartingPointPageState();
}

class _StartingPointPageState extends State<StartingPointPage> {
  late final FormGroup form;
  bool _isLoading = false;
  bool _isCheckingUser = true;
  Map<String, dynamic>? _currentUser;

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
    _checkAuthAndFetchUser();
  }

  Future<void> _checkAuthAndFetchUser() async {
    final isAuthenticated = await AuthGuard.checkAuth(context);
    if (isAuthenticated && mounted) {
      _fetchCurrentUser();
    }
  }

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final apiClient = ApiClient();
      final user = await apiClient.get<Map<String, dynamic>>('/user');

      setState(() {
        _currentUser = user;
        _isCheckingUser = false;

        if (user['name'] != null && (user['name'] as String).isNotEmpty) {
          form.control('name').value = user['name'] as String;
        }
      });

      if (user['name'] == null || (user['name'] as String).isEmpty) {
        form.control('name').markAsTouched();
      } else {
        _navigateToEntitySelect();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCheckingUser = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('ApiException')
                  ? 'فشل تحميل بيانات المستخدم'
                  : 'حدث خطأ غير متوقع',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleUpdateName() async {
    if (!form.valid) {
      form.markAllAsTouched();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiClient = ApiClient();
      final name = form.control('name').value as String;

      await apiClient.put('/user', body: {'name': name});

      _navigateToEntitySelect();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('ApiException')
                  ? 'فشل تحديث الاسم'
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

  void _navigateToEntitySelect() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EntitySelectPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingUser) {
      return Scaffold(
        backgroundColor: AppColors.offWhite,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final needsName =
        _currentUser == null ||
        _currentUser!['name'] == null ||
        (_currentUser!['name'] as String).isEmpty;

    if (!needsName) {
      return Scaffold(
        backgroundColor: AppColors.offWhite,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('إكمال التسجيل'),
        backgroundColor: AppColors.navyBlue,
        foregroundColor: AppColors.white,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ReactiveForm(
            formGroup: form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthHeader(title: 'تكوين', subtitle: 'أدخل اسمك'),
                const SizedBox(height: 32),
                AppReactiveTextField(
                  formControlName: 'name',
                  label: 'الاسم',
                  hint: 'أدخل اسمك الكامل',
                  keyboardType: TextInputType.name,
                  validationMessages: {
                    'required': (_) => 'الاسم مطلوب',
                    'minLength': (_) => 'الاسم يجب أن يكون على الأقل 3 أحرف',
                    'maxLength': (_) => 'الاسم يجب أن يكون على الأكثر 50 حرف',
                  },
                ),
                const SizedBox(height: 32),
                SubmitButton(
                  onPressed: _handleUpdateName,
                  isLoading: _isLoading,
                  text: 'متابعة',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
