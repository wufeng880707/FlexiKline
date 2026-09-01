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

part of 'cci.dart';

/// CCI 顺势指标 (Commodity Channel Index)
@CopyWith()
@FlexiIndicatorSerializable
class CCIIndicator extends ComputedIndicator {
  CCIIndicator({
    super.zIndex = 0,
    required super.height,
    super.padding = defaultSubIndicatorPadding,
    required this.calcParam,
    required this.tipsPadding,
    this.tickCount = defaultSubTickCount,
  }) : super(key: const ComputedIndicatorKey('cci'));

  @override
  final CCIParam calcParam;

  final EdgeInsets tipsPadding;
  final int tickCount;

  factory CCIIndicator.fromJson(Map<String, dynamic> json) => _$CCIIndicatorFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CCIIndicatorToJson(this);

  @override
  ComputedPaintObject<CCIIndicator> createPaintObject() {
    return CCIPaintObject();
  }

  @override
  IndicatorCalculator createCalculator(int dataIndex) => _CCICalculator(this, dataIndex);
}

class _CCICalculator extends ComputedIndicatorCalculator<CCIIndicator> with CciDataMixin<CCIIndicator> {
  _CCICalculator(super.indicator, super.dataIndex);
}

class CCIPaintObject<T extends CCIIndicator> extends ComputedPaintObject<T>
    with CciDataMixin, PaintYAxisTicksMixin, PaintYAxisTicksOnCrossMixin {
  CCIPaintObject();

  @override
  MinMax? computeVisibleMinMax(int start, int end) {
    if (!klineData.canPaintChart) return null;
    return calcuCciMinmax(
      indicator.calcParam,
      start: start,
      end: end,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    paintCciLine(canvas, size);
    paintReferenceLines(canvas, size);

    if (settingConfig.showYAxisTick) {
      paintYAxisTicks(
        canvas,
        size,
        tickCount: indicator.tickCount,
        precision: indicator.calcParam.display.precision,
      );
    }
  }

  @override
  String formatTicksValue(FlexiNum value, {required int precision}) {
    return formatNumber(
      value.toDecimal(),
      precision: precision,
      cutInvalidZero: false,
    );
  }

  @override
  void paintCross(Canvas canvas, Offset offset, {FlexiCandleModel? model}) {
    paintYAxisTicksOnCross(
      canvas,
      offset,
      precision: indicator.calcParam.display.precision,
    );
  }

  @override
  String formatTicksValueOnCross(FlexiNum value, {required int precision}) {
    return formatNumber(
      value.toDecimal(),
      precision: precision,
      cutInvalidZero: false,
    );
  }

  void paintCciLine(Canvas canvas, Size size) {
    if (!klineData.canPaintChart) return;
    final enabledLines = indicator.calcParam.enabledLines;
    if (enabledLines.isEmpty) return;
    final list = klineData.list;
    final start = klineData.start;
    final end = (klineData.end + 1).clamp(start, list.length);

    final offset = startCandleDx - candleWidthHalf;
    for (int j = 0; j < enabledLines.length; j++) {
      final lineConfig = enabledLines[j];
      double? val;
      final List<Offset> points = [];
      for (int i = start; i < end; i++) {
        val = list[i].getCciList(dataIndex)?.getItem(j);
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

  void paintReferenceLines(Canvas canvas, Size size) {
    final reference = indicator.calcParam.reference;
    if (!reference.enabled) return;

    final paint = Paint()
      ..color = reference.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = reference.lineWidth;

    // Overbought line (+100)
    final overboughtY = valueToDy(
      FlexiNum.fromNum(reference.overbought),
      correct: false,
    );
    if (reference.dashWidth > 0) {
      _drawDashedLine(
        canvas,
        Offset(0, overboughtY),
        Offset(size.width, overboughtY),
        paint,
        reference.dashWidth,
      );
    } else {
      canvas.drawLine(
        Offset(0, overboughtY),
        Offset(size.width, overboughtY),
        paint,
      );
    }

    // Zero line
    final zeroY = valueToDy(FlexiNum.zero, correct: false);
    _drawDashedLine(
      canvas,
      Offset(0, zeroY),
      Offset(size.width, zeroY),
      paint,
      reference.dashWidth > 0 ? reference.dashWidth : 2.0,
    );

    // Oversold line (-100)
    final oversoldY = valueToDy(
      FlexiNum.fromNum(reference.oversold),
      correct: false,
    );
    if (reference.dashWidth > 0) {
      _drawDashedLine(
        canvas,
        Offset(0, oversoldY),
        Offset(size.width, oversoldY),
        paint,
        reference.dashWidth,
      );
    } else {
      canvas.drawLine(
        Offset(0, oversoldY),
        Offset(size.width, oversoldY),
        paint,
      );
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    double dashWidth,
  ) {
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);

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

  @override
  Size? paintTips(
    Canvas canvas, {
    FlexiCandleModel? model,
    Offset? offset,
    Rect? tipsRect,
  }) {
    model ??= offsetToCandle(offset);
    if (model == null || !model.isValidCci(dataIndex)) return null;

    final param = indicator.calcParam;
    final enabledLines = param.enabledLines;
    final precision = param.display.precision;
    final children = <TextSpan>[];

    final cciList = model.getCciList(dataIndex)!;
    for (int i = 0; i < cciList.length && i < enabledLines.length; i++) {
      final val = cciList.getItem(i);
      if (val == null) continue;
      final lineConfig = enabledLines[i];

      String label = 'CCI';
      if (param.display.showPeriodInTips) {
        label = 'CCI${lineConfig.period}';
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
