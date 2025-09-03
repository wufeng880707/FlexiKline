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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class BaseBitFlexiKlineTheme with FlexiKlineThemeTextStyle implements IFlexiKlineTheme {
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

  @override
  Color get drawTextBg => Colors.blue;
}

class BitFlexiKlineLightTheme extends BaseBitFlexiKlineTheme {
  @override
  String get key => 'flexi_kline_config_key_bit-light';

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

  @override
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
  // TODO: implement lastPriceTextBg
  Color get lastPriceTextBg => throw UnimplementedError();
}

class BitFlexiKlineDarkTheme extends BaseBitFlexiKlineTheme {
  @override
  String key = 'flexi_kline_config_key_bit-dark';
  @override
  Color get indraTodayAvgColor => const Color(0xffff9933);
  @override
  Color get indraTodayCloseColor => const Color(0xff4d78ff);
  @override
  Color chartBg = const Color(0xFF111111);

  @override
  Color tooltipBg = const Color(0xFF16181A);

  @override
  Color countDownTextBg = const Color(0xFF333333);

  @override
  Color crossTextBg = const Color(0xFF404040);

  @override
  Color lastPriceTextBg = Colors.black54;

  @override
  Color gridLine = const Color(0xFF222222);

  @override
  Color markLine = const Color(0xFFA0A0A0);

  @override
  Color get themeColor => Colors.black;

  @override
  Color textColor = const Color(0xFFA0A0A0);

  @override
  Color ticksTextColor = const Color(0xFF949494);

  @override
  Color latestPriceTextBg = const Color(0xFF5F5F5F);

  @override
  Color crossTextColor = const Color(0xFFFFFFFF);

  @override
  Color tooltipTextColor = const Color(0xFF9D9DA1);

  @override
  Color get drawColor => Colors.lightBlue;
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

class BitFlexiKlineConfiguration with FlexiKlineThemeConfigurationMixin {
  final WidgetRef ref;

  BitFlexiKlineConfiguration({required this.ref});

  Size get initialMainSize {
    return Size(ScreenUtil().screenWidth, 300.r);
  }

  @override
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

    return genFlexiKlineConfig();
  }

  @override
  void saveFlexiKlineConfig(FlexiKlineConfig config) {
    final jsonSrc = jsonEncode(config);
    CacheUtil().setString(config.key, jsonSrc);
  }

  @override
  LoadingConfig genInnerLoadingConfig() {
    final theme = ref.read(bitFlexiKlineThemeProvider);
    return super.genInnerLoadingConfig().copyWith(
          background: theme.countDownTextBg,
          valueColor: theme.crossColor,
        );
  }

  @override
  CrossConfig genCrossConfig() {
    return super.genCrossConfig().copyWith(
          moveByCandleInBlank: true,
        );
  }

  @override
  GestureConfig genGestureConfig() {
    return super.genGestureConfig().copyWith(
          tolerance: ToleranceConfig(distanceFactor: 0.5),
        );
  }

  @override
  SettingConfig genSettingConfig() {
    return super.genSettingConfig().copyWith(
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

  @override
  List<TimeBarConfig> timeBarBuilders() {
    return getTimeBarConfigs();
  }

  List<TimeBarConfig> _getDefaultTimeBarConfigs() {
    return [
      const TimeBarConfig(
        key: 'intraDay',
        bar: '15m',
        milliseconds: Duration.millisecondsPerMinute * 15,
        multiplier: 15,
        timespan: Timespan.minute,
        showName: 'Time',
        sortOrder: 0,
        intraDay: true,
      ),
      const TimeBarConfig(
        key: '1m',
        bar: '1m',
        milliseconds: Duration.millisecondsPerMinute,
        multiplier: 1,
        timespan: Timespan.minute,
        showName: '1m',
        sortOrder: 1,
      ),
      const TimeBarConfig(
        key: '3m',
        bar: '3m',
        milliseconds: Duration.millisecondsPerMinute * 3,
        multiplier: 3,
        timespan: Timespan.minute,
        showName: '3m',
        sortOrder: 2,
      ),
      const TimeBarConfig(
        key: '5m',
        bar: '5m',
        milliseconds: Duration.millisecondsPerMinute * 5,
        multiplier: 5,
        timespan: Timespan.minute,
        showName: '5m',
        sortOrder: 3,
      ),
      const TimeBarConfig(
        key: '15m',
        bar: '15m',
        milliseconds: Duration.millisecondsPerMinute * 15,
        multiplier: 15,
        timespan: Timespan.minute,
        showName: '15m',
        sortOrder: 4,
      ),
      const TimeBarConfig(
        key: '30m',
        bar: '30m',
        milliseconds: Duration.millisecondsPerMinute * 30,
        multiplier: 30,
        timespan: Timespan.minute,
        showName: '30m',
        sortOrder: 5,
      ),
      const TimeBarConfig(
        key: '1H',
        bar: '1H',
        milliseconds: Duration.millisecondsPerHour,
        multiplier: 1,
        timespan: Timespan.hour,
        showName: '1H',
        sortOrder: 6,
      ),
      const TimeBarConfig(
        key: '2H',
        bar: '2H',
        milliseconds: Duration.millisecondsPerHour * 2,
        multiplier: 2,
        timespan: Timespan.hour,
        showName: '2H',
        sortOrder: 7,
      ),
      const TimeBarConfig(
        key: '4H',
        bar: '4H',
        milliseconds: Duration.millisecondsPerHour * 4,
        multiplier: 4,
        timespan: Timespan.hour,
        showName: '4H',
        sortOrder: 8,
      ),
      const TimeBarConfig(
        key: '6H',
        bar: '6H',
        milliseconds: Duration.millisecondsPerHour * 6,
        multiplier: 6,
        timespan: Timespan.hour,
        showName: '6H',
        sortOrder: 9,
      ),
      const TimeBarConfig(
        key: '12H',
        bar: '12H',
        milliseconds: Duration.millisecondsPerHour * 12,
        multiplier: 12,
        timespan: Timespan.hour,
        showName: '12H',
        sortOrder: 10,
      ),
      const TimeBarConfig(
        key: '1D',
        bar: '1D',
        milliseconds: Duration.millisecondsPerDay,
        multiplier: 1,
        timespan: Timespan.day,
        showName: '1D',
        sortOrder: 11,
      ),
      const TimeBarConfig(
        key: '2D',
        bar: '2D',
        milliseconds: Duration.millisecondsPerDay * 2,
        multiplier: 2,
        timespan: Timespan.day,
        showName: '2D',
        sortOrder: 12,
      ),
      const TimeBarConfig(
        key: '3D',
        bar: '3D',
        milliseconds: Duration.millisecondsPerDay * 3,
        multiplier: 3,
        timespan: Timespan.day,
        showName: '3D',
        sortOrder: 13,
      ),
      const TimeBarConfig(
        key: '1W',
        bar: '1W',
        milliseconds: Duration.millisecondsPerDay * 7,
        multiplier: 7,
        timespan: Timespan.week,
        showName: '1W',
        sortOrder: 14,
      ),
      const TimeBarConfig(
        key: '1M',
        bar: '1M',
        milliseconds: Duration.millisecondsPerDay * 30,
        multiplier: 1,
        timespan: Timespan.month,
        showName: '1M',
        sortOrder: 15,
      ),
      const TimeBarConfig(
        key: '3M',
        bar: '3M',
        milliseconds: Duration.millisecondsPerDay * 90,
        multiplier: 3,
        timespan: Timespan.month,
        showName: '3M',
        sortOrder: 16,
      ),
      // UTC时间配置
      const TimeBarConfig(
        key: '6Hutc',
        bar: '6Hutc',
        milliseconds: Duration.millisecondsPerHour * 6,
        multiplier: 6,
        timespan: Timespan.hour,
        showName: '6Hutc',
        isUtc: true,
        sortOrder: 17,
      ),
      const TimeBarConfig(
        key: '12Hutc',
        bar: '12Hutc',
        milliseconds: Duration.millisecondsPerHour * 12,
        multiplier: 12,
        timespan: Timespan.hour,
        showName: '12Hutc',
        isUtc: true,
        sortOrder: 18,
      ),
      const TimeBarConfig(
        key: 'utc1D',
        bar: '1Dutc',
        milliseconds: Duration.millisecondsPerDay,
        multiplier: 1,
        timespan: Timespan.day,
        showName: '1Dutc',
        isUtc: true,
        sortOrder: 19,
      ),
      const TimeBarConfig(
        key: 'utc2D',
        bar: '2Dutc',
        milliseconds: Duration.millisecondsPerDay * 2,
        multiplier: 2,
        timespan: Timespan.day,
        showName: '2Dutc',
        isUtc: true,
        sortOrder: 20,
      ),
      const TimeBarConfig(
        key: 'utc3D',
        bar: '3Dutc',
        milliseconds: Duration.millisecondsPerDay * 3,
        multiplier: 3,
        timespan: Timespan.day,
        showName: '3Dutc',
        isUtc: true,
        sortOrder: 21,
      ),
      const TimeBarConfig(
        key: 'utc1W',
        bar: '1Wutc',
        milliseconds: Duration.millisecondsPerDay * 7,
        multiplier: 7,
        timespan: Timespan.week,
        showName: '1Wutc',
        isUtc: true,
        sortOrder: 22,
      ),
      const TimeBarConfig(
        key: 'utc1M',
        bar: '1Mutc',
        milliseconds: Duration.millisecondsPerDay * 30,
        multiplier: 1,
        timespan: Timespan.month,
        showName: '1Mutc',
        isUtc: true,
        sortOrder: 23,
      ),
      const TimeBarConfig(
        key: 'utc3M',
        bar: '3Mutc',
        milliseconds: Duration.millisecondsPerDay * 90,
        multiplier: 3,
        timespan: Timespan.month,
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
  MainPaintObjectIndicator<PaintObjectIndicator> genMainIndicator() {
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
      return _cachedMainIndicatorBuilders!;
    }

    // 从配置中读取主指标配置
    final config = getConfig('mainIndicatorBuilders');
    if (config != null) {
      try {
        _cachedMainIndicatorBuilders = _buildMainIndicatorsFromConfig(config);
        return _cachedMainIndicatorBuilders!;
      } catch (e) {
        defLogger.e('Failed to build main indicators from config: $e');
      }
    }

    // 默认配置
    _cachedMainIndicatorBuilders = _getDefaultMainIndicators();

    // 调用super以满足@mustCallSuper要求
    final superBuilders = super.mainIndicatorBuilders;
    _cachedMainIndicatorBuilders!.addAll(superBuilders);

    return _cachedMainIndicatorBuilders!;
  }

  Map<IIndicatorKey, IndicatorBuilder> _getDefaultMainIndicators() {
    final theme = ref.read(bitFlexiKlineThemeProvider);
    return {
      // MA 移动平均线
      const FlexiIndicatorKey('ma'): (setting) => MAIndicator(
            height: theme.mainIndicatorHeight,
            padding: theme.mainIndicatorPadding,
            calcParams: [
              MaParam(
                count: 5,
                tips: TipsConfig(
                  label: 'MA5: ',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: theme.normalTextSize,
                    height: defaultTextHeight,
                  ),
                ),
              ),
              MaParam(
                count: 10,
                tips: TipsConfig(
                  label: 'MA10: ',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: theme.normalTextSize,
                    height: defaultTextHeight,
                  ),
                ),
              ),
              MaParam(
                count: 20,
                tips: TipsConfig(
                  label: 'MA20: ',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: theme.normalTextSize,
                    height: defaultTextHeight,
                  ),
                ),
              ),
            ],
            tipsPadding: theme.tipsPadding,
            lineWidth: 1.r,
          ),

      // BOLL 布林带
      const FlexiIndicatorKey('boll'): (setting) => BOLLIndicator(
            height: theme.mainIndicatorHeight,
            padding: theme.mainIndicatorPadding,
            calcParam: const BOLLParam(
              n: 20,
              std: 2,
            ),
            mbTips: const TipsConfig(
              label: 'BOLL: ',
              style: TextStyle(color: Colors.blue, fontSize: 12, height: 1.2),
            ),
            upTips: const TipsConfig(
              label: 'UB: ',
              style: TextStyle(color: Colors.red, fontSize: 12, height: 1.2),
            ),
            dnTips: const TipsConfig(
              label: 'LB: ',
              style: TextStyle(color: Colors.green, fontSize: 12, height: 1.2),
            ),
            tipsPadding: theme.tipsPadding,
            lineWidth: 1.r,
          ),

      // EMA 指数移动平均线
      const FlexiIndicatorKey('ema'): (setting) => EMAIndicator(
            height: theme.mainIndicatorHeight,
            padding: theme.mainIndicatorPadding,
            calcParams: [
              MaParam(
                count: 12,
                tips: TipsConfig(
                  label: 'EMA12: ',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: theme.normalTextSize,
                    height: defaultTextHeight,
                  ),
                ),
              ),
              MaParam(
                count: 26,
                tips: TipsConfig(
                  label: 'EMA26: ',
                  style: TextStyle(
                    color: Colors.purple,
                    fontSize: theme.normalTextSize,
                    height: defaultTextHeight,
                  ),
                ),
              ),
            ],
            tipsPadding: theme.tipsPadding,
            lineWidth: 1.r,
          ),
    };
  }

  // 副指标配置缓存
  Map<IIndicatorKey, IndicatorBuilder>? _cachedSubIndicatorBuilders;

  @override
  Map<IIndicatorKey, IndicatorBuilder> get subIndicatorBuilders {
    if (_cachedSubIndicatorBuilders != null) {
      return _cachedSubIndicatorBuilders!;
    }

    // 从配置中读取副指标配置
    final config = getConfig('subIndicatorBuilders');
    if (config != null) {
      try {
        _cachedSubIndicatorBuilders = _buildSubIndicatorsFromConfig(config);
        return _cachedSubIndicatorBuilders!;
      } catch (e) {
        defLogger.e('Failed to build sub indicators from config: $e');
      }
    }

    // 默认配置
    _cachedSubIndicatorBuilders = _getDefaultSubIndicators();

    // 调用super以满足@mustCallSuper要求
    final superBuilders = super.subIndicatorBuilders;
    _cachedSubIndicatorBuilders!.addAll(superBuilders);

    return _cachedSubIndicatorBuilders!;
  }

  Map<IIndicatorKey, IndicatorBuilder> _getDefaultSubIndicators() {
    final theme = ref.read(bitFlexiKlineThemeProvider);
    return {
      // RSI 相对强弱指标
      const FlexiIndicatorKey('rsi'): (setting) => RSIIndicator(
            height: 100.r,
            calcParams: [
              const RsiParam(
                count: 6,
                tips: TipsConfig(
                  label: 'RSI6: ',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ),
              const RsiParam(
                count: 12,
                tips: TipsConfig(
                  label: 'RSI12: ',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ),
              const RsiParam(
                count: 24,
                tips: TipsConfig(
                  label: 'RSI24: ',
                  style: TextStyle(
                    color: Colors.purple,
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ),
            ],
            tipsPadding: theme.tipsPadding,
            lineWidth: 1.r,
            precision: 2,
          ),

      // KDJ 随机指标
      const FlexiIndicatorKey('kdj'): (setting) => KDJIndicator(
            height: 100.r,
            calcParam: const KDJParam(
              n: 9,
              m1: 3,
              m2: 3,
            ),
            ktips: const TipsConfig(
              label: 'K: ',
              style: TextStyle(color: Colors.blue, fontSize: 12, height: 1.2),
            ),
            dtips: const TipsConfig(
              label: 'D: ',
              style: TextStyle(color: Colors.red, fontSize: 12, height: 1.2),
            ),
            jtips: const TipsConfig(
              label: 'J: ',
              style: TextStyle(color: Colors.green, fontSize: 12, height: 1.2),
            ),
            tipsPadding: theme.tipsPadding,
            lineWidth: 1.r,
            precision: 2,
          ),

      // MACD 指数平滑异同移动平均线
      const FlexiIndicatorKey('macd'): (setting) => MACDIndicator(
            height: 120.r,
            calcParam: const MACDParam(
              s: 12,
              l: 26,
              m: 9,
            ),
            difTips: const TipsConfig(
              label: 'DIF: ',
              style: TextStyle(color: Colors.blue, fontSize: 12, height: 1.2),
            ),
            deaTips: const TipsConfig(
              label: 'DEA: ',
              style: TextStyle(color: Colors.red, fontSize: 12, height: 1.2),
            ),
            macdTips: const TipsConfig(
              label: 'MACD: ',
              style: TextStyle(color: Colors.green, fontSize: 12, height: 1.2),
            ),
            tipsPadding: theme.tipsPadding,
            lineWidth: 1.r,
            precision: 2,
          ),

      // VOLUME 成交量
      const FlexiIndicatorKey('volume'): (setting) => VolumeIndicator(
            height: 80.r,
            padding: theme.subIndicatorPadding,
            volTips: const TipsConfig(
              label: 'VOL: ',
              style: TextStyle(color: Colors.blue, fontSize: 12, height: 1.2),
            ),
            tipsPadding: theme.tipsPadding,
            precision: 2,
          ),
    };
  }

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

  // 根据配置创建指标构建器
  IndicatorBuilder _createIndicatorBuilderFromConfig(
      Map<String, dynamic> config, BaseBitFlexiKlineTheme theme) {
    final type = config['type'] as String?;

    switch (type) {
      case 'ma':
        return (setting) => MAIndicator(
              height: (config['height'] as num?)?.toDouble() ?? theme.mainIndicatorHeight,
              padding: theme.mainIndicatorPadding,
              calcParams: _parseMaParams(config['calcParams']),
              tipsPadding: theme.tipsPadding,
              lineWidth: 1.r,
            );

      case 'boll':
        return (setting) => BOLLIndicator(
              height: (config['height'] as num?)?.toDouble() ?? theme.mainIndicatorHeight,
              padding: theme.mainIndicatorPadding,
              calcParam: _parseBOLLParam(config['calcParam']),
              mbTips: _parseTipsConfig(config['mbTips']) ??
                  const TipsConfig(
                    label: 'BOLL: ',
                    style: TextStyle(color: Colors.blue, fontSize: 12, height: 1.2),
                  ),
              upTips: _parseTipsConfig(config['upTips']) ??
                  const TipsConfig(
                    label: 'UB: ',
                    style: TextStyle(color: Colors.red, fontSize: 12, height: 1.2),
                  ),
              dnTips: _parseTipsConfig(config['dnTips']) ??
                  const TipsConfig(
                    label: 'LB: ',
                    style: TextStyle(color: Colors.green, fontSize: 12, height: 1.2),
                  ),
              tipsPadding: theme.tipsPadding,
              lineWidth: 1.r,
            );

      case 'ema':
        return (setting) => EMAIndicator(
              height: (config['height'] as num?)?.toDouble() ?? theme.mainIndicatorHeight,
              padding: theme.mainIndicatorPadding,
              calcParams: _parseMaParams(config['calcParams']),
              tipsPadding: theme.tipsPadding,
              lineWidth: 1.r,
            );

      case 'rsi':
        return (setting) => RSIIndicator(
              height: (config['height'] as num?)?.toDouble() ?? 100.r,
              calcParams: _parseRsiParams(config['calcParams']),
              tipsPadding: theme.tipsPadding,
              lineWidth: 1.r,
              precision: (config['precision'] as num?)?.toInt() ?? 2,
            );

      case 'kdj':
        return (setting) => KDJIndicator(
              height: (config['height'] as num?)?.toDouble() ?? 100.r,
              calcParam: _parseKDJParam(config['calcParam']),
              ktips: _parseTipsConfig(config['ktips']) ??
                  const TipsConfig(
                    label: 'K: ',
                    style: TextStyle(color: Colors.blue, fontSize: 12, height: 1.2),
                  ),
              dtips: _parseTipsConfig(config['dtips']) ??
                  const TipsConfig(
                    label: 'D: ',
                    style: TextStyle(color: Colors.red, fontSize: 12, height: 1.2),
                  ),
              jtips: _parseTipsConfig(config['jtips']) ??
                  const TipsConfig(
                    label: 'J: ',
                    style: TextStyle(color: Colors.green, fontSize: 12, height: 1.2),
                  ),
              tipsPadding: theme.tipsPadding,
              lineWidth: 1.r,
              precision: (config['precision'] as num?)?.toInt() ?? 2,
            );

      case 'macd':
        return (setting) => MACDIndicator(
              height: (config['height'] as num?)?.toDouble() ?? 120.r,
              calcParam: _parseMACDParam(config['calcParam']),
              difTips: _parseTipsConfig(config['difTips']) ??
                  const TipsConfig(
                    label: 'DIF: ',
                    style: TextStyle(color: Colors.blue, fontSize: 12, height: 1.2),
                  ),
              deaTips: _parseTipsConfig(config['deaTips']) ??
                  const TipsConfig(
                    label: 'DEA: ',
                    style: TextStyle(color: Colors.red, fontSize: 12, height: 1.2),
                  ),
              macdTips: _parseTipsConfig(config['macdTips']) ??
                  const TipsConfig(
                    label: 'MACD: ',
                    style: TextStyle(color: Colors.green, fontSize: 12, height: 1.2),
                  ),
              tipsPadding: theme.tipsPadding,
              lineWidth: 1.r,
              precision: (config['precision'] as num?)?.toInt() ?? 2,
            );

      case 'volume':
        return (setting) => VolumeIndicator(
              height: (config['height'] as num?)?.toDouble() ?? 80.r,
              padding: theme.subIndicatorPadding,
              volTips: _parseTipsConfig(config['volTips']) ??
                  const TipsConfig(
                    label: 'VOL: ',
                    style: TextStyle(color: Colors.blue, fontSize: 12, height: 1.2),
                  ),
              tipsPadding: theme.tipsPadding,
              precision: (config['precision'] as num?)?.toInt() ?? 2,
            );

      default:
        throw ArgumentError('Unknown indicator type: $type');
    }
  }

  // 解析参数的辅助方法
  List<MaParam> _parseMaParams(dynamic params) {
    if (params is! List) return [];
    return params.map((p) {
      if (p is Map<String, dynamic>) {
        return MaParam(
          count: (p['count'] as num?)?.toInt() ?? 5,
          tips: _parseTipsConfig(p['tips']) ??
              const TipsConfig(
                label: 'MA: ',
                style: TextStyle(color: Colors.blue, fontSize: 12, height: 1.2),
              ),
        );
      }
      return const MaParam(
        count: 5,
        tips: TipsConfig(
          label: 'MA: ',
          style: TextStyle(color: Colors.blue, fontSize: 12, height: 1.2),
        ),
      );
    }).toList();
  }

  BOLLParam _parseBOLLParam(dynamic param) {
    if (param is Map<String, dynamic>) {
      return BOLLParam(
        n: (param['n'] as num?)?.toInt() ?? 20,
        std: (param['std'] as num?)?.toInt() ?? 2,
      );
    }
    return const BOLLParam(n: 20, std: 2);
  }

  List<RsiParam> _parseRsiParams(dynamic params) {
    if (params is! List) return [];
    return params.map((p) {
      if (p is Map<String, dynamic>) {
        return RsiParam(
          count: (p['count'] as num?)?.toInt() ?? 6,
          tips: _parseTipsConfig(p['tips']) ??
              const TipsConfig(
                label: 'RSI: ',
                style: TextStyle(color: Colors.orange, fontSize: 12, height: 1.2),
              ),
        );
      }
      return const RsiParam(
        count: 6,
        tips: TipsConfig(
          label: 'RSI: ',
          style: TextStyle(color: Colors.orange, fontSize: 12, height: 1.2),
        ),
      );
    }).toList();
  }

  KDJParam _parseKDJParam(dynamic param) {
    if (param is Map<String, dynamic>) {
      return KDJParam(
        n: (param['n'] as num?)?.toInt() ?? 9,
        m1: (param['m1'] as num?)?.toInt() ?? 3,
        m2: (param['m2'] as num?)?.toInt() ?? 3,
      );
    }
    return const KDJParam(n: 9, m1: 3, m2: 3);
  }

  MACDParam _parseMACDParam(dynamic param) {
    if (param is Map<String, dynamic>) {
      return MACDParam(
        s: (param['s'] as num?)?.toInt() ?? 12,
        l: (param['l'] as num?)?.toInt() ?? 26,
        m: (param['m'] as num?)?.toInt() ?? 9,
      );
    }
    return const MACDParam(s: 12, l: 26, m: 9);
  }

  TipsConfig? _parseTipsConfig(dynamic tips) {
    if (tips is Map<String, dynamic>) {
      return TipsConfig(
        label: tips['label'] as String? ?? '',
        style: _parseTextStyle(tips['style']),
      );
    }
    return null;
  }

  TextStyle _parseTextStyle(dynamic style) {
    if (style is Map<String, dynamic>) {
      return TextStyle(
        color: _parseColor(style['color']) ?? Colors.blue,
        fontSize: (style['fontSize'] as num?)?.toDouble() ?? 12,
        height: (style['height'] as num?)?.toDouble() ?? 1.2,
      );
    }
    return const TextStyle(color: Colors.blue, fontSize: 12, height: 1.2);
  }

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

  // 便民方法：设置主指标配置
  Future<bool> setMainIndicatorConfig(Map<String, Map<String, dynamic>> config) {
    return setConfig('mainIndicatorBuilders', config);
  }

  // 便民方法：设置副指标配置
  Future<bool> setSubIndicatorConfig(Map<String, Map<String, dynamic>> config) {
    return setConfig('subIndicatorBuilders', config);
  }
}
