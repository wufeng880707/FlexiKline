import 'dart:async';
import 'dart:ui';

import 'package:example/core/providers/app_provider_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/app_locale_provider.dart';
import 'core/utils/cache_util.dart';
import 'init.dart';
import 'launch_widget.dart';
// Future<void> _initializeApp({required AppConfig appConfig}) async {

Future<void> _initializeApp() async {
  final manager = InitializationManager();
  // if (appConfig.env == AppEnv.dev || appConfig.env == AppEnv.qa) {
  //   manager.addTask(task: () => setAppProxy(), name: 'AppProxy');
  // }

  // manager.addTask(
  //   task: () async {
  //     await FirebaseUtil.initializeApp(appConfig);
  //   },
  //   retryCount: 0,
  //   name: 'firebase',
  // );

  manager.addTask(
    task: () async {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    },
    name: 'orientation',
  );

  // 执行所有任务并处理结果
  final results = await manager.execute();

  // // 根据结果决定是否降级
  // if (results['firebase']?.isSuccess == true) {
  // } else {
  //   // 切换为本地日志记录
  // }
}

void runAppByConfig() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        statusBarColor: Colors.transparent,
      ),
    );
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      // FirebaseUtil.handleError(details.exception, details.stack);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      // FirebaseUtil.handleError(error, stack);
      return true;
    };

    await CacheUtil.init();
    _initializeApp();
    runApp(
      ProviderScope(
        overrides: [],
        observers: [AppProviderObserver()],
        child: Builder(
          builder: (context) {
            return LaunchWidget();
          },
        ),
      ),
    );
  }, handleError);
}

void handleError(dynamic error, StackTrace? stackTrace) {
  debugPrint("捕获到全局异常: $error");
  debugPrint(stackTrace.toString());
  // if (!_isFirebaseInitialized()) {
  //   return;
  // }
  // FirebaseCrashlytics.instance.recordError(error, stackTrace);
}
