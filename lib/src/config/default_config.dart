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

import 'package:flutter/material.dart' hide Overlay;

import '../constant.dart';
import '../draw_objects/export.dart';
import '../extension/basic_type_ext.dart';
import '../extension/render/common.dart';
import '../framework/export.dart';
import '../indicators/export.dart';
import 'cross_config/cross_config.dart';
import 'draw_config/draw_config.dart';
import 'flexi_kline_config/flexi_kline_config.dart';
import 'gesture_config/gesture_config.dart';
import 'grid_config/grid_config.dart';
import 'line_config/line_config.dart';
import 'loading_config/loading_config.dart';
import 'magnifier_config/magnifier_config.dart';
import 'mark_config/mark_config.dart';
import 'paint_config/paint_config.dart';
import 'point_config/point_config.dart';
import 'setting_config/setting_config.dart';
import 'text_area_config/text_area_config.dart';
import 'tips_config/tips_config.dart';
import 'tolerance_config/tolerance_config.dart';
import 'tooltip_config/tooltip_config.dart';

extension IFlexiKlineThemeExt on IFlexiKlineTheme {
  /// 默认时间指标高度
  double get timeIndicatorHeight {
    return defaultTimeIndicatorHeight * scale;
  }

  /// 默认副图指标高度
  double get subIndicatorHeight {
    return defaultSubIndicatorHeight * scale;
  }

  /// 默认主图指标高度
  double get mainIndicatorHeight {
    return defaultMainIndicatorHeight * scale;
  }

  /// 默认主图区域Padding
  EdgeInsets get mainIndicatorPadding => EdgeInsets.only(
        top: 5 * scale, // 顶部留白
        bottom: 5 * scale, // 底部留白, 5: 最低价字体高度的一半, 保证最低价文本不会绘制到边线上.
      );

  /// 默认副指标图Padding
  EdgeInsets get subIndicatorPadding => EdgeInsets.only(top: 12 * scale);

  /// 默认Tips文本区域的Padding: 左边缩进8个单位
  EdgeInsets get tipsPadding => EdgeInsets.only(left: 8 * scale);

  /// 默认文本区域Padding
  EdgeInsets get textPading => EdgeInsets.all(2 * scale);

  /// 默认指标线图的宽度
  double get indicatorLineWidth {
    return defaultIndicatorLineWidth * scale;
  }

  // 默认文本配置
  double get normalTextSize => setSp(defaulTextSize);
}

abstract class BaseFlexiKlineTheme implements IFlexiKlineTheme {
  const BaseFlexiKlineTheme({
    required this.long,
    required this.short,
    required this.indraTodayAvgColor,
    required this.indraTodayCloseColor,
    required this.dragBg,
    required this.chartBg,
    required this.tooltipBg,
    required this.crossTextBg,
    this.transparent = Colors.transparent,
    required this.latestPriceTextBg,
    required this.lastPriceTextBg,
    required this.countDownTextBg,
    required this.gridLine,
    required this.crossColor,
    required this.drawColor,
    required this.markLineColor,
    required this.lineChartColor,
    required this.themeColor,
    required this.textColor,
    required this.ticksTextColor,
    required this.lastPriceTextColor,
    required this.crossTextColor,
    required this.tooltipTextColor,
  });

  @override
  final Color long;
  @override
  final Color short;

  @override
  final Color indraTodayAvgColor;

  @override
  final Color indraTodayCloseColor;

  /// 背景色
  @override
  final Color dragBg;
  @override
  final Color chartBg;
  @override
  final Color tooltipBg;
  @override
  final Color crossTextBg;
  @override
  final Color transparent;
  @override
  final Color latestPriceTextBg;
  @override
  final Color lastPriceTextBg;
  @override
  final Color countDownTextBg;

  /// 分隔线
  @override
  final Color gridLine;
  @override
  final Color crossColor;
  @override
  final Color drawColor;
  @override
  final Color markLineColor;
  @override
  final Color lineChartColor;
  @override
  final Color themeColor;

  /// 文本颜色配置
  @override
  final Color textColor;
  @override
  final Color ticksTextColor;
  @override
  final Color lastPriceTextColor;
  @override
  final Color crossTextColor;
  @override
  final Color tooltipTextColor;
}

/// 通过[IFlexiKlineTheme]来配置FlexiKline基类.
mixin FlexiKlineThemeConfigurationMixin implements IConfiguration {
  /// 扩展[key]
  String getCacheKey(String key) => '$configKey-$key';

  @override
  FlexiKlineConfig generateFlexiKlineConfig([Map<String, dynamic>? origin]) {
    return FlexiKlineConfig(
      grid: genGridConfig(),
      setting: genSettingConfig(),
      gesture: genGestureConfig(),
      cross: genCrossConfig(),
      draw: genDrawConfig(),
      mainIndicator: genMainIndicator(),
      sub: {},
    );
  }

  @override
  IndicatorBuilder<CandleIndicator> get candleIndicatorBuilder {
    return (json) => genCandleIndicator(
          jsonToInstance(json, CandleIndicator.fromJson),
        );
  }

  @override
  IndicatorBuilder<TimeIndicator> get timeIndicatorBuilder {
    return (json) => genTimeIndicator(
          jsonToInstance(json, TimeIndicator.fromJson),
        );
  }

  @override
  Map<IIndicatorKey, IndicatorBuilder> get mainIndicatorBuilders {
    return {
      // MA 移动平均线 - 主图指标
      const FlexiIndicatorKey('ma'): (json) => MAIndicator(
            height: theme.mainIndicatorHeight,
            padding: theme.mainIndicatorPadding,
            calcParam: const MaParam(
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
      const FlexiIndicatorKey('boll'): (json) => BOLLIndicator(
            height: theme.mainIndicatorHeight,
            padding: theme.mainIndicatorPadding,
            calcParam: const BOLLParam(), // 使用默认参数
            tipsPadding: theme.tipsPadding,
          ),

      // EMA 指数移动平均线 - 主图指标
      const FlexiIndicatorKey('ema'): (json) => EMAIndicator(
            height: theme.mainIndicatorHeight,
            padding: theme.mainIndicatorPadding,
            calcParam: const EmaParam(
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
      const FlexiIndicatorKey('sar'): (json) => SARIndicator(
            height: theme.mainIndicatorHeight,
            padding: theme.mainIndicatorPadding,
            calcParam: const SARParam(), // 使用默认参数
            tipsPadding: theme.tipsPadding,
            tickCount: 5,
          ),

      // AVL 威廉分形指标 - 主图指标
      const FlexiIndicatorKey('avl'): (json) => AVLIndicator(
            height: theme.mainIndicatorHeight,
            padding: theme.mainIndicatorPadding,
            calcParam: const AVLParam(), // 使用默认参数
            tipsPadding: theme.tipsPadding,
            tickCount: 5,
          ),
    };
  }

  @override
  Map<IIndicatorKey, IndicatorBuilder> get subIndicatorBuilders {
    return {
      // VOL_MA 成交量移动平均线 - 副图指标
      const FlexiIndicatorKey('volMa'): (json) => VolMaIndicator(
            height: theme.subIndicatorHeight,
            calcParam: const VolMaParam(
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
      const FlexiIndicatorKey('volume'): (json) => VolumeIndicator(
            height: theme.subIndicatorHeight,
            calcParam: const VolumeParam(), // 使用默认参数
            tipsPadding: theme.tipsPadding,
            tickCount: 5,
          ),

      // RSI 相对强弱指标 - 副图指标
      const FlexiIndicatorKey('rsi'): (json) => RSIIndicator(
            height: theme.subIndicatorHeight,
            calcParam: const RsiParam(
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
            tickCount: 5,
          ),

      // KDJ 随机指标 - 副图指标
      const FlexiIndicatorKey('kdj'): (json) => KDJIndicator(
            height: theme.subIndicatorHeight,
            calcParam: const KDJParam(), // 使用默认参数
            tipsPadding: theme.tipsPadding,
            tickCount: 5,
          ),

      // MACD 指标 - 副图指标
      const FlexiIndicatorKey('macd'): (json) => MACDIndicator(
            height: theme.subIndicatorHeight * 1.2, // MACD需要稍微高一点
            calcParam: const MACDParam(
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
            tickCount: 5,
          ),
    };
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
      const FlexiDrawType('rayLine', 2): (overlay, config) => RayLineDrawObject(overlay, config),

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
      const FlexiDrawType('fibFans', 2): (overlay, config) => FibFansDrawObject(overlay, config),
    };
  }

  /// Grid配置
  GridConfig genGridConfig() {
    return GridConfig(
      show: true,
      horizontal: GridAxis(
        show: true,
        count: 5,
        line: LineConfig(
          type: LineType.solid,
          dashes: const [2, 2],
          paint: PaintConfig(
            color: theme.gridLine,
            strokeWidth: theme.pixel,
          ),
        ),
      ),
      vertical: GridAxis(
        show: true,
        count: 5,
        line: LineConfig(
          type: LineType.solid,
          dashes: const [2, 2],
          paint: PaintConfig(
            color: theme.gridLine,
            strokeWidth: theme.pixel,
          ),
        ),
      ),
      isAllowDragIndicatorHeight: true,
      dragHitTestMinDistance: 10 * theme.scale,
      dragLine: LineConfig(
        type: LineType.dashed,
        dashes: const [3, 5],
        length: 20,
        paint: PaintConfig(
          color: theme.markLineColor,
          strokeWidth: theme.pixel * 5,
        ),
      ),
      dragLineOpacity: 0.1,
      // 全局默认的刻度值配置.
      ticksText: TextAreaConfig(
        style: TextStyle(
          fontSize: theme.normalTextSize,
          color: theme.ticksTextColor,
          overflow: TextOverflow.ellipsis,
          height: defaultTextHeight,
        ),
        textAlign: TextAlign.end,
        padding: EdgeInsets.symmetric(horizontal: 2 * theme.scale),
      ),
    );
  }

  /// Gesture配置
  GestureConfig genGestureConfig() {
    return GestureConfig(
      isInertialPan: true,
      tolerance: ToleranceConfig(),
      loadMoreWhenNoEnoughDistance: null,
      loadMoreWhenNoEnoughCandles: 60,
      scalePosition: ScalePosition.auto,
      scaleSpeed: 10,
      zoomSpeed: 1,
    );
  }

  SettingConfig genSettingConfig() {
    return SettingConfig(
      opacity: 0.5,

      /// 内置LoadingView样式配置
      loading: genInnerLoadingConfig(),

      /// 主区域最小Size
      mainMinSize: Size(120 * theme.scale, 80 * theme.scale),
      subMinHeight: 30 * theme.scale,
      useCandleTicksAsZoomSlideBar: true,

      /// 主/副图绘制参数
      minPaintBlankRate: 0.5,
      alwaysCalculateScreenOfCandlesIfEnough: false,
      candleMinWidth: theme.pixel,
      candleMaxWidth: 40 * theme.scale,
      candleWidth: 7 * theme.scale,
      candleSpacingParts: 7,
      candleFixedSpacing: 1 * theme.scale,
      candleHollowBarBorderWidth: 1 * theme.scale,
      candleLineWidth: 1 * theme.scale,
      firstCandleInitOffset: 80 * theme.scale,

      /// 绘制额外内容是否在允许在主图绘制区域之外
      allowPaintExtraOutsideMainRect: true,

      /// 是否展示Y轴刻度.
      showYAxisTick: true,
    );
  }

  LoadingConfig genInnerLoadingConfig() {
    return LoadingConfig(
      size: 24 * theme.scale,
      strokeWidth: 4 * theme.scale,
      background: theme.tooltipBg,
      valueColor: theme.textColor,
    );
  }

  CrossConfig genCrossConfig() {
    return CrossConfig(
      enable: true,
      crosshair: LineConfig(
        paint: PaintConfig(
          color: theme.crossColor,
          strokeWidth: 0.5 * theme.scale,
        ),
        type: LineType.dashed,
        dashes: const [3, 3],
      ),
      crosspoint: PointConfig(
        radius: 2 * theme.scale,
        width: 0 * theme.scale,
        color: theme.crossColor,
        borderWidth: 3 * theme.scale,
        borderColor: theme.crossColor.withAlpha(0.2.alpha),
      ),
      ticksText: TextAreaConfig(
        style: TextStyle(
          color: theme.crossTextColor,
          fontSize: theme.normalTextSize,
          fontWeight: FontWeight.normal,
          height: defaultTextHeight,
        ),
        background: theme.crossTextBg,
        padding: EdgeInsets.all(2 * theme.scale),
        border: BorderSide.none,
        borderRadius: BorderRadius.all(
          Radius.circular(2 * theme.scale),
        ),
      ),
      spacing: 1 * theme.scale,
      // onCross时, 当移动到空白区域时, Tips区域是否展示最新的蜡烛的Tips数据.
      showLatestTipsInBlank: true,
      tooltipConfig: TooltipConfig(
        show: true,

        /// tooltip 区域设置
        margin: EdgeInsets.only(
          left: 15 * theme.scale,
          right: 65 * theme.scale,
          top: 10 * theme.scale,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 4 * theme.scale,
          vertical: 4 * theme.scale,
        ),
        radius: BorderRadius.all(Radius.circular(4 * theme.scale)),

        /// tooltip 文本设置
        style: TextStyle(
          fontSize: theme.normalTextSize,
          color: theme.tooltipTextColor,
          overflow: TextOverflow.ellipsis,
          height: defaultMultiTextHeight,
        ),
      ),
    );
  }

  DrawConfig genDrawConfig() {
    return DrawConfig(
      enable: true,
      crosshair: LineConfig(
        paint: PaintConfig(
          strokeWidth: 0.5 * theme.scale,
          color: theme.drawColor,
        ),
        type: LineType.dashed,
        dashes: const [5, 3],
      ),
      crosspoint: PointConfig(
        radius: 2 * theme.scale,
        width: 0 * theme.scale,
        color: theme.drawColor,
        borderWidth: 2 * theme.scale,
        borderColor: theme.drawColor.withAlpha(0.5.alpha),
      ),
      drawLine: LineConfig(
        paint: PaintConfig(
          strokeWidth: 1 * theme.scale,
          color: theme.drawColor, // 必须指定
        ),
        type: LineType.solid,
        dashes: [5, 3],
      ),
      drawPoint: PointConfig(
        radius: 9 * theme.scale,
        width: 0 * theme.scale,
        color: const Color(0xFFFFFFFF), // 必须指定
        borderWidth: 1 * theme.scale,
        borderColor: theme.drawColor,
      ),
      ticksText: TextAreaConfig(
        style: TextStyle(
          color: const Color(0xFFFFFFFF), // 必须指定
          fontSize: theme.normalTextSize,
          fontWeight: FontWeight.normal,
          height: defaultTextHeight,
        ),
        padding: EdgeInsets.all(2 * theme.scale),
        border: BorderSide.none,
        borderRadius: BorderRadius.all(
          Radius.circular(2 * theme.scale),
        ),
      ),
      spacing: 1 * theme.scale,
      ticksGapBgOpacity: 0.1,
      hitTestMinDistance: 10 * theme.scale,
      magnetMinDistance: 10 * theme.scale,
      magnifier: MagnifierConfig(
        enable: true,
        magnificationScale: 2,
        margin: EdgeInsets.all(1 * theme.scale),
        size: Size(80 * theme.scale, 80 * theme.scale),
        decorationOpactity: 1.0,
        decorationShadows: [
          BoxShadow(
            offset: const Offset(0.1, 0.1),
            blurRadius: 2,
            spreadRadius: 3,
            color: theme.themeColor.withAlpha(0.1.alpha), // 此处不适配Theme
          )
        ],
        shapeSide: BorderSide(
          color: theme.gridLine,
          width: 1 * theme.scale,
        ),
      ),
    );
  }

  MainPaintObjectIndicator genMainIndicator();

  CandleIndicator genCandleIndicator(CandleIndicator? instance) {
    return CandleIndicator(
      zIndex: -1,
      height: theme.mainIndicatorHeight,
      padding: theme.mainIndicatorPadding,
      high: MarkConfig(
        spacing: 2 * theme.scale,
        line: LineConfig(
          type: LineType.solid,
          length: 20 * theme.scale,
          paint: PaintConfig(
            // color: theme.markLine,
            strokeWidth: 0.5 * theme.scale,
          ),
        ),
        text: TextAreaConfig(
          style: TextStyle(
            fontSize: theme.normalTextSize,
            // color: theme.textColor,
            overflow: TextOverflow.ellipsis,
            height: defaultTextHeight,
          ),
        ),
      ),
      low: MarkConfig(
        spacing: 2 * theme.scale,
        line: LineConfig(
          type: LineType.solid,
          length: 20 * theme.scale,
          paint: PaintConfig(
            // color: theme.markLine,
            strokeWidth: 0.5 * theme.scale,
          ),
        ),
        text: TextAreaConfig(
          style: TextStyle(
            fontSize: theme.normalTextSize,
            // color: theme.textColor,
            overflow: TextOverflow.ellipsis,
            height: defaultTextHeight,
          ),
        ),
      ),
      last: MarkConfig(
        show: true,
        spacing: 1 * theme.scale,
        line: LineConfig(
          type: LineType.dashed,
          dashes: [3, 3],
          paint: PaintConfig(
            // color: theme.markLine,
            strokeWidth: 0.5 * theme.scale,
          ),
        ),
        hitTestMargin: 4,
        text: TextAreaConfig(
          style: TextStyle(
            fontSize: theme.normalTextSize,
            // color: theme.lastPriceTextColor,
            overflow: TextOverflow.ellipsis,
            height: defaultTextHeight,
            textBaseline: TextBaseline.alphabetic,
          ),
          // background: theme.lastPriceTextBg,
          padding: EdgeInsets.symmetric(
            horizontal: 4 * theme.scale,
            vertical: 2 * theme.scale,
          ),
          // border: BorderSide(color: theme.transparent),
          borderRadius: BorderRadius.all(Radius.circular(10 * theme.scale)),
        ),
      ),
      latest: MarkConfig(
        show: true,
        spacing: 1 * theme.scale,
        line: LineConfig(
          type: LineType.dashed,
          dashes: [3, 3],
          paint: PaintConfig(
            // color: theme.markLine,
            strokeWidth: 0.5 * theme.scale,
          ),
        ),
        text: TextAreaConfig(
          style: TextStyle(
            fontSize: theme.normalTextSize,
            color: Colors.white,
            overflow: TextOverflow.ellipsis,
            height: defaultTextHeight,
          ),
          minWidth: 45 * theme.scale,
          textAlign: TextAlign.center,
          padding: theme.textPading,
          borderRadius: BorderRadius.all(Radius.circular(2 * theme.scale)),
        ),
      ),
      useCandleColorAsLatestBg: true,
      showCountDown: true,
      countDown: TextAreaConfig(
        style: TextStyle(
          fontSize: theme.normalTextSize,
          // color: theme.textColor,
          overflow: TextOverflow.ellipsis,
          height: defaultTextHeight,
        ),
        textAlign: TextAlign.center,
        // background: theme.countDownTextBg,
        padding: theme.textPading,
        borderRadius: BorderRadius.all(Radius.circular(2 * theme.scale)),
      ),
      chartBarStyle: instance?.chartBarStyle ?? ChartBarStyle.allSolid,
      chartType: instance?.chartType ?? ChartType.bar,
      zoomToMinChartType: instance?.zoomToMinChartType ?? ChartType.line,
      secondsChartType: instance?.secondsChartType ?? ChartType.line,
      longColor: instance?.longColor,
      shortColor: instance?.shortColor,
      lineColor: instance?.lineColor,
    );
  }

  TimeIndicator genTimeIndicator(TimeIndicator? instance) {
    return TimeIndicator(
      height: theme.timeIndicatorHeight,
      padding: EdgeInsets.zero,
      position: instance?.position ?? DrawPosition.middle,
      // 时间刻度.
      timeTick: TextAreaConfig(
        style: TextStyle(
          fontSize: theme.normalTextSize,
          // color: theme.ticksTextColor,
          overflow: TextOverflow.ellipsis,
          height: defaultTextHeight,
        ),
        textWidth: 80 * theme.scale,
        textAlign: TextAlign.center,
      ),
    );
  }
}
