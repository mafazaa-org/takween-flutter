import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../utils/api_client.dart';
import '../models/activity.dart';
import '../services/storage_service.dart';
import 'home.dart';

class ActivitySelectPage extends StatefulWidget {
  final int entityId;

  const ActivitySelectPage({
    super.key,
    required this.entityId,
  });

  @override
  State<ActivitySelectPage> createState() => _ActivitySelectPageState();
}

class _ActivitySelectPageState extends State<ActivitySelectPage> {
  final ApiClient _apiClient = ApiClient();
  List<Activity> _activities = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiClient.get<List<dynamic>>('/activity');
      setState(() {
        _activities = response.map((json) => Activity.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleActivityTap(Activity activity) async {
    await StorageService.saveSelectedActivity(activity.id, activity.name);
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    }
  }

  void _handleAddActivity() {
    // TODO: Navigate to create activity page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ميزة إضافة نشاط قريباً')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر النشاط'),
        backgroundColor: AppColors.navyBlue,
        foregroundColor: AppColors.white,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleAddActivity,
        backgroundColor: AppColors.green,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.green),
            const SizedBox(height: 16),
            Text(
              'جاري التحميل...',
              style: TextStyle(fontSize: 16, color: AppColors.gray),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'حدث خطأ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(fontSize: 14, color: AppColors.gray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchActivities,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_activities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: AppColors.gray),
              const SizedBox(height: 16),
              Text(
                'لا توجد أنشطة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'لم يتم العثور على أي أنشطة متاحة',
                style: TextStyle(fontSize: 14, color: AppColors.gray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchActivities,
                icon: const Icon(Icons.refresh),
                label: const Text('تحديث'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchActivities,
      color: AppColors.green,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _activities.length,
        itemBuilder: (context, index) {
          final activity = _activities[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(
                activity.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.green,
                size: 20,
              ),
              onTap: () => _handleActivityTap(activity),
            ),
          );
        },
      ),
    );
  }
}
