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
import 'package:flexi_kline/src/framework/draw/overlay.dart' as flexi_overlay show Overlay;
import 'package:flutter/material.dart';
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
          long: theme.long,
          short: theme.short,
          chartBg: theme.pageBg,
          tooltipBg: theme.markBg,
          countDownTextBg: theme.markBg,
          crossTextBg: theme.lightBg,
          drawTextBg: Colors.blue,
          transparent: theme.transparent,
          lastPriceTextBg: theme.translucentBg,
          gridLine: theme.gridLine,
          crossColor: theme.t1,
          drawColor: Colors.blueAccent,
          markLine: theme.t1,
          themeColor: theme.themeColor,
          textColor: theme.t1,
          ticksTextColor: theme.t2,
          lastPriceTextColor: theme.t1,
          crossTextColor: theme.themeColor,
          tooltipTextColor: theme.t1,
        );

  DefaultFlexiKlineTheme.simple({
    required this.theme,
  }) : super.simple(
          long: theme.long,
          short: theme.short,
          chartBg: theme.pageBg,
          markBg: theme.markBg,
          crossTextBg: theme.lightBg,
          lastPriceTextBg: theme.translucentBg,
          color: theme.t1,
          gridLine: theme.gridLine,
          ticksTextColor: theme.t2,
          crossTextColor: theme.themeColor,
        );

  @override
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

  @override
  Size get initialMainSize {
    return Size(ScreenUtil().screenWidth, 300.r);
  }

  @override
  IFlexiKlineTheme get theme => ref.read(defaultKlineThemeProvider);

  @override
  FlexiKlineConfig getFlexiKlineConfig() {
    try {
      final String? jsonStr = CacheUtil().get(theme.key);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final json = jsonDecode(jsonStr);
        if (json is Map<String, dynamic>) {
          //return FlexiKlineConfig.fromJson(json);
        }
      }
    } catch (err, stack) {
      defLogger.e('getFlexiKlineConfig error:$err', stackTrace: stack);
    }

    return genFlexiKlineConfig();
  }

  @override
  FlexiKlineConfig genFlexiKlineConfig() {
    return super.genFlexiKlineConfig()
      ..main.add(const FlexiIndicatorKey('ma'))
      ..sub.add(const FlexiIndicatorKey('rsi'))
      ..trade.add(const FlexiIndicatorKey('trade_mark'));
  }

  @override
  void saveFlexiKlineConfig(FlexiKlineConfig config) {
    final jsonSrc = jsonEncode(config);
    CacheUtil().setString(config.key, jsonSrc);
  }

  @override
  CandleIndicator genCandleIndicator(SettingConfig setting) {
    return super.genCandleIndicator(setting).copyWith(
          useCandleColorAsLatestBg: false, // 不使用蜡烛色做背景
          latest: MarkConfig(
            show: true,
            spacing: 1.r,
            line: LineConfig(
              type: LineType.dashed,
              dashes: [3, 3],
              paint: PaintConfig(
                color: theme.markLine,
                strokeWidth: 0.5.r,
              ),
            ),
            text: TextAreaConfig(
              style: TextStyle(
                fontSize: theme.normalTextSize,
                color: theme.textColor,
                overflow: TextOverflow.ellipsis,
                height: defaultTextHeight,
              ),
              background: theme.chartBg,
              minWidth: 45.r,
              textAlign: TextAlign.center,
              padding: theme.textPading,
              border: BorderSide(color: theme.textColor, width: 0.5.r),
              borderRadius: BorderRadius.all(Radius.circular(2 * theme.scale)),
            ),
          ),
          countDown: TextAreaConfig(
            style: TextStyle(
              fontSize: theme.normalTextSize,
              color: theme.textColor,
              overflow: TextOverflow.ellipsis,
              height: defaultTextHeight,
            ),
            textAlign: TextAlign.center,
            background: theme.countDownTextBg,
            padding: theme.textPading,
            border: BorderSide(color: theme.textColor, width: 0.5.r),
            borderRadius: BorderRadius.all(Radius.circular(2 * theme.scale)),
          ),
        );
  }

  @override
  Map<IIndicatorKey, IndicatorBuilder> mainIndicatorBuilders() {
    final theme = ref.read(defaultKlineThemeProvider);
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

      // SAR 抛物线转向指标
      const FlexiIndicatorKey('sar'): (setting) => SARIndicator(
            height: theme.mainIndicatorHeight,
            padding: theme.mainIndicatorPadding,
            calcParam: const SARParam(
              startAf: 0.02,
              step: 0.02,
              maxAf: 0.2,
            ),
            paint: PaintConfig(
              color: Colors.red,
              strokeWidth: 1.r,
            ),
            tipsPadding: theme.tipsPadding,
            tipsStyle: TextStyle(
              color: Colors.red,
              fontSize: theme.normalTextSize,
              height: defaultTextHeight,
            ),
            tickCount: 5,
          ),

      // AVL 均价线
      const FlexiIndicatorKey('avl'): (setting) => AVLIndicator(
            height: theme.mainIndicatorHeight,
            padding: theme.mainIndicatorPadding,
            calcParam: const AVLParam(),
            line: LineConfig(
              type: LineType.solid,
              paint: PaintConfig(
                color: Colors.deepOrange,
                strokeWidth: 1.r,
              ),
            ),
            tips: TipsConfig(
              label: 'AVL',
              style: TextStyle(
                color: Colors.deepOrange,
                fontSize: theme.normalTextSize,
                height: defaultTextHeight,
              ),
            ),
            tipsPadding: theme.tipsPadding,
          ),
    };
  }

  @override
  Map<IIndicatorKey, IndicatorBuilder> subIndicatorBuilders() {
    final theme = ref.read(defaultKlineThemeProvider);
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

      // VOL_MA 成交量移动平均线
      const FlexiIndicatorKey('volMa'): (setting) => VolMaIndicator(
            height: 100.r,
            volTips: TipsConfig(
              label: 'VOL: ',
              style: TextStyle(
                color: theme.textColor,
                fontSize: theme.normalTextSize,
                height: defaultTextHeight,
              ),
            ),
            calcParams: [
              MaParam(
                count: 5,
                tips: TipsConfig(
                  label: 'VOL_MA5: ',
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
                  label: 'VOL_MA10: ',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: theme.normalTextSize,
                    height: defaultTextHeight,
                  ),
                ),
              ),
            ],
            tipsPadding: theme.tipsPadding,
            maLineWidth: 1.r,
            precision: 2,
          ),

      // VOLUME 成交量
      const FlexiIndicatorKey('volume'): (setting) => VolumeIndicator(
            height: 100.r,
            volTips: TipsConfig(
              label: 'VOL: ',
              style: TextStyle(
                color: theme.textColor,
                fontSize: theme.normalTextSize,
                height: defaultTextHeight,
              ),
            ),
            tipsPadding: theme.tipsPadding,
            tickCount: 5,
            precision: 2,
          ),
    };
  }

  @override
  Map<IIndicatorKey, IndicatorBuilder<Indicator>> tradeIndicatorBuilders() {
    final theme = ref.read(defaultKlineThemeProvider);

    return {
      // 交易标记指标
      const FlexiIndicatorKey('trade_mark'): (setting) => TradeMarkIndicator(
            height: theme.mainIndicatorHeight,
            padding: theme.mainIndicatorPadding,
            calcParam: const TradeMarkParam(
              show: true,
              spacing: 4.0,
              markerRadius: 8.0,
              buyBgColor: Color(0xff03a66d),
              sellBgColor: Color(0xfff15057),
              buyStyle: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              sellStyle: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
    };
  }

  @override
  Iterable<flexi_overlay.Overlay> getOverlayListConfig(String instId) {
    return [];
  }

  @override
  void saveOverlayListConfig(String instId, Iterable<flexi_overlay.Overlay> list) {
    // 暂不实现
  }
}
