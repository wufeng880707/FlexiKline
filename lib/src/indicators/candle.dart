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
import 'package:flutter/material.dart';

import '../constant.dart';
import '../core/export.dart';
import '../data/export.dart';
import '../extension/export.dart';
import '../model/export.dart';
import '../utils/export.dart';
import '../framework/export.dart';

part 'candle.g.dart';

@FlexiIndicatorSerializable
class CandleIndicator extends SinglePaintObjectIndicator {
  CandleIndicator({
    super.key = candleKey,
    super.name = 'Candle',
    required super.height,
    super.tipsHeight,
    super.padding,

    /// 控制开关
    this.isShowLatestPrice = true,
    this.isShowCountDownTime = true,
    this.isShowLastestPriceWhenMoveOffDrawArea = true,

    /// 最新价文字
    this.latestPriceTextStyle,

    /// 最新价文字
    this.countDownTimeTextStyle,

    /// X轴上时间刻度
    this.timeTickTextStyle,
    this.timeTickTextWidth = 80,

    /// Y轴刻度文本
    this.tickTextStyle,
    this.tickPadding,

    /// 背景
    this.latestPriceBackground,
    this.latestPriceRectRadius,
    this.latestPriceBorder,
    this.latestPriceRectPadding,
    this.latestPriceRectRightMinMargin = 1,
    this.latestPriceRectRightMaxMargin = 60,

    /// 最新价刻度线
    this.latestPriceMarkLineColor,
    this.latestPriceMarkLineWidth,
    this.latestPriceMarkLineDashes,

    /// 最大最小价钱刻度线与价钱标记
    this.isShowMaxminPriceMark = true,
    this.maxminPriceTextStyle,
    this.maxminPriceMargin = 1,
    this.maxminMarkLineLength = 20,
    this.maxminMarkLineWidth,
    this.maxminMarkLineColor,
  });

  /// 控制开关
  final bool isShowLatestPrice;
  final bool isShowCountDownTime;
  // 当移出绘制区域后, 是否展示最新价X轴线.
  final bool isShowLastestPriceWhenMoveOffDrawArea;

  /// 最新价文字
  final TextStyle? latestPriceTextStyle;

  /// 倒计时方案
  final TextStyle? countDownTimeTextStyle;

  /// X轴上时间刻度
  final TextStyle? timeTickTextStyle;
  // 时间刻度文本宽度; 注设置需要大于60;
  final double timeTickTextWidth;

  /// Y轴刻度文本
  final TextStyle? tickTextStyle;
  final EdgeInsets? tickPadding;

  /// 背景
  final Color? latestPriceBackground;
  final BorderRadius? latestPriceRectRadius;
  final BorderSide? latestPriceBorder;
  final EdgeInsets? latestPriceRectPadding;
  final double latestPriceRectRightMinMargin;
  final double latestPriceRectRightMaxMargin;

  /// 最新价刻度线 (默认用cross线配置)
  final Color? latestPriceMarkLineColor;
  // 最新价X轴标志线的绘制宽度.
  final double? latestPriceMarkLineWidth;
  final List<double>? latestPriceMarkLineDashes;

  /// 最大最小价钱刻度线与价钱标记
  // 是否显示最大最小值标记
  final bool isShowMaxminPriceMark;
  final TextStyle? maxminPriceTextStyle;
  // 价钱与线之前的间距
  final double maxminPriceMargin;
  // 价钱指示线的长度
  final double maxminMarkLineLength;
  // 价钱指示线的绘制宽度
  final double? maxminMarkLineWidth;
  // 价钱指标线颜色
  final Color? maxminMarkLineColor;

  @override
  CandlePaintObject createPaintObject(
    KlineBindingBase controller,
  ) {
    return CandlePaintObject(controller: controller, indicator: this);
  }

  factory CandleIndicator.fromJson(Map<String, dynamic> json) =>
      _$CandleIndicatorFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$CandleIndicatorToJson(this);
}

class CandlePaintObject<T extends CandleIndicator>
    extends SinglePaintObjectBox<T> with PaintYAxisMarkOnCrossMixin {
  CandlePaintObject({
    required super.controller,
    required super.indicator,
  });

  BagNum? _maxHigh, _minLow;

  @override
  MinMax? initState({required int start, required int end}) {
    if (!klineData.canPaintChart) return null;

    MinMax? minmax = klineData.calculateMinmax(start: start, end: end);
    _maxHigh = minmax?.max;
    _minLow = minmax?.min;
    return minmax;
  }

  @override
  void paintChart(Canvas canvas, Size size) {
    /// 绘制蜡烛图
    paintCandleChart(canvas, size);

    /// 绘制X轴时间刻度数据. 在paintCandleChart调用
    // paintXAxisTimeTick(canvas);

    /// 绘制Y轴价钱刻度数据
    paintPriceTick(canvas, size);
  }

  @override
  void paintExtraAfterPaintChart(Canvas canvas, Size size) {
    /// 绘制最新价刻度线与价钱标记
    paintLatestPriceMark(canvas, size);
  }

  @override
  void onCross(Canvas canvas, Offset offset) {
    /// 绘制Cross Y轴价钱刻度
    paintYAxisMarkOnCross(canvas, offset);

    /// 绘制Cross X轴时间刻度
    paintXAxisMarkOnCross(canvas, offset);

    // /// 绘制Cross 命中的蜡烛数据弹窗
    // paintTips(canvas, offset: offset);
  }

  // onCross时, 格式化Y轴上的标记值.
  @override
  String formatYAxisMarkValueOnCross(BagNum value) {
    return settingBinding.formatPrice(
      value.toDecimal(),
      instId: klineData.req.instId,
      precision: klineData.req.precision,
      cutInvalidZero: false,
    );
  }

  /// 绘制蜡烛图
  void paintCandleChart(Canvas canvas, Size size) {
    if (!klineData.canPaintChart) {
      logw('paintCandleChart Data.list is empty or Index is out of bounds');
      return;
    }

    final list = klineData.list;
    int start = klineData.start;
    int end = klineData.end;

    final offset = startCandleDx - candleWidthHalf;
    final bar = klineData.timerBar;
    Offset? maxHihgOffset, minLowOffset;
    bool hasEnough = paintDxOffset > 0;
    BagNum maxHigh = list[start].high;
    BagNum minLow = list[start].low;
    CandleModel m;
    for (var i = start; i < end; i++) {
      m = list[i];
      final dx = offset - (i - start) * candleActualWidth;
      final isLong = m.close >= m.open;

      final highOff = Offset(dx, valueToDy(m.high));
      final lowOff = Offset(dx, valueToDy(m.low));
      canvas.drawLine(
        highOff,
        lowOff,
        isLong ? setting.defLongLinePaint : setting.defShortLinePaint,
      );

      final openOff = Offset(dx, valueToDy(m.open));
      final closeOff = Offset(dx, valueToDy(m.close));
      canvas.drawLine(
        openOff,
        closeOff,
        isLong ? setting.defLongBarPaint : setting.defShortBarPaint,
      );

      final timeTickIntervalCount =
          ((math.max(60, indicator.timeTickTextWidth)) / candleActualWidth)
              .round();
      if (bar != null && i % timeTickIntervalCount == 0) {
        // 绘制X轴时间刻度.
        paintXAxisTimeTick(
          canvas,
          bar: bar,
          model: m,
          offset: Offset(dx, chartRect.bottom),
          bottomHeight: chartRect.bottom,
        );
      }

      if (indicator.isShowMaxminPriceMark) {
        if (hasEnough) {
          // 满足一屏, 根据initData中的最大最小值来记录最大最小偏移量.
          if (m.high == _maxHigh) {
            maxHihgOffset = highOff;
            maxHigh = _maxHigh!;
          }
          if (m.low == _minLow) {
            minLowOffset = lowOff;
            minLow = _minLow!;
          }
        } else if (dx > 0) {
          // 如果当前绘制不足一屏, 最大最小绘制仅限可见区域.
          if (m.high >= maxHigh) {
            maxHihgOffset = highOff;
            maxHigh = m.high;
          }
          if (m.low <= minLow) {
            minLowOffset = lowOff;
            minLow = m.low;
          }
        }
      }
    }

    // 最后绘制在蜡烛图中的最大最小价钱标记
    if (indicator.isShowMaxminPriceMark &&
        (maxHihgOffset != null && maxHigh > BagNum.zero) &&
        (minLowOffset != null && minLow > BagNum.zero)) {
      paintPriceMark(canvas, maxHihgOffset, maxHigh);
      paintPriceMark(canvas, minLowOffset, minLow);
    }
  }

  /// 绘制蜡烛图上最大最小值价钱标记.
  void paintPriceMark(
    Canvas canvas,
    Offset offset,
    BagNum val,
  ) {
    final flag = offset.dx > chartRectWidthHalf ? -1 : 1;
    Offset endOffset = Offset(
      offset.dx + indicator.maxminMarkLineLength * flag,
      offset.dy,
    );
    canvas.drawLine(
      offset,
      endOffset,
      Paint()
        ..color = indicator.maxminMarkLineColor ?? setting.markLineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = indicator.maxminMarkLineWidth ?? setting.markLineWidth,
    );
    final textStyle =
        indicator.maxminPriceTextStyle ?? setting.defaultTextStyle;
    endOffset = Offset(
      endOffset.dx + flag * indicator.maxminPriceMargin,
      endOffset.dy - (textStyle.totalHeight ?? 0) / 2,
    );

    final text = settingBinding.formatPrice(
      val.toDecimal(),
      instId: klineData.req.instId,
      precision: klineData.req.precision,
    );
    canvas.drawText(
      offset: endOffset,
      drawDirection: flag < 0 ? DrawDirection.rtl : DrawDirection.ltr,
      text: text,
      style: textStyle,
      maxLines: 1,
    );
  }

  void paintXAxisTimeTick(
    Canvas canvas, {
    required TimeBar bar,
    required CandleModel model,
    required Offset offset,
    required double bottomHeight,
  }) {
    // final data = curKlineData;
    // if (data.list.isEmpty) return;
    // int start = data.start;
    // int end = data.end;

    // final offset = startCandleDx - candleWidthHalf;
    // final bar = data.timerBar;
    // for (var i = start; i < end; i++) {
    //   final model = data.list[i];
    //   final dx = offset - (i - start) * candleActualWidth;
    //   if (bar != null && i % timeTickIntervalCandleCounts == 0) {
    //     Offset(dx, mainDrawBottom);
    // 绘制X轴时间刻度.
    final textStyle = indicator.timeTickTextStyle ?? setting.defaultTextStyle;
    final dyCenterOffset =
        (paintPadding.bottom - (textStyle.totalHeight ?? 0)) / 2;
    canvas.drawText(
      offset: Offset(offset.dx, offset.dy + dyCenterOffset),
      drawDirection: DrawDirection.center,
      text: model.formatDateTimeByTimeBar(bar),
      style: textStyle,
      maxLines: 1,
      textAlign: TextAlign.center,
      textWidth: indicator.timeTickTextWidth,
    );
    //   }
    // }
  }

  void paintPriceTick(Canvas canvas, Size size) {
    final yAxisStep = chartRect.bottom / setting.gridCount;
    final dx = chartRect.right;
    double dy = 0;
    for (int i = 1; i <= grid.horizontal.count; i++) {
      dy = i * yAxisStep;
      final price = dyToValue(dy);
      if (price == null) continue;

      final text = settingBinding.formatPrice(
        price.toDecimal(),
        instId: klineData.req.instId,
        precision: klineData.req.precision,
      );

      final yAxisTickTextStyle =
          indicator.tickTextStyle ?? setting.defaultTextStyle;
      final yAxisTickRectPadding =
          indicator.tickPadding ?? setting.defaultPadding;
      final yAxisTickRectHeight =
          (yAxisTickTextStyle.totalHeight ?? 0) + yAxisTickRectPadding.vertical;

      canvas.drawText(
        offset: Offset(
          dx,
          dy - yAxisTickRectHeight, // 绘制在刻度线之上
        ),
        drawDirection: DrawDirection.rtl,
        drawableRect: drawBounding,
        text: text,
        style: yAxisTickTextStyle,
        // textWidth: tickTextWidth,
        textAlign: TextAlign.end,
        padding: yAxisTickRectPadding,
        maxLines: 1,
      );
    }
  }

  /// 绘制最新价刻度线与价钱标记
  /// 1. 价钱标记始终展示在画板最右边.
  /// 2. 最新价向右移出屏幕后, 刻度线横穿整屏.
  ///    且展示在指定价钱区间内, 如超出边界, 则停靠在最高最低线上.
  /// 3. 最新价向左移动后, 刻度线根据最新价蜡烛线平行移动.
  void paintLatestPriceMark(Canvas canvas, Size size) {
    if (!indicator.isShowLatestPrice) return;
    final data = klineData;
    final model = data.latest;
    if (model == null) {
      logd('paintLatestPriceMark > on data!');
      return;
    }

    bool showLastPriceUpdateTime = indicator.isShowCountDownTime;
    double dx = chartRect.right;
    double firstCandleDx = startCandleDx;
    double rightMargin = indicator.latestPriceRectRightMinMargin;
    double ldx = 0; // 计算最新价刻度线lineTo参数X轴的dx值. 默认0: 代表橫穿整个Canvas.
    double dy;
    if (model.close >= minMax.max) {
      dy = chartRect.top; // 画板顶部展示.
    } else if (model.close <= minMax.min) {
      dy = chartRect.bottom; // 画板底部展示.
    } else {
      dy = clampDyInChart(valueToDy(model.close));
    }
    // 计算最新价在当前画板中的X轴位置.
    if (firstCandleDx < dx) {
      ldx = firstCandleDx;
    } else {
      if (indicator.isShowLastestPriceWhenMoveOffDrawArea) {
        ldx = 0;
        rightMargin += indicator.latestPriceRectRightMaxMargin;
        showLastPriceUpdateTime = false;
      } else {
        ldx = dx - rightMargin;
      }
    }

    // 画最新价在画板中的刻度线.
    final path = Path();
    path.moveTo(dx, dy);
    path.lineTo(ldx, dy);
    canvas.drawDashPath(
      path,
      Paint()
        ..color =
            indicator.latestPriceMarkLineColor ?? setting.crosshairLineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth =
            indicator.latestPriceMarkLineWidth ?? setting.crosshairLineWidth,
      dashes:
          indicator.latestPriceMarkLineDashes ?? setting.crosshairLineDashes,
    );

    // 画最新价文本区域.
    final spanList = <TextSpan>[];
    final priceStyle =
        indicator.latestPriceTextStyle ?? setting.defaultTextStyle;
    final pricePadding =
        indicator.latestPriceRectPadding ?? setting.defaultPadding;
    spanList.add(TextSpan(
      text: settingBinding.formatPrice(
        model.close.toDecimal(),
        instId: klineData.req.instId,
        precision: klineData.req.precision,
        cutInvalidZero: false,
      ),
      style: priceStyle,
    ));

    double textHeight = (priceStyle.totalHeight ?? 0) + pricePadding.vertical;
    if (showLastPriceUpdateTime) {
      final nextUpdateDateTime = model.nextUpdateDateTime(klineData.req.bar);
      // logd(
      //   'paintLastPriceMark lastModelTime:${model.dateTime}, nextUpdateDateTime:$nextUpdateDateTime',
      // );
      if (nextUpdateDateTime != null) {
        final timeDiff = formatTimeDiff(nextUpdateDateTime);
        if (timeDiff != null) {
          final timeStyle =
              indicator.countDownTimeTextStyle ?? setting.defaultTextStyle;
          spanList.add(TextSpan(
            text: "\n$timeDiff",
            style: timeStyle,
          ));
          textHeight += timeStyle.totalHeight ?? 0;
        }
      }
    }

    canvas.drawText(
      offset: Offset(
        dx - rightMargin,
        dy - textHeight / 2, // 计算最新价文本区域相对于刻度线的位置
      ),
      drawDirection: DrawDirection.rtl,
      drawableRect: drawBounding,
      textSpan: TextSpan(
        children: spanList,
      ),
      textAlign: TextAlign.end,
      textWidthBasis: TextWidthBasis.longestLine,
      padding: pricePadding,
      backgroundColor:
          indicator.latestPriceBackground ?? setting.defaultBackground,
      borderRadius: indicator.latestPriceRectRadius ?? setting.defaultRadius,
      borderSide: indicator.latestPriceBorder ?? setting.defaultBorder,
    );
  }

  /// 绘制Cross X轴时间刻度
  @protected
  void paintXAxisMarkOnCross(Canvas canvas, Offset offset) {
    final index = dxToIndex(offset.dx);
    final model = klineData.getCandle(index);
    final timeBar = klineData.timerBar;
    if (model == null || timeBar == null) return;

    // final time = model.formatDateTimeByTimeBar(timeBar);
    final time = settingBinding.formatDateTime(model.dateTime);

    final textStyle = indicator.timeTickTextStyle ?? setting.crossTickTextStyle;
    final textPadding = setting.crossTickPadding;
    final textHeight = (textStyle.totalHeight ?? 0) + textPadding.vertical;

    final dyCenterOffset = (paintPadding.bottom - textHeight) / 2;
    canvas.drawText(
      offset: Offset(
        offset.dx,
        chartRect.bottom + dyCenterOffset,
      ),
      drawDirection: DrawDirection.center,
      text: time,
      style: setting.crossTickTextStyle,
      textAlign: TextAlign.center,
      textWidthBasis: TextWidthBasis.longestLine,
      padding: setting.crossTickPadding,
      backgroundColor: setting.crossTickBackground,
      borderRadius: setting.crossTickRadius,
      borderSide: setting.crossTickBorder,
    );
  }

  /// 绘制Cross 命中的蜡烛数据弹窗
  @override
  Size? paintTips(Canvas canvas, {CandleModel? model, Offset? offset}) {
    if (!settingBinding.showPopupCandleCard) return null;

    if (offset == null) return null;
    model ??= offsetToCandle(offset);
    final timeBar = klineData.timerBar;
    if (model == null || timeBar == null) return null;

    /// 1. 准备数据
    // ['Time', 'Open', 'High', 'Low', 'Close', 'Chg', '%Chg', 'Amount']
    final keys = settingBinding.i18nCandleCardKeys;
    final keySpanList = <TextSpan>[];
    for (var i = 0; i < keys.length; i++) {
      final text = i < keys.length - 1 ? '${keys[i]}\n' : keys[i];
      keySpanList.add(TextSpan(
        text: text,
        style: settingBinding.candleCardTitleStyle,
      ));
    }

    final instId = klineData.instId;
    final p = klineData.precision;
    TextStyle changeStyle = settingBinding.candleCardTitleStyle;
    final chgrate = model.changeRate;
    if (chgrate > 0) {
      changeStyle = settingBinding.candleCardLongStyle;
    } else if (chgrate < 0) {
      changeStyle = settingBinding.candleCardShortStyle;
    }
    final valueSpan = <TextSpan>[
      TextSpan(
        text: '${model.formatDateTimeByTimeBar(timeBar)}\n',
        style: settingBinding.candleCardTitleStyle,
      ),
      TextSpan(
        text:
            '${settingBinding.formatPrice(model.open.toDecimal(), instId: instId, precision: p)}\n',
        style: settingBinding.candleCardTitleStyle,
      ),
      TextSpan(
        text:
            '${settingBinding.formatPrice(model.high.toDecimal(), instId: instId, precision: p)}\n',
        style: settingBinding.candleCardTitleStyle,
      ),
      TextSpan(
        text:
            '${settingBinding.formatPrice(model.low.toDecimal(), instId: instId, precision: p)}\n',
        style: settingBinding.candleCardTitleStyle,
      ),
      TextSpan(
        text:
            '${settingBinding.formatPrice(model.close.toDecimal(), instId: instId, precision: p)}\n',
        style: settingBinding.candleCardTitleStyle,
      ),
      TextSpan(
        text:
            '${settingBinding.formatPrice(model.change.toDecimal(), instId: instId, precision: p)}\n',
        style: changeStyle,
      ),
      TextSpan(
        text: '${formatPercentage(model.changeRate)}\n',
        style: changeStyle,
      ),
      TextSpan(
        text: formatNumber(
          model.vol.toDecimal(),
          precision: 2,
          cutInvalidZero: true,
          showCompact: true,
        ),
        style: settingBinding.candleCardTitleStyle,
        // recognizer: _tapGestureRecognizer..onTap = () => ... // 点击事件处理?
      ),
    ];

    /// 2. 开始绘制.
    if (offset.dx > chartRectWidthHalf) {
      // 点击区域在右边; 绘制在左边
      Offset drawOffset = Offset(
        chartRect.left + settingBinding.candleCardRectMargin.left,
        chartRect.top + settingBinding.candleCardRectMargin.top,
      );

      final size = canvas.drawText(
        offset: drawOffset,
        drawDirection: DrawDirection.ltr,
        drawableRect: chartRect,
        textSpan: TextSpan(
          children: keySpanList,
          style: settingBinding.candleCardTitleStyle,
        ),
        style: settingBinding.candleCardTitleStyle,
        textAlign: TextAlign.start,
        textWidthBasis: TextWidthBasis.longestLine,
        padding: settingBinding.candleCardRectPadding,
        backgroundColor: settingBinding.candleCardRectBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(settingBinding.candleCardRectBorderRadius),
          bottomLeft:
              Radius.circular(settingBinding.candleCardRectBorderRadius),
        ),
      );

      canvas.drawText(
        offset: Offset(
          drawOffset.dx + size.width - 1,
          drawOffset.dy,
        ),
        drawDirection: DrawDirection.ltr,
        drawableRect: chartRect,
        textSpan: TextSpan(
          children: valueSpan,
          style: settingBinding.candleCardValueStyle,
        ),
        style: settingBinding.candleCardValueStyle,
        textAlign: TextAlign.end,
        textWidthBasis: TextWidthBasis.longestLine,
        padding: settingBinding.candleCardRectPadding,
        backgroundColor: settingBinding.candleCardRectBackgroundColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(settingBinding.candleCardRectBorderRadius),
          bottomRight:
              Radius.circular(settingBinding.candleCardRectBorderRadius),
        ),
      );
    } else {
      // 点击区域在左边; 绘制在右边
      Offset drawOffset = Offset(
        chartRect.right - settingBinding.candleCardRectMargin.right,
        chartRect.top + settingBinding.candleCardRectMargin.top,
      );

      final size = canvas.drawText(
        offset: drawOffset,
        drawDirection: DrawDirection.rtl,
        drawableRect: chartRect,
        textSpan: TextSpan(
          children: valueSpan,
          style: settingBinding.candleCardValueStyle,
        ),
        style: settingBinding.candleCardValueStyle,
        textAlign: TextAlign.end,
        textWidthBasis: TextWidthBasis.longestLine,
        padding: settingBinding.candleCardRectPadding,
        backgroundColor: settingBinding.candleCardRectBackgroundColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(settingBinding.candleCardRectBorderRadius),
          bottomRight:
              Radius.circular(settingBinding.candleCardRectBorderRadius),
        ),
      );

      canvas.drawText(
        offset: Offset(
          drawOffset.dx - size.width + 1,
          drawOffset.dy,
        ),
        drawDirection: DrawDirection.rtl,
        drawableRect: chartRect,
        textSpan: TextSpan(
          children: keySpanList,
          style: settingBinding.candleCardTitleStyle,
        ),
        style: settingBinding.candleCardTitleStyle,
        textAlign: TextAlign.start,
        textWidthBasis: TextWidthBasis.longestLine,
        padding: settingBinding.candleCardRectPadding,
        backgroundColor: settingBinding.candleCardRectBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(settingBinding.candleCardRectBorderRadius),
          bottomLeft:
              Radius.circular(settingBinding.candleCardRectBorderRadius),
        ),
      );
    }
    return null;
  }
}
