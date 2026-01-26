import 'package:flutter/material.dart';
import 'package:auto_route/annotations.dart';

@RoutePage()
class ParentHomePage extends StatelessWidget {
  const ParentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الصفحة الرئيسية - ولي الأمر')),
      body: const Center(child: Text('صفحة ولي الأمر / الطالب')),
    );
  }
}
