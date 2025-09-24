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
import 'package:flexi_kline/flexi_kline.dart' hide Overlay;
import 'package:flexi_kline/src/framework/draw/overlay.dart' as flexi_overlay;
import 'package:flexi_formatter/date_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class BaseBitFlexiKlineTheme with FlexiKlineThemeTextStyle implements IFlexiKlineTheme {
  abstract String key;
  
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

  @override
  Color long = const Color(0xFF21B26D);

  @override
  Color short = const Color(0xFFEE4549);

  @override
  Color transparent = Colors.transparent;

  @override
  Color crossColor = const Color(0xFFF6A701);

  @override
  Color get drawColor => Colors.blueAccent;

  Color get drawTextBg => Colors.blue;
}

class BitFlexiKlineLightTheme extends BaseBitFlexiKlineTheme {
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
  Color get gridLine => textColor;

  Color get markLine => textColor;

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
  Color get indraTodayAvgColor => const Color(0xffff9933);
  @override
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
  @override
  String key = 'flexi_kline_config_key_bit-dark';
  
  @override
  Color get indraTodayAvgColor => const Color(0xffff9933);
  @override
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
  Color get gridLine => const Color(0xFF222222);

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
  Color get lastPriceTextBg => latestPriceTextBg;

  @override
  Color get lastPriceTextColor => crossTextColor;
}

final lightBitFlexiKlineTheme = BitFlexiKlineLightTheme();
final darkBitFlexiKlineTheme = BitFlexiKlineDarkTheme();

final bitFlexiKlineThemeProvider = StateProvider<BaseBitFlexiKlineTheme>((ref) {
  final brightness = ref.watch(
    themeProvider.select((theme) => theme.brightness),
  );
  if (brightness == Brightness.dark) {
    return darkBitFlexiKlineTheme;
  } else {
    return lightBitFlexiKlineTheme;
  }
});

class BitFlexiKlineConfiguration with FlexiKlineThemeConfigurationMixin implements IConfiguration {
  final WidgetRef ref;

  BitFlexiKlineConfiguration({required this.ref});

  // 加载指标JSON配置
  Future<Map<String, dynamic>?> _loadIndicatorJsonConfig() async {
    try {
      final String jsonString =
          await rootBundle.loadString('lib/flexi_kline_indicators_configuration.json');
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
      final String jsonString =
          await rootBundle.loadString('example/lib/default_flexi_kline_configuration.json');
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

  @override
  String get configKey => 'bit';

  @override
  FlexiKlineConfig generateFlexiKlineConfig([FlexiKlineConfig? origin]) {
    // 三级配置加载策略：缓存 → JSON → 代码默认值
    
    // 1. 优先使用原始配置（通常来自缓存）
    if (origin != null) {
      defLogger.d('Generated FlexiKlineConfig from origin (cache) for bit theme');
      return origin;
    }

    // 2. 尝试从JSON配置生成（异步，这里先返回默认值）
    _generateConfigFromJsonAsync();

    // 3. 最后使用代码默认配置作为fallback
    defLogger.d('Generated FlexiKlineConfig from code defaults for bit theme');
    return super.generateFlexiKlineConfig();
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
          defLogger.d('Generated and cached FlexiKlineConfig from JSON for bit theme');
        }
      }
    } catch (e, stack) {
      defLogger.e('Error generating config from JSON for bit theme: $e', stackTrace: stack);
    }
  }

  // 从JSON配置生成FlexiKlineConfig
  FlexiKlineConfig? _generateConfigFromJson(Map<String, dynamic> jsonConfig) {
    try {
      return FlexiKlineConfig(
        grid: _parseGridConfig(jsonConfig['grid']) ?? genGridConfig(),
        setting: _parseSettingConfig(jsonConfig['setting']) ?? genSettingConfig(),
        gesture: _parseGestureConfig(jsonConfig['gesture']) ?? genGestureConfig(),
        cross: _parseCrossConfig(jsonConfig['cross']) ?? genCrossConfig(),
        draw: _parseDrawConfig(jsonConfig['draw']) ?? genDrawConfig(),
        mainIndicator: _parseMainIndicatorConfig(jsonConfig['mainIndicator']) ?? genMainIndicator(),
        sub: <IIndicatorKey>{}, // 副指标通过单独的方法管理
      );
    } catch (e, stack) {
      defLogger.e('Error parsing JSON config for bit theme: $e', stackTrace: stack);
      return null;
    }
  }

  FlexiKlineConfig getFlexiKlineConfig() {
    final theme = ref.read(bitFlexiKlineThemeProvider);
    try {
      final String? jsonStr = CacheUtil().get(theme.key);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final json = jsonDecode(jsonStr);
        if (json is Map<String, dynamic>) {
          return FlexiKlineConfig.fromJson(json);
        }
      }
    } catch (err, stack) {
      defLogger.e('getFlexiKlineConfig error:$err', stackTrace: stack);
    }

    return generateFlexiKlineConfig();
  }

  void saveFlexiKlineConfig(FlexiKlineConfig config) {
    final jsonSrc = jsonEncode(config);
    final theme = ref.read(bitFlexiKlineThemeProvider);
    CacheUtil().setString(theme.key, jsonSrc);
  }

  @override
  LoadingConfig genInnerLoadingConfig([LoadingConfig? loading]) {
    final theme = ref.read(bitFlexiKlineThemeProvider);
    return super.genInnerLoadingConfig(loading).copyWith(
          background: theme.countDownTextBg,
          valueColor: theme.crossColor,
        );
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
        );
  }

  @override
  SettingConfig genSettingConfig([SettingConfig? setting]) {
    return super.genSettingConfig(setting).copyWith(
          candleFixedSpacing: null,
          candleSpacingParts: 7,
        );
  }

  @override
  TimeIndicator genTimeIndicator(TimeIndicator? instance) {
    return super.genTimeIndicator(instance).copyWith(
          position: DrawPosition.bottom,
        );
  }

  Iterable<flexi_overlay.Overlay> getOverlayListConfig(String instId) {
    try {
      final String? jsonStr = CacheUtil().get('overlay_$instId');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final json = jsonDecode(jsonStr);
        if (json is List) {
          return json
              .map((e) => flexi_overlay.Overlay.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (err, stack) {
      defLogger.e('getOverlayListConfig error:$err', stackTrace: stack);
    }
    return [];
  }

  // 时间周期配置缓存
  List<TimeBarConfig>? _cachedTimeBarConfigs;

  /// 获取时间周期配置列表
  List<TimeBarConfig> getTimeBarConfigs() {
    if (_cachedTimeBarConfigs != null) {
      return _cachedTimeBarConfigs!;
    }

    // 从配置中读取时间周期配置
    final config = getConfig('timeBarConfigs');
    if (config != null) {
      try {
        _cachedTimeBarConfigs = _buildTimeBarConfigsFromConfig(config);
        return _cachedTimeBarConfigs!;
      } catch (e) {
        defLogger.e('Failed to build time bar configs from config: $e');
      }
    }

    // 默认配置
    _cachedTimeBarConfigs = _getDefaultTimeBarConfigs();
    return _cachedTimeBarConfigs!;
  }

  List<TimeBarConfig> timeBarBuilders() {
    return getTimeBarConfigs();
  }

  List<TimeBarConfig> _getDefaultTimeBarConfigs() {
    return [
      const TimeBarConfig(
        key: 'intraDay',
        bar: '15m',
        multiplier: 15,
        timeUnit: TimeUnit.minute,
        showName: 'Time',
        sortOrder: 0,
        intraDay: true,
      ),
      const TimeBarConfig(
        key: '1m',
        bar: '1m',
        multiplier: 1,
        timeUnit: TimeUnit.minute,
        showName: '1m',
        sortOrder: 1,
      ),
      const TimeBarConfig(
        key: '3m',
        bar: '3m',
        multiplier: 3,
        timeUnit: TimeUnit.minute,
        showName: '3m',
        sortOrder: 2,
      ),
      const TimeBarConfig(
        key: '5m',
        bar: '5m',
        multiplier: 5,
        timeUnit: TimeUnit.minute,
        showName: '5m',
        sortOrder: 3,
      ),
      const TimeBarConfig(
        key: '15m',
        bar: '15m',
        multiplier: 15,
        timeUnit: TimeUnit.minute,
        showName: '15m',
        sortOrder: 4,
      ),
      const TimeBarConfig(
        key: '30m',
        bar: '30m',
        multiplier: 30,
        timeUnit: TimeUnit.minute,
        showName: '30m',
        sortOrder: 5,
      ),
      const TimeBarConfig(
        key: '1H',
        bar: '1H',
        multiplier: 1,
        timeUnit: TimeUnit.hour,
        showName: '1H',
        sortOrder: 6,
      ),
      const TimeBarConfig(
        key: '2H',
        bar: '2H',
        multiplier: 2,
        timeUnit: TimeUnit.hour,
        showName: '2H',
        sortOrder: 7,
      ),
      const TimeBarConfig(
        key: '4H',
        bar: '4H',
        multiplier: 4,
        timeUnit: TimeUnit.hour,
        showName: '4H',
        sortOrder: 8,
      ),
      const TimeBarConfig(
        key: '6H',
        bar: '6H',
        multiplier: 6,
        timeUnit: TimeUnit.hour,
        showName: '6H',
        sortOrder: 9,
      ),
      const TimeBarConfig(
        key: '12H',
        bar: '12H',
        multiplier: 12,
        timeUnit: TimeUnit.hour,
        showName: '12H',
        sortOrder: 10,
      ),
      const TimeBarConfig(
        key: '1D',
        bar: '1D',
        multiplier: 1,
        timeUnit: TimeUnit.day,
        showName: '1D',
        sortOrder: 11,
      ),
      const TimeBarConfig(
        key: '2D',
        bar: '2D',
        multiplier: 2,
        timeUnit: TimeUnit.day,
        showName: '2D',
        sortOrder: 12,
      ),
      const TimeBarConfig(
        key: '3D',
        bar: '3D',
        multiplier: 3,
        timeUnit: TimeUnit.day,
        showName: '3D',
        sortOrder: 13,
      ),
      const TimeBarConfig(
        key: '1W',
        bar: '1W',
        multiplier: 7,
        timeUnit: TimeUnit.week,
        showName: '1W',
        sortOrder: 14,
      ),
      const TimeBarConfig(
        key: '1M',
        bar: '1M',
        multiplier: 1,
        timeUnit: TimeUnit.month,
        showName: '1M',
        sortOrder: 15,
      ),
      const TimeBarConfig(
        key: '3M',
        bar: '3M',
        multiplier: 3,
        timeUnit: TimeUnit.month,
        showName: '3M',
        sortOrder: 16,
      ),
      // UTC时间配置
      const TimeBarConfig(
        key: '6Hutc',
        bar: '6Hutc',
        multiplier: 6,
        timeUnit: TimeUnit.hour,
        showName: '6Hutc',
        isUtc: true,
        sortOrder: 17,
      ),
      const TimeBarConfig(
        key: '12Hutc',
        bar: '12Hutc',
        multiplier: 12,
        timeUnit: TimeUnit.hour,
        showName: '12Hutc',
        isUtc: true,
        sortOrder: 18,
      ),
      const TimeBarConfig(
        key: 'utc1D',
        bar: '1Dutc',
        multiplier: 1,
        timeUnit: TimeUnit.day,
        showName: '1Dutc',
        isUtc: true,
        sortOrder: 19,
      ),
      const TimeBarConfig(
        key: 'utc2D',
        bar: '2Dutc',
        multiplier: 2,
        timeUnit: TimeUnit.day,
        showName: '2Dutc',
        isUtc: true,
        sortOrder: 20,
      ),
      const TimeBarConfig(
        key: 'utc3D',
        bar: '3Dutc',
        multiplier: 3,
        timeUnit: TimeUnit.day,
        showName: '3Dutc',
        isUtc: true,
        sortOrder: 21,
      ),
      const TimeBarConfig(
        key: 'utc1W',
        bar: '1Wutc',
        multiplier: 7,
        timeUnit: TimeUnit.week,
        showName: '1Wutc',
        isUtc: true,
        sortOrder: 22,
      ),
      const TimeBarConfig(
        key: 'utc1M',
        bar: '1Mutc',
        multiplier: 1,
        timeUnit: TimeUnit.month,
        showName: '1Mutc',
        isUtc: true,
        sortOrder: 23,
      ),
      const TimeBarConfig(
        key: 'utc3M',
        bar: '3Mutc',
        multiplier: 3,
        timeUnit: TimeUnit.month,
        showName: '3Mutc',
        isUtc: true,
        sortOrder: 24,
      ),
    ];
  }

  /// 从配置构建时间周期配置列表
  List<TimeBarConfig> _buildTimeBarConfigsFromConfig(Map<String, dynamic> config) {
    final List<TimeBarConfig> configs = [];

    if (config['timeBarConfigs'] is List) {
      for (final item in config['timeBarConfigs']) {
        if (item is Map<String, dynamic>) {
          try {
            final timeBarConfig = TimeBarConfig.fromJson(item);
            configs.add(timeBarConfig);
          } catch (e) {
            defLogger.e('Failed to parse TimeBarConfig: $e');
          }
        }
      }
    }

    // 按照sortOrder排序
    configs.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return configs;
  }

  /// 设置时间周期配置
  Future<bool> setTimeBarConfigs(List<TimeBarConfig> configs) async {
    try {
      final configData = {
        'timeBarConfigs': configs.map((config) => config.toJson()).toList(),
      };

      final success = await setConfig('timeBarConfigs', configData);
      if (success) {
        _cachedTimeBarConfigs = null; // 清除缓存
      }
      return success;
    } catch (e) {
      defLogger.e('Failed to set time bar configs: $e');
      return false;
    }
  }

  // @override
  // void saveOverlayListConfig(String instId, Iterable<flexi_overlay.Overlay> list) {
  //   try {
  //     final jsonList = list.map((overlay) => overlay.toJson()).toList();
  //     final jsonSrc = jsonEncode(jsonList);
  //     CacheUtil().setString('overlay_$instId', jsonSrc);
  //   } catch (err, stack) {
  //     defLogger.e('saveOverlayListConfig error:$err', stackTrace: stack);
  //   }
  // }

  @override
  IFlexiKlineTheme get theme => ref.read(bitFlexiKlineThemeProvider);

  Iterable<flexi_overlay.Overlay> getDrawOverlayList(String instId) {
    try {
      final String? jsonStr = CacheUtil().get('draw_overlay_$instId');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final json = jsonDecode(jsonStr);
        if (json is List) {
          return json
              .map((e) => flexi_overlay.Overlay.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (err, stack) {
      defLogger.e('getDrawOverlayList error:$err', stackTrace: stack);
    }
    return [];
  }

  void saveDrawOverlayList(String instId, Iterable<flexi_overlay.Overlay> list) {
    try {
      final jsonList = list.map((overlay) => overlay.toJson()).toList();
      final jsonSrc = jsonEncode(jsonList);
      CacheUtil().setString('draw_overlay_$instId', jsonSrc);
    } catch (err, stack) {
      defLogger.e('saveDrawOverlayList error:$err', stackTrace: stack);
    }
  }

  @override
  MainPaintObjectIndicator<PaintObjectIndicator> genMainIndicator([MainPaintObjectIndicator<PaintObjectIndicator>? instance]) {
    final theme = ref.read(bitFlexiKlineThemeProvider);
    return MainPaintObjectIndicator<PaintObjectIndicator>(
      size: Size(ScreenUtil().screenWidth, 300.r),
      padding: theme.mainIndicatorPadding,
      drawBelowTipsArea: true,
    );
  }

  // 主指标配置缓存
  Map<IIndicatorKey, IndicatorBuilder>? _cachedMainIndicatorBuilders;

  @override
  Map<IIndicatorKey, IndicatorBuilder> get mainIndicatorBuilders {
    if (_cachedMainIndicatorBuilders != null) {
      // 合并super指标并返回
      final result = Map<IIndicatorKey, IndicatorBuilder>.from(_cachedMainIndicatorBuilders!);
      final superBuilders = super.mainIndicatorBuilders;
      result.addAll(superBuilders);
      return result;
    }

    // 三级配置加载策略：缓存 → JSON → 代码默认值
    
    // 1. 优先从缓存读取
    final cachedConfig = getConfig('mainIndicatorBuilders');
    if (cachedConfig != null) {
      try {
        _cachedMainIndicatorBuilders = _buildMainIndicatorsFromConfig(cachedConfig);
        defLogger.d('✅ Loaded ${_cachedMainIndicatorBuilders!.length} main indicators from cache (bit theme)');
      } catch (e) {
        defLogger.e('❌ Failed to build main indicators from cached config: $e');
        _cachedMainIndicatorBuilders = null;
      }
    }

    // 2. 缓存没有或失败，尝试从JSON加载
    if (_cachedMainIndicatorBuilders == null) {
      try {
        _cachedMainIndicatorBuilders = _loadMainIndicatorsFromJsonSync();
        if (_cachedMainIndicatorBuilders != null) {
          defLogger.d('✅ Loaded ${_cachedMainIndicatorBuilders!.length} main indicators from JSON (bit theme)');
          // 异步保存到缓存（不阻塞当前调用）
          _saveMainIndicatorsToCache(_cachedMainIndicatorBuilders!);
        }
      } catch (e) {
        defLogger.e('❌ Failed to load main indicators from JSON: $e');
      }
    }

    // 3. 最后使用代码默认配置
    if (_cachedMainIndicatorBuilders == null) {
      _cachedMainIndicatorBuilders = _getDefaultMainIndicators();
      defLogger.d('✅ Using ${_cachedMainIndicatorBuilders!.length} default main indicators (bit theme)');
    }

    // 启动异步JSON加载（用于下次更新缓存）
    _loadMainIndicatorsFromJsonAsync();

    // 合并super指标并返回
    final result = Map<IIndicatorKey, IndicatorBuilder>.from(_cachedMainIndicatorBuilders!);
    final superBuilders = super.mainIndicatorBuilders;
    result.addAll(superBuilders);
    return result;
  }

  // 同步从JSON加载主指标配置（用于初始化）
  Map<IIndicatorKey, IndicatorBuilder>? _loadMainIndicatorsFromJsonSync() {
    // Flutter中无法真正同步加载assets，这里返回null
    // 实际的JSON加载会在异步方法中完成
    defLogger.w('⚠️ Sync JSON loading not available for bit theme, will load async');
    return null;
  }

  // 异步保存主指标到缓存
  void _saveMainIndicatorsToCache(Map<IIndicatorKey, IndicatorBuilder> builders) {
    Future(() async {
      try {
        final configMap = <String, dynamic>{};
        builders.forEach((key, builder) {
          // 这里应该保存指标的配置参数，而不是空对象
          // 暂时保存基本信息，具体实现需要根据指标类型来序列化参数
          configMap[key.id] = {
            'type': key.id,
            'enabled': true,
            // TODO: 添加具体的指标参数序列化
          };
        });
        await setConfig('mainIndicatorBuilders', configMap);
        defLogger.d('✅ Saved ${builders.length} main indicators to cache (bit theme)');
      } catch (e) {
        defLogger.e('❌ Failed to save main indicators to cache: $e');
      }
    });
  }

  // 异步从JSON加载主指标配置
  Future<void> _loadMainIndicatorsFromJsonAsync() async {
    try {
      final jsonConfig = await _loadIndicatorJsonConfig();
      if (jsonConfig != null && jsonConfig['mainIndicators'] != null) {
        final mainIndicators = jsonConfig['mainIndicators'] as Map<String, dynamic>;
        _cachedMainIndicatorBuilders = _buildMainIndicatorsFromConfig(mainIndicators);
        
        // 保存到缓存
        await setConfig(
            'mainIndicatorBuilders',
            _cachedMainIndicatorBuilders!
                .map((key, builder) => MapEntry(key.id, <String, dynamic>{})));

        defLogger
            .d('✅ Async loaded ${_cachedMainIndicatorBuilders!.length} main indicators from JSON (bit theme)');
      } else {
        defLogger.w('⚠️ No mainIndicators found in JSON config (bit theme)');
      }
    } catch (e, stack) {
      defLogger.e('❌ Error loading main indicators from JSON (bit theme): $e', stackTrace: stack);
    }
  }

  Map<IIndicatorKey, IndicatorBuilder> _getDefaultMainIndicators() {
    // 返回空映射，主要依赖JSON配置和缓存
    // 只保留已优化的指标作为fallback
    return {};
  }

  // 副指标配置缓存
  Map<IIndicatorKey, IndicatorBuilder>? _cachedSubIndicatorBuilders;

  @override
  Map<IIndicatorKey, IndicatorBuilder> get subIndicatorBuilders {
    if (_cachedSubIndicatorBuilders != null) {
      // 合并super指标并返回
      final result = Map<IIndicatorKey, IndicatorBuilder>.from(_cachedSubIndicatorBuilders!);
      final superBuilders = super.subIndicatorBuilders;
      result.addAll(superBuilders);
      return result;
    }

    // 三级配置加载策略：缓存 → JSON → 代码默认值
    
    // 1. 优先从缓存读取
    final cachedConfig = getConfig('subIndicatorBuilders');
    if (cachedConfig != null) {
      try {
        _cachedSubIndicatorBuilders = _buildSubIndicatorsFromConfig(cachedConfig);
        defLogger.d('✅ Loaded ${_cachedSubIndicatorBuilders!.length} sub indicators from cache (bit theme)');
      } catch (e) {
        defLogger.e('❌ Failed to build sub indicators from cached config: $e');
        _cachedSubIndicatorBuilders = null;
      }
    }

    // 2. 缓存没有或失败，尝试从JSON加载
    if (_cachedSubIndicatorBuilders == null) {
      try {
        _cachedSubIndicatorBuilders = _loadSubIndicatorsFromJsonSync();
        if (_cachedSubIndicatorBuilders != null) {
          defLogger.d('✅ Loaded ${_cachedSubIndicatorBuilders!.length} sub indicators from JSON (bit theme)');
          // 异步保存到缓存（不阻塞当前调用）
          _saveSubIndicatorsToCache(_cachedSubIndicatorBuilders!);
        }
      } catch (e) {
        defLogger.e('❌ Failed to load sub indicators from JSON: $e');
      }
    }

    // 3. 最后使用代码默认配置
    if (_cachedSubIndicatorBuilders == null) {
      _cachedSubIndicatorBuilders = _getDefaultSubIndicators();
      defLogger.d('✅ Using ${_cachedSubIndicatorBuilders!.length} default sub indicators (bit theme)');
    }

    // 启动异步JSON加载（用于下次更新缓存）
    _loadSubIndicatorsFromJsonAsync();

    // 合并super指标并返回
    final result = Map<IIndicatorKey, IndicatorBuilder>.from(_cachedSubIndicatorBuilders!);
    final superBuilders = super.subIndicatorBuilders;
    result.addAll(superBuilders);
    return result;
  }

  // 同步从JSON加载副指标配置（用于初始化）
  Map<IIndicatorKey, IndicatorBuilder>? _loadSubIndicatorsFromJsonSync() {
    // Flutter中无法真正同步加载assets，这里返回null
    // 实际的JSON加载会在异步方法中完成
    defLogger.w('⚠️ Sync JSON loading not available for bit theme, will load async');
    return null;
  }

  // 异步保存副指标到缓存
  void _saveSubIndicatorsToCache(Map<IIndicatorKey, IndicatorBuilder> builders) {
    Future(() async {
      try {
        final configMap = <String, dynamic>{};
        builders.forEach((key, builder) {
          // 这里应该保存指标的配置参数，而不是空对象
          // 暂时保存基本信息，具体实现需要根据指标类型来序列化参数
          configMap[key.id] = {
            'type': key.id,
            'enabled': true,
            // TODO: 添加具体的指标参数序列化
          };
        });
        await setConfig('subIndicatorBuilders', configMap);
        defLogger.d('✅ Saved ${builders.length} sub indicators to cache (bit theme)');
      } catch (e) {
        defLogger.e('❌ Failed to save sub indicators to cache: $e');
      }
    });
  }

  // 异步从JSON加载副指标配置
  Future<void> _loadSubIndicatorsFromJsonAsync() async {
    try {
      final jsonConfig = await _loadIndicatorJsonConfig();
      if (jsonConfig != null && jsonConfig['subIndicators'] != null) {
        final subIndicators = jsonConfig['subIndicators'] as Map<String, dynamic>;
        _cachedSubIndicatorBuilders = _buildSubIndicatorsFromConfig(subIndicators);
        
        // 保存到缓存
        await setConfig(
            'subIndicatorBuilders',
            _cachedSubIndicatorBuilders!
                .map((key, builder) => MapEntry(key.id, <String, dynamic>{})));

        defLogger
            .d('✅ Async loaded ${_cachedSubIndicatorBuilders!.length} sub indicators from JSON (bit theme)');
      } else {
        defLogger.w('⚠️ No subIndicators found in JSON config (bit theme)');
      }
    } catch (e, stack) {
      defLogger.e('❌ Error loading sub indicators from JSON (bit theme): $e', stackTrace: stack);
    }
  }

  Map<IIndicatorKey, IndicatorBuilder> _getDefaultSubIndicators() {
    final theme = ref.read(bitFlexiKlineThemeProvider);
    return {
      // VOL_MA 成交量移动平均线 - 基本配置作为fallback
      const FlexiIndicatorKey('volMa'): (setting) => VolMaIndicator(
            height: 100.r,
            calcParam: const VolMaParam(
              lines: [
                VolMALineConfig(
                  id: 'ma_1',
                  enabled: true,
                  period: 5,
                  color: Colors.blue,
                  width: 1.0,
                  opacity: 0.8,
                ),
                VolMALineConfig(
                  id: 'ma_2',
                  enabled: true,
                  period: 10,
                  color: Colors.red,
                  width: 1.0,
                  opacity: 0.8,
                ),
              ],
              volume: VolMAVolumeConfig(
                useTrendColor: true,
                bullishColor: Color(0xff4caf50),
                bearishColor: Color(0xfff44336),
                opacity: 0.6,
              ),
              display: VolMADisplayConfig(
                precision: 2,
                showVolInTips: true,
                showPeriodInTips: true,
              ),
            ),
            tipsPadding: theme.tipsPadding,
          ),

      // VOLUME 成交量 - 基本配置作为fallback
      const FlexiIndicatorKey('volume'): (setting) => VolumeIndicator(
            height: 100.r,
            calcParam: const VolumeParam(
              showInMain: true,
              heightRatio: 0.3,
              volume: VolumeBarConfig(
                useTrendColor: true,
                bullishColor: Color(0xff4caf50),
                bearishColor: Color(0xfff44336),
                opacity: 0.6,
              ),
              display: VolumeDisplayConfig(
                precision: 2,
                showVolInTips: true,
                compactDisplay: true,
              ),
            ),
            tipsPadding: theme.tipsPadding,
            tickCount: 5,
          ),
    };
  }

  // drawObjectBuilders 使用基类的默认实现

  @override
  Map<String, dynamic>? getConfig(String key) {
    try {
      final String? jsonStr = CacheUtil().get('bit_indicator_config_$key');
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
      await CacheUtil().setString('bit_indicator_config_$key', jsonStr);

      // 清除缓存，强制重新加载
      if (key == 'mainIndicatorBuilders') {
        _cachedMainIndicatorBuilders = null;
      } else if (key == 'subIndicatorBuilders') {
        _cachedSubIndicatorBuilders = null;
      } else if (key == 'timeBarConfigs') {
        _cachedTimeBarConfigs = null;
      }

      return true;
    } catch (err, stack) {
      defLogger.e('setConfig error for key $key: $err', stackTrace: stack);
      return false;
    }
  }

  // 从配置构建主指标
  Map<IIndicatorKey, IndicatorBuilder> _buildMainIndicatorsFromConfig(Map<String, dynamic> config) {
    final Map<IIndicatorKey, IndicatorBuilder> builders = {};
    final theme = ref.read(bitFlexiKlineThemeProvider);

    // 解析配置并创建对应的指标构建器
    config.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        builders[FlexiIndicatorKey(key)] = _createIndicatorBuilderFromConfig(value, theme);
      }
    });

    return builders;
  }

  // 从配置构建副指标
  Map<IIndicatorKey, IndicatorBuilder> _buildSubIndicatorsFromConfig(Map<String, dynamic> config) {
    final Map<IIndicatorKey, IndicatorBuilder> builders = {};
    final theme = ref.read(bitFlexiKlineThemeProvider);

    // 解析配置并创建对应的指标构建器
    config.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        builders[FlexiIndicatorKey(key)] = _createIndicatorBuilderFromConfig(value, theme);
      }
    });

    return builders;
  }

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
        defLogger.e('Failed to parse MainPaintObjectIndicator from JSON (bit theme): $e');
      }
    }
    return null;
  }

  // 根据配置创建指标构建器
  IndicatorBuilder _createIndicatorBuilderFromConfig(
      Map<String, dynamic> config, BaseBitFlexiKlineTheme theme) {
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
              height: (config['height'] as num?)?.toDouble() ?? 300.r,
              padding: theme.mainIndicatorPadding,
              calcParam: _parseMaParam(config['config']) ?? const MaParam(),
              tipsPadding: theme.tipsPadding,
            );

      case 'boll':
        return (setting) => BOLLIndicator(
              height: (config['height'] as num?)?.toDouble() ?? 300.r,
              padding: theme.mainIndicatorPadding,
              calcParam: _parseBOLLParam(config['config']) ?? const BOLLParam(),
              tipsPadding: theme.tipsPadding,
            );

      case 'ema':
        return (setting) => EMAIndicator(
              height: (config['height'] as num?)?.toDouble() ?? 300.r,
              padding: theme.mainIndicatorPadding,
              calcParam: _parseEMAParam(config['config']) ?? const EmaParam(),
              tipsPadding: theme.tipsPadding,
            );

      case 'sar':
        return (setting) => SARIndicator(
              height: (config['height'] as num?)?.toDouble() ?? 300.r,
              padding: theme.mainIndicatorPadding,
              calcParam: _parseSARParam(config['config']) ?? const SARParam(),
              tipsPadding: theme.tipsPadding,
              tickCount: (config['tickCount'] as num?)?.toInt() ?? 5,
            );

      case 'avl':
        return (setting) => AVLIndicator(
              height: (config['height'] as num?)?.toDouble() ?? 300.r,
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
              difTips: _parseTipsConfig(config['difTips']) ?? TipsConfig(
                label: 'DIF: ',
                style: TextStyle(color: Colors.blue, fontSize: 12.sp, height: 1.2),
              ),
              deaTips: _parseTipsConfig(config['deaTips']) ?? TipsConfig(
                label: 'DEA: ',
                style: TextStyle(color: Colors.red, fontSize: 12.sp, height: 1.2),
              ),
              macdTips: _parseTipsConfig(config['macdTips']) ?? TipsConfig(
                label: 'MACD: ',
                style: TextStyle(color: Colors.green, fontSize: 12.sp, height: 1.2),
              ),
              tipsPadding: theme.tipsPadding,
              tickCount: (config['tickCount'] as num?)?.toInt() ?? 5,
            );

      default:
        // 对于不支持的指标类型，记录日志并返回一个默认的Volume指标
        defLogger.w('Unsupported indicator type: $type, fallback to volume indicator (bit theme)');
        return (setting) => VolumeIndicator(
              height: 100.r,
              calcParam: const VolumeParam(),
              tipsPadding: theme.tipsPadding,
              tickCount: 5,
            );
    }
  }

  // 解析参数的辅助方法 - 只保留已优化指标的解析方法

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

  // 解析 EMAParam
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

  // 解析 RSIParam
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
        case 100: return FontWeight.w100;
        case 200: return FontWeight.w200;
        case 300: return FontWeight.w300;
        case 400: return FontWeight.w400;
        case 500: return FontWeight.w500;
        case 600: return FontWeight.w600;
        case 700: return FontWeight.w700;
        case 800: return FontWeight.w800;
        case 900: return FontWeight.w900;
      }
    } else if (weight is String) {
      switch (weight.toLowerCase()) {
        case 'normal': return FontWeight.normal;
        case 'bold': return FontWeight.bold;
      }
    }
    return null;
  }

  // 便民方法：设置主指标配置
  Future<bool> setMainIndicatorConfig(Map<String, Map<String, dynamic>> config) {
    return setConfig('mainIndicatorBuilders', config);
  }

  // 便民方法：设置副指标配置
  Future<bool> setSubIndicatorConfig(Map<String, Map<String, dynamic>> config) {
    return setConfig('subIndicatorBuilders', config);
  }
}
