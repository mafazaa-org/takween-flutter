import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../pages/phone_register.dart';

class AuthGuard {
  static Future<bool> checkAuth(BuildContext context) async {
    await StorageService.init();
    if (!StorageService.isLoggedIn() && context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PhoneRegisterPage()),
        (route) => false,
      );
      return false;
    }
    return true;
  }
}
