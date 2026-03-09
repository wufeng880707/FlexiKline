part of 'trade_mark.dart';

/// 交易标记指标Key
const tradeMarkIndicatorKey = FlexiIndicatorKey('tradeMark');

/// 交易标记指标
@CopyWith()
class TradeMarkIndicator extends PaintObjectIndicator implements IPrecomputable {
  TradeMarkIndicator({
    super.zIndex = 100, // 高层级，确保在其他指标之上
    super.height = 0, // 不占用高度
    super.padding = EdgeInsets.zero,
    this.calcParam = const TradeMarkParam(),
    this.tradeMarks = const [],
  }) : super(key: tradeMarkIndicatorKey);

  /// 计算参数
  @override
  final TradeMarkParam calcParam;

  /// 交易标记数据
  final List<TradeMarkData> tradeMarks;

  @override
  PaintObjectBox createPaintObject(IPaintContext context) {
    return TradeMarkPaintObject(context: context, indicator: this);
  }

  /// 更新交易标记数据
  TradeMarkIndicator updateTradeMarks(List<TradeMarkData> newMarks) {
    return TradeMarkIndicator(
      zIndex: zIndex,
      height: height,
      padding: padding,
      calcParam: calcParam,
      tradeMarks: newMarks,
    );
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
      calcParam: json['calcParam'] != null ? TradeMarkParam.fromJson(json['calcParam'] as Map<String, dynamic>) : const TradeMarkParam(),
      tradeMarks: (json['tradeMarks'] as List<dynamic>?)?.map((e) => TradeMarkData.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
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
      'tradeMarks': tradeMarks.map((e) => e.toJson()).toList(),
    };
  }
}

/// 交易标记绘制对象
class TradeMarkPaintObject<T extends TradeMarkIndicator> extends PaintObjectBox<T> {
  TradeMarkPaintObject({
    required super.context,
    required super.indicator,
  });

  /// 预处理的交易标记数据（按K线分组）
  final Map<int, CandleTradeMarks> _groupedMarks = {};

  /// 最后一次数据更新时间
  int _lastDataUpdateTime = 0;

  @override
  MinMax? initState(int start, int end) {
    _preprocessTradeMarks();
    return null; // 交易标记不影响价格范围
  }

  @override
  void onCross(Canvas canvas, Offset offset) {
    // 交易标记不需要十字光标交互
  }

  @override
  void didUpdateIndicator(T oldIndicator) {
    super.didUpdateIndicator(oldIndicator);
    if (oldIndicator.tradeMarks.length != indicator.tradeMarks.length || _lastDataUpdateTime == 0) {
      _preprocessTradeMarks();
    }
  }

  /// 预处理交易标记数据，按K线时间戳分组
  void _preprocessTradeMarks() {
    _groupedMarks.clear();
    if (!klineData.canPaintChart || indicator.tradeMarks.isEmpty) return;

    final timeBar = klineData.req.timeBar;

    // 按K线时间戳分组交易标记
    for (final mark in indicator.tradeMarks) {
      final candleTime = (mark.timestamp ~/ timeBar.milliseconds) * timeBar.milliseconds;

      if (!_groupedMarks.containsKey(candleTime)) {
        _groupedMarks[candleTime] = const CandleTradeMarks();
      }

      final current = _groupedMarks[candleTime]!;

      if (mark.type == TradeType.buy) {
        final newBuyMark = current.buyMark?.merge(mark) ?? mark;
        _groupedMarks[candleTime] = CandleTradeMarks(
          buyMark: newBuyMark,
          sellMark: current.sellMark,
        );
      } else {
        final newSellMark = current.sellMark?.merge(mark) ?? mark;
        _groupedMarks[candleTime] = CandleTradeMarks(
          buyMark: current.buyMark,
          sellMark: newSellMark,
        );
      }
    }

    _lastDataUpdateTime = DateTime.now().millisecondsSinceEpoch;
  }

  @override
  void paintChart(Canvas canvas, Size size) {
    if (!klineData.canPaintChart || !indicator.calcParam.show || _groupedMarks.isEmpty) return;

    final startIndex = (klineData.start - 2).clamp(0, klineData.list.length - 1);
    final endIndex = (klineData.end + 2).clamp(0, klineData.list.length - 1);

    // 创建画笔
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = startIndex; i <= endIndex; i++) {
      final candle = klineData.list[i];
      final marks = _groupedMarks[candle.ts];

      if (marks != null && !marks.isEmpty) {
        final x = indexToDx(i) ?? 0;

        // 绘制买入标记（在K线下方）
        if (marks.hasBuy) {
          final y = valueToDy(candle.low) + indicator.calcParam.spacing + indicator.calcParam.markerRadius;
          _drawTradeMark(canvas, Offset(x, y), marks.buyMark!, paint);
        }

        // 绘制卖出标记（在K线上方）
        if (marks.hasSell) {
          final y = valueToDy(candle.high) - indicator.calcParam.spacing - indicator.calcParam.markerRadius;
          _drawTradeMark(canvas, Offset(x, y), marks.sellMark!, paint);
        }
      }
    }
  }

  /// 绘制单个交易标记
  void _drawTradeMark(Canvas canvas, Offset center, TradeMarkData mark, Paint paint) {
    final param = indicator.calcParam;
    final radius = param.markerRadius;

    // 准备文本
    String text = mark.type == TradeType.buy ? 'B' : 'S';
    if (mark.count > 1 && param.showQuantity) {
      text = '$text${mark.count}';
    }

    // 获取基础文字样式
    final baseTextStyle = mark.type == TradeType.buy ? param.buyTextStyle : param.sellTextStyle;

    // 如果有多个交易，稍微减小字体
    final textStyle = mark.count > 1 ? baseTextStyle.copyWith(fontSize: (baseTextStyle.fontSize ?? 12.0) - 1) : baseTextStyle;

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    );

    // 绘制圆形背景
    paint.color = mark.type == TradeType.buy ? param.buyBgColor : param.sellBgColor;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);

    // 绘制边框（如果设置了边框颜色）
    if (param.borderColor != null) {
      paint.color = param.borderColor!;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = param.borderWidth;
      canvas.drawCircle(center, radius, paint);
    }

    // 绘制文字
    textPainter.layout();
    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );
    textPainter.paint(canvas, textOffset);

    // 重置画笔
    paint.style = PaintingStyle.fill;
    paint.strokeWidth = 1;
  }

  @override
  Size? paintTips(
    Canvas canvas, {
    CandleModel? model,
    Offset? offset,
    Rect? tipsRect,
  }) {
    model ??= offsetToCandle(offset);
    if (model == null || !indicator.calcParam.show) return null;

    final marks = _groupedMarks[model.ts];
    if (marks == null || marks.isEmpty) return null;

    final tips = <String>[];
    final param = indicator.calcParam;

    if (marks.hasBuy) {
      final buy = marks.buyMark!;
      String tipText = '买入: ${formatNumber(buy.price.toDecimal(), precision: klineData.precision)}';

      if (param.showQuantity) {
        tipText += ' 数量: ${formatNumber(buy.volume.toDecimal(), precision: 4)}';
      }

      if (buy.count > 1) {
        tipText += ' (${buy.count}次)';
      }

      tips.add(tipText);
    }

    if (marks.hasSell) {
      final sell = marks.sellMark!;
      String tipText = '卖出: ${formatNumber(sell.price.toDecimal(), precision: klineData.precision)}';

      if (param.showQuantity) {
        tipText += ' 数量: ${formatNumber(sell.volume.toDecimal(), precision: 4)}';
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
      style: TextStyle(
        color: theme.textColor,
        fontSize: 12,
      ),
      drawDirection: DrawDirection.ltr,
      drawableRect: tipsRect,
      textAlign: TextAlign.left,
      maxLines: tips.length,
    );
  }

  bool hitTest(Offset position) {
    // 交易标记不响应点击事件
    return false;
  }
}
