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

import 'dart:ui';

import '../core/core.dart';
import '../extension/export.dart';
import '../framework/draw/overlay.dart';
import '../utils/export.dart';

class FibFansParams {
  final List<double> params;
  final Color gridColor;
  const FibFansParams({required this.params, required this.gridColor});
}

class FibFansDrawObject extends DrawObject {
  FibFansDrawObject(super.overlay, super.config);

  @override
  FibFansParams getDrawParams(IDrawContext context) {
    return FibFansParams(
      params: const [0.382, 0.5, 0.618],
      gridColor: lineColor.withValues(alpha: 0.3),
    );
  }

  Rect? getRectangleRect() {
    final points = allPoints;
    final first = points.firstOrNull?.offset;
    final second = points.secondOrNull?.offset;
    if (first == null || second == null) {
      return null;
    }
    return Rect.fromPoints(first, second);
  }

  @override
  bool hitTest(IDrawContext context, Offset position, {bool isMove = false}) {
    assert(
      points.length == 2,
      'FibFans hitTest points.length:${points.length} must be equals 2',
    );
    final rectangle = getRectangleRect();
    if (rectangle == null) return false;

    return rectangle.include(position);
  }

  @override
  void drawing(IDrawContext context, Canvas canvas, Size size) {
    if (isReady) {
      final points = allPoints;
      final first = points.firstOrNull?.offset;
      final second = points.secondOrNull?.offset;
      if (first == null || second == null) {
        return;
      }
      _drawFibFans(context, canvas, first, second);
    }
    drawConnectingLine(context, canvas, size);
  }

  @override
  void draw(IDrawContext context, Canvas canvas, Size size) {
    assert(
      points.length == 2,
      'FibFans draw points.length:${points.length} must be equals 2',
    );

    final first = points.firstOrNull?.offset;
    final second = points.secondOrNull?.offset;
    if (first == null || second == null) {
      return;
    }

    _drawFibFans(context, canvas, first, second);
  }

  /// 绘制斐波那契扇形
  void _drawFibFans(
    IDrawContext context,
    Canvas canvas,
    Offset A,
    Offset B,
  ) {
    final mainRect = context.mainRect;
    final drawParams = getDrawParams(context);
    final fibFansParams = drawParams.params;
    final fibText = config.ticksText;
    final fibGridColor = drawParams.gridColor;
    final isDrawGrid = true;
    final colors = [lineColor];
    int i = 0;

    final dxLen = B.dx - A.dx;
    final dyLen = B.dy - A.dy;
    Offset fans1, fans2, hori, vert;
    double dx, dy;

    final areaHeight = fibText.areaHeight;
    final txtHalft = areaHeight / 2;
    final txtHeight = dyLen >= 0 ? areaHeight : 0;
    final vertTxtDirection = dxLen >= 0 ? DrawDirection.rtl : DrawDirection.ltr;

    for (var rate in fibFansParams) {
      dx = A.dx + dxLen * rate;
      dy = A.dy + dyLen * rate;
      hori = Offset(dx, A.dy);
      vert = Offset(A.dx, dy);
      fans1 = Offset(B.dx, dy);
      fans2 = Offset(dx, B.dy);

      if (isDrawGrid) {
        /// 画扇形网格线
        canvas.drawLineType(
          line.type,
          Path()..addPolygon([vert, fans1], false),
          line.linePaint..color = fibGridColor,
          dashes: line.dashes,
        );
        canvas.drawLineType(
          line.type,
          Path()..addPolygon([hori, fans2], false),
          line.linePaint..color = fibGridColor,
          dashes: line.dashes,
        );
      }

      final color = colors[i++ % colors.length];

      /// 画扇形线
      final fnas1Points = reflectPointsOnRect(A, fans1, mainRect);
      canvas.drawLineType(
        line.type,
        Path()..addPolygon(fnas1Points, false),
        line.linePaint..color = color,
        dashes: line.dashes,
      );
      final fnas2Points = reflectPointsOnRect(A, fans2, mainRect);
      canvas.drawLineType(
        line.type,
        Path()..addPolygon(fnas2Points, false),
        line.linePaint..color = color,
        dashes: line.dashes,
      );

      /// 画扇形参数值
      canvas.drawTextArea(
        text: rate.toString(),
        drawDirection: DrawDirection.center,
        offset: Offset(dx, A.dy - txtHeight),
        textConfig: fibText,
      );
      canvas.drawTextArea(
        text: rate.toString(),
        drawDirection: vertTxtDirection,
        offset: Offset(A.dx, dy - txtHalft),
        textConfig: fibText,
      );
    }
  }
}
