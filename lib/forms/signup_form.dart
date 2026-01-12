import 'package:reactive_forms/reactive_forms.dart';

class SignupForm {
  static FormGroup buildForm() => fb.group(
    {
      'name': FormControl<String>(value: '', validators: [Validators.required]),
      'phone': FormControl<String>(
        value: '',
        validators: [Validators.required, Validators.minLength(10)],
      ),
      'role': FormControl<String>(value: 'parent'),
    },
  );

  static final Map<String, Map<String, String Function(Object)>>
  validationMessages = {
    'name': {'required': (_) => 'الرجاء إدخال الاسم'},
    'phone': {
      'required': (_) => 'الرجاء إدخال رقم الهاتف',
      'minLength': (_) => 'رقم الهاتف يجب أن يكون 10 أرقام على الأقل',
    },
  };
}
