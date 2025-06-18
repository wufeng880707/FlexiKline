import 'package:example/core/network/http/dio_provider.dart';
import 'package:example/core/providers/theme_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_ume_kit_perf_plus/flutter_ume_kit_perf_plus.dart';
import 'package:flutter_ume_kit_ui_plus/flutter_ume_kit_ui_plus.dart';
import 'package:flutter_ume_plus/flutter_ume_plus.dart';

import 'core/providers/app_locale_provider.dart';
import 'core/providers/app_router_provider.dart';
import 'features/test/app_dio_inspector.dart';
import 'features/theme/flexi_theme.dart';
import 'lang/generated/l10n.dart';

class LaunchWidget extends ConsumerStatefulWidget {
  const LaunchWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LaunchWidgetState();
}

class _LaunchWidgetState extends ConsumerState<LaunchWidget> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addObserver(this);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   initUserInfo();
    //
    //   /// 监听闪屏动画执行完成
    //   _setupSplashListener();
    // });

    if (kDebugMode) {
      PluginManager.instance
        ..register(
          AppDioInspector(key: const ValueKey('OKX'), dio: ref.read(dioProvider), showName: 'OKX'),
        )
        ..register(Performance())
        ..register(const MemoryInfoPage())
        ..register(const WidgetInfoInspector())
        ..register(const WidgetDetailInspector())
        ..register(const ColorSucker())
        ..register(AlignRuler())
        ..register(const ColorPicker()) // New feature
        ..register(const TouchIndicator());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      return UMEWidget(child: buildApp(context));
    } else {
      return buildApp(context);
    }
  }

  Widget buildApp(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      fontSizeResolver: FontSizeResolvers.radius,
      builder: (context, child) {
        return MaterialApp.router(
          restorationScopeId: 'flexiKlineApp',
          routerConfig: ref.watch(routerProvider),
          builder: FlutterSmartDialog.init(),
          debugShowCheckedModeBanner: false,
          // 本地化支持
          locale: ref.watch(localeProvider),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocaleNotifier.supportedLocales,
          // 主题设置
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ref.watch(themeProvider),
          themeAnimationCurve: Curves.linear,
          themeAnimationDuration: const Duration(milliseconds: 500),
          // themeAnimationStyle: ActionDispatcher,
          // scrollBehavior: NoThumbScrollBehavior().copyWith(scrollbars: false),
        );
      },
    );
  }
}
