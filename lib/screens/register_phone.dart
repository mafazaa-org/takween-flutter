import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../services/api_client.dart';
import '../routes/router.gr.dart';

@RoutePage()
class RegisterPhonePage extends StatefulWidget {
  const RegisterPhonePage({super.key});

  @override
  State<RegisterPhonePage> createState() => _RegisterPhonePageState();
}

class _RegisterPhonePageState extends State<RegisterPhonePage> {
  final TextEditingController _phoneController = TextEditingController();
  final ApiClient _apiClient = ApiClient();
  final _formKey = GlobalKey<FormState>();
  String? _selectedRole;
  String? _completePhoneNumber;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate() || _selectedRole == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _apiClient.post<Map<String, dynamic>>(
        '/user/phone/register',
         {
        'phone': _completePhoneNumber,
        'type': _selectedRole,
      },
      );

      if (mounted) {
        context.router.push(VerifyPhoneRoute(phone: _completePhoneNumber!));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
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
      appBar: AppBar(title: const Text('تسجيل رقم الهاتف')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const Text(
                'أدخل رقم هاتفك',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'سنرسل لك رمز التحقق',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              IntlPhoneField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  hintText: 'أدخل رقم هاتفك',
                ),
                initialCountryCode: 'EG',
                searchText: 'ابحث عن الدولة',
                invalidNumberMessage: 'رقم الهاتف غير صحيح',
                validator: (phone) {
                  if (phone == null || phone.number.isEmpty) {
                    return 'الرجاء إدخال رقم الهاتف';
                  }
                  try {
                    if (!phone.isValidNumber()) {
                      return 'رقم الهاتف غير صحيح';
                    }
                  } catch (e) {
                    // Handle cases where phone number is too short or invalid format
                    return 'رقم الهاتف غير صحيح';
                  }
                  return null;
                },
                onChanged: (phone) {
                  setState(() {
                    try {
                      if (phone.isValidNumber()) {
                        _completePhoneNumber = phone.completeNumber;
                      } else {
                        _completePhoneNumber = null;
                      }
                    } catch (e) {
                      // If validation fails due to too short number, set to null
                      _completePhoneNumber = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 32),
              const Text(
                'اختر نوع المستخدم',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedRole = 'parent';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedRole == 'parent'
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300],
                        foregroundColor: _selectedRole == 'parent'
                            ? Colors.white
                            : Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'ولي أمر / طالب',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedRole = 'admin';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedRole == 'admin'
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300],
                        foregroundColor: _selectedRole == 'admin'
                            ? Colors.white
                            : Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('مدير', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed:
                    _completePhoneNumber != null &&
                        _completePhoneNumber!.isNotEmpty &&
                        _selectedRole != null &&
                        !_isLoading
                    ? _handleRegistration
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'متابعة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
