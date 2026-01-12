import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class AuthLink extends StatelessWidget {
  final String question;
  final String action;
  final VoidCallback onTap;

  const AuthLink({
    super.key,
    required this.question,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(question, style: TextStyle(color: AppColors.gray)),
        TextButton(
          onPressed: onTap,
          child: Text(
            action,
            style: TextStyle(
              color: AppColors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

