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

import 'package:example/generated/l10n.dart';
import 'package:flexi_kline/flexi_kline.dart' hide Overlay;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../config.dart';
import '../theme/export.dart';
import '../utils/cache_util.dart';

Map<TooltipLabel, String> tooltipLables() {
  return {
    TooltipLabel.time: S.current.tooltipTime,
    TooltipLabel.open: S.current.tooltipOpen,
    TooltipLabel.high: S.current.tooltipHigh,
    TooltipLabel.low: S.current.tooltipLow,
    TooltipLabel.close: S.current.tooltipClose,
    TooltipLabel.chg: S.current.tooltipChg,
    TooltipLabel.chgRate: S.current.tooltipChgRate,
    TooltipLabel.range: S.current.tooltipRange,
    TooltipLabel.amount: S.current.tooltipAmount,
    TooltipLabel.turnover: S.current.tooltipTurnover,
  };
}

class DefaultFlexiKlineTheme extends BaseFlexiKlineTheme with FlexiKlineThemeTextStyle {
  final FKTheme theme;

  DefaultFlexiKlineTheme({
    required this.theme,
  }) : super(
          indraTodayAvgColor: theme.indraTodayAvgColor,
          indraTodayCloseColor: theme.indraTodayCloseColor,
          dragBg: theme.translucentBg,
          latestPriceTextBg: theme.translucentBg,
          lineChartColor: const Color(0xFF2196F3),
          markLineColor: theme.t1,
          long: theme.long,
          short: theme.short,
          chartBg: theme.pageBg,
          tooltipBg: theme.markBg,
          countDownTextBg: theme.markBg,
          crossTextBg: theme.lightBg,
          transparent: theme.transparent,
          lastPriceTextBg: theme.translucentBg,
          gridLine: theme.gridLine,
          crossColor: theme.t1,
          drawColor: Colors.blueAccent,
          themeColor: theme.themeColor,
          textColor: theme.t1,
          ticksTextColor: theme.t2,
          lastPriceTextColor: theme.t1,
          crossTextColor: theme.themeColor,
          tooltipTextColor: theme.t1,
        );

  String get key {
    return 'flexi_kline_config_key-${theme.brightness.name}';
  }

  double? _scale;
  @override
  double get scale => _scale ??= math.min(
        ScreenUtil().scaleWidth,
        ScreenUtil().scaleHeight,
      );

  double? _pixel;
  @override
  double get pixel {
    if (_pixel != null) return _pixel!;
    double? ratio = ScreenUtil().pixelRatio;
    ratio ??= PlatformDispatcher.instance.displays.first.devicePixelRatio;
    _pixel = 1 / ratio;
    return _pixel!;
  }

  @override
  double setDp(num size) => ScreenUtil().radius(size);

  @override
  double setSp(num fontSize) => ScreenUtil().setSp(fontSize);
}

final defaultKlineThemeProvider = StateProvider<DefaultFlexiKlineTheme>((ref) {
  return ref.watch(
    themeProvider.select((theme) => DefaultFlexiKlineTheme(theme: theme)),
  );
});

class DefaultFlexiKlineConfiguration with FlexiKlineThemeConfigurationMixin {
  final WidgetRef ref;

  DefaultFlexiKlineConfiguration({required this.ref});

  // ========== 基础配置 ==========

  @override
  IFlexiKlineTheme get theme => ref.read(defaultKlineThemeProvider);

  @override
  String get configKey => 'default';

  // ========== JSON配置加载 ==========

  Future<Map<String, dynamic>?> loadIndicatorJsonConfig() async {
    try {
      final String jsonString =
          await rootBundle.loadString('lib/flexi_kline_indicators_configuration.json');
      final Map<String, dynamic> config = jsonDecode(jsonString);
      defLogger.d('Successfully loaded indicator JSON config');
      return config;
    } catch (err, stack) {
      defLogger.e('loadIndicatorJsonConfig error: $err', stackTrace: stack);
      return null;
    }
  }

  Future<Map<String, dynamic>?> loadThemeJsonConfig() async {
    try {
      final String jsonString =
          await rootBundle.loadString('example/lib/default_flexi_kline_configuration.json');
      final Map<String, dynamic> config = jsonDecode(jsonString);
      defLogger.d('Successfully loaded theme JSON config');
      return config;
    } catch (err, stack) {
      defLogger.e('loadThemeJsonConfig error: $err', stackTrace: stack);
      return null;
    }
  }

  IndicatorBuilder createIndicatorBuilderFromConfig(
    Map<String, dynamic> config,
    IFlexiKlineTheme theme,
  ) {
    return _createIndicatorBuilderFromConfig(config, theme as DefaultFlexiKlineTheme);
  }

  // ========== 默认指标配置 ==========

  @override
  Map<IIndicatorKey, IndicatorBuilder> get mainIndicatorBuilders {
    // 三层配置加载策略: 缓存 -> JSON -> 代码默认值
    try {
      // 1. 尝试从缓存加载
      final cachedIndicators = _loadMainIndicatorsFromCache();
      if (cachedIndicators.isNotEmpty) {
        defLogger.d('Loaded ${cachedIndicators.length} main indicators from cache');
        return cachedIndicators;
      }

      // 2. 尝试从JSON同步加载
      final jsonIndicators = _loadMainIndicatorsFromJsonSync();
      if (jsonIndicators.isNotEmpty) {
        defLogger.d('Loaded ${jsonIndicators.length} main indicators from JSON');
        // 异步保存到缓存
        _saveMainIndicatorsToCache(jsonIndicators);
        return jsonIndicators;
      }
    } catch (err, stack) {
      defLogger.e('Error loading main indicators: $err', stackTrace: stack);
    }

    // 3. 返回代码默认值（空映射，依赖JSON配置）
    defLogger.d('Using empty main indicators map, relying on JSON configuration');
    return super.mainIndicatorBuilders;
  }

  /// 获取默认主指标配置的方法，用于重置操作
  /// 优先从JSON同步加载，如果没有则使用代码默认值
  @override
  Map<IIndicatorKey, IndicatorBuilder> getDefaultMainIndicatorBuilders() {
    try {
      // 1. 尝试从JSON同步加载
      final jsonIndicators = _loadMainIndicatorsFromJsonSync();
      if (jsonIndicators.isNotEmpty) {
        defLogger.d('Loaded ${jsonIndicators.length} default main indicators from JSON');
        // 异步保存到缓存
        _saveMainIndicatorsToCache(jsonIndicators);
        return jsonIndicators;
      }

      // 2. 使用代码默认值
      defLogger.d('Using code default main indicators');
      return super.mainIndicatorBuilders;
    } catch (err, stack) {
      defLogger.e('Error loading default main indicators: $err', stackTrace: stack);
      // 3. 出错时返回代码默认值
      return super.mainIndicatorBuilders;
    }
  }

  @override
  Map<IIndicatorKey, IndicatorBuilder> get subIndicatorBuilders {
    // 三层配置加载策略: 缓存 -> JSON -> 代码默认值
    try {
      // 1. 尝试从缓存加载
      final cachedIndicators = _loadSubIndicatorsFromCache();
      if (cachedIndicators.isNotEmpty) {
        defLogger.d('Loaded ${cachedIndicators.length} sub indicators from cache');
        return cachedIndicators;
      }
    } catch (err, stack) {
      defLogger.e('Error loading sub indicators: $err', stackTrace: stack);
    }

    // 2. 返回默认配置（包含JSON同步加载逻辑）
    defLogger.d('Using default sub indicators');
    return getDefaultSubIndicatorBuilders();
  }

  /// 获取默认副指标配置的方法，用于重置操作
  /// 优先从JSON同步加载，如果没有则使用代码默认值
  @override
  Map<IIndicatorKey, IndicatorBuilder> getDefaultSubIndicatorBuilders() {
    try {
      // 1. 尝试从JSON同步加载
      final jsonIndicators = _loadSubIndicatorsFromJsonSync();
      if (jsonIndicators.isNotEmpty) {
        defLogger.d('Loaded ${jsonIndicators.length} default sub indicators from JSON');
        // 异步保存到缓存
        _saveSubIndicatorsToCache(jsonIndicators);
        return jsonIndicators;
      }

      // 2. 使用代码默认值
      defLogger.d('Using code default sub indicators');
      return super.subIndicatorBuilders;
    } catch (err, stack) {
      defLogger.e('Error loading default sub indicators: $err', stackTrace: stack);
      // 3. 出错时返回代码默认值
      return super.subIndicatorBuilders;
    }
  }

  // ========== 指标加载和缓存方法 ==========

  /// 从缓存加载主指标配置
  Map<IIndicatorKey, IndicatorBuilder> _loadMainIndicatorsFromCache() {
    try {
      final cacheKey = '${configKey}_main_indicators';
      final cachedData = getConfig(cacheKey);
      if (cachedData != null && cachedData['indicators'] is List) {
        final theme = ref.read(defaultKlineThemeProvider);
        final indicators = <IIndicatorKey, IndicatorBuilder>{};

        for (final indicatorConfig in cachedData['indicators']) {
          if (indicatorConfig is Map<String, dynamic>) {
            final key = FlexiIndicatorKey(indicatorConfig['key'] as String);
            final builder = createIndicatorBuilderFromConfig(indicatorConfig, theme);
            indicators[key] = builder;
          }
        }
        return indicators;
      }
    } catch (err, stack) {
      defLogger.e('_loadMainIndicatorsFromCache error: $err', stackTrace: stack);
    }
    return {};
  }

  /// 从缓存加载副指标配置
  Map<IIndicatorKey, IndicatorBuilder> _loadSubIndicatorsFromCache() {
    try {
      final cacheKey = '${configKey}_sub_indicators';
      final cachedData = getConfig(cacheKey);
      if (cachedData != null && cachedData['indicators'] is List) {
        final theme = ref.read(defaultKlineThemeProvider);
        final indicators = <IIndicatorKey, IndicatorBuilder>{};

        for (final indicatorConfig in cachedData['indicators']) {
          if (indicatorConfig is Map<String, dynamic>) {
            final key = FlexiIndicatorKey(indicatorConfig['key'] as String);
            final builder = createIndicatorBuilderFromConfig(indicatorConfig, theme);
            indicators[key] = builder;
          }
        }
        return indicators;
      }
    } catch (err, stack) {
      defLogger.e('_loadSubIndicatorsFromCache error: $err', stackTrace: stack);
    }
    return {};
  }

  /// 同步从JSON加载主指标配置
  Map<IIndicatorKey, IndicatorBuilder> _loadMainIndicatorsFromJsonSync() {
    try {
      // 尝试从缓存中获取JSON配置数据
      final jsonCacheKey = '${configKey}_indicator_json_config';
      final jsonConfig = getConfig(jsonCacheKey);

      if (jsonConfig != null && jsonConfig['mainIndicators'] is Map) {
        return _parseMainIndicatorsFromJson(jsonConfig['mainIndicators']);
      }
    } catch (err, stack) {
      defLogger.e('_loadMainIndicatorsFromJsonSync error: $err', stackTrace: stack);
    }
    return {};
  }

  /// 同步从JSON加载副指标配置
  Map<IIndicatorKey, IndicatorBuilder> _loadSubIndicatorsFromJsonSync() {
    try {
      // 尝试从缓存中获取JSON配置数据
      final jsonCacheKey = '${configKey}_indicator_json_config';
      final jsonConfig = getConfig(jsonCacheKey);

      if (jsonConfig != null && jsonConfig['subIndicators'] is Map) {
        return _parseSubIndicatorsFromJson(jsonConfig['subIndicators']);
      }
    } catch (err, stack) {
      defLogger.e('_loadSubIndicatorsFromJsonSync error: $err', stackTrace: stack);
    }
    return {};
  }

  /// 解析主指标JSON配置
  Map<IIndicatorKey, IndicatorBuilder> _parseMainIndicatorsFromJson(
      Map<String, dynamic> mainIndicators) {
    final theme = ref.read(defaultKlineThemeProvider);
    final indicators = <IIndicatorKey, IndicatorBuilder>{};

    for (final entry in mainIndicators.entries) {
      try {
        final key = FlexiIndicatorKey(entry.key);
        final config = entry.value as Map<String, dynamic>;
        final builder = createIndicatorBuilderFromConfig(config, theme);
        indicators[key] = builder;
      } catch (err, stack) {
        defLogger.e('Error parsing main indicator ${entry.key}: $err', stackTrace: stack);
      }
    }
    return indicators;
  }

  /// 解析副指标JSON配置
  Map<IIndicatorKey, IndicatorBuilder> _parseSubIndicatorsFromJson(
      Map<String, dynamic> subIndicators) {
    final theme = ref.read(defaultKlineThemeProvider);
    final indicators = <IIndicatorKey, IndicatorBuilder>{};

    for (final entry in subIndicators.entries) {
      try {
        final key = FlexiIndicatorKey(entry.key);
        final config = entry.value as Map<String, dynamic>;
        final builder = createIndicatorBuilderFromConfig(config, theme);
        indicators[key] = builder;
      } catch (err, stack) {
        defLogger.e('Error parsing sub indicator ${entry.key}: $err', stackTrace: stack);
      }
    }
    return indicators;
  }

  /// 保存主指标配置到缓存
  void _saveMainIndicatorsToCache(Map<IIndicatorKey, IndicatorBuilder> indicators) {
    try {
      final cacheKey = '${configKey}_main_indicators';
      final indicatorsList = indicators.entries
          .map((entry) => {
                'key': entry.key.id,
                'type': entry.key.id, // 简化处理，使用key作为type
              })
          .toList();

      setConfig(cacheKey, {'indicators': indicatorsList});
    } catch (err, stack) {
      defLogger.e('_saveMainIndicatorsToCache error: $err', stackTrace: stack);
    }
  }

  /// 保存副指标配置到缓存
  void _saveSubIndicatorsToCache(Map<IIndicatorKey, IndicatorBuilder> indicators) {
    try {
      final cacheKey = '${configKey}_sub_indicators';
      final indicatorsList = indicators.entries
          .map((entry) => {
                'key': entry.key.id,
                'type': entry.key.id, // 简化处理，使用key作为type
              })
          .toList();

      setConfig(cacheKey, {'indicators': indicatorsList});
    } catch (err, stack) {
      defLogger.e('_saveSubIndicatorsToCache error: $err', stackTrace: stack);
    }
  }

  @override
  MainPaintObjectIndicator<PaintObjectIndicator> genMainIndicator(
      [MainPaintObjectIndicator<PaintObjectIndicator>? instance]) {
    final theme = ref.read(defaultKlineThemeProvider);
    return MainPaintObjectIndicator<PaintObjectIndicator>(
      size: Size(ScreenUtil().screenWidth, 300.r),
      padding: theme.mainIndicatorPadding,
      drawBelowTipsArea: true,
    );
  }

  // ========== 缓存管理实现 ==========

  @override
  Map<String, dynamic>? getConfig(String key) {
    try {
      final String? jsonStr = CacheUtil().get(key);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final json = jsonDecode(jsonStr);
        if (json is Map<String, dynamic>) {
          return json;
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
      await CacheUtil().setString(key, jsonStr);
      return true;
    } catch (err, stack) {
      defLogger.e('setConfig error for key $key: $err', stackTrace: stack);
      return false;
    }
  }

  // ========== 时间周期配置 ==========

  /// 获取时间周期配置列表
  @override
  List<ITimeBar> getTimeBarConfigs() {
    // 返回常用的时间周期列表
    return [
      TimeBar.m1, // 1m
      TimeBar.m3, // 3m
      TimeBar.m5, // 5m
      TimeBar.m15, // 15m
      TimeBar.m30, // 30m
      TimeBar.H1, // 1H
      TimeBar.H2, // 2H
      TimeBar.H4, // 4H
      TimeBar.H6, // 6H
      TimeBar.H12, // 12H
      TimeBar.D1, // 1D
      TimeBar.W1, // 1W
      TimeBar.M1, // 1M
    ];
  }

  // ========== 指标构建器创建 ==========

  // 根据配置创建指标构建器
  IndicatorBuilder _createIndicatorBuilderFromConfig(
      Map<String, dynamic> config, DefaultFlexiKlineTheme theme) {
    final type = config['type'] as String?;

    switch (type) {
      // ✅ 已优化的指标类型
      case 'volMa':
        return (setting) => VolMaIndicator(
              height: (config['height'] as num?)?.toDouble() ?? 100.r,
              calcParam: _parseVolMaParam(config['config']) ?? const VolMaParam(lines: []),
              tipsPadding: theme.tipsPadding,
            );

      case 'volume':
        return (setting) => VolumeIndicator(
              height: (config['height'] as num?)?.toDouble() ?? 100.r,
              calcParam: _parseVolumeParam(config['config']) ?? const VolumeParam(),
              tipsPadding: theme.tipsPadding,
              tickCount: (config['tickCount'] as num?)?.toInt() ?? 5,
            );

      // 📈 主指标类型
      case 'ma':
        return (setting) => MAIndicator(
              height: (config['height'] as num?)?.toDouble() ?? theme.mainIndicatorHeight,
              padding: theme.mainIndicatorPadding,
              calcParam: _parseMaParam(config['config']) ?? const MaParam(),
              tipsPadding: theme.tipsPadding,
            );

      case 'boll':
        return (setting) => BOLLIndicator(
              height: (config['height'] as num?)?.toDouble() ?? theme.mainIndicatorHeight,
              padding: theme.mainIndicatorPadding,
              calcParam: _parseBOLLParam(config['config']) ?? const BOLLParam(),
              tipsPadding: theme.tipsPadding,
            );

      case 'ema':
        return (setting) => EMAIndicator(
              height: (config['height'] as num?)?.toDouble() ?? theme.mainIndicatorHeight,
              padding: theme.mainIndicatorPadding,
              calcParam: _parseEMAParam(config['config']) ?? const EmaParam(),
              tipsPadding: theme.tipsPadding,
            );

      case 'sar':
        return (setting) => SARIndicator(
              height: (config['height'] as num?)?.toDouble() ?? theme.mainIndicatorHeight,
              padding: theme.mainIndicatorPadding,
              calcParam: _parseSARParam(config['config']) ?? const SARParam(),
              tipsPadding: theme.tipsPadding,
              tickCount: (config['tickCount'] as num?)?.toInt() ?? 5,
            );

      case 'avl':
        return (setting) => AVLIndicator(
              height: (config['height'] as num?)?.toDouble() ?? theme.mainIndicatorHeight,
              padding: theme.mainIndicatorPadding,
              calcParam: _parseAVLParam(config['config']) ?? const AVLParam(),
              tipsPadding: theme.tipsPadding,
              tickCount: (config['tickCount'] as num?)?.toInt() ?? 5,
            );

      // 📊 副指标类型
      case 'rsi':
        return (setting) => RSIIndicator(
              height: (config['height'] as num?)?.toDouble() ?? 100.r,
              calcParam: _parseRSIParam(config['config']) ?? const RsiParam(lines: []),
              tipsPadding: theme.tipsPadding,
              tickCount: (config['tickCount'] as num?)?.toInt() ?? 5,
            );

      case 'kdj':
        return (setting) => KDJIndicator(
              height: (config['height'] as num?)?.toDouble() ?? 100.r,
              calcParam: _parseKDJParam(config['config']) ?? const KDJParam(),
              tipsPadding: theme.tipsPadding,
              tickCount: (config['tickCount'] as num?)?.toInt() ?? 5,
            );

      case 'macd':
        return (setting) => MACDIndicator(
              height: (config['height'] as num?)?.toDouble() ?? 120.r,
              calcParam: _parseMACDParam(config['config']) ?? const MACDParam(s: 12, l: 26, m: 9),
              difTips: _parseTipsConfig(config['difTips']) ??
                  TipsConfig(
                    label: 'DIF: ',
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: theme.normalTextSize,
                        height: defaultTextHeight),
                  ),
              deaTips: _parseTipsConfig(config['deaTips']) ??
                  TipsConfig(
                    label: 'DEA: ',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: theme.normalTextSize,
                        height: defaultTextHeight),
                  ),
              macdTips: _parseTipsConfig(config['macdTips']) ??
                  TipsConfig(
                    label: 'MACD: ',
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: theme.normalTextSize,
                        height: defaultTextHeight),
                  ),
              tipsPadding: theme.tipsPadding,
              tickCount: (config['tickCount'] as num?)?.toInt() ?? 5,
            );

      default:
        // 对于不支持的指标类型，记录日志并返回一个默认的Volume指标
        defLogger.w('Unsupported indicator type: $type, fallback to volume indicator');
        return (setting) => VolumeIndicator(
              height: 100.r,
              calcParam: const VolumeParam(),
              tipsPadding: theme.tipsPadding,
              tickCount: 5,
            );
    }
  }

  // ========== 参数解析方法 ==========

  // 解析 VolMaParam
  VolMaParam? _parseVolMaParam(dynamic config) {
    if (config is Map<String, dynamic>) {
      return VolMaParam.fromJsonConfig(config);
    }
    return null;
  }

  // 解析 VolumeParam
  VolumeParam? _parseVolumeParam(dynamic config) {
    if (config is Map<String, dynamic>) {
      return VolumeParam.fromJsonConfig(config);
    }
    return null;
  }

  // 解析 MaParam
  MaParam? _parseMaParam(dynamic config) {
    if (config is Map<String, dynamic>) {
      return MaParam.fromJsonConfig(config);
    }
    return null;
  }

  // 解析 BOLLParam
  BOLLParam? _parseBOLLParam(dynamic config) {
    if (config is Map<String, dynamic>) {
      return BOLLParam.fromJsonConfig(config);
    }
    return null;
  }

  // 解析 EmaParam
  EmaParam? _parseEMAParam(dynamic config) {
    if (config is Map<String, dynamic>) {
      return EmaParam.fromJsonConfig(config);
    }
    return null;
  }

  // 解析 SARParam
  SARParam? _parseSARParam(dynamic config) {
    if (config is Map<String, dynamic>) {
      return SARParam.fromJsonConfig(config);
    }
    return null;
  }

  // 解析 AVLParam
  AVLParam? _parseAVLParam(dynamic config) {
    if (config is Map<String, dynamic>) {
      return AVLParam.fromJsonConfig(config);
    }
    return null;
  }

  // 解析 RsiParam
  RsiParam? _parseRSIParam(dynamic config) {
    if (config is Map<String, dynamic>) {
      return RsiParam.fromJsonConfig(config);
    }
    return null;
  }

  // 解析 KDJParam
  KDJParam? _parseKDJParam(dynamic config) {
    if (config is Map<String, dynamic>) {
      return KDJParam.fromJsonConfig(config);
    }
    return null;
  }

  // 解析 MACDParam
  MACDParam? _parseMACDParam(dynamic config) {
    if (config is Map<String, dynamic>) {
      return MACDParam.fromJsonConfig(config);
    }
    return null;
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
        color: _parseColor(style['color']) ?? Colors.blue,
        fontSize: (style['fontSize'] as num?)?.toDouble() ?? 12,
        height: (style['height'] as num?)?.toDouble() ?? defaultTextHeight,
        fontWeight: _parseFontWeight(style['fontWeight']),
      );
    }
    return const TextStyle(
      color: Colors.blue,
      fontSize: 12,
      height: defaultTextHeight,
    );
  }

  // 解析 Color
  Color? _parseColor(dynamic color) {
    if (color is int) {
      return Color(color);
    } else if (color is String) {
      // 解析颜色字符串，如 "#FF0000" 或 "0xFFFF0000"
      if (color.startsWith('#')) {
        return Color(int.parse(color.substring(1), radix: 16) + 0xFF000000);
      } else if (color.startsWith('0x')) {
        return Color(int.parse(color.substring(2), radix: 16));
      }
    }
    return null;
  }

  // 解析 FontWeight
  FontWeight? _parseFontWeight(dynamic weight) {
    if (weight is String) {
      switch (weight.toLowerCase()) {
        case 'bold':
          return FontWeight.bold;
        case 'normal':
          return FontWeight.normal;
        case 'w100':
          return FontWeight.w100;
        case 'w200':
          return FontWeight.w200;
        case 'w300':
          return FontWeight.w300;
        case 'w400':
          return FontWeight.w400;
        case 'w500':
          return FontWeight.w500;
        case 'w600':
          return FontWeight.w600;
        case 'w700':
          return FontWeight.w700;
        case 'w800':
          return FontWeight.w800;
        case 'w900':
          return FontWeight.w900;
      }
    } else if (weight is int) {
      return FontWeight.values.firstWhere(
        (fw) => fw.index == weight,
        orElse: () => FontWeight.normal,
      );
    }
    return null;
  }
}
