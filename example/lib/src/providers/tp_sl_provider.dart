import 'dart:math' as math;

import 'package:flexi_kline/flexi_kline.dart';
import 'package:flutter/foundation.dart';

/// 持仓数据管理
///
/// 负责持仓数据的存储及通过 [BusinessOverlayBinding] 注入到 controller。
class PositionDataManager {
  PositionDataManager(this._controller);

  final FlexiKlineController _controller;

  List<PositionData> _positions = [];
  List<PositionData> get positions => _positions;

  void setPositions(List<PositionData> positions) {
    _positions = positions;
    _controller.syncBusinessOverlays(
      _positions.map((position) => PositionOverlay(data: position)),
      type: BusinessOverlayType.position,
    );
  }

  void removePosition(String positionId) {
    _positions = _positions.where((p) => p.positionId != positionId).toList();
    _controller.removeBusinessOverlay(positionId);
  }

  void updatePositionPrice(
    String positionId,
    double newPrice, {
    TpSlDragTarget? target,
  }) {
    _positions = _positions.map((position) {
      if (position.positionId != positionId) return position;
      return switch (target) {
        TpSlDragTarget.tp => position.copyWith(tpPrice: newPrice),
        TpSlDragTarget.sl => position.copyWith(slPrice: newPrice),
        null => position.copyWith(entryPrice: newPrice),
      };
    }).toList();

    final updated =
        _positions.firstWhere((position) => position.positionId == positionId);
    _controller.updateBusinessOverlay(PositionOverlay(data: updated));
  }

  void clear() {
    _positions = [];
    _controller.removeBusinessOverlayByType(BusinessOverlayType.position);
  }

  void dispose() {
    _positions = [];
  }
}

/// 生成模拟持仓数据
List<PositionData> createTestPositions(KlineData klineData) {
  if (!klineData.canPaintChart || klineData.list.isEmpty) return [];

  final list = klineData.list;
  final lastCandle = list.last;
  final currentPrice = lastCandle.close.toDouble();
  final rng = math.Random(456);

  final range = (lastCandle.high.toDouble() - lastCandle.low.toDouble()).abs();
  final unit = range > 0 ? range : currentPrice * 0.002;

  final positions = <PositionData>[
    PositionData(
      positionId: 'long_pos_1',
      side: PositionSide.long,
      entryPrice: double.parse(
        (currentPrice - unit * (1 + rng.nextDouble()))
            .toStringAsFixed(klineData.precision),
      ),
      quantity: 0.5,
      pnl: 150.0 + rng.nextDouble() * 100,
      tpPrice: double.parse(
        (currentPrice + unit * (3 + rng.nextDouble() * 2))
            .toStringAsFixed(klineData.precision),
      ),
      slPrice: double.parse(
        (currentPrice - unit * (4 + rng.nextDouble() * 2))
            .toStringAsFixed(klineData.precision),
      ),
      label: 'BTC多',
    ),
    PositionData(
      positionId: 'short_pos_1',
      side: PositionSide.short,
      entryPrice: double.parse(
        (currentPrice + unit * (0.5 + rng.nextDouble()))
            .toStringAsFixed(klineData.precision),
      ),
      quantity: 0.3,
      pnl: -(50.0 + rng.nextDouble() * 80),
      tpPrice: double.parse(
        (currentPrice - unit * (2 + rng.nextDouble() * 2))
            .toStringAsFixed(klineData.precision),
      ),
      slPrice: double.parse(
        (currentPrice + unit * (5 + rng.nextDouble() * 2))
            .toStringAsFixed(klineData.precision),
      ),
      label: 'BTC空',
    ),
  ];

  debugPrint(
    '[Position] 生成 ${positions.length} 笔模拟持仓 '
    '(当前价: $currentPrice)',
  );
  return positions;
}
