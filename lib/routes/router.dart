import 'package:auto_route/auto_route.dart';
import 'package:takween/routes/auth_guard.dart';
import 'package:takween/routes/user_type_guard.dart';
import 'package:takween/routes/guest_guard.dart';
import 'package:takween/routes/router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: LoadingRoute.page, initial: true, guards: [UserTypeGuard()]),
    AutoRoute(page: RegisterPhoneRoute.page, guards: [GuestGuard()]),
    AutoRoute(page: VerifyPhoneRoute.page, guards: [GuestGuard()]),
    AutoRoute(page: ParentHomeRoute.page),
    AutoRoute(page: AdminHomeRoute.page),
    AutoRoute(page: EntitySelectRoute.page),
    AutoRoute(page: ActivitySelectRoute.page),
  ];

  @override
  List<AutoRouteGuard> get guards => [AuthGuard()];
}
