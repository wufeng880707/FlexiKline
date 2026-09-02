import 'package:example/src/i18n.dart';
import 'package:example/src/theme/theme_manager.dart';
import 'package:example/src/utils/cache_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// example 最小冒烟测试。
///
/// 完整 MyApp 启动链依赖 OKX/Polygon 网络与全局 HttpClient 初始化，
/// 不适合在 widget 测试中拉起；此处验证 app 运行所需的基础设施
/// （SharedPreferences 缓存 / i18n / 主题管理器）可正常初始化。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUpAll(() async {
    await CacheUtil().init();
  });

  test('I18nManager initializes with supported locales', () {
    final manager = I18nManager();
    final locale = manager.init();
    expect(locale, isA<Locale>());
    expect(manager.supportedLocales, isNotEmpty);
    expect(manager.localizationsDelegates, isNotEmpty);
  });

  test('ThemeManager initializes with a valid theme mode', () {
    final manager = ThemeManager();
    final mode = manager.init();
    expect(mode, isA<ThemeMode>());
  });
}
