import 'package:flutter/material.dart';
import 'reactive_text_field.dart';

class PasswordField extends StatefulWidget {
  final String formControlName;
  final String label;
  final String? hint;
  final Map<String, String Function(Object)>? validationMessages;

  const PasswordField({
    super.key,
    required this.formControlName,
    required this.label,
    this.hint,
    this.validationMessages,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AppReactiveTextField(
      formControlName: widget.formControlName,
      label: widget.label,
      hint: widget.hint ?? '••••••••',
      obscureText: _obscureText,
      validationMessages: widget.validationMessages,
      suffixIcon: IconButton(
        icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
        onPressed: () => setState(() => _obscureText = !_obscureText),
      ),
    );
  }
}

