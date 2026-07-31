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

part of 'rsi.dart';

/// RSI 相对强弱指标
@CopyWith()
class RSIIndicator extends DataIndicator implements IPrecomputable {
  RSIIndicator({
    super.zIndex = 0,
    required super.height,
    super.padding = defaultSubIndicatorPadding,
    required this.calcParam,
    required this.tipsPadding,
    this.tickCount = defaultSubTickCount,
  }) : super(key: const DataIndicatorKey('rsi'));

  final RsiParam calcParam;
  final EdgeInsets tipsPadding;
  final int tickCount;

  dynamic getCalcParam() => calcParam;

  @override
  DataPaintObject<RSIIndicator> createPaintObject() {
    return RSIPaintObject();
  }
}

class RSIPaintObject<T extends RSIIndicator> extends DataPaintObject<T>
    with RsiDataMixin, PaintYAxisTicksMixin, PaintYAxisTicksOnCrossMixin {
  RSIPaintObject();

  @override
  MinMax? computeVisibleMinMax(int start, int end) {
    if (!klineData.canPaintChart) return null;

    return calcuRsiMinmax(
      indicator.calcParam,
      start: start,
      end: end,
    );
  }

  @override
  void paintChart(Canvas canvas, Size size) {
    paintRsiLine(canvas, size);
    paintReferenceLines(canvas, size);

    /// 绘制Y轴刻度值
    if (settingConfig.showYAxisTick) {
      paintYAxisTicks(
        canvas,
        size,
        tickCount: indicator.tickCount,
        precision: indicator.calcParam.display.precision,
      );
    }
  }

  /// 重写[paintYAxisTicks]中的格式化刻度值.
  @override
  String formatTicksValue(FlexiNum value, {required int precision}) {
    return formatNumber(
      value.toDecimal(),
      precision: precision,
      cutInvalidZero: false,
    );
  }

  @override
  void onCross(Canvas canvas, Offset offset) {
    /// onCross时, 绘制Y轴上的标记值
    paintYAxisTicksOnCross(
      canvas,
      offset,
      precision: indicator.calcParam.display.precision,
    );
  }

  /// 在onCross时, 重写[paintYAxisTicksOnCross]中的格式化刻度值
  @override
  String formatTicksValueOnCross(FlexiNum value, {required int precision}) {
    return formatNumber(
      value.toDecimal(),
      precision: precision,
      cutInvalidZero: false,
    );
  }

  /// 绘制RSI指标线
  void paintRsiLine(Canvas canvas, Size size) {
    if (!klineData.canPaintChart) return;
    final enabledLines = indicator.calcParam.enabledLines;
    if (enabledLines.isEmpty) return;
    final list = klineData.list;
    int start = klineData.start;
    int end = (klineData.end + 1).clamp(start, list.length); // 多绘制一根蜡烛

    final offset = startCandleDx - candleWidthHalf;
    for (int j = 0; j < enabledLines.length; j++) {
      final lineConfig = enabledLines[j];
      double? val;
      final List<Offset> points = [];
      for (int i = start; i < end; i++) {
        val = list[i].getRsiList(dataIndex)?.getItem(j);
        if (val == null) continue;
        points.add(Offset(
          offset - (i - start) * candleActualWidth,
          valueToDy(FlexiNum.fromNum(val), correct: false),
        ));
      }

      if (points.isNotEmpty) {
        canvas.drawPath(
          Path()..addPolygon(points, false),
          Paint()
            ..color = lineConfig.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = lineConfig.width,
        );

        // 绘制节点
        if (indicator.calcParam.display.pointRadius > 0) {
          for (final point in points) {
            canvas.drawCircle(
              point,
              indicator.calcParam.display.pointRadius,
              Paint()
                ..color = lineConfig.color
                ..style = PaintingStyle.fill,
            );
          }
        }
      }
    }
  }

  /// 绘制参考线（超买超卖线）
  void paintReferenceLines(Canvas canvas, Size size) {
    final reference = indicator.calcParam.reference;
    if (!reference.enabled) return;

    final paint = Paint()
      ..color = reference.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = reference.lineWidth;

    // 超买线
    final overboughtY = valueToDy(FlexiNum.fromNum(reference.overbought), correct: false);
    if (reference.dashWidth > 0) {
      _drawDashedLine(canvas, Offset(0, overboughtY), Offset(size.width, overboughtY), paint, reference.dashWidth);
    } else {
      canvas.drawLine(Offset(0, overboughtY), Offset(size.width, overboughtY), paint);
    }

    // 超卖线
    final oversoldY = valueToDy(FlexiNum.fromNum(reference.oversold), correct: false);
    if (reference.dashWidth > 0) {
      _drawDashedLine(canvas, Offset(0, oversoldY), Offset(size.width, oversoldY), paint, reference.dashWidth);
    } else {
      canvas.drawLine(Offset(0, oversoldY), Offset(size.width, oversoldY), paint);
    }
  }

  /// 绘制虚线
  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint, double dashWidth) {
    final path = Path();
    path.moveTo(start.dx, start.dy);
    path.lineTo(end.dx, end.dy);

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final nextDistance = (distance + dashWidth).clamp(0.0, metric.length);
        if (draw) {
          final extractPath = metric.extractPath(distance, nextDistance);
          canvas.drawPath(extractPath, paint);
        }
        distance = nextDistance;
        draw = !draw;
      }
    }
  }

  /// RSI 绘制tips区域
  @override
  Size? paintTips(
    Canvas canvas, {
    FlexiCandleModel? model,
    Offset? offset,
    Rect? tipsRect,
  }) {
    model ??= offsetToCandle(offset);
    if (model == null || !model.isValidRsi(dataIndex)) return null;

    final param = indicator.calcParam;
    final enabledLines = param.enabledLines;
    final precision = param.display.precision;
    final children = <TextSpan>[];
    double? val;
    
    final rsiList = model.getRsiList(dataIndex)!;
    for (int i = 0; i < rsiList.length && i < enabledLines.length; i++) {
      val = rsiList.getItem(i);
      if (val == null) continue;
      final lineConfig = enabledLines[i];

      String label = 'RSI';
      if (param.display.showPeriodInTips) {
        label = 'RSI${lineConfig.period}';
      }

      final text = formatNumber(
        val.toDecimal(),
        precision: precision,
        cutInvalidZero: true,
        prefix: '$label: ',
        suffix: '  ',
      );
      children.add(TextSpan(
        text: text,
        style: TextStyle(color: lineConfig.color, fontSize: 12),
      ));
    }

    // 显示参考线数值
    if (param.reference.enabled && param.display.showReferenceValue) {
      children.add(TextSpan(
        text: 'OB:${param.reference.overbought.toInt()} OS:${param.reference.oversold.toInt()}  ',
        style: TextStyle(color: param.reference.color, fontSize: 12),
      ));
    }

    if (children.isNotEmpty) {
      tipsRect ??= drawableRect;
      return canvas.drawText(
        offset: tipsRect.topLeft,
        textSpan: TextSpan(children: children),
        drawDirection: DrawDirection.ltr,
        drawableRect: tipsRect,
        textAlign: TextAlign.left,
        padding: indicator.tipsPadding,
        maxLines: 1,
      );
    }
    return null;
  }
}
