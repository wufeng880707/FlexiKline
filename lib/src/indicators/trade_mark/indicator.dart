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
  @override
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
  MinMax? initState(int start, int end) {
    return null;
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

    final startIndex = klineData.start;
    final endIndex = klineData.end;
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = startIndex; i <= endIndex; i++) {
      final candle = klineData.list[i];
      final marks = groupedMarks[candle.ts];
      if (marks == null || marks.isEmpty) continue;

      final x = indexToDx(i) ?? 0;

      if (marks.hasBuy) {
        final y = valueToDy(candle.low) +
            indicator.calcParam.spacing +
            indicator.calcParam.markerRadius;
        _drawTradeMark(canvas, Offset(x, y), marks.buyMark!, paint);
      }

      if (marks.hasSell) {
        final y = valueToDy(candle.high) -
            indicator.calcParam.spacing -
            indicator.calcParam.markerRadius;
        _drawTradeMark(canvas, Offset(x, y), marks.sellMark!, paint);
      }
    }
  }

  void _drawTradeMark(
    Canvas canvas,
    Offset center,
    TradeMarkData mark,
    Paint paint,
  ) {
    final param = indicator.calcParam;
    final radius = param.markerRadius;

    String text = mark.type == TradeType.buy ? 'B' : 'S';
    if (mark.count > 1 && param.showQuantity) {
      text = '$text${mark.count}';
    }

    final baseTextStyle =
        mark.type == TradeType.buy ? param.buyTextStyle : param.sellTextStyle;
    final textStyle = mark.count > 1
        ? baseTextStyle.copyWith(
            fontSize: (baseTextStyle.fontSize ?? 12.0) - 1)
        : baseTextStyle;

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );

    paint.color =
        mark.type == TradeType.buy ? param.buyBgColor : param.sellBgColor;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);

    if (param.borderColor != null) {
      paint.color = param.borderColor!;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = param.borderWidth;
      canvas.drawCircle(center, radius, paint);
    }

    textPainter.layout();
    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );
    textPainter.paint(canvas, textOffset);

    paint.style = PaintingStyle.fill;
    paint.strokeWidth = 1;
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
