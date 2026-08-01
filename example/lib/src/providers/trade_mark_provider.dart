import 'dart:math' as math;

import 'package:flexi_kline/flexi_kline.dart';
import 'package:flutter/foundation.dart';

/// 交易标记数据管理
///
/// 负责原始交易数据的存储、按 interval 分组，以及注入到 controller。
/// 使用方式:
/// 1. 创建 TradeMarkDataManager 实例
/// 2. 调用 setRawMarks() 设置原始数据
/// 3. 监听 controller.intervalListenable，interval 变化时调用 regroup()
/// 4. 分组结果自动通过 setBusinessData 注入到 controller
class TradeMarkDataManager {
  TradeMarkDataManager(this._controller);

  final FlexiKlineController _controller;

  List<TradeMarkData> _rawMarks = [];
  ITimeInterval? _currentTimeBar;
  Map<int, CandleTradeMarks> _groupedMarks = const {};

  List<TradeMarkData> get rawMarks => _rawMarks;
  Map<int, CandleTradeMarks> get groupedMarks => _groupedMarks;

  /// 设置原始交易标记数据并按当前 interval 分组
  void setRawMarks(List<TradeMarkData> marks) {
    _rawMarks = marks;
    _regroup();
  }

  /// 清空数据
  void clear() {
    _rawMarks = [];
    _groupedMarks = const {};
    _controller.removeBusinessData(tradeMarkIndicatorKey);
  }

  /// 当 interval 变化时调用，重新分组并注入
  void onTimeBarChanged(ITimeInterval? interval) {
    if (interval == null || interval == _currentTimeBar) return;
    _currentTimeBar = interval;
    _regroup();
  }

  void _regroup() {
    final interval = _currentTimeBar;
    if (interval == null || _rawMarks.isEmpty) {
      _groupedMarks = const {};
      _controller.removeBusinessData(tradeMarkIndicatorKey);
      return;
    }

    _groupedMarks = groupTradeMarksByKlineData(
      _rawMarks,
      _controller.klineData,
      fallbackInterval: interval,
    );
    _controller.setBusinessData(tradeMarkIndicatorKey, _groupedMarks);
  }

  void dispose() {
    _rawMarks = [];
    _groupedMarks = const {};
  }
}

/// 按 interval 分组交易标记数据（纯函数，可在 isolate 中执行）
Map<int, CandleTradeMarks> groupTradeMarksByTimeBar(
  List<TradeMarkData> marks,
  ITimeInterval interval,
) {
  if (marks.isEmpty) return const {};

  final ms = interval.milliseconds;
  final result = <int, CandleTradeMarks>{};

  for (final mark in marks) {
    final candleTime = (mark.timestamp ~/ ms) * ms;
    _mergeTradeMark(result, candleTime, mark);
  }

  return result;
}

/// 按当前 K 线真实时间戳分组交易标记。
///
/// 绘制层使用 `groupedMarks[candle.ts]` 精确读取数据，所以这里必须把订单
/// 时间对齐到当前列表里的 candle.ts，而不是只按 interval 数学取整。
Map<int, CandleTradeMarks> groupTradeMarksByKlineData(
  List<TradeMarkData> marks,
  KlineData klineData, {
  ITimeInterval? fallbackInterval,
}) {
  if (marks.isEmpty) return const {};
  if (klineData.list.isEmpty || !klineData.spec.interval.isValid) {
    if (fallbackInterval == null) return const {};
    return groupTradeMarksByTimeBar(marks, fallbackInterval);
  }

  final result = <int, CandleTradeMarks>{};
  for (final mark in marks) {
    final indexValue = klineData.timestampToIndex(mark.timestamp);
    if (indexValue == null) continue;

    final index = indexValue.truncate();
    if (index < 0 || index >= klineData.list.length) continue;

    _mergeTradeMark(result, klineData.list[index].ts, mark);
  }

  return result;
}

void _mergeTradeMark(
  Map<int, CandleTradeMarks> result,
  int candleTime,
  TradeMarkData mark,
) {
  final current = result[candleTime] ?? const CandleTradeMarks();

  if (mark.type == TradeType.buy) {
    result[candleTime] = CandleTradeMarks(
      buyMark: current.buyMark?.merge(mark) ?? mark,
      sellMark: current.sellMark,
    );
  } else {
    result[candleTime] = CandleTradeMarks(
      buyMark: current.buyMark,
      sellMark: current.sellMark?.merge(mark) ?? mark,
    );
  }
}

/// 生成模拟"最近下单"的交易标记
///
/// 模拟最近一段时间的买卖订单，直接使用 K 线真实时间戳和价格，
/// 确保标记精确落在真实蜡烛上。
List<TradeMarkData> createTestTradeMarks(KlineData klineData) {
  if (!klineData.canPaintChart || klineData.list.isEmpty) return [];

  final list = klineData.list;
  final len = list.length;
  final rng = math.Random(42);
  final marks = <TradeMarkData>[];

  // 取最近 80% 的蜡烛区间，模拟最近的交易
  final recentStart = (len * 0.2).toInt();

  // 生成约 15~25 笔订单
  final orderCount = 15 + rng.nextInt(11);

  for (int n = 0; n < orderCount; n++) {
    final idx = recentStart + rng.nextInt(len - recentStart);
    final candle = list[idx];
    final isBuy = rng.nextBool();

    final high = candle.high.toDouble();
    final low = candle.low.toDouble();
    final range = high - low;
    // 买单偏低位成交，卖单偏高位成交
    final price = isBuy
        ? low + range * rng.nextDouble() * 0.4
        : high - range * rng.nextDouble() * 0.4;
    final volume = 0.01 + rng.nextDouble() * 0.5;

    marks.add(TradeMarkData(
      timestamp: candle.ts,
      type: isBuy ? TradeType.buy : TradeType.sell,
      price: double.parse(price.toStringAsFixed(2)),
      maxPrice: high,
      volume: double.parse(volume.toStringAsFixed(4)),
      orderId: '${isBuy ? "buy" : "sell"}_${candle.ts}_$n',
    ));
  }

  // 在最新蜡烛附近密集放几笔（模拟刚刚下单）
  for (int n = 0; n < 5; n++) {
    final idx = len - 1 - rng.nextInt(math.min(10, len));
    final candle = list[idx];
    final isBuy = n % 2 == 0;
    final high = candle.high.toDouble();
    final low = candle.low.toDouble();
    final price = isBuy ? low : high;
    final volume = 0.05 + rng.nextDouble() * 0.3;

    marks.add(TradeMarkData(
      timestamp: candle.ts,
      type: isBuy ? TradeType.buy : TradeType.sell,
      price: double.parse(price.toStringAsFixed(2)),
      maxPrice: high,
      volume: double.parse(volume.toStringAsFixed(4)),
      orderId: 'recent_${isBuy ? "buy" : "sell"}_$n',
    ));
  }

  debugPrint(
    '[TradeMark] 生成 ${marks.length} 笔模拟订单 '
    '(K线范围: ${list.length} 根, '
    'interval: ${klineData.spec.interval.debugLabel})',
  );
  return marks;
}
