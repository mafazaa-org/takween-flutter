// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i9;
import 'package:flutter/material.dart' as _i10;
import 'package:takween/screens/admin/activity_select.dart' as _i1;
import 'package:takween/screens/admin/admin_home.dart' as _i2;
import 'package:takween/screens/admin/entity_select.dart' as _i3;
import 'package:takween/screens/home.dart' as _i4;
import 'package:takween/screens/loading.dart' as _i5;
import 'package:takween/screens/parent_home.dart' as _i6;
import 'package:takween/screens/register_phone.dart' as _i7;
import 'package:takween/screens/verify_phone.dart' as _i8;

/// generated route for
/// [_i1.ActivitySelectPage]
class ActivitySelectRoute extends _i9.PageRouteInfo<void> {
  const ActivitySelectRoute({List<_i9.PageRouteInfo>? children})
    : super(ActivitySelectRoute.name, initialChildren: children);

  static const String name = 'ActivitySelectRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i1.ActivitySelectPage();
    },
  );
}

/// generated route for
/// [_i2.AdminHomePage]
class AdminHomeRoute extends _i9.PageRouteInfo<void> {
  const AdminHomeRoute({List<_i9.PageRouteInfo>? children})
    : super(AdminHomeRoute.name, initialChildren: children);

  static const String name = 'AdminHomeRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i2.AdminHomePage();
    },
  );
}

/// generated route for
/// [_i3.EntitySelectPage]
class EntitySelectRoute extends _i9.PageRouteInfo<void> {
  const EntitySelectRoute({List<_i9.PageRouteInfo>? children})
    : super(EntitySelectRoute.name, initialChildren: children);

  static const String name = 'EntitySelectRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i3.EntitySelectPage();
    },
  );
}

/// generated route for
/// [_i4.HomePage]
class HomeRoute extends _i9.PageRouteInfo<void> {
  const HomeRoute({List<_i9.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i4.HomePage();
    },
  );
}

/// generated route for
/// [_i5.LoadingPage]
class LoadingRoute extends _i9.PageRouteInfo<void> {
  const LoadingRoute({List<_i9.PageRouteInfo>? children})
    : super(LoadingRoute.name, initialChildren: children);

  static const String name = 'LoadingRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i5.LoadingPage();
    },
  );
}

/// generated route for
/// [_i6.ParentHomePage]
class ParentHomeRoute extends _i9.PageRouteInfo<void> {
  const ParentHomeRoute({List<_i9.PageRouteInfo>? children})
    : super(ParentHomeRoute.name, initialChildren: children);

  static const String name = 'ParentHomeRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i6.ParentHomePage();
    },
  );
}

/// generated route for
/// [_i7.RegisterPhonePage]
class RegisterPhoneRoute extends _i9.PageRouteInfo<void> {
  const RegisterPhoneRoute({List<_i9.PageRouteInfo>? children})
    : super(RegisterPhoneRoute.name, initialChildren: children);

  static const String name = 'RegisterPhoneRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i7.RegisterPhonePage();
    },
  );
}

/// generated route for
/// [_i8.VerifyPhonePage]
class VerifyPhoneRoute extends _i9.PageRouteInfo<VerifyPhoneRouteArgs> {
  VerifyPhoneRoute({
    _i10.Key? key,
    required String phone,
    List<_i9.PageRouteInfo>? children,
  }) : super(
         VerifyPhoneRoute.name,
         args: VerifyPhoneRouteArgs(key: key, phone: phone),
         initialChildren: children,
       );

  static const String name = 'VerifyPhoneRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VerifyPhoneRouteArgs>();
      return _i8.VerifyPhonePage(key: args.key, phone: args.phone);
    },
  );
}

class VerifyPhoneRouteArgs {
  const VerifyPhoneRouteArgs({this.key, required this.phone});

  final _i10.Key? key;

  final String phone;

  @override
  String toString() {
    return 'VerifyPhoneRouteArgs{key: $key, phone: $phone}';
  }
}
