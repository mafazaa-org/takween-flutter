import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../pages/entity_select.dart';

class AuthHelper {
  static Future<void> checkLoginStatus(BuildContext context) async {
    await StorageService.init();
    if (StorageService.isLoggedIn() && context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EntitySelectPage()),
      );
    }
  }

  static Future<void> handleAuthSuccess(
    BuildContext context,
    Future<void> Function() authAction,
  ) async {
    await authAction();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EntitySelectPage()),
      );
    }
  }
}

