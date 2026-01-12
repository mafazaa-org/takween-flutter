import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../config/app_colors.dart';
import '../services/storage_service.dart';
import '../forms/login_form.dart';
import '../components/reactive_text_field.dart';
import '../components/submit_button.dart';
import '../components/auth_header.dart';
import '../components/auth_link.dart';
import '../utils/auth_helper.dart';
import 'signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final FormGroup form;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    form = LoginForm.buildForm();
    AuthHelper.checkLoginStatus(context);
  }

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
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
        title: const Text('تسجيل الدخول'),
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
                  title: 'تكوين',
                  subtitle: 'مرحباً بك',
                ),
                AppReactiveTextField(
                  formControlName: 'email',
                  label: 'البريد الإلكتروني',
                  hint: 'example@email.com',
                  keyboardType: TextInputType.emailAddress,
                  validationMessages: LoginForm.validationMessages['email'],
                ),
                const SizedBox(height: 32),
                SubmitButton(
                  onPressed: _handleLogin,
                  isLoading: _isLoading,
                  text: 'تسجيل الدخول',
                ),
                const SizedBox(height: 16),
                AuthLink(
                  question: 'ليس لديك حساب؟ ',
                  action: 'إنشاء حساب',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupPage()),
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
