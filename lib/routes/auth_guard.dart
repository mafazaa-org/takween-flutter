import 'package:auto_route/auto_route.dart';
import 'package:takween/routes/router.gr.dart';
import 'package:takween/services/storage.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    // the navigation is paused until resolver.next() is called with either
    // true to resume/continue navigation or false to abort navigation

    final routeName = resolver.routeName;

    if (routeName == RegisterPhoneRoute.name ||
        routeName == VerifyPhoneRoute.name) {
      resolver.next(true);
      return;
    }

    final accessToken = Storage.getString('accessToken');
    final refreshToken = Storage.getString('refreshToken');

    if (accessToken == null || refreshToken == null) {
      resolver.redirect(RegisterPhoneRoute());
    } else {
      resolver.next(true);
    }

    return;
  }
}
