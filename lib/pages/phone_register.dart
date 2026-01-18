import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../config/app_colors.dart';
import '../services/storage_service.dart';
import '../components/phone_field.dart';
import '../components/submit_button.dart';
import '../components/auth_header.dart';
import '../utils/api_client.dart';
import 'phone_verify.dart';

class PhoneRegisterPage extends StatefulWidget {
  const PhoneRegisterPage({super.key});

  @override
  State<PhoneRegisterPage> createState() => _PhoneRegisterPageState();
}

class _PhoneRegisterPageState extends State<PhoneRegisterPage> {
  late final FormGroup form;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    form = FormGroup({
      'phone': FormControl<String>(validators: [Validators.required]),
      'type': FormControl<String>(
        value: 'parent',
        validators: [Validators.required],
      ),
    });
    StorageService.init();
  }

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!form.valid) {
      form.markAllAsTouched();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiClient = ApiClient();
      final phone = form.control('phone').value as String;
      final type = form.control('type').value as String;

      await apiClient.post(
        '/user/phone/register',
        body: {'phone': phone, 'type': type},
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PhoneVerifyPage(phone: phone)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('ApiException')
                  ? 'حدث خطأ في الإرسال'
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
        title: const Text('تسجيل رقم الهاتف'),
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
                const AuthHeader(title: 'تكوين', subtitle: 'أدخل رقم الهاتف'),
                const SizedBox(height: 32),
                PhoneField(
                  formControlName: 'phone',
                  label: 'رقم الهاتف',
                  validationMessages: {'required': (_) => 'رقم الهاتف مطلوب'},
                ),
                const SizedBox(height: 24),
                ReactiveFormConsumer(
                  builder: (context, form, child) {
                    final isParent = form.control('type').value == 'parent';

                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.lightGray),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                form.control('type').value = 'parent';
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: isParent
                                      ? AppColors.green
                                      : AppColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'طالب/ولي أمر',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                form.control('type').value = 'admin';
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: !isParent
                                      ? AppColors.green
                                      : AppColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'مشرف',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: !isParent
                                        ? AppColors.white
                                        : AppColors.charcoal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                SubmitButton(
                  onPressed: _handleRegister,
                  isLoading: _isLoading,
                  text: 'إرسال رمز التحقق',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
