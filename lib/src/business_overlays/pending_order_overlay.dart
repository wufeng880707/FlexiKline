// Copyright 2024 Andy.Zhao
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/painting.dart';

import '../framework/business_overlay/business_overlay.dart';
import '../model/export.dart';

/// 订单方向
enum OrderSide { buy, sell }

/// 委托订单数据
class PendingOrderData {
  final String id;
  final OrderSide side;
  final double price;
  final double quantity;
  final String? label;

  const PendingOrderData({
    required this.id,
    required this.side,
    required this.price,
    required this.quantity,
    this.label,
  });

  PendingOrderData copyWith({
    String? id,
    OrderSide? side,
    double? price,
    double? quantity,
    String? label,
  }) {
    return PendingOrderData(
      id: id ?? this.id,
      side: side ?? this.side,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      label: label ?? this.label,
    );
  }

  @override
  String toString() => 'PendingOrder(id: $id, side: $side, price: $price, qty: $quantity)';
}

/// 委托订单叠加对象
class PendingOrderOverlay extends BusinessOverlayObject {
  PendingOrderOverlay({
    required this.data,
    this.buyColor = const Color(0xFF26A69A),
    this.sellColor = const Color(0xFFEF5350),
    this.labelTextColor = const Color(0xFFFFFFFF),
    this.lineWidth = 1.0,
    this.editingLineWidth = 2.0,
    this.dashWidth = 4.0,
    this.dashSpace = 3.0,
    this.labelFontSize = 10.0,
    this.labelPaddingH = 6.0,
    this.labelPaddingV = 3.0,
    this.labelBorderRadius = 3.0,
    this.hitTestDistance = 12.0,
    this.handleSize = 16.0,
    this.closeBtnSize = 16.0,
  });

  PendingOrderData data;

  final Color buyColor;
  final Color sellColor;
  final Color labelTextColor;
  final double lineWidth;
  final double editingLineWidth;
  final double dashWidth;
  final double dashSpace;
  final double labelFontSize;
  final double labelPaddingH;
  final double labelPaddingV;
  final double labelBorderRadius;
  final double hitTestDistance;
  final double handleSize;
  final double closeBtnSize;

  double? _draggingDy;

  Color get _color => data.side == OrderSide.buy ? buyColor : sellColor;

  @override
  String get id => data.id;

  @override
  BusinessOverlayType get type => BusinessOverlayType.pendingOrder;

  // ---- 渲染 ----

  @override
  void paintNormal(Canvas canvas, BusinessOverlayPaintContext ctx) {
    final dy = ctx.valueToDy(FlexiNum.fromNum(data.price));
    final rect = ctx.chartRect;
    _drawDashedLine(canvas, rect.left, rect.right, dy, _color, lineWidth);
    _drawLabel(canvas, ctx, dy, false);
  }

  @override
  void paintEditing(Canvas canvas, BusinessOverlayPaintContext ctx) {
    final dy = ctx.valueToDy(FlexiNum.fromNum(data.price));
    final rect = ctx.chartRect;
    _drawDashedLine(canvas, rect.left, rect.right, dy, _color, editingLineWidth);
    _drawDragHandle(canvas, Offset(rect.left + 16, dy), _color);
    _drawLabel(canvas, ctx, dy, true);
    _drawCloseButton(canvas, ctx, dy);
  }

  @override
  void paintDragging(Canvas canvas, BusinessOverlayPaintContext ctx) {
    final dy = _draggingDy ?? ctx.valueToDy(FlexiNum.fromNum(data.price));
    final rect = ctx.chartRect;
    _drawDashedLine(canvas, rect.left, rect.right, dy, _color, editingLineWidth);
    _drawDragHandle(canvas, Offset(rect.left + 16, dy), _color);

    final price = ctx.dyToValue(dy);
    if (price != null) {
      final tempData = data.copyWith(price: price.toDouble());
      _drawLabelWithData(canvas, ctx, dy, tempData, true);
    }
    _drawCloseButton(canvas, ctx, dy);
  }

  // ---- HitTest ----

  @override
  BusinessOverlayHitResult? hitTest(
    Offset position,
    BusinessOverlayPaintContext ctx,
  ) {
    final dy = ctx.valueToDy(FlexiNum.fromNum(data.price));
    final rect = ctx.chartRect;

    if (position.dx < rect.left || position.dx > rect.right) return null;
    if ((position.dy - dy).abs() > hitTestDistance) return null;

    // 拖拽手柄区域（左侧）
    if ((position.dx - (rect.left + 16)).abs() < handleSize) {
      return BusinessOverlayHitResult(
        objectId: id,
        area: BusinessOverlayHitArea.dragHandle,
      );
    }

    // 关闭按钮区域
    final closeBtnRect = _getCloseBtnRect(ctx, dy);
    if (closeBtnRect.contains(position)) {
      return BusinessOverlayHitResult(
        objectId: id,
        area: BusinessOverlayHitArea.close,
      );
    }

    // 整条线
    return BusinessOverlayHitResult(
      objectId: id,
      area: BusinessOverlayHitArea.line,
    );
  }

  // ---- Drag ----

  @override
  void onDragStart(Offset position, BusinessOverlayPaintContext ctx) {
    _draggingDy = position.dy;
  }

  @override
  void onDragUpdate(Offset position, Offset delta, Rect chartRect) {
    _draggingDy = position.dy.clamp(chartRect.top, chartRect.bottom);
  }

  @override
  BusinessOverlayDragResult? onDragEnd(BusinessOverlayPaintContext ctx) {
    FlexiNum? newPrice;
    if (_draggingDy != null) {
      newPrice = ctx.dyToValue(_draggingDy!);
    }
    _draggingDy = null;
    return BusinessOverlayDragResult(value: newPrice);
  }

  @override
  void onDragCancel() {
    _draggingDy = null;
  }

  // ---- Private ----

  void _drawDashedLine(
    Canvas canvas,
    double startX,
    double endX,
    double dy,
    Color color,
    double width,
  ) {
    final path = Path();
    double dx = startX;
    bool draw = true;
    while (dx < endX) {
      if (draw) {
        path.moveTo(dx, dy);
        path.lineTo((dx + dashWidth).clamp(startX, endX), dy);
      }
      dx += draw ? dashWidth : dashSpace;
      draw = !draw;
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = width
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawLabel(
    Canvas canvas,
    BusinessOverlayPaintContext ctx,
    double dy,
    bool isEditing,
  ) {
    _drawLabelWithData(canvas, ctx, dy, data, isEditing);
  }

  void _drawLabelWithData(
    Canvas canvas,
    BusinessOverlayPaintContext ctx,
    double dy,
    PendingOrderData d,
    bool isEditing,
  ) {
    final sideText = d.side == OrderSide.buy ? 'BUY' : 'SELL';
    final priceText = d.price.toStringAsFixed(ctx.precision);
    final text = d.label != null ? '${d.label} $priceText' : '$sideText $priceText';

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: labelTextColor,
          fontSize: labelFontSize,
          fontWeight: isEditing ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final labelW = tp.width + labelPaddingH * 2;
    final labelH = tp.height + labelPaddingV * 2;
    final left = isEditing ? ctx.chartRect.left + handleSize + 20 : ctx.chartRect.left + 8;
    final top = dy - labelH / 2;

    final rrect = RRect.fromLTRBR(
      left,
      top,
      left + labelW,
      top + labelH,
      Radius.circular(labelBorderRadius),
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = _color
        ..style = PaintingStyle.fill,
    );

    tp.paint(canvas, Offset(left + labelPaddingH, top + labelPaddingV));
  }

  void _drawDragHandle(Canvas canvas, Offset center, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: handleSize, height: handleSize),
        const Radius.circular(3),
      ),
      paint,
    );

    final linePaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (int i = -1; i <= 1; i++) {
      final y = center.dy + i * 3.5;
      canvas.drawLine(
        Offset(center.dx - 4, y),
        Offset(center.dx + 4, y),
        linePaint,
      );
    }
  }

  void _drawCloseButton(
    Canvas canvas,
    BusinessOverlayPaintContext ctx,
    double dy,
  ) {
    final btnRect = _getCloseBtnRect(ctx, dy);
    final center = btnRect.center;

    canvas.drawRRect(
      RRect.fromRectAndRadius(btnRect, const Radius.circular(3)),
      Paint()
        ..color = _color.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill,
    );

    final xPaint = Paint()
      ..color = _color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const d = 4.0;
    canvas.drawLine(Offset(center.dx - d, center.dy - d), Offset(center.dx + d, center.dy + d), xPaint);
    canvas.drawLine(Offset(center.dx + d, center.dy - d), Offset(center.dx - d, center.dy + d), xPaint);
  }

  Rect _getCloseBtnRect(BusinessOverlayPaintContext ctx, double dy) {
    final right = ctx.chartRect.right - 8;
    return Rect.fromCenter(
      center: Offset(right - closeBtnSize / 2, dy),
      width: closeBtnSize,
      height: closeBtnSize,
    );
  }
}
