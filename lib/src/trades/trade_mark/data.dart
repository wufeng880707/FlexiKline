part of 'trade_mark.dart';

/// 交易标记数据计算
mixin TradeMarkDataMixin<T extends TradeMarkIndicator> on SinglePaintObjectBox<T> {
  /// 全局交易信号数据存储
  static final Map<int, Set<TradeSignalType>> _globalTradeSignals = {};
  
  /// 获取交易信号数据
  Map<int, Set<TradeSignalType>> get tradeSignalMap => _globalTradeSignals;
  
  /// 设置交易信号数据
  static void setGlobalTradeSignals(Map<int, Set<TradeSignalType>> signals) {
    _globalTradeSignals
      ..clear()
      ..addAll(signals);
  }
  
  /// 获取指定时间戳的交易信号
  Set<TradeSignalType> getTradeSignalsForTimestamp(int timestamp) {
    return tradeSignalMap[timestamp] ?? <TradeSignalType>{};
  }

  /// 获取当前可见范围内的所有交易信号
  Map<int, Set<TradeSignalType>> getVisibleTradeSignals() {
    final signals = <int, Set<TradeSignalType>>{};
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
} 