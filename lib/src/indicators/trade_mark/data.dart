part of 'trade_mark.dart';

/// 交易类型枚举
enum TradeType {
  buy,
  sell,
}

/// 交易标记数据模型
class TradeMarkData {
  final int timestamp;
  final TradeType type;
  final double volume;
  final double price;
  final double maxPrice;  // 最高价格（合并交易时记录最高价）
  final String? orderId;
  final int count; // 交易次数（如果合并了多个交易）

  const TradeMarkData({
    required this.timestamp,
    required this.type,
    required this.volume,
    required this.price,
    required this.maxPrice,
    this.orderId,
    this.count = 1,
  });

  /// 合并同类型的交易
  TradeMarkData merge(TradeMarkData other) {
    assert(type == other.type, '只能合并相同类型的交易');

    return TradeMarkData(
      timestamp: timestamp > other.timestamp ? timestamp : other.timestamp, // 取最新时间
      type: type,
      price: other.price, // 取最后一次交易价格
      maxPrice: maxPrice > other.maxPrice ? maxPrice : other.maxPrice, // 取最高价格
      volume: volume + other.volume, // 累加交易量
      orderId: other.orderId ?? orderId,
      count: count + other.count,
    );
  }

  factory TradeMarkData.fromJson(Map<String, dynamic> json) {
    return TradeMarkData(
      timestamp: json['timestamp'] as int,
      type: TradeType.values[json['type'] as int],
      price: (json['price'] as num).toDouble(),
      maxPrice: (json['maxPrice'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
      orderId: json['orderId'] as String?,
      count: json['count'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'type': type.index,
      'volume': volume,
      'price': price,
      'maxPrice': maxPrice,
      'orderId': orderId,
      'count': count,
    };
  }
  
  @override
  String toString() => 'TradeMarkData(type: $type, price: $price, maxPrice: $maxPrice, volume: $volume, count: $count)';
}

/// 单根K线的交易标记汇总
class CandleTradeMarks {
  /// 买入标记（显示在K线下方）
  final TradeMarkData? buyMark;
  
  /// 卖出标记（显示在K线上方）
  final TradeMarkData? sellMark;
  
  const CandleTradeMarks({
    this.buyMark,
    this.sellMark,
  });
  
  bool get hasBuy => buyMark != null;
  bool get hasSell => sellMark != null;
  bool get isEmpty => buyMark == null && sellMark == null;
}

/// 扩展CandleModel以获取交易标记
@visibleForTesting
extension CandleModelTradeMarkExt on CandleModel {
  /// 获取该K线的交易标记（需要从外部数据源获取）
  CandleTradeMarks getTradeMarks(List<TradeMarkData> allMarks, ITimeBar timeBar) {
    final candleStart = ts;
    final candleEnd = candleStart + timeBar.milliseconds;
    
    // 筛选该K线时间范围内的交易
    final candleMarks = allMarks.where((mark) => 
        mark.timestamp >= candleStart && mark.timestamp < candleEnd).toList();
    
    if (candleMarks.isEmpty) return const CandleTradeMarks();
    
    // 分离买卖并合并同类型交易
    final buyMarks = candleMarks.where((m) => m.type == TradeType.buy).toList();
    final sellMarks = candleMarks.where((m) => m.type == TradeType.sell).toList();
    
    TradeMarkData? buyMark;
    TradeMarkData? sellMark;
    
    if (buyMarks.isNotEmpty) {
      buyMark = buyMarks.reduce((a, b) => a.merge(b));
    }
    
    if (sellMarks.isNotEmpty) {
      sellMark = sellMarks.reduce((a, b) => a.merge(b));
    }
    
    return CandleTradeMarks(buyMark: buyMark, sellMark: sellMark);
  }
}
