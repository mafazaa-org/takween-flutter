// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i19;
import 'package:flutter/material.dart' as _i20;
import 'package:takween/screens/admin/activity_management.dart' as _i1;
import 'package:takween/screens/admin/activity_select.dart' as _i2;
import 'package:takween/screens/admin/admin_home.dart' as _i3;
import 'package:takween/screens/admin/attendance_management.dart' as _i4;
import 'package:takween/screens/admin/classroom_management.dart' as _i5;
import 'package:takween/screens/admin/communication_hub.dart' as _i6;
import 'package:takween/screens/admin/content_management.dart' as _i7;
import 'package:takween/screens/admin/daily_attendance.dart' as _i8;
import 'package:takween/screens/admin/entity_select.dart' as _i9;
import 'package:takween/screens/admin/evaluation_management.dart' as _i10;
import 'package:takween/screens/admin/homework_management.dart' as _i12;
import 'package:takween/screens/admin/report_generation.dart' as _i16;
import 'package:takween/screens/admin/sitting_management.dart' as _i17;
import 'package:takween/screens/home.dart' as _i11;
import 'package:takween/screens/loading.dart' as _i13;
import 'package:takween/screens/parent_home.dart' as _i14;
import 'package:takween/screens/register_phone.dart' as _i15;
import 'package:takween/screens/verify_phone.dart' as _i18;

/// generated route for
/// [_i1.ActivityManagementPage]
class ActivityManagementRoute extends _i19.PageRouteInfo<void> {
  const ActivityManagementRoute({List<_i19.PageRouteInfo>? children})
    : super(ActivityManagementRoute.name, initialChildren: children);

  static const String name = 'ActivityManagementRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i1.ActivityManagementPage();
    },
  );
}

/// generated route for
/// [_i2.ActivitySelectPage]
class ActivitySelectRoute extends _i19.PageRouteInfo<void> {
  const ActivitySelectRoute({List<_i19.PageRouteInfo>? children})
    : super(ActivitySelectRoute.name, initialChildren: children);

  static const String name = 'ActivitySelectRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i2.ActivitySelectPage();
    },
  );
}

/// generated route for
/// [_i3.AdminHomePage]
class AdminHomeRoute extends _i19.PageRouteInfo<void> {
  const AdminHomeRoute({List<_i19.PageRouteInfo>? children})
    : super(AdminHomeRoute.name, initialChildren: children);

  static const String name = 'AdminHomeRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i3.AdminHomePage();
    },
  );
}

/// generated route for
/// [_i4.AttendanceManagementPage]
class AttendanceManagementRoute
    extends _i19.PageRouteInfo<AttendanceManagementRouteArgs> {
  AttendanceManagementRoute({
    _i20.Key? key,
    String? activityId,
    List<_i19.PageRouteInfo>? children,
  }) : super(
         AttendanceManagementRoute.name,
         args: AttendanceManagementRouteArgs(key: key, activityId: activityId),
         initialChildren: children,
       );

  static const String name = 'AttendanceManagementRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AttendanceManagementRouteArgs>(
        orElse: () => const AttendanceManagementRouteArgs(),
      );
      return _i4.AttendanceManagementPage(
        key: args.key,
        activityId: args.activityId,
      );
    },
  );
}

class AttendanceManagementRouteArgs {
  const AttendanceManagementRouteArgs({this.key, this.activityId});

  final _i20.Key? key;

  final String? activityId;

  @override
  String toString() {
    return 'AttendanceManagementRouteArgs{key: $key, activityId: $activityId}';
  }
}

/// generated route for
/// [_i5.ClassroomManagementPage]
class ClassroomManagementRoute
    extends _i19.PageRouteInfo<ClassroomManagementRouteArgs> {
  ClassroomManagementRoute({
    _i20.Key? key,
    String? activityId,
    List<_i19.PageRouteInfo>? children,
  }) : super(
         ClassroomManagementRoute.name,
         args: ClassroomManagementRouteArgs(key: key, activityId: activityId),
         initialChildren: children,
       );

  static const String name = 'ClassroomManagementRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ClassroomManagementRouteArgs>(
        orElse: () => const ClassroomManagementRouteArgs(),
      );
      return _i5.ClassroomManagementPage(
        key: args.key,
        activityId: args.activityId,
      );
    },
  );
}

class ClassroomManagementRouteArgs {
  const ClassroomManagementRouteArgs({this.key, this.activityId});

  final _i20.Key? key;

  final String? activityId;

  @override
  String toString() {
    return 'ClassroomManagementRouteArgs{key: $key, activityId: $activityId}';
  }
}

/// generated route for
/// [_i6.CommunicationHubPage]
class CommunicationHubRoute
    extends _i19.PageRouteInfo<CommunicationHubRouteArgs> {
  CommunicationHubRoute({
    _i20.Key? key,
    String? activityId,
    List<_i19.PageRouteInfo>? children,
  }) : super(
         CommunicationHubRoute.name,
         args: CommunicationHubRouteArgs(key: key, activityId: activityId),
         initialChildren: children,
       );

  static const String name = 'CommunicationHubRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CommunicationHubRouteArgs>(
        orElse: () => const CommunicationHubRouteArgs(),
      );
      return _i6.CommunicationHubPage(
        key: args.key,
        activityId: args.activityId,
      );
    },
  );
}

class CommunicationHubRouteArgs {
  const CommunicationHubRouteArgs({this.key, this.activityId});

  final _i20.Key? key;

  final String? activityId;

  @override
  String toString() {
    return 'CommunicationHubRouteArgs{key: $key, activityId: $activityId}';
  }
}

/// generated route for
/// [_i7.ContentManagementPage]
class ContentManagementRoute
    extends _i19.PageRouteInfo<ContentManagementRouteArgs> {
  ContentManagementRoute({
    _i20.Key? key,
    String? activityId,
    List<_i19.PageRouteInfo>? children,
  }) : super(
         ContentManagementRoute.name,
         args: ContentManagementRouteArgs(key: key, activityId: activityId),
         initialChildren: children,
       );

  static const String name = 'ContentManagementRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ContentManagementRouteArgs>(
        orElse: () => const ContentManagementRouteArgs(),
      );
      return _i7.ContentManagementPage(
        key: args.key,
        activityId: args.activityId,
      );
    },
  );
}

class ContentManagementRouteArgs {
  const ContentManagementRouteArgs({this.key, this.activityId});

  final _i20.Key? key;

  final String? activityId;

  @override
  String toString() {
    return 'ContentManagementRouteArgs{key: $key, activityId: $activityId}';
  }
}

/// generated route for
/// [_i8.DailyAttendancePage]
class DailyAttendanceRoute
    extends _i19.PageRouteInfo<DailyAttendanceRouteArgs> {
  DailyAttendanceRoute({
    _i20.Key? key,
    required List<Map<String, dynamic>> sittings,
    required List<Map<String, dynamic>> students,
    List<_i19.PageRouteInfo>? children,
  }) : super(
         DailyAttendanceRoute.name,
         args: DailyAttendanceRouteArgs(
           key: key,
           sittings: sittings,
           students: students,
         ),
         initialChildren: children,
       );

  static const String name = 'DailyAttendanceRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DailyAttendanceRouteArgs>();
      return _i8.DailyAttendancePage(
        key: args.key,
        sittings: args.sittings,
        students: args.students,
      );
    },
  );
}

class DailyAttendanceRouteArgs {
  const DailyAttendanceRouteArgs({
    this.key,
    required this.sittings,
    required this.students,
  });

  final _i20.Key? key;

  final List<Map<String, dynamic>> sittings;

  final List<Map<String, dynamic>> students;

  @override
  String toString() {
    return 'DailyAttendanceRouteArgs{key: $key, sittings: $sittings, students: $students}';
  }
}

/// generated route for
/// [_i9.EntitySelectPage]
class EntitySelectRoute extends _i19.PageRouteInfo<void> {
  const EntitySelectRoute({List<_i19.PageRouteInfo>? children})
    : super(EntitySelectRoute.name, initialChildren: children);

  static const String name = 'EntitySelectRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i9.EntitySelectPage();
    },
  );
}

/// generated route for
/// [_i10.EvaluationManagementPage]
class EvaluationManagementRoute
    extends _i19.PageRouteInfo<EvaluationManagementRouteArgs> {
  EvaluationManagementRoute({
    _i20.Key? key,
    String? activityId,
    List<_i19.PageRouteInfo>? children,
  }) : super(
         EvaluationManagementRoute.name,
         args: EvaluationManagementRouteArgs(key: key, activityId: activityId),
         initialChildren: children,
       );

  static const String name = 'EvaluationManagementRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EvaluationManagementRouteArgs>(
        orElse: () => const EvaluationManagementRouteArgs(),
      );
      return _i10.EvaluationManagementPage(
        key: args.key,
        activityId: args.activityId,
      );
    },
  );
}

class EvaluationManagementRouteArgs {
  const EvaluationManagementRouteArgs({this.key, this.activityId});

  final _i20.Key? key;

  final String? activityId;

  @override
  String toString() {
    return 'EvaluationManagementRouteArgs{key: $key, activityId: $activityId}';
  }
}

/// generated route for
/// [_i11.HomePage]
class HomeRoute extends _i19.PageRouteInfo<void> {
  const HomeRoute({List<_i19.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i11.HomePage();
    },
  );
}

/// generated route for
/// [_i12.HomeworkManagementPage]
class HomeworkManagementRoute
    extends _i19.PageRouteInfo<HomeworkManagementRouteArgs> {
  HomeworkManagementRoute({
    _i20.Key? key,
    String? activityId,
    List<_i19.PageRouteInfo>? children,
  }) : super(
         HomeworkManagementRoute.name,
         args: HomeworkManagementRouteArgs(key: key, activityId: activityId),
         initialChildren: children,
       );

  static const String name = 'HomeworkManagementRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<HomeworkManagementRouteArgs>(
        orElse: () => const HomeworkManagementRouteArgs(),
      );
      return _i12.HomeworkManagementPage(
        key: args.key,
        activityId: args.activityId,
      );
    },
  );
}

class HomeworkManagementRouteArgs {
  const HomeworkManagementRouteArgs({this.key, this.activityId});

  final _i20.Key? key;

  final String? activityId;

  @override
  String toString() {
    return 'HomeworkManagementRouteArgs{key: $key, activityId: $activityId}';
  }
}

/// generated route for
/// [_i13.LoadingPage]
class LoadingRoute extends _i19.PageRouteInfo<void> {
  const LoadingRoute({List<_i19.PageRouteInfo>? children})
    : super(LoadingRoute.name, initialChildren: children);

  static const String name = 'LoadingRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i13.LoadingPage();
    },
  );
}

/// generated route for
/// [_i14.ParentHomePage]
class ParentHomeRoute extends _i19.PageRouteInfo<void> {
  const ParentHomeRoute({List<_i19.PageRouteInfo>? children})
    : super(ParentHomeRoute.name, initialChildren: children);

  static const String name = 'ParentHomeRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i14.ParentHomePage();
    },
  );
}

/// generated route for
/// [_i15.RegisterPhonePage]
class RegisterPhoneRoute extends _i19.PageRouteInfo<void> {
  const RegisterPhoneRoute({List<_i19.PageRouteInfo>? children})
    : super(RegisterPhoneRoute.name, initialChildren: children);

  static const String name = 'RegisterPhoneRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      return const _i15.RegisterPhonePage();
    },
  );
}

/// generated route for
/// [_i16.ReportGenerationPage]
class ReportGenerationRoute
    extends _i19.PageRouteInfo<ReportGenerationRouteArgs> {
  ReportGenerationRoute({
    _i20.Key? key,
    required String reportType,
    String? entityId,
    String? activityId,
    List<_i19.PageRouteInfo>? children,
  }) : super(
         ReportGenerationRoute.name,
         args: ReportGenerationRouteArgs(
           key: key,
           reportType: reportType,
           entityId: entityId,
           activityId: activityId,
         ),
         initialChildren: children,
       );

  static const String name = 'ReportGenerationRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ReportGenerationRouteArgs>();
      return _i16.ReportGenerationPage(
        key: args.key,
        reportType: args.reportType,
        entityId: args.entityId,
        activityId: args.activityId,
      );
    },
  );
}

class ReportGenerationRouteArgs {
  const ReportGenerationRouteArgs({
    this.key,
    required this.reportType,
    this.entityId,
    this.activityId,
  });

  final _i20.Key? key;

  final String reportType;

  final String? entityId;

  final String? activityId;

  @override
  String toString() {
    return 'ReportGenerationRouteArgs{key: $key, reportType: $reportType, entityId: $entityId, activityId: $activityId}';
  }
}

/// generated route for
/// [_i17.SittingManagementPage]
class SittingManagementRoute
    extends _i19.PageRouteInfo<SittingManagementRouteArgs> {
  SittingManagementRoute({
    _i20.Key? key,
    String? classroomId,
    List<_i19.PageRouteInfo>? children,
  }) : super(
         SittingManagementRoute.name,
         args: SittingManagementRouteArgs(key: key, classroomId: classroomId),
         initialChildren: children,
       );

  static const String name = 'SittingManagementRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SittingManagementRouteArgs>(
        orElse: () => const SittingManagementRouteArgs(),
      );
      return _i17.SittingManagementPage(
        key: args.key,
        classroomId: args.classroomId,
      );
    },
  );
}

class SittingManagementRouteArgs {
  const SittingManagementRouteArgs({this.key, this.classroomId});

  final _i20.Key? key;

  final String? classroomId;

  @override
  String toString() {
    return 'SittingManagementRouteArgs{key: $key, classroomId: $classroomId}';
  }
}

/// generated route for
/// [_i18.VerifyPhonePage]
class VerifyPhoneRoute extends _i19.PageRouteInfo<VerifyPhoneRouteArgs> {
  VerifyPhoneRoute({
    _i20.Key? key,
    required String phone,
    List<_i19.PageRouteInfo>? children,
  }) : super(
         VerifyPhoneRoute.name,
         args: VerifyPhoneRouteArgs(key: key, phone: phone),
         initialChildren: children,
       );

  static const String name = 'VerifyPhoneRoute';

  static _i19.PageInfo page = _i19.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VerifyPhoneRouteArgs>();
      return _i18.VerifyPhonePage(key: args.key, phone: args.phone);
    },
  );
}

class VerifyPhoneRouteArgs {
  const VerifyPhoneRouteArgs({this.key, required this.phone});

  final _i20.Key? key;

  final String phone;

  @override
  String toString() {
    return 'VerifyPhoneRouteArgs{key: $key, phone: $phone}';
  }
}
