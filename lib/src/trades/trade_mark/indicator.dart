part of 'trade_mark.dart';

/// 交易标记指标
@CopyWith()
@FlexiIndicatorSerializable
class TradeMarkIndicator extends SinglePaintObjectIndicator {
  TradeMarkIndicator({
    super.zIndex = 0,
    required super.height,
    super.padding = defaultMainIndicatorPadding,
    this.calcParam = const TradeMarkParam(),
  }) : super(key: const FlexiIndicatorKey('trade_mark'));

  @override
  final TradeMarkParam calcParam;

  @override
  TradeMarkPaintObject createPaintObject(
    IPaintContext context, {
    KlineEventBus? eventBus,
  }) {
    return TradeMarkPaintObject(context: context, indicator: this);
  }

  factory TradeMarkIndicator.fromJson(Map<String, dynamic> json) => _$TradeMarkIndicatorFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TradeMarkIndicatorToJson(this);
}

class TradeMarkPaintObject<T extends TradeMarkIndicator> extends SinglePaintObjectBox<T> with TradeMarkDataMixin<T> {
  TradeMarkPaintObject({
    required super.context,
    required super.indicator,
  });

  @override
  MinMax? initState({required int start, required int end}) {
    // 交易标记不需要计算MinMax，直接返回null
    return null;
  }

  @override
  void paintChart(Canvas canvas, Size size) {
    final param = indicator.calcParam;
    if (!param.show || !klineData.canPaintChart) return;

    final candleWidth = candleActualWidth;
    final halfCandleWidth = candleWidthHalf;
    final start = klineData.start;
    final end = klineData.end;

    int signalCount = 0;
    const double signalPadding = 2;

    for (int i = start; i < end; i++) {
      final candle = klineData.list[i];
      final signals = tradeSignalMap[candle.ts];
      if (signals == null || signals.isEmpty) continue;

      signalCount++;
      final double x = startCandleDx - (i - start) * candleWidth - halfCandleWidth;

      for (final signal in signals) {
        switch (signal.type) {
          case TradeSignalType.buy:
            final y = valueToDy(candle.low) + signalPadding;
            _drawSignal(
              canvas,
              x,
              y,
              'B',
              param.buyStyle,
              param.buyBgColor,
              param.width,
              param.height - param.width,
              up: true,
            );
            break;
          case TradeSignalType.sell:
            final y = valueToDy(candle.high) - signalPadding;
            _drawSignal(
              canvas,
              x,
              y,
              'S',
              param.sellStyle,
              param.sellBgColor,
              param.width,
              param.height - param.width,
              up: false,
            );
            break;
          // 可扩展更多信号类型
        }
      }
    }
    // 可选：调试输出信号数量
    // if (kDebugMode) print('本区间信号数量: $signalCount');
  }

  void _drawSignal(
      Canvas canvas,
      double x,
      double y,
      String text,
      TextStyle style,
      Color bgColor,
      double size, // 正方形边长，如24
      double arrowH, // 箭头高度，如6
      {bool up = false} // true: 上箭头, false: 下箭头
      ) {
    final double r = size / 4; // 圆角半径
    final double half = size / 2;
    final double left = x - half;
    final double right = x + half;
    final double allHeight = size + arrowH;
    final double top = y;

    final Path path = Path();
    if (up) {
      // 上箭头
      path.moveTo(x, top); // 顶部箭头尖
      path.lineTo(right - r, top + arrowH);
      path.arcToPoint(Offset(right, top + arrowH + r), radius: Radius.circular(r));
      path.lineTo(right, y + allHeight - r);
      path.arcToPoint(Offset(right - r, y + allHeight), radius: Radius.circular(r));
      path.lineTo(left + r, y + allHeight);
      path.arcToPoint(Offset(left, y + allHeight - r), radius: Radius.circular(r));
      path.lineTo(left, top + r + arrowH);
      path.arcToPoint(Offset(left + r, top + arrowH), radius: Radius.circular(r));
      path.close();
    } else {
      // 下箭头
      path.moveTo(left + r, top - allHeight);
      path.lineTo(right - r, top - allHeight);
      path.arcToPoint(Offset(right, top - allHeight + r), radius: Radius.circular(r));
      path.lineTo(right, top - arrowH - r);
      path.arcToPoint(Offset(right - r, top - arrowH), radius: Radius.circular(r));
      path.lineTo(x, top); // 底部箭头尖
      path.lineTo(left + r, top - arrowH);
      path.arcToPoint(Offset(left, top - arrowH - r), radius: Radius.circular(r));
      path.lineTo(left, top - allHeight + r);
      path.arcToPoint(Offset(left + r, top - allHeight), radius: Radius.circular(r));
      path.close();
    }

    // 绘制背景
    final paint = Paint()..color = bgColor;
    canvas.drawPath(path, paint);

    // 绘制文字
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();

    final double textY = up ? (y + arrowH + size / 2 - textPainter.height / 2) : (y - arrowH - size / 2 - textPainter.height / 2);

    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, textY),
    );
  }

  @override
  void onCross(Canvas canvas, Offset offset) {
    // 交易标记不需要十字线交互
  }

  @override
  Size? paintTips(
    Canvas canvas, {
    CandleModel? model,
    Offset? offset,
    Rect? tipsRect,
  }) {
    // 交易标记不需要tips显示
    return null;
  }
}
