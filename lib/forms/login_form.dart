import 'package:reactive_forms/reactive_forms.dart';

class LoginForm {
  static FormGroup buildForm() => fb.group({
    'email': FormControl<String>(
      value: '',
      validators: [Validators.required, Validators.email],
    ),
  });

  static final Map<String, Map<String, String Function(Object)>>
  validationMessages = {
    'email': {
      'required': (_) => 'الرجاء إدخال البريد الإلكتروني',
      'email': (_) => 'الرجاء إدخال بريد إلكتروني صحيح',
    },
  };
}
