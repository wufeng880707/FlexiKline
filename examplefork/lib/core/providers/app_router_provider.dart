import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/klines/presentation/screens/kline_home_screen.dart';

/// 设置 全局的导航器键（GlobalKey）
final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'KlineDemo',
);

extension StateExt on State {
  void exit<T extends Object?>([T? result]) {
    if (mounted) {
      context.pop(result);
    } else {
      GoRouter.of(globalNavigatorKey.currentContext!).pop(result);
    }
  }
}

extension GlobalKeyExt on GlobalKey<NavigatorState> {
  ProviderContainer get ref {
    final context = currentContext!;
    final ref = ProviderScope.containerOf(context);
    return ref;
  }
}

final routerProvider = Provider.autoDispose<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: globalNavigatorKey,
    observers: [],
    initialLocation: '/',
    restorationScopeId: 'router',
    routes: routeList,
    debugLogDiagnostics: kDebugMode,
  );
  ref.onDispose(router.dispose);
  return router;
});

final List<RouteBase> routeList = <RouteBase>[
  GoRoute(
    name: 'home',
    path: '/',
    pageBuilder: (context, state) {
      return const MaterialPage<void>(restorationId: 'homeKline', child: KlineHomeScreen());
    },
  ),
  // GoRoute(
  //   name: 'accurateKline',
  //   path: '/accurate_kline',
  //   pageBuilder: (context, state) {
  //     return const MaterialPage<void>(
  //       restorationId: 'accurateKline',
  //       child: AccurateKlineDemoPage(),
  //     );
  //   },
  // ),
  // GoRoute(
  //   name: 'indicatorSetting',
  //   path: '/indicator_setting',
  //   pageBuilder: (context, state) {
  //     return const MaterialPage<void>(
  //       restorationId: 'indicatorSetting',
  //       child: IndicatorSettingPage(),
  //     );
  //   },
  // ),
  // GoRoute(
  //   name: 'klineSetting',
  //   path: '/kline_setting',
  //   pageBuilder: (context, state) {
  //     final controller = state.extra as FlexiKlineController;
  //     return MaterialPage<void>(
  //       restorationId: 'klineSetting',
  //       child: KlineSettingPage(controller: controller),
  //     );
  //   },
  // ),
];
