import 'package:flutter/material.dart';
import 'package:auto_route/annotations.dart';

@RoutePage()
class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الصفحة الرئيسية - المدير')),
      body: const Center(child: Text('صفحة المدير')),
    );
  }
}
