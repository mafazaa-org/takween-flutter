import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../config/app_colors.dart';
import '../services/storage_service.dart';
import '../components/reactive_text_field.dart';
import '../components/submit_button.dart';
import '../components/auth_header.dart';
import '../utils/api_client.dart';
import 'starting_point.dart';

class PhoneVerifyPage extends StatefulWidget {
  final String phone;

  const PhoneVerifyPage({
    super.key,
    required this.phone,
  });

  @override
  State<PhoneVerifyPage> createState() => _PhoneVerifyPageState();
}

class _PhoneVerifyPageState extends State<PhoneVerifyPage> {
  late final FormGroup form;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    form = FormGroup({
      'code': FormControl<String>(
        validators: [
          Validators.required,
          Validators.pattern(r'^\d{6}$'),
        ],
      ),
    });
    StorageService.init();
  }

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  String _maskPhone(String phone) {
    if (phone.length < 4) return phone;
    final lastFour = phone.substring(phone.length - 4);
    return '***$lastFour';
  }

  Future<void> _handleVerify() async {
    if (!form.valid) {
      form.markAllAsTouched();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiClient = ApiClient();
      final code = form.control('code').value as String;

      final response = await apiClient.post<Map<String, dynamic>>(
        '/user/phone/verify',
        body: {
          'phone': widget.phone,
          'code': code,
        },
      );

      final adminData = response['admin'] as Map<String, dynamic>?;
      if (adminData != null) {
        final accessToken = adminData['accessToken'] as String;
        final refreshToken = adminData['refreshToken'] as String;

        await StorageService.setTokens(accessToken, refreshToken);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const StartingPointPage(),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('ApiException')
                  ? 'رمز التحقق غير صحيح'
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
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('التحقق من رقم الهاتف'),
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
                  subtitle: 'أدخل رمز التحقق',
                ),
                const SizedBox(height: 24),
                Text(
                  'تم إرسال رمز التحقق إلى ${_maskPhone(widget.phone)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 32),
                AppReactiveTextField(
                  formControlName: 'code',
                  label: 'رمز التحقق',
                  hint: '123456',
                  keyboardType: TextInputType.number,
                  validationMessages: {
                    'required': (_) => 'رمز التحقق مطلوب',
                    'pattern': (_) => 'يجب أن يكون الرمز 6 أرقام',
                  },
                ),
                const SizedBox(height: 32),
                SubmitButton(
                  onPressed: _handleVerify,
                  isLoading: _isLoading,
                  text: 'التحقق',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
