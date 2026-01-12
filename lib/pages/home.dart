import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/storage_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? _selectedEntity;
  Map<String, dynamic>? _selectedActivity;

  @override
  void initState() {
    super.initState();
    _loadSelections();
  }

  void _loadSelections() {
    setState(() {
      _selectedEntity = StorageService.getSelectedEntity();
      _selectedActivity = StorageService.getSelectedActivity();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الرئيسية'),
        backgroundColor: AppColors.navyBlue,
        foregroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'مرحباً بك',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              if (_selectedEntity != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الكيان المختار',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.gray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedEntity!['name'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navyBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (_selectedActivity != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'النشاط المختار',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.gray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedActivity!['name'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navyBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (_selectedEntity == null && _selectedActivity == null) ...[
                const Spacer(),
                Icon(Icons.home_outlined, size: 64, color: AppColors.gray),
                const SizedBox(height: 16),
                Text(
                  'لا توجد بيانات مختارة',
                  style: TextStyle(fontSize: 18, color: AppColors.gray),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
