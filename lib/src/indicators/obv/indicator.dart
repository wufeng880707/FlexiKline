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

part of 'obv.dart';

/// OBV 能量潮指标 (On-Balance Volume)
@CopyWith()
@FlexiIndicatorSerializable
class OBVIndicator extends ComputedIndicator {
  OBVIndicator({
    super.zIndex = 0,
    required super.height,
    super.padding = defaultSubIndicatorPadding,
    required this.calcParam,
    required this.tipsPadding,
    this.tickCount = defaultSubTickCount,
  }) : super(key: const ComputedIndicatorKey('obv'));

  @override
  final OBVParam calcParam;

  final EdgeInsets tipsPadding;
  final int tickCount;

  factory OBVIndicator.fromJson(Map<String, dynamic> json) => _$OBVIndicatorFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$OBVIndicatorToJson(this);

  @override
  ComputedPaintObject<OBVIndicator> createPaintObject() {
    return OBVPaintObject();
  }
}

class OBVPaintObject<T extends OBVIndicator> extends ComputedPaintObject<T>
    with ObvDataMixin, PaintYAxisTicksMixin, PaintYAxisTicksOnCrossMixin {
  OBVPaintObject();

  @override
  MinMax? computeVisibleMinMax(int start, int end) {
    if (!klineData.canPaintChart) return null;
    return calcuObvMinmax(
      indicator.calcParam,
      start: start,
      end: end,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    paintObvLine(canvas, size);
    paintObvMALines(canvas, size);

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
    return _formatObvValue(value, precision);
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
    return _formatObvValue(value, precision);
  }

  /// OBV 数值通常很大，使用缩写格式（K/M/B）
  String _formatObvValue(FlexiNum value, int precision) {
    final v = value.toDouble();
    final absV = v.abs();
    if (absV >= 1e9) {
      return '${(v / 1e9).toStringAsFixed(precision)}B';
    } else if (absV >= 1e6) {
      return '${(v / 1e6).toStringAsFixed(precision)}M';
    } else if (absV >= 1e3) {
      return '${(v / 1e3).toStringAsFixed(precision)}K';
    }
    return formatNumber(
      value.toDecimal(),
      precision: precision,
      cutInvalidZero: false,
    );
  }

  void paintObvLine(Canvas canvas, Size size) {
    if (!klineData.canPaintChart) return;
    if (!indicator.calcParam.obvLine.enabled) return;
    final list = klineData.list;
    final start = klineData.start;
    final end = (klineData.end + 1).clamp(start, list.length);

    final offset = startCandleDx - candleWidthHalf;
    final List<Offset> points = [];
    for (int i = start; i < end; i++) {
      final val = list[i].getObvValue(dataIndex);
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
          ..color = indicator.calcParam.obvLine.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = indicator.calcParam.obvLine.width,
      );
    }
  }

  void paintObvMALines(Canvas canvas, Size size) {
    if (!klineData.canPaintChart) return;
    final enabledMALines = indicator.calcParam.enabledMALines;
    if (enabledMALines.isEmpty) return;
    final list = klineData.list;
    final start = klineData.start;
    final end = (klineData.end + 1).clamp(start, list.length);

    final offset = startCandleDx - candleWidthHalf;
    for (int j = 0; j < enabledMALines.length; j++) {
      final maConfig = enabledMALines[j];
      final maSlotIndex = j + 1;
      final List<Offset> points = [];

      for (int i = start; i < end; i++) {
        final val = list[i].getObvList(dataIndex)?.getItem(maSlotIndex);
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
            ..color = maConfig.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = maConfig.width,
        );
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
    if (model == null || !model.isValidObv(dataIndex)) return null;

    final param = indicator.calcParam;
    final precision = param.display.precision;
    final children = <TextSpan>[];

    // OBV 主线值
    final obvVal = model.getObvValue(dataIndex);
    if (obvVal != null) {
      children.add(TextSpan(
        text: 'OBV: ${_formatObvValue(FlexiNum.fromNum(obvVal), precision)}  ',
        style: TextStyle(color: param.obvLine.color, fontSize: 12),
      ));
    }

    // MA 线值
    if (param.display.showMAInTips) {
      final enabledMALines = param.enabledMALines;
      final obvList = model.getObvList(dataIndex);
      for (int j = 0; j < enabledMALines.length; j++) {
        final maSlotIndex = j + 1;
        final maVal = obvList?.getItem(maSlotIndex);
        if (maVal == null) continue;
        final maConfig = enabledMALines[j];
        children.add(TextSpan(
          text: 'MA${maConfig.period}: ${_formatObvValue(FlexiNum.fromNum(maVal), precision)}  ',
          style: TextStyle(color: maConfig.color, fontSize: 12),
        ));
      }
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
