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

part of 'macd.dart';

@CopyWith()
@FlexiIndicatorSerializable
class MACDIndicator extends ComputedIndicator {
  MACDIndicator({
    super.zIndex = 0,
    required super.height,
    super.padding = defaultSubIndicatorPadding,
    this.calcParam = const MACDParam(s: 12, l: 26, m: 9),
    required this.difTips,
    required this.deaTips,
    required this.macdTips,
    required this.tipsPadding,
    this.tickCount = defaultSubTickCount,
  }) : super(key: const ComputedIndicatorKey('macd'));

  /// MACD 参数（包含所有配置）
  @override
  final MACDParam calcParam;

  /// Tips 相关参数（仅用于显示）
  final TipsConfig difTips;
  final TipsConfig deaTips;
  final TipsConfig macdTips;
  final EdgeInsets tipsPadding;
  final int tickCount;

  @override
  ComputedPaintObject<MACDIndicator> createPaintObject() {
    return MACDPaintObject();
  }

  factory MACDIndicator.fromJson(Map<String, dynamic> json) => _$MACDIndicatorFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$MACDIndicatorToJson(this);
}

class MACDPaintObject<T extends MACDIndicator> extends ComputedPaintObject<T>
    with MacdDataMixin<T>, PaintYAxisTicksMixin, PaintYAxisTicksOnCrossMixin {
  MACDPaintObject();

  @override
  MinMax? computeVisibleMinMax(int start, int end) {
    if (!klineData.canPaintChart) return null;
    return calcuMacdMinmax(
      indicator.calcParam,
      start: start,
      end: end,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    paintMacdChart(canvas, size);
    if (settingConfig.showYAxisTick) {
      paintYAxisTicks(
        canvas,
        size,
        tickCount: indicator.tickCount,
        precision: indicator.calcParam.precision,
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
      precision: indicator.calcParam.precision,
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

  /// 绘制MACD图
  void paintMacdChart(Canvas canvas, Size size) {
    if (!klineData.canPaintChart) return;
    final list = klineData.list;
    final len = list.length;
    if (!indicator.calcParam.isValid(len)) return;
    int start = klineData.start;
    int end = (klineData.end + 1).clamp(start, len); // 多绘制一根蜡烛

    // 📊 根据配置决定是否收集线条点位
    final List<Offset> difPoints = [];
    final List<Offset> deaPoints = [];
    final param = indicator.calcParam;

    double zeroDy = valueToDy(FlexiNum.zero);
    final offset = startCandleDx - candleWidthHalf;
    final candleHalf = candleWidthHalf - candleSpacing;

    for (int i = start; i < end; i++) {
      final m = list[i];
      if (!m.isValidMacdData(dataIndex)) continue;
      final dx = offset - (i - start) * candleActualWidth;

      // 📈 只有启用的线条才收集点位
      if (param.difLine.enabled && m.macdDif(dataIndex) != null) {
        difPoints.add(Offset(dx, valueToDy(m.macdDif(dataIndex)!, correct: false)));
      }
      if (param.deaLine.enabled && m.macdDea(dataIndex) != null) {
        deaPoints.add(Offset(dx, valueToDy(m.macdDea(dataIndex)!, correct: false)));
      }

      // 📊 根据配置决定是否绘制柱状图
      if (param.histogramEnabled && m.macdVal(dataIndex) != null) {
        final next = list.getItem(i + 1);
        final histogramColor = _getHistogramColor(m.macdVal(dataIndex)!, next?.macdVal(dataIndex));
        final histogramStyle = _getHistogramStyle(m.macdVal(dataIndex)!, next?.macdVal(dataIndex));

        if (histogramStyle == HistogramStyle.hollow &&
            next?.macdVal(dataIndex) != null &&
            m.macdVal(dataIndex)! > next!.macdVal(dataIndex)!) {
          // 空心柱状图
          final hollowBarPaint = Paint()
            ..color = histogramColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;

          canvas.drawPath(
            Path()
              ..addRect(Rect.fromPoints(
                Offset(dx - candleHalf, zeroDy),
                Offset(dx + candleHalf, valueToDy(m.macdVal(dataIndex)!, correct: false)),
              )),
            hollowBarPaint,
          );
        } else {
          // 实心柱状图
          final solidBarPaint = Paint()
            ..color = histogramColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = candleWidth;

          canvas.drawLine(
            Offset(dx, zeroDy),
            Offset(dx, valueToDy(m.macdVal(dataIndex)!)),
            solidBarPaint,
          );
        }
      }
    }

    // 📈 根据配置绘制DIF线
    if (param.difLine.enabled && difPoints.isNotEmpty) {
      canvas.drawPath(
        Path()..addPolygon(difPoints, false),
        Paint()
          ..color = param.difLine.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = param.difLine.width,
      );
    }

    // 📈 根据配置绘制DEA线
    if (param.deaLine.enabled && deaPoints.isNotEmpty) {
      canvas.drawPath(
        Path()..addPolygon(deaPoints, false),
        Paint()
          ..color = param.deaLine.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = param.deaLine.width,
      );
    }

    // 📏 根据配置绘制零轴线
    if (param.showZeroLine) {
      _paintZeroLine(canvas, size, zeroDy);
    }
  }

  /// 绘制零轴线
  void _paintZeroLine(Canvas canvas, Size size, double zeroDy) {
    final param = indicator.calcParam;
    final paint = Paint()
      ..color = param.zeroLineColor
      ..strokeWidth = param.zeroLineWidth
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, zeroDy),
      Offset(size.width, zeroDy),
      paint,
    );
  }

  /// 根据 MACD 值和趋势获取柱状图颜色
  Color _getHistogramColor(FlexiNum currentMacd, FlexiNum? nextMacd) {
    final isBullish = currentMacd > FlexiNum.zero;
    final isIncreasing = nextMacd != null && currentMacd > nextMacd;

    if (isBullish) {
      return isIncreasing ? indicator.calcParam.bullishIncreasing.color : indicator.calcParam.bullishDecreasing.color;
    } else {
      return isIncreasing ? indicator.calcParam.bearishIncreasing.color : indicator.calcParam.bearishDecreasing.color;
    }
  }

  /// 根据 MACD 值和趋势获取柱状图样式
  HistogramStyle _getHistogramStyle(FlexiNum currentMacd, FlexiNum? nextMacd) {
    final isBullish = currentMacd > FlexiNum.zero;
    final isIncreasing = nextMacd != null && currentMacd > nextMacd;

    if (isBullish) {
      return isIncreasing ? indicator.calcParam.bullishIncreasing.style : indicator.calcParam.bullishDecreasing.style;
    } else {
      return isIncreasing ? indicator.calcParam.bearishIncreasing.style : indicator.calcParam.bearishDecreasing.style;
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
    if (model == null || !model.isValidMacdData(dataIndex)) return null;

    final precision = indicator.calcParam.precision;
    final param = indicator.calcParam;
    final children = <TextSpan>[];

    // 📈 根据配置决定是否显示DIF
    if (param.difLine.enabled && model.macdDif(dataIndex) != null) {
      children.add(TextSpan(
        text: formatNumber(
          model.macdDif(dataIndex)!.toDecimal(),
          precision: indicator.difTips.getP(precision),
          cutInvalidZero: true,
          prefix: indicator.difTips.label,
          suffix: ' ',
        ),
        style: indicator.difTips.style.copyWith(color: param.difLine.color),
      ));
    }

    // 📈 根据配置决定是否显示DEA
    if (param.deaLine.enabled && model.macdDea(dataIndex) != null) {
      children.add(TextSpan(
        text: formatNumber(
          model.macdDea(dataIndex)!.toDecimal(),
          precision: indicator.deaTips.getP(precision),
          cutInvalidZero: true,
          prefix: indicator.deaTips.label,
          suffix: ' ',
        ),
        style: indicator.deaTips.style.copyWith(color: param.deaLine.color),
      ));
    }

    // 📊 根据配置决定是否显示MACD
    if (param.histogramEnabled && model.macdVal(dataIndex) != null) {
      children.add(TextSpan(
        text: formatNumber(
          model.macdVal(dataIndex)!.toDecimal(),
          precision: indicator.macdTips.getP(precision),
          cutInvalidZero: true,
          prefix: indicator.macdTips.label,
          suffix: ' ',
        ),
        style: indicator.macdTips.style.copyWith(color: _getHistogramColor(model.macdVal(dataIndex)!, null)),
      ));
    }

    // 📋 如果没有任何内容要显示，返回null
    if (children.isEmpty) return null;

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
}
