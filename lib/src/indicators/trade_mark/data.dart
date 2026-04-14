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
  final double maxPrice;
  final String? orderId;
  final int count;

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
      timestamp: timestamp > other.timestamp ? timestamp : other.timestamp,
      type: type,
      price: other.price,
      maxPrice: maxPrice > other.maxPrice ? maxPrice : other.maxPrice,
      volume: volume + other.volume,
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
  String toString() =>
      'TradeMarkData(type: $type, price: $price, maxPrice: $maxPrice, volume: $volume, count: $count)';
}

/// 单根K线的交易标记汇总
class CandleTradeMarks {
  final TradeMarkData? buyMark;
  final TradeMarkData? sellMark;

  const CandleTradeMarks({
    this.buyMark,
    this.sellMark,
  });

  bool get hasBuy => buyMark != null;
  bool get hasSell => sellMark != null;
  bool get isEmpty => buyMark == null && sellMark == null;
}
