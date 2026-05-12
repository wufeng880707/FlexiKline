import 'dart:math' as math;

import 'package:flexi_kline/flexi_kline.dart';
import 'package:flutter/foundation.dart';

/// 委托订单数据管理
///
/// 负责委托订单数据的存储及通过 [BusinessOverlayBinding] 注入到 controller。
class PendingOrderDataManager {
  PendingOrderDataManager(this._controller);

  final FlexiKlineController _controller;

  List<PendingOrderData> _orders = [];
  List<PendingOrderData> get orders => _orders;

  void setOrders(List<PendingOrderData> orders) {
    _orders = orders;
    _controller.removeBusinessOverlayByType(BusinessOverlayType.pendingOrder);
    for (final order in _orders) {
      _controller.addBusinessOverlay(PendingOrderOverlay(data: order));
    }
  }

  void addOrder(PendingOrderData order) {
    _orders = [..._orders, order];
    _controller.addBusinessOverlay(PendingOrderOverlay(data: order));
  }

  void removeOrder(String orderId) {
    _orders = _orders.where((o) => o.id != orderId).toList();
    _controller.removeBusinessOverlay(orderId);
  }

  void updateOrderPrice(String orderId, double newPrice) {
    _orders = _orders.map((o) {
      if (o.id == orderId) return o.copyWith(price: newPrice);
      return o;
    }).toList();
    // 原地更新单个 overlay，保持当前编辑/拖拽状态
    final updated = _orders.firstWhere((o) => o.id == orderId);
    _controller.updateBusinessOverlay(PendingOrderOverlay(data: updated));
  }

  void clear() {
    _orders = [];
    _controller.removeBusinessOverlayByType(BusinessOverlayType.pendingOrder);
  }

  void dispose() {
    _orders = [];
  }
}

/// 生成模拟委托订单
List<PendingOrderData> createTestPendingOrders(KlineData klineData) {
  if (!klineData.canPaintChart || klineData.list.isEmpty) return [];

  final list = klineData.list;
  final lastCandle = list.last;
  final currentPrice = lastCandle.close.toDouble();
  final rng = math.Random(123);

  final range = (lastCandle.high.toDouble() - lastCandle.low.toDouble()).abs();
  final step = range > 0 ? range : currentPrice * 0.002;

  final orders = <PendingOrderData>[];

  for (int i = 1; i <= 3; i++) {
    final offset = step * (1 + rng.nextDouble() * 2) * i;
    orders.add(PendingOrderData(
      id: 'buy_limit_$i',
      side: OrderSide.buy,
      price: double.parse((currentPrice - offset).toStringAsFixed(klineData.precision)),
      quantity: double.parse((0.1 + rng.nextDouble() * 0.5).toStringAsFixed(4)),
      label: '限价',
    ));
  }

  for (int i = 1; i <= 2; i++) {
    final offset = step * (1 + rng.nextDouble() * 2) * i;
    orders.add(PendingOrderData(
      id: 'sell_limit_$i',
      side: OrderSide.sell,
      price: double.parse((currentPrice + offset).toStringAsFixed(klineData.precision)),
      quantity: double.parse((0.1 + rng.nextDouble() * 0.5).toStringAsFixed(4)),
      label: '限价',
    ));
  }

  debugPrint(
    '[PendingOrder] 生成 ${orders.length} 笔模拟委托订单 '
    '(当前价: $currentPrice)',
  );
  return orders;
}
