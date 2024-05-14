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

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../constant.dart';
import '../model/export.dart';
import '../utils/export.dart';
import 'binding_base.dart';
import 'interface.dart';

mixin SettingBinding on KlineBindingBase implements ISetting, IConfig {
  @override
  void init() {
    _settingConfig = SettingConfig.fromJson(settingConfigData);
    logd('init setting');
    super.init();
  }

  @override
  void initState() {
    super.initState();
    logd("initState setting");
  }

  @override
  void dispose() {
    super.dispose();
    logd("dispose setting");
  }

  @override
  void storeState() {
    super.storeState();
    logd("storeState setting");
    storeSettingData(settingConfig);
  }

  @override
  void loadConfig(Map<String, dynamic> configData) {
    logd("loadConfig setting");
    _settingConfig = SettingConfig.fromJson(configData);
    super.loadConfig(configData);
  }

  late SettingConfig _settingConfig;

  @override
  SettingConfig get settingConfig => _settingConfig;

  VoidCallback? onSizeChange;
  ValueChanged<bool>? onLoading;

  Color get longColor => settingConfig.longColor;
  Color get shortColor => settingConfig.shortColor;
  Color get longTintColor => settingConfig.longTintColor;
  Color get shortTintColor => settingConfig.shortTintColor;

  /// Loading配置
  double get loadingProgressSize => settingConfig.loadingProgressSize;
  double get loadingProgressStrokeWidth =>
      settingConfig.loadingProgressStrokeWidth;
  Color get loadingProgressBackgroundColor =>
      settingConfig.loadingProgressBackgroundColor;
  Color get loadingProgressValueColor =>
      settingConfig.loadingProgressValueColor;

  /// 一个像素的值.
  double get pixel {
    final mediaQuery = MediaQueryData.fromView(ui.window);
    return 1.0 / mediaQuery.devicePixelRatio;
  }

  /// 整个画布区域大小 = 由主图区域 + 副图区域
  Rect get canvasRect => Rect.fromLTRB(
        mainRect.left,
        mainRect.top,
        math.max(mainRectSize.width, subRectSize.width),
        mainRectSize.height + subRectSize.height,
      );
  double get canvasWidth => canvasRect.width;
  double get canvasHeight => canvasRect.height;

  /// 主图区域大小
  // Rect _mainRect = Rect.zero;
  Rect get mainRect => settingConfig.mainRect;
  Size get mainRectSize => Size(mainRect.width, mainRect.height);
  void setMainSize(Size size) {
    settingConfig.mainRect = Rect.fromLTRB(
      0,
      0,
      size.width,
      size.height,
    );
    updateMainIndicatorParam(height: size.height);
    onSizeChange?.call();
  }

  /// 主图总宽度
  double get mainRectWidth => mainRect.width;

  /// 主图总高度
  double get mainRectHeight => mainRect.height;

  /// 主图区域的tips高度
  double get mainTipsHeight => settingConfig.mainTipsHeight;

  /// 主图上下padding
  EdgeInsets get mainPadding => settingConfig.mainPadding;

  Rect get mainDrawRect => Rect.fromLTRB(
        mainRect.left + mainPadding.left,
        mainRect.top + mainPadding.top,
        mainRect.right - mainPadding.right,
        mainRect.bottom - mainPadding.bottom,
      );

  /// X轴主绘制区域真实宽.
  double get mainDrawWidth => mainRectWidth - mainPadding.horizontal;

  /// Y轴主绘制区域真实高.
  double get mainDrawHeight => mainRectHeight - mainPadding.vertical;

  /// X轴上主绘制区域宽度的半值.
  double get mainDrawWidthHalf => mainDrawWidth / 2;

  /// X轴主绘制区域的左边界值
  double get mainDrawLeft => mainPadding.left;

  /// X轴主绘制区域右边界值
  double get mainDrawRight => mainRectWidth - mainPadding.right;

  /// Y轴主绘制区域上边界值
  double get mainDrawTop => mainPadding.top;

  /// Y轴主绘制区域下边界值
  double get mainDrawBottom => mainRectHeight - mainPadding.bottom;

  bool checkOffsetInMainRect(Offset offset) {
    return mainRect.contains(offset);
  }

  double clampDxInMain(double dx) => dx.clamp(mainDrawLeft, mainDrawRight);
  double clampDyInMain(double dy) => dy.clamp(mainDrawTop, mainDrawBottom);

  /// 绘制区域最少留白比例
  /// 例如: 当蜡烛数量不足以绘制一屏, 向右移动到末尾时, 绘制区域左边最少留白区域占可绘制区域(canvasWidth)的比例
  // double _minPaintBlankRate = 0.5;
  // double get minPaintBlankRate => settingData.minPaintBlankRate;
  // set minPaintBlankRate(double val) {
  //   settingData.minPaintBlankRate = val.clamp(0, 0.9);
  // }

  /// 绘制区域最少留白宽度.
  double get minPaintBlankWidth =>
      mainDrawWidth * settingConfig.minPaintBlankRate.clamp(0, 0.9);

  /// 如果足够总是计算一屏的蜡烛.
  /// 当滑动或初始化时会存在(minPaintBlankRate)的空白, 此时, 计算按一屏的蜡烛数量向后计算.
  // bool get alwaysCalculateScreenOfCandlesIfEnough =>
  //     settingData.alwaysCalculateScreenOfCandlesIfEnough;

  // Gesture Pan
  // 平移结束后, candle惯性平移, 持续的最长时间.
  @Deprecated('待优化')
  int panMaxDurationWhenPanEnd = 1000;
  // 平移结束后, candle惯性平移, 此时每一帧移动的最大偏移量. 值越大, 移动的会越远.
  double panMaxOffsetPreFrameWhenPanEnd = 30.0;

  /// 最大蜡烛宽度[1, 50]
  // double _candleMaxWidth = 40.0;
  double get candleMaxWidth => settingConfig.candleMaxWidth;
  set candleMaxWidth(double width) {
    settingConfig.candleMaxWidth = width.clamp(1.0, 50.0);
  }

  /// 单根蜡烛宽度
  // double _candleWidth = 8.0;
  double get candleWidth => settingConfig.candleWidth;
  set candleWidth(double width) {
    // 限制蜡烛宽度范围[1, candleMaxWidth]
    settingConfig.candleWidth = width.clamp(1.0, candleMaxWidth);
  }

  /// 蜡烛间距
  double get candleSpacing => settingConfig.candleSpacing;

  /// 单根蜡烛所占据实际宽度
  double get candleActualWidth => candleWidth + candleSpacing;

  /// 单根蜡烛的一半
  double get candleWidthHalf => candleActualWidth / 2;

  /// 绘制区域宽度内, 可绘制的蜡烛数
  int get maxCandleCount => (mainDrawWidth / candleActualWidth).ceil();

  // /// 绘制线图的默认线宽
  // double get indicatorLineWidth => settingData.indicatorLineWidth;

  // /// 指标图 涨跌 bar/line 配置
  // // 实心
  // Paint get defLongBarPaint => Paint()
  //   ..color = longColor
  //   ..style = PaintingStyle.stroke
  //   ..strokeWidth = candleWidth;
  // Paint get defShortBarPaint => Paint()
  //   ..color = shortColor
  //   ..style = PaintingStyle.stroke
  //   ..strokeWidth = candleWidth;
  // // 实心, 浅色
  // Paint get defLongTintBarPaint => Paint()
  //   ..color = longTintColor
  //   ..style = PaintingStyle.stroke
  //   ..strokeWidth = candleWidth;
  // Paint get defShortTintBarPaint => Paint()
  //   ..color = shortTintColor
  //   ..style = PaintingStyle.stroke
  //   ..strokeWidth = candleWidth;
  // // 空心
  // Paint get defLongHollowBarPaint => Paint()
  //   ..color = longColor
  //   ..style = PaintingStyle.stroke
  //   ..strokeWidth = 1;
  // Paint get defShortHollowBarPaint => Paint()
  //   ..color = shortColor
  //   ..style = PaintingStyle.stroke
  //   ..strokeWidth = 1;
  // // 线
  // double get candleLineWidth => settingData.candleLineWidth;
  // Paint get defLongLinePaint => Paint()
  //   ..color = longColor
  //   ..style = PaintingStyle.stroke
  //   ..strokeWidth = candleLineWidth;
  // Paint get defShortLinePaint => Paint()
  //   ..color = shortColor
  //   ..style = PaintingStyle.stroke
  //   ..strokeWidth = candleLineWidth;

  // Candle 第一根Candle相对于mainRect右边的偏移
  double get firstCandleInitOffset => settingConfig.firstCandleInitOffset;

  /// Grid Axis config
  // 主图区域grid数量
  // int get gridCount => settingData.gridCount;
  // // 主图区域grid线的颜色
  // Color get gridLineColor => settingData.gridLineColor;
  // // 主图区域grid线的宽度(默认1像素)
  // double get gridLineWidth => settingData.gridLineWidth;
  // int get gridXAxisCount => gridCount + 1; // 平分5份: 上下边线都展示
  // int get gridYAxisCount => gridCount - 1; // 平分5份: 左右边线不展示
  // Paint get gridXAxisLinePaint => Paint()
  //   ..color = gridLineColor
  //   ..style = PaintingStyle.stroke
  //   ..strokeWidth = gridLineWidth;
  // Paint get gridYAxisLinePaint => Paint()
  //   ..color = gridLineColor
  //   ..style = PaintingStyle.stroke
  //   ..strokeWidth = gridLineWidth;

  /// Y轴上刻度线配置
  // // Y轴刻度字体大小
  // double yAxisTickTextSize = 10;
  // // Y轴刻度字体颜色
  // Color yAxisTickTextColor = Colors.black;
  // // Y轴刻度字体高度
  // double yAxisTickTextHeight = 1;

  /// 全局默认的Y轴刻度值配置.
  // TextStyle? _defaultYAxisTickTextStyle;
  // Y轴刻度字体样式
  // TextStyle get defaultYAxisTickTextStyle =>
  //     _defaultYAxisTickTextStyle ??
  //     const TextStyle(
  //       fontSize: 10,
  //       color: Colors.black,
  //       overflow: TextOverflow.ellipsis,
  //       height: 1,
  //     );
  // Y轴刻度区域padding
  // EdgeInsets? _defaultYAxisTickRectPadding;
  // EdgeInsets get defaultYAxisTickRectPadding =>
  //     _defaultYAxisTickRectPadding ??
  //     const EdgeInsets.only(
  //       right: 2,
  //     );

  /// 全局默认文本配置: TextStyle / Background / Border
  // TextStyle get defaultTextStyle => settingData.defaultTextStyle;
  // TextStyle get longTextStyle => settingData.longTextStyle;
  // TextStyle get shortTextStyle => settingData.shortTextStyle;
  // EdgeInsets get defaultPadding => settingData.defaultPadding;
  // 默认线颜色
  // Color? _defaultLineColor;
  // Color get defaultLineColor => _defaultLineColor ?? Colors.black;
  // // 默认背景色
  // Color? _defaultRectBackgroundColor;
  // Color get defaultRectBackgroundColor =>
  //     _defaultRectBackgroundColor ?? Colors.white;
  // Color? _defaultRectBorderColor;
  // Color get defaultRectBorderColor => _defaultRectBorderColor ?? Colors.black;

  /// Cross 配置 ///
  // cross line
  // Color crossLineColor = Colors.black;
  // double crossLineWidth = 0.5;
  // List<double> crossLineDashes = const [3, 3];
  // Paint get crossLinePaint => Paint()
  //   ..color = crossLineColor
  //   ..style = PaintingStyle.stroke
  //   ..strokeWidth = crossLineWidth;
  // // cross point
  // Color corssPointColor = Colors.black;
  // double crossPointRadius = 2;
  // double crossPointWidth = 6;
  // Paint get crossPointPaint => Paint()
  //   ..color = corssPointColor
  //   ..strokeWidth = crossPointWidth
  //   ..style = PaintingStyle.fill;

  // cross Y轴对应刻度文本区域配置 (价钱, Volume ...)
  // double crossYTickFontSize = 10;
  // double crossYTickTextWidth = 100; // TODO 暂无用
  // Color crossYTickColor = Colors.white;
  // TextStyle get crossYTickTextStyle => TextStyle(
  //       fontSize: crossYTickFontSize,
  //       color: crossYTickColor,
  //       overflow: TextOverflow.ellipsis,
  //       height: 1,
  //       textBaseline: TextBaseline.alphabetic,
  //     );

  /// onCross时, 当移动到空白区域时, Tips区域是否展示最新的蜡烛的Tips数据.
  bool showLatestTipsInBlank = true;

  /// onCross时 Y轴对应刻度文本区域配置
  // Color crossYTickRectBackgroundColor = Colors.black;
  // double crossYTickRectBorderRadius = 2;
  // double crossYTickRectBorderWidth = 0.0;
  // Color crossYTickRectBorderColor = Colors.transparent;
  // double crossYTickRectRigthMargin = 1;
  // EdgeInsets crossYTickRectPadding = const EdgeInsets.symmetric(
  //   horizontal: 2,
  //   vertical: 2,
  // );
  // cross YAxis Tick Rect总高度.
  // double get crossYTickRectHeight {
  //   final textHeight = crossYTickFontSize * (crossYTickTextStyle.height ?? 1);
  //   return textHeight + crossYTickRectPadding.vertical;
  // }

  /// Cross X轴对应刻度文本配置(时间)
  // double crossXTickFontSize = 10;
  // double crossXTickTextWidth = 100; // TODO 暂无用
  // Color crossXTickColor = Colors.white;
  // TextStyle get crossXTickTextStyle => TextStyle(
  //       fontSize: crossXTickFontSize,
  //       color: crossXTickColor,
  //       overflow: TextOverflow.ellipsis,
  //       height: 1,
  //       textBaseline: TextBaseline.alphabetic,
  //     );
  // cross X轴对应刻度文本区域的配置
  // Color crossXTickRectBackgroundColor = Colors.black;
  // double crossXTickRectBorderRadius = 2;
  // double crossXTickRectBorderWidth = 0.0;
  // Color crossXTickRectBorderColor = Colors.transparent;
  // EdgeInsets crossXTickRectPadding = const EdgeInsets.symmetric(
  //   horizontal: 2,
  //   vertical: 2,
  // );
  // double get crossXTickRectHeight {
  //   final textHeight = crossXTickFontSize * (crossXTickTextStyle.height ?? 1);
  //   return textHeight + crossXTickRectPadding.vertical;
  // }

  // candle Card 配置
  bool showPopupCandleCard = true;

  // candle Card background config.
  Color candleCardRectBackgroundColor = const Color(0xFFF2F2F2);
  double candleCardRectBorderRadius = 4;
  EdgeInsets candleCardRectMargin = const EdgeInsets.only(
    left: 15,
    right: 65,
    top: 4,
  );
  EdgeInsets candleCardRectPadding = const EdgeInsets.symmetric(
    horizontal: 4,
    vertical: 4,
  );

  double candleCardTextSize = 10;
  double candleCardTextHeight = 1.5; // 文本跨度的高度，为字体大小的倍数
  TextStyle get candleCardTextStyle => TextStyle(
        fontSize: candleCardTextSize,
        color: Colors.black,
        overflow: TextOverflow.ellipsis,
        height: candleCardTextHeight,
        textBaseline: TextBaseline.alphabetic,
      );

  // candle Card Title Style
  TextStyle? _candleCardTitleStyle;
  TextStyle get candleCardTitleStyle =>
      _candleCardTitleStyle ?? candleCardTextStyle;
  set candleCardTitleStyle(TextStyle style) => _candleCardTitleStyle = style;

  // candle Card Value Style
  TextStyle? _candleCardValueStyle;
  TextStyle get candleCardValueStyle =>
      _candleCardValueStyle ?? candleCardTextStyle;
  set candleCardValueStyle(TextStyle style) => _candleCardValueStyle = style;

  // Cross Candle Long Style
  TextStyle? _candleCardLongStyle;
  TextStyle get candleCardLongStyle =>
      _candleCardLongStyle ??
      candleCardTextStyle.copyWith(
        color: longColor,
      );
  set candleCardLongStyle(TextStyle style) => _candleCardLongStyle = style;

  // candle Card Short Style
  TextStyle? _candleCardShortStyle;
  TextStyle get candleCardShortStyle =>
      _candleCardShortStyle ??
      candleCardTextStyle.copyWith(
        color: shortColor,
      );
  set candleCardShortStyle(TextStyle style) => _candleCardShortStyle = style;

  // candle Card信息多语言配置.
  List<String> _i18nCandleCardKeys = i18nCandleCardEn;
  List<String> get i18nCandleCardKeys => _i18nCandleCardKeys;
  set i18nCandleCardKeys(List<String> keys) {
    if (keys.isNotEmpty && keys.length == i18nCandleCardEn.length) {
      _i18nCandleCardKeys = keys;
    }
  }

  //////////////////////////////////////

  /// 价钱格式化函数
  String Function(String instId, Decimal val,
      {int? precision, bool? cutInvalidZero})? priceFormat;

  /// 价钱格式化函数
  /// TODO: 待优化
  String formatPrice(
    Decimal val, {
    int? precision,
    required String instId,
    bool cutInvalidZero = true,
  }) {
    int p = precision ?? defaultPrecision;
    if (priceFormat != null) {
      return priceFormat!.call(
        instId,
        val,
        precision: p,
        cutInvalidZero: cutInvalidZero,
      );
    }
    return formatNumber(
      val,
      precision: p,
      defIfZero: '--',
      cutInvalidZero: cutInvalidZero,
      // showThousands: true,
    );
  }

  /// 时间格式化函数
  String Function(DateTime dateTime)? dateTimeFormat;
  String formatDateTime(DateTime dateTime) {
    if (dateTimeFormat != null) {
      return dateTimeFormat!.call(dateTime);
    }
    return formatyyMMddHHMMss(dateTime);
  }

  /// 定制展示Candle Card info.
  List<CardInfo> Function(CandleModel model)? customCandleCardInfo;

  ///////////////////////////////////////////
  /// 以下是副图的绘制配置 /////////////////////
  //////////////////////////////////////////
  /// 副图整个区域
  Rect get subRect => Rect.fromLTRB(
        mainRect.left,
        mainRect.bottom,
        mainRect.right,
        mainRect.bottom + subRectHeight,
      );

  /// 副图整个区域大小
  Size get subRectSize => Size(subRect.width, subRect.height);

  /// 副区的指标图最大数量
  int get subChartMaxCount => settingConfig.subChartMaxCount;

  /// 副区的单个指标图默认配置
  // final double subChartDefaultHeight = defaultSubIndicatorHeight;
  // final double subChartDefaultTipsHeight = defaultIndicatorTipsHeight;
  // final EdgeInsets subChartDefaultPadding = const EdgeInsets.only(
  //   left: 8,
  // );

  /// 副区的指标图的右侧右侧刻度数量
  // int subChartYAxisTickCount = 3; // 高中低=>top, middle, bottom

  /// Tips文本区域默认配置
  // tips默认字体大小
  // double tipsDefaultTextSize = 10;
  // // tips默认字体高度
  // double tipsDefaultTextHeight = 1.2;
  // // tips默认字体颜色
  // Color tipsDefaultTextColor = Colors.black;
  // EdgeInsets tipsRectDefaultPadding = const EdgeInsets.only(
  //   left: 8,
  // );
}
