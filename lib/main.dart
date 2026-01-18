import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'config/app_theme.dart';
import 'config/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تكوين الراسخين',
        theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}
