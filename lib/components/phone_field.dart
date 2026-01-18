import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../config/app_colors.dart';

class PhoneField extends StatelessWidget {
  final String formControlName;
  final String label;
  final Map<String, String Function(Object)>? validationMessages;

  const PhoneField({
    super.key,
    required this.formControlName,
    required this.label,
    this.validationMessages,
  });

  @override
  Widget build(BuildContext context) {
    return ReactiveFormConsumer(
      builder: (context, form, child) {
        final control = form.control(formControlName);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 8),
            IntlPhoneField(
              decoration: InputDecoration(
                hintText: '5xxxxxxxx',
                filled: true,
                fillColor: AppColors.lightGray,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.green, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.error, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.error, width: 2),
                ),
                errorText: control.hasErrors && control.touched
                    ? _getErrorMessage(control.errors, validationMessages)
                    : null,
              ),
              initialCountryCode: 'SA',
              onChanged: (phone) {
                control.value = phone.completeNumber;
              },
              validator: (phone) {
                if (phone == null || phone.number.isEmpty) {
                  return validationMessages?['required']?.call('') ?? 'رقم الهاتف مطلوب';
                }
                if (phone.completeNumber.isEmpty) {
                  return validationMessages?['required']?.call('') ?? 'رقم الهاتف مطلوب';
                }
                return null;
              },
            ),
          ],
        );
      },
    );
  }

  String? _getErrorMessage(
    Map<String, dynamic> errors,
    Map<String, String Function(Object)>? validationMessages,
  ) {
    if (errors.isEmpty || validationMessages == null) return null;

    final firstError = errors.entries.first;
    final errorKey = firstError.key;
    final errorValue = firstError.value;

    return validationMessages[errorKey]?.call(errorValue);
  }
}
