import 'package:flutter/material.dart';
import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import '../../routes/router.gr.dart';
import '../../services/storage.dart';

@RoutePage()
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSelection();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshSelection();
  }

  @override
  void didUpdateWidget(covariant AdminHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _refreshSelection();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh when app resumes to ensure latest selections
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshSelection();
      });
    }
  }

  void _checkSelection() {
    final selectedEntity = Storage.getJson('selectedEntity');
    final selectedActivity = Storage.getJson('selectedActivity');

    if (selectedEntity == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.router.replace(const EntitySelectRoute());
        }
      });
    } else if (selectedEntity != null && selectedActivity == null) {
      // If entity is selected but no activity is selected, go to activity selection
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.router.replace(const ActivitySelectRoute());
        }
      });
    }
  }

  void _refreshSelection() {
    setState(() {});
  }

  Future<void> _changeEntity() async {
    await context.router.push(const EntitySelectRoute());
    if (mounted) {
      _refreshSelection();
      _checkSelection();
    }
  }

  Future<void> _changeActivity() async {
    await context.router.push(const ActivitySelectRoute());
    if (mounted) {
      _refreshSelection();
      _checkSelection();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedEntity = Storage.getJson('selectedEntity');
    final selectedActivity = Storage.getJson('selectedActivity');

    if (selectedEntity == null || selectedActivity == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('الصفحة الرئيسية - المدير'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            onSelected: (value) {
              if (value == 'entity') {
                _changeEntity();
              } else if (value == 'activity') {
                _changeActivity();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'entity',
                child: Row(
                  children: [
                    Icon(Icons.business, size: 20),
                    SizedBox(width: 8),
                    Text('تغيير الكيان'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'activity',
                child: Row(
                  children: [
                    Icon(Icons.sports_soccer, size: 20),
                    SizedBox(width: 8),
                    Text('تغيير النشاط'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'الكيان المحدد: ${selectedEntity['name'] ?? 'غير محدد'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              'النشاط المحدد: ${selectedActivity['name'] ?? 'غير محدد'}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
