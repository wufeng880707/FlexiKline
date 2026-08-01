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

/// 持仓方向
enum PositionSide { long, short }

/// 可拖拽的止盈止损目标类型
enum TpSlDragTarget { tp, sl }

/// 持仓止盈止损命中标识
class TpSlHitTarget {
  final String positionId;
  final TpSlDragTarget target;
  const TpSlHitTarget(this.positionId, this.target);
  @override
  String toString() => 'TpSlHitTarget($positionId, $target)';
}

/// 持仓数据
class PositionData {
  final String positionId;
  final PositionSide side;
  final double entryPrice;
  final double quantity;
  final double? pnl;
  final double? tpPrice;
  final double? slPrice;
  final String? label;

  const PositionData({
    required this.positionId,
    required this.side,
    required this.entryPrice,
    required this.quantity,
    this.pnl,
    this.tpPrice,
    this.slPrice,
    this.label,
  });

  bool get hasTp => tpPrice != null;
  bool get hasSl => slPrice != null;

  PositionData copyWith({
    String? positionId,
    PositionSide? side,
    double? entryPrice,
    double? quantity,
    double? pnl,
    double? tpPrice,
    double? slPrice,
    String? label,
  }) {
    return PositionData(
      positionId: positionId ?? this.positionId,
      side: side ?? this.side,
      entryPrice: entryPrice ?? this.entryPrice,
      quantity: quantity ?? this.quantity,
      pnl: pnl ?? this.pnl,
      tpPrice: tpPrice ?? this.tpPrice,
      slPrice: slPrice ?? this.slPrice,
      label: label ?? this.label,
    );
  }

  @override
  String toString() => 'Position(id: $positionId, side: $side, entry: $entryPrice, tp: $tpPrice, sl: $slPrice)';
}

/// 当前持仓叠加对象
class PositionOverlay extends BusinessOverlayObject {
  PositionOverlay({
    required this.data,
    this.entryColor = const Color(0xFF26A69A),
    this.tpColor = const Color(0xFF26A69A),
    this.slColor = const Color(0xFFEF5350),
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
    this.tpSlBtnWidth = 52.0,
    this.zoneTpAlpha = 0.1,
    this.zoneSlAlpha = 0.1,
  });

  PositionData data;

  final Color entryColor;
  final Color tpColor;
  final Color slColor;
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
  final double tpSlBtnWidth;
  final double zoneTpAlpha;
  final double zoneSlAlpha;

  double? _draggingDy;
  TpSlDragTarget? _draggingTarget;

  @override
  String get id => data.positionId;

  @override
  BusinessOverlayType get type => BusinessOverlayType.position;

  // ---- 渲染 ----

  @override
  void paintNormal(Canvas canvas, BusinessOverlayPaintContext ctx) {
    final entryDy = ctx.valueToDy(FlexiNum.fromNum(data.entryPrice));
    final rect = ctx.chartRect;

    _drawDashedLine(canvas, rect.left, rect.right, entryDy, entryColor, lineWidth);
    _drawEntryLabel(canvas, ctx, entryDy, false);

    if (data.hasTp) {
      final tpDy = ctx.valueToDy(FlexiNum.fromNum(data.tpPrice!));
      _drawZone(canvas, ctx, entryDy, tpDy, tpColor.withValues(alpha: zoneTpAlpha));
      _drawDashedLine(canvas, rect.left, rect.right, tpDy, tpColor, lineWidth);
      _drawPriceTag(canvas, ctx, tpDy, 'TP ${data.tpPrice!.toStringAsFixed(ctx.precision)}', tpColor, false);
    }
    if (data.hasSl) {
      final slDy = ctx.valueToDy(FlexiNum.fromNum(data.slPrice!));
      _drawZone(canvas, ctx, entryDy, slDy, slColor.withValues(alpha: zoneSlAlpha));
      _drawDashedLine(canvas, rect.left, rect.right, slDy, slColor, lineWidth);
      _drawPriceTag(canvas, ctx, slDy, 'SL ${data.slPrice!.toStringAsFixed(ctx.precision)}', slColor, false);
    }
  }

  @override
  void paintEditing(Canvas canvas, BusinessOverlayPaintContext ctx) {
    final entryDy = ctx.valueToDy(FlexiNum.fromNum(data.entryPrice));
    final rect = ctx.chartRect;

    _drawDashedLine(canvas, rect.left, rect.right, entryDy, entryColor, editingLineWidth);
    _drawDragHandle(canvas, Offset(rect.left + 16, entryDy), entryColor);
    _drawEntryLabel(canvas, ctx, entryDy, true);
    _drawCloseButton(canvas, ctx, entryDy);
    _drawTpSlButton(canvas, ctx, entryDy);

    if (data.hasTp) {
      final tpDy = ctx.valueToDy(FlexiNum.fromNum(data.tpPrice!));
      _drawZone(canvas, ctx, entryDy, tpDy, tpColor.withValues(alpha: zoneTpAlpha));
      _drawDashedLine(canvas, rect.left, rect.right, tpDy, tpColor, editingLineWidth);
      _drawDragHandle(canvas, Offset(rect.left + 16, tpDy), tpColor);
      _drawPriceTag(canvas, ctx, tpDy, 'TP ${data.tpPrice!.toStringAsFixed(ctx.precision)}', tpColor, true);
    }
    if (data.hasSl) {
      final slDy = ctx.valueToDy(FlexiNum.fromNum(data.slPrice!));
      _drawZone(canvas, ctx, entryDy, slDy, slColor.withValues(alpha: zoneSlAlpha));
      _drawDashedLine(canvas, rect.left, rect.right, slDy, slColor, editingLineWidth);
      _drawDragHandle(canvas, Offset(rect.left + 16, slDy), slColor);
      _drawPriceTag(canvas, ctx, slDy, 'SL ${data.slPrice!.toStringAsFixed(ctx.precision)}', slColor, true);
    }
  }

  @override
  void paintDragging(Canvas canvas, BusinessOverlayPaintContext ctx) {
    final entryDy = ctx.valueToDy(FlexiNum.fromNum(data.entryPrice));
    final rect = ctx.chartRect;

    _drawDashedLine(canvas, rect.left, rect.right, entryDy, entryColor, editingLineWidth);
    _drawDragHandle(canvas, Offset(rect.left + 16, entryDy), entryColor);
    _drawEntryLabel(canvas, ctx, entryDy, true);
    _drawCloseButton(canvas, ctx, entryDy);
    _drawTpSlButton(canvas, ctx, entryDy);

    if (data.hasTp) {
      final isDraggingTp = _draggingTarget == TpSlDragTarget.tp;
      final tpDy = isDraggingTp && _draggingDy != null ? _draggingDy! : ctx.valueToDy(FlexiNum.fromNum(data.tpPrice!));
      _drawZone(canvas, ctx, entryDy, tpDy, tpColor.withValues(alpha: zoneTpAlpha));
      _drawDashedLine(canvas, rect.left, rect.right, tpDy, tpColor, editingLineWidth);
      _drawDragHandle(canvas, Offset(rect.left + 16, tpDy), tpColor);

      final tpLabel = isDraggingTp && _draggingDy != null
          ? 'TP ${ctx.dyToValue(_draggingDy!)?.toDouble().toStringAsFixed(ctx.precision) ?? ''}'
          : 'TP ${data.tpPrice!.toStringAsFixed(ctx.precision)}';
      _drawPriceTag(canvas, ctx, tpDy, tpLabel, tpColor, true);
    }
    if (data.hasSl) {
      final isDraggingSl = _draggingTarget == TpSlDragTarget.sl;
      final slDy = isDraggingSl && _draggingDy != null ? _draggingDy! : ctx.valueToDy(FlexiNum.fromNum(data.slPrice!));
      _drawZone(canvas, ctx, entryDy, slDy, slColor.withValues(alpha: zoneSlAlpha));
      _drawDashedLine(canvas, rect.left, rect.right, slDy, slColor, editingLineWidth);
      _drawDragHandle(canvas, Offset(rect.left + 16, slDy), slColor);

      final slLabel = isDraggingSl && _draggingDy != null
          ? 'SL ${ctx.dyToValue(_draggingDy!)?.toDouble().toStringAsFixed(ctx.precision) ?? ''}'
          : 'SL ${data.slPrice!.toStringAsFixed(ctx.precision)}';
      _drawPriceTag(canvas, ctx, slDy, slLabel, slColor, true);
    }
  }

  // ---- HitTest ----

  @override
  BusinessOverlayHitResult? hitTest(
    Offset position,
    BusinessOverlayPaintContext ctx,
  ) {
    final rect = ctx.chartRect;
    if (position.dx < rect.left || position.dx > rect.right) return null;

    final entryDy = ctx.valueToDy(FlexiNum.fromNum(data.entryPrice));

    // TP/SL 线检测
    if (data.hasTp) {
      final tpDy = ctx.valueToDy(FlexiNum.fromNum(data.tpPrice!));
      if ((position.dy - tpDy).abs() < hitTestDistance) {
        if ((position.dx - (rect.left + 16)).abs() < handleSize) {
          return BusinessOverlayHitResult(
            objectId: id,
            area: BusinessOverlayHitArea.dragHandle,
            extra: TpSlHitTarget(id, TpSlDragTarget.tp),
          );
        }
        return BusinessOverlayHitResult(
          objectId: id,
          area: BusinessOverlayHitArea.line,
          extra: TpSlHitTarget(id, TpSlDragTarget.tp),
        );
      }
    }
    if (data.hasSl) {
      final slDy = ctx.valueToDy(FlexiNum.fromNum(data.slPrice!));
      if ((position.dy - slDy).abs() < hitTestDistance) {
        if ((position.dx - (rect.left + 16)).abs() < handleSize) {
          return BusinessOverlayHitResult(
            objectId: id,
            area: BusinessOverlayHitArea.dragHandle,
            extra: TpSlHitTarget(id, TpSlDragTarget.sl),
          );
        }
        return BusinessOverlayHitResult(
          objectId: id,
          area: BusinessOverlayHitArea.line,
          extra: TpSlHitTarget(id, TpSlDragTarget.sl),
        );
      }
    }

    // 开仓价线
    if ((position.dy - entryDy).abs() > hitTestDistance) return null;

    if ((position.dx - (rect.left + 16)).abs() < handleSize) {
      return BusinessOverlayHitResult(objectId: id, area: BusinessOverlayHitArea.dragHandle);
    }

    final closeBtnRect = _getCloseBtnRect(ctx, entryDy);
    if (closeBtnRect.contains(position)) {
      return BusinessOverlayHitResult(objectId: id, area: BusinessOverlayHitArea.close);
    }

    final tpSlBtnRect = _getTpSlBtnRect(ctx, entryDy);
    if (tpSlBtnRect.contains(position)) {
      return BusinessOverlayHitResult(objectId: id, area: BusinessOverlayHitArea.tpSl);
    }

    return BusinessOverlayHitResult(objectId: id, area: BusinessOverlayHitArea.line);
  }

  // ---- Drag ----

  @override
  void onDragStart(Offset position, BusinessOverlayPaintContext ctx) {
    _draggingDy = position.dy;
    // 检测是否在 TP/SL 线上开始拖拽
    if (data.hasTp) {
      final tpDy = ctx.valueToDy(FlexiNum.fromNum(data.tpPrice!));
      if ((position.dy - tpDy).abs() < hitTestDistance) {
        _draggingTarget = TpSlDragTarget.tp;
        return;
      }
    }
    if (data.hasSl) {
      final slDy = ctx.valueToDy(FlexiNum.fromNum(data.slPrice!));
      if ((position.dy - slDy).abs() < hitTestDistance) {
        _draggingTarget = TpSlDragTarget.sl;
        return;
      }
    }
    _draggingTarget = null;
  }

  @override
  void onDragUpdate(Offset position, Offset delta, Rect chartRect) {
    _draggingDy = position.dy.clamp(chartRect.top, chartRect.bottom);
  }

  @override
  BusinessOverlayDragResult? onDragEnd(BusinessOverlayPaintContext ctx) {
    FlexiNum? newPrice;
    final target = _draggingTarget;
    if (_draggingDy != null) {
      newPrice = ctx.dyToValue(_draggingDy!);
    }
    _draggingDy = null;
    _draggingTarget = null;
    return BusinessOverlayDragResult(value: newPrice, target: target);
  }

  @override
  void onDragCancel() {
    _draggingDy = null;
    _draggingTarget = null;
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
          ..style = PaintingStyle.stroke);
  }

  void _drawZone(Canvas canvas, BusinessOverlayPaintContext ctx, double fromDy, double toDy, Color color) {
    final top = fromDy < toDy ? fromDy : toDy;
    final bottom = fromDy > toDy ? fromDy : toDy;
    canvas.drawRect(
      Rect.fromLTRB(ctx.chartRect.left, top, ctx.chartRect.right, bottom),
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  void _drawEntryLabel(Canvas canvas, BusinessOverlayPaintContext ctx, double dy, bool isEditing) {
    final sideText = data.side == PositionSide.long ? 'LONG' : 'SHORT';
    final priceText = data.entryPrice.toStringAsFixed(ctx.precision);
    String text = '$sideText $priceText';
    if (data.pnl != null) {
      final sign = data.pnl! >= 0 ? '+' : '';
      text += ' PNL $sign${data.pnl!.toStringAsFixed(2)}';
    }

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
            color: labelTextColor,
            fontSize: labelFontSize,
            fontWeight: isEditing ? FontWeight.bold : FontWeight.normal),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final labelW = tp.width + labelPaddingH * 2;
    final labelH = tp.height + labelPaddingV * 2;
    final left = isEditing ? ctx.chartRect.left + handleSize + 20 : ctx.chartRect.left + 8;
    final top = dy - labelH / 2;

    canvas.drawRRect(
      RRect.fromLTRBR(left, top, left + labelW, top + labelH, Radius.circular(labelBorderRadius)),
      Paint()
        ..color = entryColor
        ..style = PaintingStyle.fill,
    );
    tp.paint(canvas, Offset(left + labelPaddingH, top + labelPaddingV));
  }

  void _drawPriceTag(
      Canvas canvas, BusinessOverlayPaintContext ctx, double dy, String text, Color bgColor, bool isEditing) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
            color: labelTextColor,
            fontSize: labelFontSize,
            fontWeight: isEditing ? FontWeight.bold : FontWeight.normal),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final labelW = tp.width + labelPaddingH * 2;
    final labelH = tp.height + labelPaddingV * 2;
    final left = ctx.chartRect.left + 8;
    final top = dy - labelH / 2;

    canvas.drawRRect(
      RRect.fromLTRBR(left, top, left + labelW, top + labelH, Radius.circular(labelBorderRadius)),
      Paint()
        ..color = bgColor
        ..style = PaintingStyle.fill,
    );
    tp.paint(canvas, Offset(left + labelPaddingH, top + labelPaddingV));
  }

  void _drawDragHandle(Canvas canvas, Offset center, Color color) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: handleSize, height: handleSize), const Radius.circular(3)),
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    final linePaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (int i = -1; i <= 1; i++) {
      final y = center.dy + i * 3.5;
      canvas.drawLine(Offset(center.dx - 4, y), Offset(center.dx + 4, y), linePaint);
    }
  }

  void _drawCloseButton(Canvas canvas, BusinessOverlayPaintContext ctx, double dy) {
    final btnRect = _getCloseBtnRect(ctx, dy);
    final center = btnRect.center;
    canvas.drawRRect(
      RRect.fromRectAndRadius(btnRect, const Radius.circular(3)),
      Paint()
        ..color = entryColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill,
    );
    final xPaint = Paint()
      ..color = entryColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const d = 4.0;
    canvas.drawLine(Offset(center.dx - d, center.dy - d), Offset(center.dx + d, center.dy + d), xPaint);
    canvas.drawLine(Offset(center.dx + d, center.dy - d), Offset(center.dx - d, center.dy + d), xPaint);
  }

  void _drawTpSlButton(Canvas canvas, BusinessOverlayPaintContext ctx, double dy) {
    final btnRect = _getTpSlBtnRect(ctx, dy);
    canvas.drawRRect(
      RRect.fromRectAndRadius(btnRect, const Radius.circular(3)),
      Paint()
        ..color = entryColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(btnRect, const Radius.circular(3)),
      Paint()
        ..color = entryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: '止盈/止损',
        style: TextStyle(color: entryColor, fontSize: labelFontSize),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
        canvas, Offset(btnRect.left + (btnRect.width - tp.width) / 2, btnRect.top + (btnRect.height - tp.height) / 2));
  }

  Rect _getCloseBtnRect(BusinessOverlayPaintContext ctx, double dy) {
    final right = ctx.chartRect.right - 8;
    return Rect.fromCenter(center: Offset(right - closeBtnSize / 2, dy), width: closeBtnSize, height: closeBtnSize);
  }

  Rect _getTpSlBtnRect(BusinessOverlayPaintContext ctx, double dy) {
    final closeRect = _getCloseBtnRect(ctx, dy);
    return Rect.fromLTWH(closeRect.left - tpSlBtnWidth - 8, dy - closeBtnSize / 2, tpSlBtnWidth, closeBtnSize);
  }
}
