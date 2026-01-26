import 'package:auto_route/auto_route.dart';
import 'package:takween/routes/router.gr.dart';
import 'package:takween/services/api_client.dart';
import 'package:takween/services/storage.dart';

class UserTypeGuard extends AutoRouteGuard {
  final ApiClient _apiClient = ApiClient();

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    try {
      final userData = await _apiClient.get<Map<String, dynamic>>(
        '/user',
        fromJson: (json) => json,
      );

      await Storage.setJson('user', userData);

      final userType =
          userData['type'] as String? ?? userData['role'] as String?;

      if (userType == 'admin') {
        resolver.redirect(const AdminHomeRoute());
      } else if (userType == 'parent') {
        resolver.redirect(const ParentHomeRoute());
      } else {
        resolver.next(true);
      }
    } catch (e) {
      resolver.next(true);
    }
  }
}
