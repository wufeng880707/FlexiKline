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

part of 'candle.dart';

@CopyWith()
@FlexiIndicatorSerializable
class CandleIndicator extends PaintObjectIndicator {
  CandleIndicator({
    super.zIndex = -1,
    required super.height,
    super.padding = defaultMainIndicatorPadding,

    // 最高价
    required this.high,
    // 最低价
    required this.low,
    // 最后价: 当最新蜡烛不在可视区域时使用.
    required this.last,
    // 最新价: 当最新蜡烛在可视区域时使用.
    required this.latest,
    this.useCandleColorAsLatestBg = true,
    // 倒计时, 在latest最新价之下展示
    this.showCountDown = true,
    required this.countDown,
  }) : super(key: candleIndicatorKey);

  // 最高价
  final MarkConfig high;
  // 最低价
  final MarkConfig low;
  // 最后价: 当最新蜡烛不在可视区域时使用.
  final MarkConfig last;
  // 最新价: 当最新蜡烛在可视区域时使用.
  final MarkConfig latest;
  // 使用蜡烛颜色做为Latest的背景
  final bool useCandleColorAsLatestBg;
  // 倒计时, 在latest最新价之下展示
  final bool showCountDown;
  final TextAreaConfig countDown;

  @override
  CandlePaintObject createPaintObject(
    IPaintContext context, {
    KlineEventBus? eventBus,
  }) {
    return CandlePaintObject(
      context: context,
      indicator: this,
      eventBus: eventBus,
    );
  }

  factory CandleIndicator.fromJson(Map<String, dynamic> json) => _$CandleIndicatorFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$CandleIndicatorToJson(this);
}

class CandlePaintObject<T extends CandleIndicator> extends PaintObjectBox<T>
    with PaintYAxisTicksOnCrossMixin, ClickableMixin {
  final KlineEventBus? eventBus;

  CandlePaintObject({
    required super.context,
    required super.indicator,
    this.eventBus,
  });

  BagNum? _maxHigh, _minLow;

  @override
  MinMax? initState(int start, int end) {
    if (!klineData.canPaintChart) return null;

    MinMax? minmax = klineData.calculateMinmax(start, end);
    _maxHigh = minmax?.max;
    _minLow = minmax?.min;
    return minmax;
  }

  @override
  void paintChart(Canvas canvas, Size size) {
    // 清空点击区域
    clearClickAreas();

    final timeBar = klineData.req.timeBar;
    if (timeBar.intraDay) {
      ///分时图
      paintIntraDayChart(canvas, size);
    } else {
      /// 绘制蜡烛图
      paintCandleChart(canvas, size);
    }

    /// 绘制价钱刻度数据
    if (settingConfig.showYAxisTick) {
      paintYAxisPriceTick(canvas, size);
    }
  }

  @override
  void paintExtraAboveChart(Canvas canvas, Size size) {
    /// 绘制最新价刻度线与价钱标记
    paintLatestPriceMark(canvas, size);
  }

  @override
  void onCross(Canvas canvas, Offset offset) {
    /// 绘制Cross Y轴价钱刻度
    paintYAxisTicksOnCross(
      canvas,
      offset,
      precision: klineData.precision,
    );
  }

  // onCross时, 格式化Y轴上的标记值.
  @override
  String formatTicksValueOnCross(BagNum value, {required int precision}) {
    return formatPrice(
      value.toDecimal(),
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
        isLong ? settingConfig.defLongLinePaint : settingConfig.defShortLinePaint,
      );

      final openOff = Offset(dx, valueToDy(m.open));
      final closeOff = Offset(dx, valueToDy(m.close));
      
      // 应用最小蜡烛高度
      final minHeight = settingConfig.minCandleHeight;
      final actualHeight = (closeOff.dy - openOff.dy).abs();
      
      if (actualHeight < minHeight) {
        // 如果实际高度小于最小高度，调整收盘价位置
        final adjustedCloseOff = isLong 
          ? Offset(dx, openOff.dy - minHeight)  // 阳线向下延伸
          : Offset(dx, openOff.dy + minHeight); // 阴线向上延伸
        
        canvas.drawLine(
          openOff,
          adjustedCloseOff,
          isLong ? settingConfig.defLongBarPaint : settingConfig.defShortBarPaint,
        );
      } else {
        canvas.drawLine(
          openOff,
          closeOff,
          isLong ? settingConfig.defLongBarPaint : settingConfig.defShortBarPaint,
        );
      }

      if (indicator.high.show) {
        if (hasEnough) {
          if (m.high == _maxHigh) {
            maxHihgOffset = highOff;
            maxHigh = _maxHigh!;
          }
        } else if (dx > 0) {
          if (m.high >= maxHigh) {
            maxHihgOffset = highOff;
            maxHigh = m.high;
          }
        }
      }

      if (indicator.low.show) {
        if (hasEnough) {
          if (m.low == _minLow) {
            minLowOffset = lowOff;
            minLow = _minLow!;
          }
        } else {
          if (m.low <= minLow) {
            minLowOffset = lowOff;
            minLow = m.low;
          }
        }
      }
    }

    // 最后绘制在蜡烛图中的最大价钱标记
    if (maxHihgOffset != null && maxHigh > BagNum.zero) {
      paintPriceMark(canvas, maxHihgOffset, maxHigh, indicator.high);
    }
    // 最后绘制在蜡烛图中的最小价钱标记
    if (minLowOffset != null && minLow > BagNum.zero) {
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
    canvas.drawLine(offset, endOffset, markConfig.line.linePaint);

    final markText = markConfig.text;

    endOffset = Offset(
      endOffset.dx + flag * markConfig.spacing,
      endOffset.dy - (markText.areaHeight) / 2,
    );

    final text = formatPrice(val.toDecimal(), precision: klineData.precision);

    canvas.drawTextArea(
      offset: endOffset,
      drawDirection: flag < 0 ? DrawDirection.rtl : DrawDirection.ltr,
      text: text,
      textConfig: markText,
    );
  }

  /// 绘制蜡烛图右侧价钱刻度
  void paintYAxisPriceTick(Canvas canvas, Size size) {
    final dyStep = drawableRect.height / gridConfig.horizontal.count;
    final dx = chartRect.right;
    double dy = 0;
    for (int i = 1; i <= gridConfig.horizontal.count; i++) {
      dy = i * dyStep;
      final price = dyToValue(dy);
      if (price == null) continue;

      final text = formatPrice(
        price.toDecimal(),
        precision: klineData.precision,
        cutInvalidZero: false,
        showThousands: true,
      );

      final ticksText = settingConfig.ticksText;

      canvas.drawTextArea(
        offset: Offset(
          dx,
          dy - ticksText.areaHeight,
        ),
        drawDirection: DrawDirection.rtl,
        drawableRect: drawableRect,
        text: text,
        textConfig: ticksText,
      );
    }
  }

  /// 缓存latest文本相对于屏幕右侧的负偏移量
  double _latestTextOffset = 0.0;

  /// 绘制最新价刻度线与价钱标记
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
      dy = chartRect.top;
    } else if (model.close <= minMax.min) {
      dy = chartRect.bottom;
    } else {
      dy = clampDyInChart(valueToDy(model.close));
    }

    // 计算最新价XAxis位置.
    double rdx = chartRect.right;
    double ldx = 0;

    if (paintDxOffset < _latestTextOffset) {
      // 绘制最新价和倒计时
      final latest = indicator.latest;
      if (!latest.show) return;

      ldx = startCandleDx;

      /// 绘制首根蜡烛到rdx的刻度线.
      final latestPath = Path();
      latestPath.moveTo(rdx, dy);
      latestPath.lineTo(ldx, dy);
      canvas.drawLineByConfig(
        latestPath,
        latest.line,
      );

      TextAreaConfig textConfig = latest.text;

      /// 最新价文本和样式配置
      final text = formatPrice(
        model.close.toDecimal(),
        precision: klineData.req.precision,
        cutInvalidZero: false,
      );

      Color? background = textConfig.background;
      if (indicator.useCandleColorAsLatestBg) {
        background = model.close >= model.open ? settingConfig.longColor : settingConfig.shortColor;
      }

      BorderRadius? borderRadius = textConfig.borderRadius;

      /// 倒计时Text
      String? countDownText;
      if (indicator.showCountDown) {
        final nextUpdateDateTime = model.nextUpdateDateTime(klineData.req.timeBar);
        if (nextUpdateDateTime != null) {
          countDownText = formatTimeDiff(nextUpdateDateTime);
        }
      }
      if (countDownText != null) {
        borderRadius = borderRadius?.copyWith(
          topLeft: borderRadius.topLeft,
          topRight: borderRadius.topRight,
          bottomLeft: const Radius.circular(0),
          bottomRight: const Radius.circular(0),
        );
      }

      final offset = Offset(
        rdx - latest.spacing,
        dy - latest.text.areaHeight / 2,
      );

      /// 绘制最新价标记
      final size = canvas.drawTextArea(
        offset: offset,
        drawDirection: DrawDirection.rtl,
        drawableRect: drawableRect,
        text: text,
        textConfig: textConfig,
        backgroundColor: background,
        borderRadius: borderRadius,
      );
      _latestTextOffset = -size.width;

      if (countDownText != null) {
        final countDown = indicator.countDown;

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
          drawableRect: drawableRect,
          text: countDownText,
          style: countDown.style.copyWith(
            height: (countDown.areaHeight - 1) / countDown.textHeight,
          ),
          textAlign: countDown.textAlign,
          textWidth: size.width,
          backgroundColor: countDown.background,
          borderRadius: borderRadius,
          borderSide: countDown.border,
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
      canvas.drawLineByConfig(
        lastPath,
        last.line,
      );

      final text = formatPrice(
        model.close.toDecimal(),
        precision: klineData.precision,
        cutInvalidZero: true,
      );

      // 计算最后价的点击区域
      final textSize = _calculateTextSize('$text ▸', last.text);
      final offset = Offset(
        rdx + _latestTextOffset - last.spacing,
        dy - last.text.areaHeight / 2,
      );

      // 记录最后价点击区域
      final left = offset.dx - textSize.width;
      final top = offset.dy;
      final clickArea = ClickArea(
        rect: Rect.fromLTWH(
          left,
          top,
          textSize.width,
          textSize.height,
        ),
        data: {
          'price': model.close.toDecimal(),
          'text': text,
        },
        onTap: () => eventBus?.emit('lastPriceTap', {}),
      );
      addClickArea(clickArea);

      /// 绘制最后价标记
      canvas.drawTextArea(
        offset: offset,
        drawDirection: DrawDirection.rtl,
        drawableRect: drawableRect,
        text: '$text ▸',
        textConfig: last.text,
      );
    }
  }

  /// 绘制分时图图
  void paintIntraDayChart(Canvas canvas, Size size) {
    if (!klineData.canPaintChart) {
      logw('paintIntraDayChart Data.list is empty or Index is out of bounds');
      return;
    }

    final list = klineData.list;
    int start = klineData.start;
    int end = klineData.end;

    final offset = startCandleDx - candleWidthHalf;
    Offset? maxHihgOffset, minLowOffset;
    bool hasEnough = paintDxOffset > 0;
    BagNum maxHigh = list[start].high;
    BagNum minLow = list[start].low;
    CandleModel m;
    Path path = Path();
    bool isShowAvgLine = false;
    double startDx = 0;
    double endDx = 0;
    Offset? lastPoint;
    for (var i = start; i < end; i++) {
      m = list[i];
      final dx = offset - (i - start) * candleActualWidth;

      final highOff = Offset(dx, valueToDy(m.high));
      final lowOff = Offset(dx, valueToDy(m.low));

      // 计算平均价格：(high + low + close) / 3
      final avgPrice = (m.high + m.low + m.close) / BagNum.three;
      final bagNumAvg = avgPrice;
      double avgDy = valueToDy(bagNumAvg);

      if (!isShowAvgLine) isShowAvgLine = true;

      if (i == start) {
        startDx = dx;
        path.moveTo(dx, valueToDy(m.close));
      } else {
        if (i == end - 1) {
          endDx = dx;
        }
        path.lineTo(dx, valueToDy(m.close));
      }

      if (isShowAvgLine && lastPoint != null) {
        canvas.drawLine(lastPoint, Offset(dx, avgDy), settingConfig.indraTodayAvgLinePaint);
      }

      if (indicator.high.show || indicator.low.show) {
        if (hasEnough) {
          if (m.high == _maxHigh) {
            maxHihgOffset = highOff;
            maxHigh = _maxHigh!;
          }
          if (m.low == _minLow) {
            minLowOffset = lowOff;
            minLow = _minLow!;
          }
        } else if (dx > 0) {
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
      if (isShowAvgLine) {
        lastPoint = Offset(dx, avgDy);
      }
    }

    // 绘制价格波动线
    canvas.drawLineType(LineType.solid, path, settingConfig.indraTodayLinePaint);

    // 绘制渐变色块
    Path gradientPath = Path.from(path);
    gradientPath.lineTo(endDx, size.height);
    gradientPath.lineTo(startDx, size.height);
    gradientPath.close();
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          settingConfig.indraTodayCloseColor.withOpacity(0.4),
          settingConfig.indraTodayCloseColor.withOpacity(0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));
    canvas.drawPath(gradientPath, gradientPaint);
  }

  @override
  Size? paintTips(
    Canvas canvas, {
    CandleModel? model,
    Offset? offset,
    Rect? tipsRect,
  }) {
    return null;
  }

  /// 计算文本尺寸
  Size _calculateTextSize(String text, TextAreaConfig config) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: config.style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.size;
  }
}
