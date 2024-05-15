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
    super.tipsHeight = defaultIndicatorTipsHeight,
    super.padding = const EdgeInsets.only(bottom: 15),

    // 最高价
    this.high = const MarkConfig(
      spacing: 2,
      line: LineConfig(
        type: LineType.solid,
        color: Colors.black,
        length: 20,
        width: 0.5,
      ),
    ),
    // 最低价
    this.low = const MarkConfig(
      spacing: 2,
      line: LineConfig(
        type: LineType.solid,
        color: Colors.black,
        length: 20,
        width: 0.5,
      ),
    ),
    // 最后价: 当最新蜡烛不在可视区域时使用.
    this.last = const MarkConfig(
      show: true,
      spacing: 100,
      line: LineConfig(
        type: LineType.dashed,
        color: Colors.black,
        width: 0.5,
        dashes: [3, 3],
      ),
      text: TextAreaConfig(
        style: TextStyle(
          fontSize: defaulTextSize,
          color: Colors.white,
          overflow: TextOverflow.ellipsis,
          height: defaultTextHeight,
          textBaseline: TextBaseline.alphabetic,
        ),
        background: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        border: BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    ),
    // 最新价: 当最新蜡烛在可视区域时使用.
    this.latest = const MarkConfig(
      show: true,
      spacing: 1,
      line: LineConfig(
        type: LineType.dashed,
        color: Colors.black,
        width: 0.5,
        dashes: [3, 3],
      ),
      text: TextAreaConfig(
        style: TextStyle(
          fontSize: defaulTextSize,
          color: Colors.black,
          overflow: TextOverflow.ellipsis,
          height: defaultTextHeight,
        ),
        textAlign: TextAlign.end,
        background: Colors.white,
        padding: defaultTextPading,
        border: BorderSide(color: Colors.black, width: 0.5),
        borderRadius: BorderRadius.all(Radius.circular(2)),
      ),
    ),
    this.prettyLatest = const TextAreaConfig(
      style: TextStyle(
        fontSize: defaulTextSize,
        color: Colors.white,
        overflow: TextOverflow.ellipsis,
        height: defaultTextHeight,
      ),
      textAlign: TextAlign.end,
      // background: 背景由涨跌颜色决定,
      padding: defaultTextPading,
      borderRadius: BorderRadius.all(Radius.circular(2)),
    ),
    // 倒计时, 在latest最新价之下展示
    this.showCountDown = true,
    this.countDown = const TextAreaConfig(
      style: TextStyle(
        fontSize: defaulTextSize,
        color: Colors.black,
        overflow: TextOverflow.ellipsis,
        height: defaultTextHeight,
      ),
      textAlign: TextAlign.center,
      background: Colors.grey,
      padding: defaultTextPading,
      border: BorderSide(color: Colors.black, width: 0.5),
      borderRadius: BorderRadius.all(Radius.circular(2)),
    ),
    // 时间刻度.
    this.timeTick = const TextAreaConfig(
      style: TextStyle(
        fontSize: defaulTextSize,
        color: Colors.black,
        overflow: TextOverflow.ellipsis,
        height: defaultTextHeight,
      ),
      textWidth: 80,
    ),
  });

  // 最高价
  final MarkConfig high;
  // 最低价
  final MarkConfig low;
  // 最后价: 当最新蜡烛不在可视区域时使用.
  final MarkConfig last;
  // 最新价: 当最新蜡烛在可视区域时使用.
  final MarkConfig latest;
  // 最新价: PrettyLatest
  final TextAreaConfig? prettyLatest;
  // 倒计时, 在latest最新价之下展示
  final bool showCountDown;
  final TextAreaConfig countDown;
  // 时间刻度.
  final TextAreaConfig timeTick;

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
    extends SinglePaintObjectBox<T> with PaintHorizontalTickOnCrossMixin {
  CandlePaintObject({
    required super.controller,
    required super.indicator,
  });

  BagNum? _maxHigh, _minLow;

  /// 两个时间刻度间隔的蜡烛数
  int get timeTickIntervalCount {
    return ((math.max(60, indicator.timeTick.textWidth ?? 0)) /
            setting.candleActualWidth)
        .round();
  }

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

    /// 绘制X轴时间刻度数据. 已在paintCandleChart调用
    // paintTimeTick(canvas);

    /// 绘制价钱刻度数据
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
    paintHorizontalTickOnCross(
      canvas,
      offset,
      precision: klineData.precision,
    );

    /// 绘制Cross X轴时间刻度
    paintTimeTickOnCross(canvas, offset);
  }

  // onCross时, 格式化Y轴上的标记值.
  @override
  String formatTickValueOnCross(BagNum value, {required int precision}) {
    return setting.formatPrice(
      value.toDecimal(),
      instId: klineData.instId,
      precision: klineData.precision,
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
        isLong
            ? settingConfig.defLongLinePaint
            : settingConfig.defShortLinePaint,
      );

      final openOff = Offset(dx, valueToDy(m.open));
      final closeOff = Offset(dx, valueToDy(m.close));
      canvas.drawLine(
        openOff,
        closeOff,
        isLong ? settingConfig.defLongBarPaint : settingConfig.defShortBarPaint,
      );

      if (bar != null && i % timeTickIntervalCount == 0) {
        // 绘制时间刻度.
        paintTimeTick(
          canvas,
          bar: bar,
          model: m,
          offset: Offset(dx, chartRect.bottom),
          bottomHeight: chartRect.bottom,
        );
      }

      if (indicator.high.show || indicator.low.show) {
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
    if ((indicator.high.show || indicator.low.show) &&
        (maxHihgOffset != null && maxHigh > BagNum.zero) &&
        (minLowOffset != null && minLow > BagNum.zero)) {
      paintPriceMark(canvas, maxHihgOffset, maxHigh, indicator.high);
      paintPriceMark(canvas, minLowOffset, minLow, indicator.low);
    }
  }

  /// 绘制蜡烛图上最大最小值价钱标记.
  void paintPriceMark(
    Canvas canvas,
    Offset offset,
    BagNum val,
    MarkConfig markConfig,
  ) {
    final flag = offset.dx > chartRectWidthHalf ? -1 : 1;
    Offset endOffset = Offset(
      offset.dx + markConfig.lineLength * flag,
      offset.dy,
    );
    canvas.drawLine(
      offset,
      endOffset,
      Paint()
        ..color = markConfig.line.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = markConfig.line.width,
    );

    final markText = markConfig.text;

    endOffset = Offset(
      endOffset.dx + flag * markConfig.spacing,
      endOffset.dy - (markText.areaHeight) / 2,
    );

    final text = setting.formatPrice(
      val.toDecimal(),
      instId: klineData.instId,
      precision: klineData.precision,
    );

    canvas.drawText(
      offset: endOffset,
      drawDirection: flag < 0 ? DrawDirection.rtl : DrawDirection.ltr,
      text: text,
      style: markText.style,
      textAlign: markText.textAlign,
      textWidth: markText.textWidth,
      padding: markText.padding,
      backgroundColor: markText.background,
      borderRadius: markText.borderRadius,
      borderSide: markText.border,
      maxLines: markText.maxLines ?? 1,
    );
  }

  /// 绘制时间刻度
  void paintTimeTick(
    Canvas canvas, {
    required TimeBar bar,
    required CandleModel model,
    required Offset offset,
    required double bottomHeight,
  }) {
    // final data = klineData;
    // if (data.list.isEmpty) return;
    // int start = data.start;
    // int end = data.end;

    // final offset = startCandleDx - candleWidthHalf;
    // final bar = data.timerBar;
    // for (var i = start; i < end; i++) {
    //   final model = data.list[i];
    //   final dx = offset - (i - start) * candleActualWidth;
    //   if (bar != null && i % timeTickIntervalCount == 0) {
    //     final offset = Offset(dx,  chartRect.bottom);

    // 绘制时间刻度.
    final timeTick = indicator.timeTick;
    final dyCenterOffset = (indicator.padding.bottom - timeTick.areaHeight) / 2;
    canvas.drawText(
      offset: Offset(
        offset.dx,
        offset.dy + dyCenterOffset,
      ),
      drawDirection: DrawDirection.center,
      text: model.formatDateTimeByTimeBar(bar),
      style: timeTick.style,
      textAlign: timeTick.textAlign,
      textWidth: timeTick.textWidth,
      padding: timeTick.padding,
      backgroundColor: timeTick.background,
      borderRadius: timeTick.borderRadius,
      borderSide: timeTick.border,
      maxLines: timeTick.maxLines ?? 1,
    );

    //   }
    // }
  }

  /// 绘制蜡烛图右侧价钱刻度
  /// 根据Grid horizontal配置来绘制, 保证在grid.horizontal线之上.
  void paintPriceTick(Canvas canvas, Size size) {
    final dyStep = chartRect.bottom / gridConfig.horizontal.count;
    final dx = chartRect.right;
    double dy = 0;
    for (int i = 1; i <= gridConfig.horizontal.count; i++) {
      dy = i * dyStep;
      final price = dyToValue(dy);
      if (price == null) continue;

      final text = setting.formatPrice(
        price.toDecimal(),
        instId: klineData.instId,
        precision: klineData.precision,
        cutInvalidZero: false,
      );

      final tickText = settingConfig.tickText;

      canvas.drawText(
        offset: Offset(
          dx,
          dy - tickText.areaHeight, // 绘制在刻度线之上
        ),
        drawDirection: DrawDirection.rtl,
        drawableRect: drawBounding,
        text: text,
        style: tickText.style,
        textAlign: tickText.textAlign,
        textWidth: tickText.textWidth,
        padding: tickText.padding,
        backgroundColor: tickText.background,
        borderRadius: tickText.borderRadius,
        borderSide: tickText.border,
        maxLines: tickText.maxLines ?? 1,
      );
    }
  }

  /// 绘制最新价刻度线与价钱标记
  /// 1. 价钱标记始终展示在画板最右边.
  /// 2. 最新价向右移出屏幕后, 刻度线横穿整屏.
  ///    且展示在指定价钱区间内, 如超出边界, 则停靠在最高最低线上.
  /// 3. 最新价向左移动后, 刻度线根据最新价蜡烛线平行移动.
  void paintLatestPriceMark(Canvas canvas, Size size) {
    if (!indicator.latest.show || !indicator.last.show) return;
    final data = klineData;
    final model = data.latest;
    if (model == null) {
      logd('paintLatestPriceMark > on data!');
      return;
    }

    // 计算最新价YAxis位置.
    double dy;
    if (model.close >= minMax.max) {
      dy = chartRect.top; // 画板顶部展示.
    } else if (model.close <= minMax.min) {
      dy = chartRect.bottom; // 画板底部展示.
    } else {
      dy = clampDyInChart(valueToDy(model.close));
    }

    // 计算最新价XAxis位置.
    // bool showLastPriceUpdateTime = indicator.isShowCountDownTime;
    final firstCandleDx = startCandleDx;
    double rdx = chartRect.right;
    // double rightMargin = indicator.latestPriceRectRightMinMargin;
    double ldx = 0; // 计算最新价刻度线lineTo参数X轴的dx值. 默认0: 代表橫穿整个Canvas.

    if (firstCandleDx < rdx) {
      // 绘制最新价和倒计时
      final latest = indicator.latest;
      if (!latest.show) return;

      ldx = firstCandleDx;

      /// 绘制首根蜡烛到rdx的刻度线.
      final latestPath = Path();
      latestPath.moveTo(rdx, dy);
      latestPath.lineTo(ldx, dy);
      canvas.drawLineType(
        indicator.last.line.type,
        latestPath,
        Paint()
          ..color = latest.line.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = latest.line.width,
        dashes: latest.line.dashes,
      );

      /// 计算最新价和倒计时区域的文本和高度
      final text = setting.formatPrice(
        model.close.toDecimal(),
        instId: klineData.req.instId,
        precision: klineData.req.precision,
        cutInvalidZero: false,
      );

      /// 计算倒计时Text
      String? countDownText;
      if (indicator.showCountDown) {
        final nextUpdateDateTime = model.nextUpdateDateTime(klineData.req.bar);
        if (nextUpdateDateTime != null) {
          countDownText = formatTimeDiff(nextUpdateDateTime);
        }
      }

      TextAreaConfig textConfig;
      Color? background;

      if (indicator.prettyLatest != null) {
        textConfig = indicator.prettyLatest!;
        background = model.close >= model.open
            ? settingConfig.longColor
            : settingConfig.shortColor;
      } else {
        textConfig = latest.text;
        background = textConfig.background;
      }

      BorderSide? borderSide = textConfig.border;
      BorderRadius? borderRadius = textConfig.borderRadius;
      if (countDownText != null) {
        // 如果展示倒计时, 最新价仅保留顶部radius
        borderRadius = borderRadius?.copyWith(
          topLeft: borderRadius.topLeft,
          topRight: borderRadius.topRight,
          bottomLeft: const Radius.circular(0),
          bottomRight: const Radius.circular(0),
        );
      }

      final offset = Offset(
        rdx - latest.spacing,
        dy - latest.text.areaHeight / 2, // 垂直居中
      );

      /// 绘制最新价标记
      final size = canvas.drawText(
        offset: offset,
        drawDirection: DrawDirection.rtl,
        drawableRect: drawBounding,
        text: text,
        style: textConfig.style,
        textAlign: textConfig.textAlign,
        textWidth: textConfig.textWidth,
        padding: textConfig.padding,
        backgroundColor: background,
        borderRadius: borderRadius,
        borderSide: borderSide,
        maxLines: textConfig.maxLines ?? 1,
      );

      if (countDownText != null) {
        final countDown = indicator.countDown;

        // 展示倒计时, 倒计时radius始终使用最新价的, 且保留底部radius
        borderRadius = borderRadius?.copyWith(
          topLeft: const Radius.circular(0),
          topRight: const Radius.circular(0),
          bottomLeft: borderRadius.topLeft,
          bottomRight: borderRadius.topRight,
        );

        /// 绘制倒计时标记
        canvas.drawText(
          offset: Offset(
            offset.dx,
            offset.dy + size.height - 0.5,
          ),
          drawDirection: DrawDirection.rtl,
          drawableRect: drawBounding,
          text: countDownText,
          style: countDown.style.copyWith(
            // 修正倒计时文本区域高度:
            // 由于倒计时使用了固定宽度(最新价的size.width), 保持与最新价同宽.
            // 此处无法再为countDown设置padding, 固在此处修正
            height: (countDown.areaHeight - 1) / countDown.textHeight,
          ),
          textAlign: countDown.textAlign,
          textWidth: size.width,
          // padding: countDown.padding,
          backgroundColor: countDown.background,
          borderRadius: borderRadius,
          borderSide: borderSide,
          maxLines: countDown.maxLines ?? 1,
        );
      }
    } else {
      /// 绘制最后价
      final last = indicator.last;
      if (!last.show) return;

      ldx = 0;

      /// 绘制横穿画板的最后价刻度线.
      final lastPath = Path();
      lastPath.moveTo(rdx, dy);
      lastPath.lineTo(ldx, dy);
      canvas.drawLineType(
        indicator.last.line.type,
        lastPath,
        Paint()
          ..color = last.line.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = last.line.width,
        dashes: last.line.dashes,
      );

      final text = setting.formatPrice(
        model.close.toDecimal(),
        instId: klineData.instId,
        precision: klineData.precision,
        cutInvalidZero: true,
      );

      /// 绘制最后价标记
      canvas.drawText(
        offset: Offset(
          rdx - last.spacing,
          dy - last.text.areaHeight / 2, // 居中
        ),
        drawDirection: DrawDirection.center,
        drawableRect: drawBounding,
        text: '$text ▸', // ➤➤▹►▸▶︎≻
        style: last.text.style,
        textAlign: last.text.textAlign,
        textWidth: last.text.textWidth,
        padding: last.text.padding,
        backgroundColor: last.text.background,
        borderRadius: last.text.borderRadius,
        borderSide: last.text.border,
        maxLines: last.text.maxLines ?? 1,
      );
    }
  }

  /// 绘制OnCross 时间刻度
  @protected
  void paintTimeTickOnCross(Canvas canvas, Offset offset) {
    final index = dxToIndex(offset.dx);
    final model = klineData.getCandle(index);
    final timeBar = klineData.timerBar;
    if (model == null || timeBar == null) return;

    // final time = model.formatDateTimeByTimeBar(timeBar);
    final time = setting.formatDateTime(model.dateTime);

    final tickText = crossConfig.tickText;

    final dyCenterOffset = (indicator.padding.bottom - tickText.areaHeight) / 2;
    canvas.drawText(
      offset: Offset(
        offset.dx,
        chartRect.bottom + dyCenterOffset,
      ),
      drawDirection: DrawDirection.center,
      text: time,
      style: tickText.style,
      textAlign: TextAlign.center,
      textWidthBasis: TextWidthBasis.longestLine,
      padding: tickText.padding,
      backgroundColor: tickText.background,
      borderRadius: tickText.borderRadius,
      borderSide: tickText.border,
    );
  }

  /// 绘制Cross 命中的蜡烛数据弹窗
  @override
  Size? paintTips(Canvas canvas, {CandleModel? model, Offset? offset}) {
    if (!setting.showPopupCandleCard) return null;

    if (offset == null) return null;
    model ??= offsetToCandle(offset);
    final timeBar = klineData.timerBar;
    if (model == null || timeBar == null) return null;

    /// 1. 准备数据
    // ['Time', 'Open', 'High', 'Low', 'Close', 'Chg', '%Chg', 'Amount']
    final keys = setting.i18nCandleCardKeys;
    final keySpanList = <TextSpan>[];
    for (var i = 0; i < keys.length; i++) {
      final text = i < keys.length - 1 ? '${keys[i]}\n' : keys[i];
      keySpanList.add(TextSpan(
        text: text,
        style: setting.candleCardTitleStyle,
      ));
    }

    final instId = klineData.instId;
    final p = klineData.precision;
    TextStyle changeStyle = setting.candleCardTitleStyle;
    final chgrate = model.changeRate;
    if (chgrate > 0) {
      changeStyle = setting.candleCardLongStyle;
    } else if (chgrate < 0) {
      changeStyle = setting.candleCardShortStyle;
    }
    final valueSpan = <TextSpan>[
      TextSpan(
        text: '${model.formatDateTimeByTimeBar(timeBar)}\n',
        style: setting.candleCardTitleStyle,
      ),
      TextSpan(
        text:
            '${setting.formatPrice(model.open.toDecimal(), instId: instId, precision: p)}\n',
        style: setting.candleCardTitleStyle,
      ),
      TextSpan(
        text:
            '${setting.formatPrice(model.high.toDecimal(), instId: instId, precision: p)}\n',
        style: setting.candleCardTitleStyle,
      ),
      TextSpan(
        text:
            '${setting.formatPrice(model.low.toDecimal(), instId: instId, precision: p)}\n',
        style: setting.candleCardTitleStyle,
      ),
      TextSpan(
        text:
            '${setting.formatPrice(model.close.toDecimal(), instId: instId, precision: p)}\n',
        style: setting.candleCardTitleStyle,
      ),
      TextSpan(
        text:
            '${setting.formatPrice(model.change.toDecimal(), instId: instId, precision: p)}\n',
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
        style: setting.candleCardTitleStyle,
        // recognizer: _tapGestureRecognizer..onTap = () => ... // 点击事件处理?
      ),
    ];

    /// 2. 开始绘制.
    if (offset.dx > chartRectWidthHalf) {
      // 点击区域在右边; 绘制在左边
      Offset drawOffset = Offset(
        chartRect.left + setting.candleCardRectMargin.left,
        chartRect.top + setting.candleCardRectMargin.top,
      );

      final size = canvas.drawText(
        offset: drawOffset,
        drawDirection: DrawDirection.ltr,
        drawableRect: chartRect,
        textSpan: TextSpan(
          children: keySpanList,
          style: setting.candleCardTitleStyle,
        ),
        style: setting.candleCardTitleStyle,
        textAlign: TextAlign.start,
        textWidthBasis: TextWidthBasis.longestLine,
        padding: setting.candleCardRectPadding,
        backgroundColor: setting.candleCardRectBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(setting.candleCardRectBorderRadius),
          bottomLeft: Radius.circular(setting.candleCardRectBorderRadius),
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
          style: setting.candleCardValueStyle,
        ),
        style: setting.candleCardValueStyle,
        textAlign: TextAlign.end,
        textWidthBasis: TextWidthBasis.longestLine,
        padding: setting.candleCardRectPadding,
        backgroundColor: setting.candleCardRectBackgroundColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(setting.candleCardRectBorderRadius),
          bottomRight: Radius.circular(setting.candleCardRectBorderRadius),
        ),
      );
    } else {
      // 点击区域在左边; 绘制在右边
      Offset drawOffset = Offset(
        chartRect.right - setting.candleCardRectMargin.right,
        chartRect.top + setting.candleCardRectMargin.top,
      );

      final size = canvas.drawText(
        offset: drawOffset,
        drawDirection: DrawDirection.rtl,
        drawableRect: chartRect,
        textSpan: TextSpan(
          children: valueSpan,
          style: setting.candleCardValueStyle,
        ),
        style: setting.candleCardValueStyle,
        textAlign: TextAlign.end,
        textWidthBasis: TextWidthBasis.longestLine,
        padding: setting.candleCardRectPadding,
        backgroundColor: setting.candleCardRectBackgroundColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(setting.candleCardRectBorderRadius),
          bottomRight: Radius.circular(setting.candleCardRectBorderRadius),
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
          style: setting.candleCardTitleStyle,
        ),
        style: setting.candleCardTitleStyle,
        textAlign: TextAlign.start,
        textWidthBasis: TextWidthBasis.longestLine,
        padding: setting.candleCardRectPadding,
        backgroundColor: setting.candleCardRectBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(setting.candleCardRectBorderRadius),
          bottomLeft: Radius.circular(setting.candleCardRectBorderRadius),
        ),
      );
    }
    return null;
  }
}
