import 'package:auto_route/auto_route.dart';
import 'package:takween/routes/router.gr.dart';
import 'package:takween/services/storage.dart';

class GuestGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final accessToken = Storage.getString('accessToken');
    final refreshToken = Storage.getString('refreshToken');

    if (accessToken != null && refreshToken != null) {
      resolver.redirect(const LoadingRoute());
    } else {
      resolver.next(true);
    }
  }
}
