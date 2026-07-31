part of 'trade_mark.dart';

/// 交易标记指标Key
const tradeMarkIndicatorKey = BusinessIndicatorKey('tradeMark');

/// 交易标记指标
///
/// 只负责样式配置，不持有业务数据。
/// 业务数据通过 [FlexiKlineController.setBusinessData] 注入，
/// [TradeMarkPaintObject] 在绘制时通过 [IPaintContext.getBusinessData] 获取。
@CopyWith()
class TradeMarkIndicator extends BusinessIndicator {
  TradeMarkIndicator({
    super.zIndex = 100,
    super.height = 0,
    super.padding = EdgeInsets.zero,
    this.calcParam = const TradeMarkParam(),
  }) : super(key: tradeMarkIndicatorKey);

  /// 样式参数
  final TradeMarkParam calcParam;

  @override
  BusinessPaintObject<TradeMarkIndicator> createPaintObject() {
    return TradeMarkPaintObject();
  }

  factory TradeMarkIndicator.fromJson(Map<String, dynamic> json) {
    return TradeMarkIndicator(
      zIndex: json['zIndex'] as int? ?? 100,
      height: (json['height'] as num?)?.toDouble() ?? 0,
      padding: json['padding'] != null
          ? EdgeInsets.fromLTRB(
              (json['padding']['left'] as num?)?.toDouble() ?? 0,
              (json['padding']['top'] as num?)?.toDouble() ?? 0,
              (json['padding']['right'] as num?)?.toDouble() ?? 0,
              (json['padding']['bottom'] as num?)?.toDouble() ?? 0,
            )
          : EdgeInsets.zero,
      calcParam: json['calcParam'] != null
          ? TradeMarkParam.fromJson(json['calcParam'] as Map<String, dynamic>)
          : const TradeMarkParam(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'zIndex': zIndex,
      'height': height,
      'padding': {
        'left': padding.left,
        'top': padding.top,
        'right': padding.right,
        'bottom': padding.bottom,
      },
      'calcParam': calcParam.toJson(),
    };
  }
}

/// 交易标记绘制对象
///
/// 通过 [IPaintContext.getBusinessData] 获取 [Map<int, CandleTradeMarks>] 格式的数据。
/// 数据分组由外部完成（如 Riverpod Provider），绘制帧内不做任何数据处理。
class TradeMarkPaintObject<T extends TradeMarkIndicator>
    extends BusinessPaintObject<T> {
  TradeMarkPaintObject();

  @override
  MinMax? computeVisibleMinMax(int start, int end) {
    if (!klineData.canPaintChart) return null;
    if (!indicator.calcParam.show) return null;

    final groupedMarks = getBusinessData<Map<int, CandleTradeMarks>>(
      tradeMarkIndicatorKey,
    );
    if (groupedMarks == null || groupedMarks.isEmpty) return null;

    bool hasVisibleBuy = false;
    bool hasVisibleSell = false;
    for (int i = start; i <= end && i < klineData.list.length; i++) {
      final marks = groupedMarks[klineData.list[i].ts];
      if (marks == null || marks.isEmpty) continue;
      if (marks.hasBuy) hasVisibleBuy = true;
      if (marks.hasSell) hasVisibleSell = true;
      if (hasVisibleBuy && hasVisibleSell) break;
    }

    if (!hasVisibleBuy && !hasVisibleSell) return null;

    final candleMinMax = klineData.calculateMinmax(start, end);
    if (candleMinMax == null) return null;

    final param = indicator.calcParam;
    final markPixelHeight = _estimateMarkHeight(param);

    // padding 区域（topRect/bottomRect）已经为箭头提供了视觉空间，
    // 只补充 padding 覆盖不足的部分，避免顶部/底部出现双重空白。
    final topPaddingPx = chartRect.top - drawableRect.top;
    final bottomPaddingPx = drawableRect.bottom - chartRect.bottom;

    final extraTopPx = hasVisibleSell
        ? math.max(0.0, markPixelHeight - topPaddingPx)
        : 0.0;
    final extraBottomPx = hasVisibleBuy
        ? math.max(0.0, markPixelHeight - bottomPaddingPx)
        : 0.0;

    // padding 已足够容纳箭头，无需扩展 minMax
    if (extraTopPx == 0 && extraBottomPx == 0) return null;

    final availableHeight = chartRect.height - extraTopPx - extraBottomPx;
    if (availableHeight <= 0) return null;

    final priceRange = candleMinMax.diffDivisor.toDouble();
    if (priceRange <= 0) return null;

    final pricePerPx = priceRange / availableHeight;

    return MinMax(
      min: extraBottomPx > 0
          ? candleMinMax.min - FlexiNum.fromNum(pricePerPx * extraBottomPx)
          : candleMinMax.min,
      max: extraTopPx > 0
          ? candleMinMax.max + FlexiNum.fromNum(pricePerPx * extraTopPx)
          : candleMinMax.max,
    );
  }

  /// 估算单个买卖标记在 Y 方向占用的总像素高度
  double _estimateMarkHeight(TradeMarkParam param) {
    if (param.useArrowStyle) {
      final fontSize = param.buyTextStyle.fontSize ?? 8.0;
      // spacing + 箭头 + 文字标签（fontSize + padding*2）
      return param.spacing + param.arrowSize + fontSize + 6.0;
    } else {
      return param.spacing + param.markerRadius * 2;
    }
  }

  @override
  void onCross(Canvas canvas, Offset offset) {}

  @override
  void paintChart(Canvas canvas, Size size) {
    if (!klineData.canPaintChart) return;
    if (!indicator.calcParam.show) return;

    final groupedMarks = getBusinessData<Map<int, CandleTradeMarks>>(
      tradeMarkIndicatorKey,
    );
    if (groupedMarks == null || groupedMarks.isEmpty) return;

    final startIndex = math.max(0, klineData.start);
    final endIndex = math.min(klineData.end, klineData.list.length - 1);
    if (startIndex > endIndex) return;

    final paint = Paint()..style = PaintingStyle.fill;
    final param = indicator.calcParam;

    for (int i = startIndex; i <= endIndex; i++) {
      final candle = klineData.list[i];
      final marks = groupedMarks[candle.ts];
      if (marks == null || marks.isEmpty) continue;

      final rawDx = indexToDx(i);
      if (rawDx == null) continue;
      // indexToDx 返回的是蜡烛区域的右边缘，减去半宽得到蜡烛中心线
      final cx = rawDx - candleWidthHalf;

      if (marks.hasBuy) {
        final tipY = valueToDy(candle.low) + param.spacing;
        _drawBuyMark(canvas, cx, tipY, marks.buyMark!, paint);
      }

      if (marks.hasSell) {
        final tipY = valueToDy(candle.high) - param.spacing;
        _drawSellMark(canvas, cx, tipY, marks.sellMark!, paint);
      }
    }
  }

  /// 绘制买入标记：向上的箭头，尖端在 tipY，体在下方
  ///
  /// ```
  ///     ▲       ← tipY (箭头尖端，紧贴蜡烛低点)
  ///    / \
  ///   /   \
  ///  ╔═════╗
  ///  ║  B  ║   ← 标签体
  ///  ╚═════╝
  /// ```
  void _drawBuyMark(
    Canvas canvas,
    double cx,
    double tipY,
    TradeMarkData mark,
    Paint paint,
  ) {
    final param = indicator.calcParam;
    final color = param.buyBgColor;

    if (param.useArrowStyle) {
      final arrowH = param.arrowSize;
      final arrowW = param.arrowSize;

      // 箭头三角形（尖端朝上）
      final arrowPath = Path()
        ..moveTo(cx, tipY)
        ..lineTo(cx - arrowW, tipY + arrowH)
        ..lineTo(cx + arrowW, tipY + arrowH)
        ..close();

      paint
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawPath(arrowPath, paint);

      // 标签紧接箭头底部
      _drawLabel(canvas, cx, tipY + arrowH, mark, paint, color, below: true);
    } else {
      final center = Offset(cx, tipY + param.markerRadius);
      _drawCircleMark(canvas, center, mark, paint, color);
    }
  }

  /// 绘制卖出标记：向下的箭头，尖端在 tipY，体在上方
  ///
  /// ```
  ///  ╔═════╗
  ///  ║  S  ║   ← 标签体
  ///  ╚═════╝
  ///   \   /
  ///    \ /
  ///     ▼       ← tipY (箭头尖端，紧贴蜡烛高点)
  /// ```
  void _drawSellMark(
    Canvas canvas,
    double cx,
    double tipY,
    TradeMarkData mark,
    Paint paint,
  ) {
    final param = indicator.calcParam;
    final color = param.sellBgColor;

    if (param.useArrowStyle) {
      final arrowH = param.arrowSize;
      final arrowW = param.arrowSize;

      // 箭头三角形（尖端朝下）
      final arrowPath = Path()
        ..moveTo(cx, tipY)
        ..lineTo(cx - arrowW, tipY - arrowH)
        ..lineTo(cx + arrowW, tipY - arrowH)
        ..close();

      paint
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawPath(arrowPath, paint);

      // 标签紧接箭头顶部
      _drawLabel(canvas, cx, tipY - arrowH, mark, paint, color, below: false);
    } else {
      final center = Offset(cx, tipY - param.markerRadius);
      _drawCircleMark(canvas, center, mark, paint, color);
    }
  }

  /// 绘制文字标签（矩形带圆角）
  void _drawLabel(
    Canvas canvas,
    double cx,
    double anchorY,
    TradeMarkData mark,
    Paint paint,
    Color bgColor, {
    required bool below,
  }) {
    final param = indicator.calcParam;
    final textStyle =
        mark.type == TradeType.buy ? param.buyTextStyle : param.sellTextStyle;

    String text = mark.type == TradeType.buy ? 'B' : 'S';
    if (mark.count > 1 && param.showQuantity) {
      text = '$text${mark.count}';
    }

    final tp = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    const padH = 3.0;
    const padV = 1.5;
    final labelW = tp.width + padH * 2;
    final labelH = tp.height + padV * 2;

    final left = cx - labelW / 2;
    final top = below ? anchorY : anchorY - labelH;

    final rrect = RRect.fromLTRBR(
      left,
      top,
      left + labelW,
      top + labelH,
      const Radius.circular(2),
    );

    paint
      ..color = bgColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, paint);

    tp.paint(canvas, Offset(left + padH, top + padV));
  }

  /// 圆形样式（备用）
  void _drawCircleMark(
    Canvas canvas,
    Offset center,
    TradeMarkData mark,
    Paint paint,
    Color bgColor,
  ) {
    final param = indicator.calcParam;
    final radius = param.markerRadius;

    paint
      ..color = bgColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);

    if (param.borderColor != null && param.borderWidth > 0) {
      paint
        ..color = param.borderColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = param.borderWidth;
      canvas.drawCircle(center, radius, paint);
      paint
        ..style = PaintingStyle.fill
        ..strokeWidth = 1;
    }

    final textStyle =
        mark.type == TradeType.buy ? param.buyTextStyle : param.sellTextStyle;
    final text = mark.type == TradeType.buy ? 'B' : 'S';

    final tp = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
    );
  }

  @override
  Size? paintTips(
    Canvas canvas, {
    FlexiCandleModel? model,
    Offset? offset,
    Rect? tipsRect,
  }) {
    model ??= offsetToCandle(offset);
    if (model == null || !indicator.calcParam.show) return null;

    final groupedMarks = getBusinessData<Map<int, CandleTradeMarks>>(
      tradeMarkIndicatorKey,
    );
    if (groupedMarks == null) return null;

    final marks = groupedMarks[model.ts];
    if (marks == null || marks.isEmpty) return null;

    final tips = <String>[];
    final param = indicator.calcParam;

    if (marks.hasBuy) {
      final buy = marks.buyMark!;
      String tipText =
          '买入: ${formatNumber(buy.price.toDecimal(), precision: klineData.precision)}';
      if (param.showQuantity) {
        tipText +=
            ' 数量: ${formatNumber(buy.volume.toDecimal(), precision: 4)}';
      }
      if (buy.count > 1) {
        tipText += ' (${buy.count}次)';
      }
      tips.add(tipText);
    }

    if (marks.hasSell) {
      final sell = marks.sellMark!;
      String tipText =
          '卖出: ${formatNumber(sell.price.toDecimal(), precision: klineData.precision)}';
      if (param.showQuantity) {
        tipText +=
            ' 数量: ${formatNumber(sell.volume.toDecimal(), precision: 4)}';
      }
      if (sell.count > 1) {
        tipText += ' (${sell.count}次)';
      }
      tips.add(tipText);
    }

    if (tips.isEmpty) return null;

    tipsRect ??= drawableRect;
    final text = tips.join('   ');
    return canvas.drawText(
      offset: tipsRect.topLeft,
      text: text,
      style: TextStyle(color: theme.textColor, fontSize: 12),
      drawDirection: DrawDirection.ltr,
      drawableRect: tipsRect,
      textAlign: TextAlign.left,
      maxLines: tips.length,
    );
  }

  bool hitTest(Offset position) => false;
}
