import 'package:flutter/material.dart';
import 'config/app_theme.dart';
import 'config/env.dart';
import 'services/storage.dart';
import 'routes/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.load();
  await Storage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _appRouter = AppRouter();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'تكوين الراسخين',
      theme: AppTheme.lightTheme,
      routerConfig: _appRouter.config(),
    );
  }
}
