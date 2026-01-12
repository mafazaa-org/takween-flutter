import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../config/app_colors.dart';

class AppReactiveTextField extends StatelessWidget {
  final String formControlName;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final bool readOnly;
  final Map<String, String Function(Object)>? validationMessages;

  const AppReactiveTextField({
    super.key,
    required this.formControlName,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.readOnly = false,
    this.validationMessages,
  });

  @override
  Widget build(BuildContext context) {
    return ReactiveTextField<String>(
      formControlName: formControlName,
      obscureText: obscureText,
      keyboardType: keyboardType,
      readOnly: readOnly,
      validationMessages: validationMessages,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.lightGray,
        suffixIcon: suffixIcon,
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
      ),
    );
  }
}

