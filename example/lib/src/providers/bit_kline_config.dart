// Copyright 2024 Andy.Zhao
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';

import 'package:example/src/config.dart';
import 'package:example/src/theme/export.dart';
import 'package:example/src/theme/flexi_theme.dart';
import 'package:example/src/utils/cache_util.dart';
import 'package:flexi_formatter/date_time.dart' show TimeUnit;
import 'package:flexi_kline/flexi_kline.dart' hide Overlay;
import 'package:flexi_kline/src/framework/draw/overlay.dart' as flexi_overlay;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class BaseBitFlexiKlineTheme implements IFlexiKlineTheme {
  abstract String key;

// 添加构造函数接收动态颜色
  BaseBitFlexiKlineTheme({
    required Color long,
    required Color short,
  })  : longColor = long,
        shortColor = short;

  @override
  final Color longColor;

  @override
  final Color shortColor;

  Color get long => longColor;
  Color get short => shortColor;

  Color get countDownTextBg;
  Color get latestPriceTextBg;
  Color get lastPriceTextBg;
  Color get gridLine;
  Color get crossColor => const Color(0xFFF6A701);
  Color get drawColor => Colors.blueAccent;
  Color get drawTextBg => Colors.blue;
  Color get drawTextColor => const Color(0xFFFFFFFF);
  Color get themeColor;
  Color get lastPriceTextColor;

  Color transparent = Colors.transparent;

  @override
  Color get latestPriceBg => latestPriceTextBg;

  @override
  Color get lastPriceBg => lastPriceTextBg;

  @override
  Color get countdownBg => countDownTextBg;

  @override
  Color get gridLineColor => gridLine;

  @override
  Color get crosshairColor => crossColor;

  @override
  Color get drawToolColor => drawColor;

  @override
  Color get lastPriceColor => lastPriceTextColor;

  double? _scale;
  double get scale => _scale ??= math.min(
        ScreenUtil().scaleWidth,
        ScreenUtil().scaleHeight,
      );

  double? _pixel;
  double get pixel {
    if (_pixel != null) return _pixel!;
    double? ratio = ScreenUtil().pixelRatio;
    ratio ??= PlatformDispatcher.instance.displays.first.devicePixelRatio;
    _pixel = 1 / ratio;
    return _pixel!;
  }

  double setDp(num size) => ScreenUtil().radius(size);

  double setSp(num fontSize) => ScreenUtil().setSp(fontSize);
}

class BitFlexiKlineLightTheme extends BaseBitFlexiKlineTheme {
  // 透传参数给父类
  BitFlexiKlineLightTheme({
    required super.long,
    required super.short,
  });

  @override
  String key = 'flexi_kline_config_key_bit-light';

  @override
  Color get chartBg => const Color(0xFFFBFDFF);

  @override
  Color get tooltipBg => const Color(0xFFFFFFFF);

  @override
  Color get countDownTextBg => const Color(0xFFF5F5F5);

  @override
  Color get crossTextBg => const Color(0xFF444444);

  @override
  Color get lastPriceTextBg => Colors.black54;

  @override
  Color get gridLine => const Color(0xFFB0B0B0);

  Color get markLine => const Color(0xFF949494);

  @override
  Color get themeColor => Colors.white;

  @override
  Color get textColor => const Color(0xFF111111);

  @override
  Color get ticksTextColor => const Color(0xFF949494);

  @override
  Color get lastPriceTextColor => crossTextColor;

  @override
  Color get crossTextColor => const Color(0xFFF9F8F8);

  @override
  Color get tooltipTextColor => textColor;

  @override
  Color get drawColor => Colors.blue;

  @override
  Color get drawTextColor => const Color(0xFF000000);

  Color get indraTodayAvgColor => const Color(0xffff9933);
  Color get indraTodayCloseColor => const Color(0xff4d78ff);

  @override
  Color get dragBg => const Color(0x33000000);

  @override
  Color get latestPriceTextBg => const Color(0xFF000000);

  @override
  Color get lineChartColor => const Color(0xFF2196F3);

  @override
  Color get markLineColor => textColor;
}

class BitFlexiKlineDarkTheme extends BaseBitFlexiKlineTheme {
  BitFlexiKlineDarkTheme({
    required super.long,
    required super.short,
  });

  @override
  String key = 'flexi_kline_config_key_bit-dark';

  Color get indraTodayAvgColor => const Color(0xffff9933);
  Color get indraTodayCloseColor => const Color(0xff4d78ff);

  @override
  Color get dragBg => const Color(0x33FFFFFF);

  @override
  Color get lineChartColor => const Color(0xFF64B5F6);

  @override
  Color get markLineColor => markLine;

  @override
  Color get chartBg => const Color(0xFF111111);

  @override
  Color get tooltipBg => const Color(0xFF16181A);

  @override
  Color get countDownTextBg => const Color(0xFF333333);

  @override
  Color get crossTextBg => const Color(0xFF404040);

  @override
  Color get gridLine => const Color(0xFF333333);

  Color get markLine => const Color(0xFFA0A0A0);

  @override
  Color get themeColor => Colors.black;

  @override
  Color get textColor => const Color(0xFFA0A0A0);

  @override
  Color get ticksTextColor => const Color(0xFF949494);

  @override
  Color get latestPriceTextBg => const Color(0xFF5F5F5F);

  @override
  Color get crossTextColor => const Color(0xFFFFFFFF);

  @override
  Color get tooltipTextColor => const Color(0xFF9D9DA1);

  @override
  Color get drawColor => Colors.lightBlue;

  @override
  Color get drawTextColor => const Color(0xFFFFFFFF);

  @override
  Color get lastPriceTextBg => latestPriceTextBg;

  @override
  Color get lastPriceTextColor => crossTextColor;
}

final bitFlexiKlineThemeProvider = StateProvider<BaseBitFlexiKlineTheme>((ref) {
  final brightness = ref.watch(
    themeProvider.select((theme) => theme.brightness),
  );

  // 2. 监听涨跌色变化 (假设 FKTheme 中有 longColor/shortColor)
  // 如果没有，你需要从你的设置 Provider 中 watch
  final theme = ref.watch(themeProvider);
  final longColor = theme.long; // 或者 ref.watch(settingsProvider).longColor
  final shortColor = theme.short;

  if (brightness == Brightness.dark) {
    // 每次颜色变化，都会创建新的 Theme 实例，触发界面刷新
    return BitFlexiKlineDarkTheme(long: longColor, short: shortColor);
  } else {
    return BitFlexiKlineLightTheme(long: longColor, short: shortColor);
  }
});

class BitFlexiKlineConfiguration
    with FlexiKlineConfigurationMixin
    implements IConfiguration, IIndicatorConfig {
  final WidgetRef ref;

  BitFlexiKlineConfiguration({required this.ref});
  // 加载指标JSON配置
  Future<Map<String, dynamic>?> _loadIndicatorJsonConfig() async {
    try {
      final String jsonString = await rootBundle
          .loadString('lib/flexi_kline_indicators_configuration.json');
      final Map<String, dynamic> config = jsonDecode(jsonString);
      defLogger.d('Successfully loaded indicator JSON config for bit theme');
      return config;
    } catch (err, stack) {
      defLogger.e('_loadIndicatorJsonConfig error: $err', stackTrace: stack);
      return null;
    }
  }

  // 加载主题JSON配置
  Future<Map<String, dynamic>?> _loadThemeJsonConfig() async {
    try {
      final String jsonString = await rootBundle
          .loadString('lib/default_flexi_kline_configuration.json');
      final Map<String, dynamic> config = jsonDecode(jsonString);
      defLogger.d('Successfully loaded theme JSON config for bit theme');
      return config;
    } catch (err, stack) {
      defLogger.e('_loadThemeJsonConfig error: $err', stackTrace: stack);
      return null;
    }
  }

  Size get initialMainSize {
    return Size(ScreenUtil().screenWidth, 300.r);
  }

  String get configKey => 'bit';

  FlexiKlineConfig getFlexiKlineConfig() {
    final cacheKey = 'flexi_kline_config_$configKey';
    try {
      final String? jsonStr = CacheUtil().get(cacheKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final json = jsonDecode(jsonStr);
        if (json is Map<String, dynamic>) {
          // 反序列化得到配置（此时包含旧的选中状态，且可能包含旧颜色）
          final origin = FlexiKlineConfig.fromJson(json);
          return generateFlexiKlineConfig(origin);
        }
      }
    } catch (err, stack) {
      defLogger.e('getFlexiKlineConfig error:$err', stackTrace: stack);
    }

    return generateFlexiKlineConfig();
  }

  void saveFlexiKlineConfig(FlexiKlineConfig config) {
    final jsonSrc = jsonEncode(config);
    // 使用统一的 key 保存
    final cacheKey = 'flexi_kline_config_$configKey';
    CacheUtil().setString(cacheKey, jsonSrc);
  }

  @override
  FlexiKlineConfig generateFlexiKlineConfig([FlexiKlineConfig? origin]) {
    // 异步尝试加载最新的JSON配置（如果需要）
    _generateConfigFromJsonAsync();
    // 从而实现：保留用户配置的结构/数值，但强制刷新颜色为当前主题色
    return super.generateFlexiKlineConfig(origin);
  }

  // 异步从JSON生成配置并更新缓存
  Future<void> _generateConfigFromJsonAsync() async {
    try {
      final themeJsonConfig = await _loadThemeJsonConfig();
      if (themeJsonConfig != null) {
        // 从JSON配置生成FlexiKlineConfig
        final config = _generateConfigFromJson(themeJsonConfig);
        if (config != null) {
          // 保存到缓存以供下次使用
          await setConfig('flexi_kline_config', config.toJson());
          defLogger.d(
              'Generated and cached FlexiKlineConfig from JSON for bit theme');
        }
      }
    } catch (e, stack) {
      defLogger.e('Error generating config from JSON for bit theme: $e',
          stackTrace: stack);
    }
  }

  // 从JSON配置生成FlexiKlineConfig
  FlexiKlineConfig? _generateConfigFromJson(Map<String, dynamic> jsonConfig) {
    try {
      // 解析 JSON 配置 (可能只包含部分结构性配置，且无颜色)
      final grid = _parseGridConfig(jsonConfig['grid']);
      final setting = _parseSettingConfig(jsonConfig['setting']);
      final gesture = _parseGestureConfig(jsonConfig['gesture']);
      final cross = _parseCrossConfig(jsonConfig['cross']);
      final draw = _parseDrawConfig(jsonConfig['draw']);
      final mainIndicator =
          _parseMainIndicatorConfig(jsonConfig['mainIndicator']);

      // 将解析出的配置传给 gen...Config 方法，让它与 Theme 默认值(主要是颜色)进行合并
      // 这样既保留了 JSON 中的结构设置，又能在 Theme 变化时正确应用颜色
      return FlexiKlineConfig(
        grid: genGridConfig(grid),
        setting: genSettingConfig(setting),
        gesture: genGestureConfig(gesture),
        cross: genCrossConfig(cross),
        draw: genDrawConfig(draw),
        mainIndicator: genMainIndicator(mainIndicator),
        sub: <IIndicatorKey>{}, // 副指标通过单独的方法管理
      );
    } catch (e, stack) {
      defLogger.e('Error parsing JSON config for bit theme: $e',
          stackTrace: stack);
      return null;
    }
  }

  @override
  CrossConfig genCrossConfig([CrossConfig? cross]) {
    return super.genCrossConfig(cross).copyWith(
          moveByCandleInBlank: true,
        );
  }

  @override
  GestureConfig genGestureConfig([GestureConfig? gesture]) {
    return super.genGestureConfig(gesture).copyWith(
          tolerance: ToleranceConfig(distanceFactor: 0.5),
          enableZoom: true,
          isManualSetZoomRect: false,
        );
  }

  @override
  SettingConfig genSettingConfig([SettingConfig? setting]) {
    final theme = ref.read(bitFlexiKlineThemeProvider);
    final config = super.genSettingConfig(setting);
    return super.genSettingConfig(setting).copyWith(
          candleFixedSpacing: null,
          candleSpacingParts: 7,
          loading: config.loading.copyWith(
            backgroundColor: theme.countDownTextBg,
            valueColor: theme.crossColor,
          ),
        );
  }

  IndicatorBuilder<TimeIndicator> get timeIndicatorBuilder {
    return (json) => TimeIndicator.fromJson(json).copyWith(
          position: DrawPosition.bottom,
        );
  }

  @override
  CandleBaseIndicator get candle {
    return CandleIndicator.fromJson(
      getConfig(candleIndicatorKey.id) ?? const {},
    );
  }

  @override
  TimeBaseIndicator get time {
    return timeIndicatorBuilder(
      getConfig(timeIndicatorKey.id) ?? const {},
    );
  }

  @override
  List<Indicator> get mainIndicators {
    return mainIndicatorBuilders.entries
        .map((entry) => entry.value(getConfig(entry.key.id) ?? const {}))
        .cast<Indicator>()
        .toList(growable: false);
  }

  @override
  List<Indicator> get subIndicators {
    return subIndicatorBuilders.entries
        .map((entry) => entry.value(getConfig(entry.key.id) ?? const {}))
        .cast<Indicator>()
        .toList(growable: false);
  }

  Iterable<flexi_overlay.Overlay> getOverlayListConfig(String instId) {
    try {
      final String? jsonStr = CacheUtil().get('overlay_$instId');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final json = jsonDecode(jsonStr);
        if (json is List) {
          return json
              .map((e) =>
                  flexi_overlay.Overlay.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (err, stack) {
      defLogger.e('getOverlayListConfig error:$err', stackTrace: stack);
    }
    return [];
  }

  // 时间周期配置缓存
  List<ITimeInterval>? _cachedTimeBarConfigs;

  /// 获取时间周期配置列表
  List<ITimeInterval> getTimeBarConfigs() {
    if (_cachedTimeBarConfigs != null) {
      return _cachedTimeBarConfigs!;
    }

    // 默认配置
    _cachedTimeBarConfigs = _getDefaultTimeBarConfigs();
    return _cachedTimeBarConfigs!;
  }

  List<ITimeInterval> _getDefaultTimeBarConfigs() {
    // 返回常用的时间周期列表
    return [
      const FlexiTimeInterval(1, TimeUnit.minute),
      const FlexiTimeInterval(3, TimeUnit.minute),
      const FlexiTimeInterval(5, TimeUnit.minute),
      const FlexiTimeInterval(15, TimeUnit.minute),
      const FlexiTimeInterval(30, TimeUnit.minute),
      const FlexiTimeInterval(1, TimeUnit.hour),
      const FlexiTimeInterval(2, TimeUnit.hour),
      const FlexiTimeInterval(4, TimeUnit.hour),
      const FlexiTimeInterval(6, TimeUnit.hour),
      const FlexiTimeInterval(12, TimeUnit.hour),
      const FlexiTimeInterval(1, TimeUnit.day),
      const FlexiTimeInterval(2, TimeUnit.day),
      const FlexiTimeInterval(3, TimeUnit.day),
      const FlexiTimeInterval(1, TimeUnit.week),
      const FlexiTimeInterval(1, TimeUnit.month),
      const FlexiTimeInterval(3, TimeUnit.month),
      // UTC 时间周期
      const FlexiTimeInterval(6, TimeUnit.hour),
      const FlexiTimeInterval(12, TimeUnit.hour),
      const FlexiTimeInterval(1, TimeUnit.day),
      const FlexiTimeInterval(1, TimeUnit.week),
      const FlexiTimeInterval(1, TimeUnit.month),
    ];
  }

  @override
  IFlexiKlineTheme get theme => ref.read(bitFlexiKlineThemeProvider);

  Iterable<flexi_overlay.Overlay> getDrawOverlayList(String instId) {
    try {
      final String? jsonStr = CacheUtil().get('draw_overlay_$instId');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final json = jsonDecode(jsonStr);
        if (json is List) {
          return json
              .map((e) =>
                  flexi_overlay.Overlay.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (err, stack) {
      defLogger.e('getDrawOverlayList error:$err', stackTrace: stack);
    }
    return [];
  }

  void saveDrawOverlayList(
      String instId, Iterable<flexi_overlay.Overlay> list) {
    try {
      final jsonList = list.map((overlay) => overlay.toJson()).toList();
      final jsonSrc = jsonEncode(jsonList);
      CacheUtil().setString('draw_overlay_$instId', jsonSrc);
    } catch (err, stack) {
      defLogger.e('saveDrawOverlayList error:$err', stackTrace: stack);
    }
  }

  @override
  MainPaintObjectIndicator genMainIndicator(
      [MainPaintObjectIndicator<Indicator>? mainIndicator]) {
    final theme = ref.read(bitFlexiKlineThemeProvider);
    // 确保TradeMarkIndicator始终存在（即使默认隐藏）
    final children = <IIndicatorKey>{};
    if (mainIndicator?.children != null) {
      children.addAll(mainIndicator!.children);
    }
    children.add(tradeMarkIndicatorKey);

    return MainPaintObjectIndicator(
      size: Size(ScreenUtil().screenWidth, 300.r),
      padding: theme.mainIndicatorPadding,
      drawBelowTipsArea: true,
      children: children,
    );
  }

  // 主指标配置缓存
  Map<IIndicatorKey, IndicatorBuilder>? _cachedMainIndicatorBuilders;

  Map<IIndicatorKey, IndicatorBuilder> get mainIndicatorBuilders {
    if (_cachedMainIndicatorBuilders != null) {
      return _withBusinessMainIndicatorBuilders(_cachedMainIndicatorBuilders!);
    }

    // 1. 优先从缓存读取
    final cachedConfig = getConfig('mainIndicatorBuilders');
    if (cachedConfig != null) {
      try {
        _cachedMainIndicatorBuilders =
            _buildMainIndicatorsFromConfig(cachedConfig);
        defLogger.d(
            '✅ Loaded ${_cachedMainIndicatorBuilders!.length} main indicators from cache (bit theme)');
      } catch (e) {
        defLogger.e('❌ Failed to build main indicators from cached config: $e');
        _cachedMainIndicatorBuilders = null;
      }
    }

    // 2. 缓存没有或失败，尝试从JSON加载
    if (_cachedMainIndicatorBuilders == null) {
      try {
        _cachedMainIndicatorBuilders = _loadMainIndicatorsFromJsonSync();
        // 如果是同步返回null，则启动异步加载
        if (_cachedMainIndicatorBuilders == null) {
          _loadMainIndicatorsFromJsonAsync();
        } else {
          defLogger.d(
              '✅ Loaded ${_cachedMainIndicatorBuilders!.length} main indicators from JSON (bit theme)');
        }
      } catch (e) {
        defLogger.e('❌ Failed to load main indicators from JSON: $e');
      }
    }

    // 3. 最后使用代码默认配置
    if (_cachedMainIndicatorBuilders == null) {
      _cachedMainIndicatorBuilders = getDefaultMainIndicatorBuilders();
      defLogger.d(
          '✅ Using ${_cachedMainIndicatorBuilders!.length} default main indicators (bit theme)');
    }

    return _withBusinessMainIndicatorBuilders(_cachedMainIndicatorBuilders!);
  }

  Map<IIndicatorKey, IndicatorBuilder> _withBusinessMainIndicatorBuilders(
    Map<IIndicatorKey, IndicatorBuilder> builders,
  ) {
    final result = Map<IIndicatorKey, IndicatorBuilder>.from(builders);
    final superBuilders = <IIndicatorKey, IndicatorBuilder>{};
    result.addAll(superBuilders);

    result[tradeMarkIndicatorKey] ??= (json) => _parseTradeMarkIndicator(json);

    return result;
  }

  Map<IIndicatorKey, IndicatorBuilder> getDefaultMainIndicatorBuilders() {
    // 用于重置：尝试从 JSON 加载默认配置
    try {
      _loadMainIndicatorsFromJsonAsync().then((_) {
        // 异步加载完成后，这里不做特别处理，因为界面通常会监听状态变化
        // 或者依赖下次 get 调用
      });
      // 这里的同步返回可能不包含最新 JSON 数据，只能尽力而为
      // 实际上，重置操作应该调用 _loadMainIndicatorsFromJsonAsync 然后刷新界面
      if (_cachedMainIndicatorBuilders != null) {
        return _cachedMainIndicatorBuilders!;
      }
    } catch (e) {
      defLogger.e('getDefaultMainIndicatorBuilders error: $e');
    }
    return _getDefaultMainIndicators();
  }

  // 同步从JSON加载主指标配置（用于初始化）
  Map<IIndicatorKey, IndicatorBuilder>? _loadMainIndicatorsFromJsonSync() {
    // Flutter中无法真正同步加载assets，这里返回null
    // 实际的JSON加载会在异步方法中完成
    defLogger
        .w('⚠️ Sync JSON loading not available for bit theme, will load async');
    return null;
  }

  // 异步从JSON加载主指标配置
  Future<void> _loadMainIndicatorsFromJsonAsync() async {
    try {
      final jsonConfig = await _loadIndicatorJsonConfig();
      if (jsonConfig != null && jsonConfig['mainIndicators'] != null) {
        final mainIndicators =
            jsonConfig['mainIndicators'] as Map<String, dynamic>;
        _cachedMainIndicatorBuilders =
            _buildMainIndicatorsFromConfig(mainIndicators);

        // ✅ 关键修复：保存完整的配置参数到缓存
        await setConfig('mainIndicatorBuilders', mainIndicators);

        defLogger.d(
            '✅ Async loaded ${_cachedMainIndicatorBuilders!.length} main indicators from JSON (bit theme)');
      } else {
        defLogger.w('⚠️ No mainIndicators found in JSON config (bit theme)');
      }
    } catch (e, stack) {
      defLogger.e('❌ Error loading main indicators from JSON (bit theme): $e',
          stackTrace: stack);
    }
  }

  // 副指标配置缓存
  Map<IIndicatorKey, IndicatorBuilder>? _cachedSubIndicatorBuilders;

  Map<IIndicatorKey, IndicatorBuilder> get subIndicatorBuilders {
    if (_cachedSubIndicatorBuilders != null) {
      // 合并super指标并返回
      final result = Map<IIndicatorKey, IndicatorBuilder>.from(
          _cachedSubIndicatorBuilders!);
      final superBuilders = <IIndicatorKey, IndicatorBuilder>{};
      result.addAll(superBuilders);
      return result;
    }

    // 三级配置加载策略：缓存 → JSON → 代码默认值

    // 1. 优先从缓存读取
    final cachedConfig = getConfig('subIndicatorBuilders');
    if (cachedConfig != null) {
      try {
        _cachedSubIndicatorBuilders =
            _buildSubIndicatorsFromConfig(cachedConfig);
        defLogger.d(
            '✅ Loaded ${_cachedSubIndicatorBuilders!.length} sub indicators from cache (bit theme)');
      } catch (e) {
        defLogger.e('❌ Failed to build sub indicators from cached config: $e');
        _cachedSubIndicatorBuilders = null;
      }
    }

    // 2. 缓存没有或失败，尝试从JSON加载
    if (_cachedSubIndicatorBuilders == null) {
      try {
        _cachedSubIndicatorBuilders = _loadSubIndicatorsFromJsonSync();
        // 如果是同步返回null，则启动异步加载
        if (_cachedSubIndicatorBuilders == null) {
          _loadSubIndicatorsFromJsonAsync();
        } else {
          defLogger.d(
              '✅ Loaded ${_cachedSubIndicatorBuilders!.length} sub indicators from JSON (bit theme)');
        }
      } catch (e) {
        defLogger.e('❌ Failed to load sub indicators from JSON: $e');
      }
    }

    // 3. 最后使用代码默认配置
    if (_cachedSubIndicatorBuilders == null) {
      _cachedSubIndicatorBuilders = getDefaultSubIndicators();
      defLogger.d(
          '✅ Using ${_cachedSubIndicatorBuilders!.length} default sub indicators (bit theme)');
    }

    // 4. 合并代码默认配置中缓存缺失的指标（确保新增指标始终可用）
    final defaults = getDefaultSubIndicators();
    for (final entry in defaults.entries) {
      _cachedSubIndicatorBuilders!.putIfAbsent(entry.key, () => entry.value);
    }

    // 合并super指标并返回
    final result =
        Map<IIndicatorKey, IndicatorBuilder>.from(_cachedSubIndicatorBuilders!);
    final superBuilders = <IIndicatorKey, IndicatorBuilder>{};
    result.addAll(superBuilders);
    return result;
  }

  Map<IIndicatorKey, IndicatorBuilder> getDefaultSubIndicatorBuilders() {
    // 用于重置
    try {
      _loadSubIndicatorsFromJsonAsync();
      if (_cachedSubIndicatorBuilders != null) {
        return _cachedSubIndicatorBuilders!;
      }
    } catch (e) {
      defLogger.e('getDefaultSubIndicatorBuilders error: $e');
    }
    return getDefaultSubIndicators();
  }

  // 同步从JSON加载副指标配置（用于初始化）
  Map<IIndicatorKey, IndicatorBuilder>? _loadSubIndicatorsFromJsonSync() {
    // Flutter中无法真正同步加载assets，这里返回null
    defLogger
        .w('⚠️ Sync JSON loading not available for bit theme, will load async');
    return null;
  }

  // 异步从JSON加载副指标配置
  Future<void> _loadSubIndicatorsFromJsonAsync() async {
    try {
      final jsonConfig = await _loadIndicatorJsonConfig();
      if (jsonConfig != null && jsonConfig['subIndicators'] != null) {
        final subIndicators =
            jsonConfig['subIndicators'] as Map<String, dynamic>;
        _cachedSubIndicatorBuilders =
            _buildSubIndicatorsFromConfig(subIndicators);

        // ✅ 关键修复：保存完整的配置参数到缓存
        await setConfig('subIndicatorBuilders', subIndicators);

        defLogger.d(
            '✅ Async loaded ${_cachedSubIndicatorBuilders!.length} sub indicators from JSON (bit theme)');
      } else {
        defLogger.w('⚠️ No subIndicators found in JSON config (bit theme)');
      }
    } catch (e, stack) {
      defLogger.e('❌ Error loading sub indicators from JSON (bit theme): $e',
          stackTrace: stack);
    }
  }

  // drawObjectBuilders 使用基类的默认实现

  @override
  Map<String, dynamic>? getConfig(String key) {
    try {
      final String? jsonStr = CacheUtil().get('bit_indicator_config_$key');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        dynamic json = jsonDecode(jsonStr);

        // 防御性编程：处理可能的双重序列化问题
        // 有时候缓存中可能存的是 JSON 字符串的字符串
        if (json is String) {
          try {
            json = jsonDecode(json);
          } catch (e) {
            // ignore: 尝试再次 decode 失败，保持原样
          }
        }

        if (json is Map<String, dynamic>) {
          return json;
        } else {
          defLogger.w(
              'getConfig: expected Map<String, dynamic> but got ${json.runtimeType} for key $key');
        }
      }
    } catch (err, stack) {
      defLogger.e('getConfig error for key $key: $err', stackTrace: stack);
    }
    return null;
  }

  @override
  Future<bool> setConfig(String key, Map<String, dynamic> value) async {
    try {
      final jsonStr = jsonEncode(value);
      await CacheUtil().setString('bit_indicator_config_$key', jsonStr);

      // 清除缓存，强制重新加载
      if (key == 'mainIndicatorBuilders') {
        _cachedMainIndicatorBuilders = null;
      } else if (key == 'subIndicatorBuilders') {
        _cachedSubIndicatorBuilders = null;
      } else if (key == 'intervalConfigs') {
        _cachedTimeBarConfigs = null;
      }

      return true;
    } catch (err, stack) {
      defLogger.e('setConfig error for key $key: $err', stackTrace: stack);
      return false;
    }
  }

  // 从配置构建主指标
  Map<IIndicatorKey, IndicatorBuilder> _buildMainIndicatorsFromConfig(
      Map<String, dynamic> config) {
    final Map<IIndicatorKey, IndicatorBuilder> builders = {};
    final theme = ref.read(bitFlexiKlineThemeProvider);

    // 解析配置并创建对应的指标构建器
    config.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        builders[ComputedIndicatorKey(key)] =
            _createIndicatorBuilderFromConfig(value, theme);
      }
    });

    return builders;
  }

  // 从配置构建副指标
  Map<IIndicatorKey, IndicatorBuilder> _buildSubIndicatorsFromConfig(
      Map<String, dynamic> config) {
    final Map<IIndicatorKey, IndicatorBuilder> builders = {};
    final theme = ref.read(bitFlexiKlineThemeProvider);

    // 解析配置并创建对应的指标构建器
    config.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        builders[ComputedIndicatorKey(key)] =
            _createIndicatorBuilderFromConfig(value, theme);
      }
    });

    return builders;
  }

  @override
  Map<IDrawType, DrawObjectBuilder> get drawObjectBuilders {
    return {
      // 趋势线
      const FlexiDrawType('trendLine', 2): (overlay, config) =>
          TrendLineDrawObject(overlay, config),

      // 趋势角度线
      const FlexiDrawType('trendAngle', 2): (overlay, config) =>
          TrendAngleDrawObject(overlay, config),

      // 十字线
      const FlexiDrawType('crossLine', 1): (overlay, config) =>
          CrossLineDrawObject(overlay, config),

      // 水平线
      const FlexiDrawType('horizontalLine', 1): (overlay, config) =>
          HorizontalLineDrawObject(overlay, config),

      // 水平射线
      const FlexiDrawType('horizontalRayLine', 2): (overlay, config) =>
          HorizontalRayLineDrawObject(overlay, config),

      // 水平趋势线
      const FlexiDrawType('horizontalTrendLine', 2): (overlay, config) =>
          HorizontalTrendLineDrawObject(overlay, config),

      // 垂直线
      const FlexiDrawType('verticalLine', 1): (overlay, config) =>
          VerticalLineDrawObject(overlay, config),

      // 延长趋势线
      const FlexiDrawType('extendedTrendLine', 2): (overlay, config) =>
          ExtendedTrendLineDrawObject(overlay, config),

      // 箭头线
      const FlexiDrawType('arrowLine', 2): (overlay, config) =>
          ArrowLineDrawObject(overlay, config),

      // 射线
      const FlexiDrawType('rayLine', 2): (overlay, config) =>
          RayLineDrawObject(overlay, config),

      // 价格线
      const FlexiDrawType('priceLine', 1): (overlay, config) =>
          PriceLineDrawObject(overlay, config),

      // 平行通道
      const FlexiDrawType('parallelChannel', 3): (overlay, config) =>
          ParalleChannelDrawObject(overlay, config),

      // 矩形
      const FlexiDrawType('rectangle', 2): (overlay, config) =>
          RectangleDrawObject(overlay, config),

      // 斐波那契回调
      const FlexiDrawType('fibRetracement', 2): (overlay, config) =>
          FibRetracementDrawObject(overlay, config),

      // 斐波那契扩展
      const FlexiDrawType('fibExpansion', 3): (overlay, config) =>
          FibExpansionDrawObject(overlay, config),

      // 斐波那契扇形
      const FlexiDrawType('fibFans', 2): (overlay, config) =>
          FibFansDrawObject(overlay, config),
    };
  }

  // 便民方法：设置主指标配置
  Future<bool> setMainIndicatorConfig(
      Map<String, Map<String, dynamic>> config) {
    return setConfig('mainIndicatorBuilders', config);
  }

  // 便民方法：设置副指标配置
  Future<bool> setSubIndicatorConfig(Map<String, Map<String, dynamic>> config) {
    return setConfig('subIndicatorBuilders', config);
  }
}

extension BitFlexiKlineConfigurationParse on BitFlexiKlineConfiguration {
  // JSON配置解析方法
  GridConfig? _parseGridConfig(dynamic config) {
    if (config is Map<String, dynamic>) {
      try {
        return GridConfig.fromJson(config);
      } catch (e) {
        defLogger.e('Failed to parse GridConfig from JSON (bit theme): $e');
      }
    }
    return null;
  }

  SettingConfig? _parseSettingConfig(dynamic config) {
    if (config is Map<String, dynamic>) {
      try {
        return SettingConfig.fromJson(config);
      } catch (e) {
        defLogger.e('Failed to parse SettingConfig from JSON (bit theme): $e');
      }
    }
    return null;
  }

  GestureConfig? _parseGestureConfig(dynamic config) {
    if (config is Map<String, dynamic>) {
      try {
        return GestureConfig.fromJson(config);
      } catch (e) {
        defLogger.e('Failed to parse GestureConfig from JSON (bit theme): $e');
      }
    }
    return null;
  }

  CrossConfig? _parseCrossConfig(dynamic config) {
    if (config is Map<String, dynamic>) {
      try {
        return CrossConfig.fromJson(config);
      } catch (e) {
        defLogger.e('Failed to parse CrossConfig from JSON (bit theme): $e');
      }
    }
    return null;
  }

  DrawConfig? _parseDrawConfig(dynamic config) {
    if (config is Map<String, dynamic>) {
      try {
        return DrawConfig.fromJson(config);
      } catch (e) {
        defLogger.e('Failed to parse DrawConfig from JSON (bit theme): $e');
      }
    }
    return null;
  }

  MainPaintObjectIndicator? _parseMainIndicatorConfig(dynamic config) {
    if (config is Map<String, dynamic>) {
      try {
        return MainPaintObjectIndicator.fromJson(config);
      } catch (e) {
        defLogger.e(
            'Failed to parse MainPaintObjectIndicator from JSON (bit theme): $e');
      }
    }
    return null;
  }

  /// 解析交易标记指标配置
  TradeMarkIndicator _parseTradeMarkIndicator(Map<String, dynamic>? config) {
    if (config == null) {
      return TradeMarkIndicator(calcParam: const TradeMarkParam());
    }

    TradeMarkParam? calcParam;
    if (config.containsKey('calcParam')) {
      try {
        calcParam = TradeMarkParam.fromJson(
          config['calcParam'] as Map<String, dynamic>,
        );
      } catch (e) {
        defLogger.w('Failed to parse TradeMarkParam: $e');
      }
    }

    return TradeMarkIndicator(calcParam: calcParam ?? const TradeMarkParam());
  }

  // 根据配置创建指标构建器
  IndicatorBuilder _createIndicatorBuilderFromConfig(
      Map<String, dynamic> config, BaseBitFlexiKlineTheme theme) {
    final type = config['type'] as String?;

    switch (type) {
      // ✅ 已优化的指标类型
      case 'volMa':
        return (setting) => VolMaIndicator(
              height: _indicatorHeight(setting, config, 100.r),
              calcParam:
                  _parseVolMaParam(_indicatorCalcParam(setting, config)) ??
                      const VolMaParam(lines: []),
              tipsPadding: theme.tipsPadding,
            );

      case 'volume':
        return (setting) => VolumeIndicator(
              height: _indicatorHeight(setting, config, 100.r),
              calcParam:
                  _parseVolumeParam(_indicatorCalcParam(setting, config)) ??
                      const VolumeParam(),
              tipsPadding: theme.tipsPadding,
              tickCount: _indicatorTickCount(setting, config, 5),
            );

      // 📈 主指标类型
      case 'ma':
        return (setting) => MAIndicator(
              height: _indicatorHeight(setting, config, 300.r),
              padding: theme.mainIndicatorPadding,
              calcParam: _parseMaParam(_indicatorCalcParam(setting, config)) ??
                  const MaParam(),
              tipsPadding: theme.tipsPadding,
            );

      case 'boll':
        return (setting) => BOLLIndicator(
              height: _indicatorHeight(setting, config, 300.r),
              padding: theme.mainIndicatorPadding,
              calcParam:
                  _parseBOLLParam(_indicatorCalcParam(setting, config)) ??
                      const BOLLParam(),
              tipsPadding: theme.tipsPadding,
            );

      case 'ema':
        return (setting) => EMAIndicator(
              height: _indicatorHeight(setting, config, 300.r),
              padding: theme.mainIndicatorPadding,
              calcParam: _parseEMAParam(_indicatorCalcParam(setting, config)) ??
                  const EmaParam(),
              tipsPadding: theme.tipsPadding,
            );

      case 'sar':
        return (setting) => SARIndicator(
              height: _indicatorHeight(setting, config, 300.r),
              padding: theme.mainIndicatorPadding,
              calcParam: _parseSARParam(_indicatorCalcParam(setting, config)) ??
                  const SARParam(),
              tipsPadding: theme.tipsPadding,
              tickCount: _indicatorTickCount(setting, config, 5),
            );

      case 'avl':
        return (setting) => AVLIndicator(
              height: _indicatorHeight(setting, config, 300.r),
              padding: theme.mainIndicatorPadding,
              calcParam: _parseAVLParam(_indicatorCalcParam(setting, config)) ??
                  const AVLParam(),
              tipsPadding: theme.tipsPadding,
              tickCount: _indicatorTickCount(setting, config, 5),
            );

      // 📊 副指标类型
      case 'rsi':
        return (setting) => RSIIndicator(
              height: _indicatorHeight(setting, config, 100.r),
              calcParam: _parseRSIParam(_indicatorCalcParam(setting, config)) ??
                  const RsiParam(lines: []),
              tipsPadding: theme.tipsPadding,
              tickCount: _indicatorTickCount(setting, config, 5),
            );

      case 'kdj':
        return (setting) => KDJIndicator(
              height: _indicatorHeight(setting, config, 100.r),
              calcParam: _parseKDJParam(_indicatorCalcParam(setting, config)) ??
                  const KDJParam(),
              tipsPadding: theme.tipsPadding,
              tickCount: _indicatorTickCount(setting, config, 5),
            );

      case 'cci':
        return (setting) => CCIIndicator(
              height: _indicatorHeight(setting, config, 100.r),
              calcParam: _parseCCIParam(_indicatorCalcParam(setting, config)) ??
                  const CCIParam(
                    lines: [
                      CCILineConfig(
                        id: 'cci14',
                        enabled: true,
                        period: 14,
                        color: Color(0xFF00BCD4),
                        width: 1.0,
                      ),
                    ],
                  ),
              tipsPadding: theme.tipsPadding,
              tickCount: _indicatorTickCount(setting, config, 5),
            );

      case 'obv':
        return (setting) => OBVIndicator(
              height: _indicatorHeight(setting, config, 100.r),
              calcParam: _parseOBVParam(_indicatorCalcParam(setting, config)) ??
                  const OBVParam(),
              tipsPadding: theme.tipsPadding,
              tickCount: _indicatorTickCount(setting, config, 5),
            );

      case 'macd':
        return (setting) => MACDIndicator(
              height: _indicatorHeight(setting, config, 120.r),
              calcParam:
                  _parseMACDParam(_indicatorCalcParam(setting, config)) ??
                      const MACDParam(s: 12, l: 26, m: 9),
              difTips: _parseTipsConfig(config['difTips']) ??
                  TipsConfig(
                    label: 'DIF: ',
                    style: TextStyle(
                        color: Colors.blue, fontSize: 12.sp, height: 1.2),
                  ),
              deaTips: _parseTipsConfig(config['deaTips']) ??
                  TipsConfig(
                    label: 'DEA: ',
                    style: TextStyle(
                        color: Colors.red, fontSize: 12.sp, height: 1.2),
                  ),
              macdTips: _parseTipsConfig(config['macdTips']) ??
                  TipsConfig(
                    label: 'MACD: ',
                    style: TextStyle(
                        color: Colors.green, fontSize: 12.sp, height: 1.2),
                  ),
              tipsPadding: theme.tipsPadding,
              tickCount: _indicatorTickCount(setting, config, 5),
            );

      default:
        // 对于不支持的指标类型，记录日志并返回一个默认的Volume指标
        defLogger.w(
            'Unsupported indicator type: $type, fallback to volume indicator (bit theme)');
        return (setting) => VolumeIndicator(
              height: 100.r,
              calcParam: const VolumeParam(),
              tipsPadding: theme.tipsPadding,
              tickCount: 5,
            );
    }
  }

  dynamic _indicatorCalcParam(
    Map<String, dynamic> setting,
    Map<String, dynamic> config,
  ) {
    return setting['calcParam'] ??
        setting['config'] ??
        config['calcParam'] ??
        config['config'];
  }

  double _indicatorHeight(
    Map<String, dynamic> setting,
    Map<String, dynamic> config,
    double fallback,
  ) {
    return (setting['height'] as num?)?.toDouble() ??
        (config['height'] as num?)?.toDouble() ??
        fallback;
  }

  int _indicatorTickCount(
    Map<String, dynamic> setting,
    Map<String, dynamic> config,
    int fallback,
  ) {
    return (setting['tickCount'] as num?)?.toInt() ??
        (config['tickCount'] as num?)?.toInt() ??
        fallback;
  }

  Map<String, dynamic>? _asJsonMap(dynamic config) {
    if (config is Map<String, dynamic>) return config;
    if (config is Map) return Map<String, dynamic>.from(config);
    return null;
  }

  T? _parseParam<T>(
    dynamic config,
    T Function(Map<String, dynamic> json) fromJson, [
    T Function(Map<String, dynamic> json)? fromJsonConfig,
  ]) {
    final json = _asJsonMap(config);
    if (json == null) return null;

    try {
      return fromJson(json);
    } catch (_) {
      if (fromJsonConfig == null) return null;
    }

    try {
      return fromJsonConfig(json);
    } catch (_) {
      return null;
    }
  }

  // 解析参数的辅助方法 - 只保留已优化指标的解析方法
  // 解析 VolMaParam
  VolMaParam? _parseVolMaParam(dynamic config) {
    return _parseParam(config, VolMaParam.fromJson, VolMaParam.fromJsonConfig);
  }

  // 解析 VolumeParam
  VolumeParam? _parseVolumeParam(dynamic config) {
    return _parseParam(
        config, VolumeParam.fromJson, VolumeParam.fromJsonConfig);
  }

  // 解析 MaParam
  MaParam? _parseMaParam(dynamic config) {
    return _parseParam(config, MaParam.fromJson, MaParam.fromJsonConfig);
  }

  // 解析 BOLLParam
  BOLLParam? _parseBOLLParam(dynamic config) {
    return _parseParam(config, BOLLParam.fromJson, BOLLParam.fromJsonConfig);
  }

  // 解析 EMAParam
  EmaParam? _parseEMAParam(dynamic config) {
    return _parseParam(config, EmaParam.fromJson, EmaParam.fromJsonConfig);
  }

  // 解析 SARParam
  SARParam? _parseSARParam(dynamic config) {
    return _parseParam(config, SARParam.fromJson, SARParam.fromJsonConfig);
  }

  // 解析 AVLParam
  AVLParam? _parseAVLParam(dynamic config) {
    return _parseParam(config, AVLParam.fromJson, AVLParam.fromJsonConfig);
  }

  // 解析 RSIParam
  RsiParam? _parseRSIParam(dynamic config) {
    return _parseParam(config, RsiParam.fromJson, RsiParam.fromJsonConfig);
  }

  // 解析 KDJParam
  KDJParam? _parseKDJParam(dynamic config) {
    return _parseParam(config, KDJParam.fromJson, KDJParam.fromJsonConfig);
  }

  // 解析 CCIParam
  CCIParam? _parseCCIParam(dynamic config) {
    return _parseParam(config, CCIParam.fromJson);
  }

  // 解析 OBVParam
  OBVParam? _parseOBVParam(dynamic config) {
    return _parseParam(config, OBVParam.fromJson);
  }

  // 解析 MACDParam
  MACDParam? _parseMACDParam(dynamic config) {
    return _parseParam(config, MACDParam.fromJson, MACDParam.fromJsonConfig);
  }

  // 解析 TipsConfig
  TipsConfig? _parseTipsConfig(dynamic tips) {
    if (tips is Map<String, dynamic>) {
      return TipsConfig(
        label: tips['label'] as String? ?? '',
        style: _parseTextStyle(tips['style']),
      );
    }
    return null;
  }

  // 解析 TextStyle
  TextStyle _parseTextStyle(dynamic style) {
    if (style is Map<String, dynamic>) {
      return TextStyle(
        color: _parseColor(style['color']) ?? Colors.black,
        fontSize: (style['fontSize'] as num?)?.toDouble() ?? 12.sp,
        fontWeight: _parseFontWeight(style['fontWeight']),
        height: (style['height'] as num?)?.toDouble() ?? 1.2,
      );
    }
    return TextStyle(fontSize: 12.sp);
  }

  // 解析 Color
  Color? _parseColor(dynamic color) {
    if (color is int) {
      return Color(color);
    } else if (color is String) {
      return Color(int.parse(color.replaceFirst('#', '0xff')));
    }
    return null;
  }

  // 解析 FontWeight
  FontWeight? _parseFontWeight(dynamic weight) {
    if (weight is int) {
      switch (weight) {
        case 100:
          return FontWeight.w100;
        case 200:
          return FontWeight.w200;
        case 300:
          return FontWeight.w300;
        case 400:
          return FontWeight.w400;
        case 500:
          return FontWeight.w500;
        case 600:
          return FontWeight.w600;
        case 700:
          return FontWeight.w700;
        case 800:
          return FontWeight.w800;
        case 900:
          return FontWeight.w900;
      }
    } else if (weight is String) {
      switch (weight.toLowerCase()) {
        case 'normal':
          return FontWeight.normal;
        case 'bold':
          return FontWeight.bold;
      }
    }
    return null;
  }
}

extension BitFlexiKlineConfigurationDefault on BitFlexiKlineConfiguration {
  /// ======================= 指标默认 ====================
  Map<IIndicatorKey, IndicatorBuilder> _getDefaultMainIndicators() {
    return {
      // MA 移动平均线 - 主图指标
      const ComputedIndicatorKey('ma'): (json) => MAIndicator(
            height: _indicatorHeight(
                json, const <String, dynamic>{}, theme.mainIndicatorHeight),
            padding: theme.mainIndicatorPadding,
            calcParam: _parseMaParam(json['calcParam'] ?? json['config']) ??
                const MaParam(
                  lines: [
                    MALineConfig(
                      id: 'ma5',
                      enabled: true,
                      period: 5,
                      color: Color(0xFF2196F3), // 蓝色
                      width: 1.0,
                    ),
                    MALineConfig(
                      id: 'ma10',
                      enabled: true,
                      period: 10,
                      color: Color(0xFFF44336), // 红色
                      width: 1.0,
                    ),
                    MALineConfig(
                      id: 'ma20',
                      enabled: true,
                      period: 20,
                      color: Color(0xFF4CAF50), // 绿色
                      width: 1.0,
                    ),
                  ],
                ),
            tipsPadding: theme.tipsPadding,
          ),

      // BOLL 布林带 - 主图指标
      const ComputedIndicatorKey('boll'): (json) => BOLLIndicator(
            height: _indicatorHeight(
                json, const <String, dynamic>{}, theme.mainIndicatorHeight),
            padding: theme.mainIndicatorPadding,
            calcParam: _parseBOLLParam(json['calcParam'] ?? json['config']) ??
                const BOLLParam(), // 使用默认参数
            tipsPadding: theme.tipsPadding,
          ),

      // EMA 指数移动平均线 - 主图指标
      const ComputedIndicatorKey('ema'): (json) => EMAIndicator(
            height: _indicatorHeight(
                json, const <String, dynamic>{}, theme.mainIndicatorHeight),
            padding: theme.mainIndicatorPadding,
            calcParam: _parseEMAParam(json['calcParam'] ?? json['config']) ??
                const EmaParam(
                  lines: [
                    EMALineConfig(
                      id: 'ema7',
                      enabled: true,
                      period: 7,
                      color: Color(0xFF00BCD4), // 青色
                      width: 1.0,
                    ),
                    EMALineConfig(
                      id: 'ema25',
                      enabled: true,
                      period: 25,
                      color: Color(0xFFE91E63), // 粉色
                      width: 1.0,
                    ),
                    EMALineConfig(
                      id: 'ema99',
                      enabled: true,
                      period: 99,
                      color: Color(0xFFE91E63), // 粉色
                      width: 1.0,
                    ),
                  ],
                ),
            tipsPadding: theme.tipsPadding,
          ),

      // SAR 抛物线指标 - 主图指标
      const ComputedIndicatorKey('sar'): (json) => SARIndicator(
            height: _indicatorHeight(
                json, const <String, dynamic>{}, theme.mainIndicatorHeight),
            padding: theme.mainIndicatorPadding,
            calcParam: _parseSARParam(json['calcParam'] ?? json['config']) ??
                const SARParam(), // 使用默认参数
            tipsPadding: theme.tipsPadding,
            tickCount: _indicatorTickCount(json, const <String, dynamic>{}, 5),
          ),

      // AVL 威廉分形指标 - 主图指标
      const ComputedIndicatorKey('avl'): (json) => AVLIndicator(
            height: _indicatorHeight(
                json, const <String, dynamic>{}, theme.mainIndicatorHeight),
            padding: theme.mainIndicatorPadding,
            calcParam: _parseAVLParam(json['calcParam'] ?? json['config']) ??
                const AVLParam(), // 使用默认参数
            tipsPadding: theme.tipsPadding,
            tickCount: _indicatorTickCount(json, const <String, dynamic>{}, 5),
          ),

      tradeMarkIndicatorKey: (json) => _parseTradeMarkIndicator(json),
    };
  }

  Map<IIndicatorKey, IndicatorBuilder> getDefaultSubIndicators() {
    return {
      // VOL_MA 成交量移动平均线 - 副图指标
      const ComputedIndicatorKey('volMa'): (json) => VolMaIndicator(
            height: _indicatorHeight(
                json, const <String, dynamic>{}, theme.subIndicatorHeight),
            calcParam: _parseVolMaParam(json['calcParam'] ?? json['config']) ??
                const VolMaParam(
                  lines: [
                    VolMALineConfig(
                      id: 'volMa5',
                      enabled: true,
                      period: 5,
                      color: Color(0xFF2196F3), // 蓝色
                      width: 1.0,
                      opacity: 0.8,
                    ),
                    VolMALineConfig(
                      id: 'volMa10',
                      enabled: true,
                      period: 10,
                      color: Color(0xFFF44336), // 红色
                      width: 1.0,
                      opacity: 0.8,
                    ),
                  ],
                ),
            tipsPadding: theme.tipsPadding,
          ),

      // VOLUME 成交量 - 副图指标
      const ComputedIndicatorKey('volume'): (json) => VolumeIndicator(
            height: _indicatorHeight(
                json, const <String, dynamic>{}, theme.subIndicatorHeight),
            calcParam: _parseVolumeParam(json['calcParam'] ?? json['config']) ??
                const VolumeParam(), // 使用默认参数
            tipsPadding: theme.tipsPadding,
            tickCount: _indicatorTickCount(json, const <String, dynamic>{}, 5),
          ),

      // RSI 相对强弱指标 - 副图指标
      const ComputedIndicatorKey('rsi'): (json) => RSIIndicator(
            height: _indicatorHeight(
                json, const <String, dynamic>{}, theme.subIndicatorHeight),
            calcParam: _parseRSIParam(json['calcParam'] ?? json['config']) ??
                const RsiParam(
                  lines: [
                    RSILineConfig(
                      id: 'rsi14',
                      enabled: true,
                      period: 14,
                      color: Color(0xFF9C27B0), // 紫色
                      width: 1.0,
                    ),
                  ],
                ),
            tipsPadding: theme.tipsPadding,
            tickCount: _indicatorTickCount(json, const <String, dynamic>{}, 5),
          ),

      // KDJ 随机指标 - 副图指标
      const ComputedIndicatorKey('kdj'): (json) => KDJIndicator(
            height: _indicatorHeight(
                json, const <String, dynamic>{}, theme.subIndicatorHeight),
            calcParam: _parseKDJParam(json['calcParam'] ?? json['config']) ??
                const KDJParam(),
            tipsPadding: theme.tipsPadding,
            tickCount: _indicatorTickCount(json, const <String, dynamic>{}, 5),
          ),

      // CCI 顺势指标 - 副图指标
      const ComputedIndicatorKey('cci'): (json) => CCIIndicator(
            height: _indicatorHeight(
                json, const <String, dynamic>{}, theme.subIndicatorHeight),
            calcParam: _parseCCIParam(json['calcParam'] ?? json['config']) ??
                const CCIParam(
                  lines: [
                    CCILineConfig(
                      id: 'cci14',
                      enabled: true,
                      period: 14,
                      color: Color(0xFF00BCD4),
                      width: 1.0,
                    ),
                  ],
                ),
            tipsPadding: theme.tipsPadding,
            tickCount: _indicatorTickCount(json, const <String, dynamic>{}, 5),
          ),

      // MACD 指标 - 副图指标
      const ComputedIndicatorKey('macd'): (json) => MACDIndicator(
            height: _indicatorHeight(json, const <String, dynamic>{},
                theme.subIndicatorHeight * 1.2),
            calcParam: _parseMACDParam(json['calcParam'] ?? json['config']) ??
                const MACDParam(
                  s: 12, // 短期周期
                  l: 26, // 长期周期
                  m: 9, // 信号周期
                ),
            difTips: const TipsConfig(
              label: 'DIF: ',
              style: TextStyle(
                color: Color(0xFF2196F3),
                fontSize: 12,
                height: 1.2,
              ),
            ),
            deaTips: const TipsConfig(
              label: 'DEA: ',
              style: TextStyle(
                color: Color(0xFFF44336),
                fontSize: 12,
                height: 1.2,
              ),
            ),
            macdTips: const TipsConfig(
              label: 'MACD: ',
              style: TextStyle(
                color: Color(0xFF4CAF50),
                fontSize: 12,
                height: 1.2,
              ),
            ),
            tipsPadding: theme.tipsPadding,
            tickCount: _indicatorTickCount(json, const <String, dynamic>{}, 5),
          ),

      // OBV 能量潮指标 - 副图指标
      const ComputedIndicatorKey('obv'): (json) => OBVIndicator(
            height: _indicatorHeight(
                json, const <String, dynamic>{}, theme.subIndicatorHeight),
            calcParam: _parseOBVParam(json['calcParam'] ?? json['config']) ??
                const OBVParam(
                  obvLine: OBVLineConfig(
                    enabled: true,
                    color: Color(0xFFFF9800),
                    width: 1.0,
                  ),
                ),
            tipsPadding: theme.tipsPadding,
            tickCount: _indicatorTickCount(json, const <String, dynamic>{}, 5),
          ),
    };
  }
}
