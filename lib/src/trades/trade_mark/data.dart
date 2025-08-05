part of 'trade_mark.dart';

/// 交易信号类型
enum TradeSignalType {
  buy,
  sell,
}

class TradeSignalModel {
  final int orderTs;
  final TradeSignalType type;
  final double quantity;
  final double price;
  final String orderId;

  TradeSignalModel({
    required this.orderTs,
    required this.type,
    required this.quantity,
    required this.price,
    required this.orderId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TradeSignalModel &&
          runtimeType == other.runtimeType &&
          orderTs == other.orderTs &&
          type == other.type &&
          orderId == other.orderId;

  @override
  int get hashCode => orderTs.hashCode ^ type.hashCode ^ orderId.hashCode;
}

/// 交易标记数据计算
mixin TradeMarkDataMixin<T extends TradeMarkIndicator> on PaintObjectBox<T> {
  /// 全局交易信号数据存储
  static final Map<int, Set<TradeSignalModel>> _globalTradeSignals = {};

  /// 获取交易信号数据
  Map<int, Set<TradeSignalModel>> get tradeSignalMap => _globalTradeSignals;

  /// 设置交易信号数据
  static void setGlobalTradeSignals(Map<int, Set<TradeSignalModel>> signals) {
    _globalTradeSignals
      ..clear()
      ..addAll(signals);
  }

  /// 获取指定时间戳的交易信号
  Set<TradeSignalModel> getTradeSignalsForTimestamp(int timestamp) {
    return tradeSignalMap[timestamp] ?? <TradeSignalModel>{};
  }

  /// 获取当前可见范围内的所有交易信号
  Map<int, Set<TradeSignalModel>> getVisibleTradeSignals() {
    final signals = <int, Set<TradeSignalModel>>{};
    final start = klineData.start;
    final end = klineData.end;
    for (int i = start; i < end; i++) {
      final ts = klineData.list[i].ts;
      final s = tradeSignalMap[ts];
      if (s != null && s.isNotEmpty) {
        signals[ts] = s;
      }
    }
    return signals;
  }

  /// 检查是否有任何交易信号
  bool get hasAnyTradeSignals {
    final start = klineData.start;
    final end = klineData.end;
    for (int i = start; i < end; i++) {
      final ts = klineData.list[i].ts;
      final s = tradeSignalMap[ts];
      if (s != null && s.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  // /// 高效归属订单信号到K线正点
  // /// [orders] 订单信号列表，需有 ts 和 signalType 字段
  // /// [klineList] K线列表，需有 ts 字段，升序排列
  // /// 返回 Map<klineTs, Set<TradeSignalType>>
  // static Map<int, Set<TradeSignalType>> processTradeSignalsForKlines({
  //   required List<dynamic> orders, // 订单信号对象，需有 ts 和 signalType
  //   required List<CandleModel> klineList,
  //   int Function(dynamic order)? getOrderTs,
  //   TradeSignalType Function(dynamic order)? getSignalType,
  // }) {
  //   final map = <int, Set<TradeSignalType>>{};
  //   if (klineList.length < 2) return map;
  //   final int startTs = klineList.first.ts;
  //   final int interval = klineList[1].ts - klineList[0].ts;
  //   if (interval <= 0) return map;
  //   getOrderTs ??= (order) => order.ts;
  //   getSignalType ??= (order) => order.signalType;
  //   for (final order in orders) {
  //     final ts = getOrderTs(order);
  //     if (ts == null || ts < startTs) continue;
  //     int index = ((ts - startTs) ~/ interval);
  //     if (index < 0 || index >= klineList.length) continue;
  //     final klineTs = klineList[index].ts;
  //     final type = getSignalType(order);
  //     if (type == null) continue;
  //     map[klineTs] ??= <TradeSignalType>{};
  //     map[klineTs]!.add(type);
  //   }
  //   return map;
  // }

  static Map<int, Set<TradeSignalModel>> processTradeSignalsForKlines({
    required List<TradeSignalModel> orders,
    required List<CandleModel> klineList,
  }) {
    final map = <int, Set<TradeSignalModel>>{};
    if (klineList.length < 2) return map;

    // 1. 升序排序，保证最老到最新

    final sortedKlineList = List<CandleModel>.from(klineList)..sort((a, b) => a.ts.compareTo(b.ts));

    final int startTs = sortedKlineList.first.ts;
    final int interval = sortedKlineList[1].ts - sortedKlineList[0].ts;
    if (interval <= 0) return map;

    print('K线区间: ${startTs} ~ ${sortedKlineList.last.ts}, interval: $interval');
    print('订单信号数量: ${orders.length}');
    for (final order in orders) {
      final ts = order.orderTs;
      print('订单信号时间: $ts');
      if (ts < startTs) {
        print('订单信号早于K线区间，跳过');
        continue;
      }
      final int index = ((ts - startTs) ~/ interval);
      if (index < 0 || index >= sortedKlineList.length) {
        print('订单信号超出K线区间，跳过');
        continue;
      }
      final int klineTs = sortedKlineList[index].ts;
      print('归属到K线: $klineTs');
      map.putIfAbsent(klineTs, () => <TradeSignalModel>{}).add(order);
    }
    print('归属后信号map: $map');
    return map;
  }
}
