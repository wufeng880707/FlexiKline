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
  TradeMarkPaintObject createPaintObject(IPaintContext context) {
    return TradeMarkPaintObject(context: context, indicator: this);
  }

  factory TradeMarkIndicator.fromJson(Map<String, dynamic> json) =>
      _$TradeMarkIndicatorFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TradeMarkIndicatorToJson(this);
}

class TradeMarkPaintObject<T extends TradeMarkIndicator> extends SinglePaintObjectBox<T> 
    with TradeMarkDataMixin<T> {
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
    if (!param.show) return;

    if (!klineData.canPaintChart) return;

    final candleWidth = candleActualWidth;
    final halfCandleWidth = candleWidthHalf;
    final start = klineData.start;
    final end = klineData.end;

    int signalCount = 0;
    for (int i = start; i < end; i++) {
      final candle = klineData.list[i];
      final signals = tradeSignalMap[candle.ts];
      if (signals == null || signals.isEmpty) continue;

      signalCount++;
      final double x = startCandleDx - (i - start) * candleWidth - halfCandleWidth;

      // 买信号在最低价
      if (signals.contains(TradeSignalType.buy)) {
        final y = valueToDy(candle.low);
        _drawSignal(
          canvas,
          x,
          y,
          'B',
          param.buyStyle,
          param.buyBgColor,
          param.markerRadius,
        );
      }
      // 卖信号在最高价
      if (signals.contains(TradeSignalType.sell)) {
        final y = valueToDy(candle.high);
        _drawSignal(
          canvas,
          x,
          y,
          'S',
          param.sellStyle,
          param.sellBgColor,
          param.markerRadius,
        );
      }
    }
    
    // 添加调试信息
    if (signalCount > 0) {
      print('TradeMark: Painted $signalCount signals in range $start-$end');
    }
  }

  void _drawSignal(
    Canvas canvas,
    double x,
    double y,
    String text,
    TextStyle style,
    Color bgColor,
    double radius,
  ) {
    final paint = Paint()..color = bgColor;
    canvas.drawCircle(Offset(x, y), radius, paint);

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
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