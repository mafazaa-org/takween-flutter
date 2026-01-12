import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../config/app_colors.dart';
import '../forms/signup_form.dart';
import '../components/reactive_text_field.dart';
import '../components/role_selector.dart';
import '../components/submit_button.dart';
import '../components/auth_header.dart';
import '../components/auth_link.dart';
import '../services/storage_service.dart';
import '../utils/auth_helper.dart';
import 'login.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late final FormGroup form;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    form = SignupForm.buildForm();
    AuthHelper.checkLoginStatus(context);
  }

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!form.valid) {
      form.markAllAsTouched();
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 1));
      final token = 'token_${DateTime.now().millisecondsSinceEpoch}';
      await AuthHelper.handleAuthSuccess(
        context,
        () => StorageService.setAuthToken(token),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد'),
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
                const AuthHeader(
                  title: 'إنشاء حساب جديد',
                  subtitle: 'أدخل بياناتك للتسجيل',
                ),
                AppReactiveTextField(
                  formControlName: 'name',
                  label: 'الاسم',
                  hint: 'أدخل اسمك الكامل',
                  validationMessages: SignupForm.validationMessages['name'],
                ),
                const SizedBox(height: 20),
                AppReactiveTextField(
                  formControlName: 'phone',
                  label: 'رقم الهاتف',
                  hint: '05xxxxxxxx',
                  keyboardType: TextInputType.phone,
                  validationMessages: SignupForm.validationMessages['phone'],
                ),
                const SizedBox(height: 32),
                const RoleSelector(formControlName: 'role'),
                const SizedBox(height: 32),
                SubmitButton(
                  onPressed: _handleSignup,
                  isLoading: _isLoading,
                  text: 'إنشاء حساب',
                ),
                const SizedBox(height: 16),
                AuthLink(
                  question: 'لديك حساب بالفعل؟ ',
                  action: 'تسجيل الدخول',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
