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
class MACDIndicator extends SinglePaintObjectIndicator implements IPrecomputable {
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
    required this.lineWidth,
    this.precision = 2,
  }) : super(key: const FlexiIndicatorKey('macd'));

  /// Macd相关参数
  @override
  final MACDParam calcParam;

  /// 绘制相关参数
  final TipsConfig difTips;
  final TipsConfig deaTips;
  final TipsConfig macdTips;
  final EdgeInsets tipsPadding;
  final int tickCount;
  final double lineWidth;
  final int precision;

  @override
  SinglePaintObjectBox createPaintObject(IPaintContext context) {
    return MACDPaintObject(context: context, indicator: this);
  }

  factory MACDIndicator.fromJson(Map<String, dynamic> json) => _$MACDIndicatorFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$MACDIndicatorToJson(this);
}

class MACDPaintObject<T extends MACDIndicator> extends SinglePaintObjectBox<T> with MacdDataMixin<T> {
  MACDPaintObject({required super.context, required super.indicator});

  @override
  MinMax? initState({required int start, required int end}) {
    if (!klineData.canPaintChart) return null;
    return calcuMacdMinmax(
      indicator.calcParam,
      start: start,
      end: end,
    );
  }

  @override
  void paintChart(Canvas canvas, Size size) {
    paintMacdChart(canvas, size);
    // 如需绘制Y轴刻度，可在此调用paintYAxisTicks等
  }

  @override
  void onCross(Canvas canvas, Offset offset) {
    // MACD不需要特殊十字线处理，可留空
  }

  /// 绘制MACD图
  void paintMacdChart(Canvas canvas, Size size) {
    if (!klineData.canPaintChart) return;
    final list = klineData.list;
    final len = list.length;
    if (!indicator.calcParam.isValid(len)) return;
    int start = klineData.start;
    int end = (klineData.end + 1).clamp(start, len); // 多绘制一根蜡烛

    final List<Offset> difPoints = [];
    final List<Offset> deaPoints = [];
    double zeroDy = valueToDy(BagNum.zero);
    final offset = startCandleDx - candleWidthHalf;
    final candleHalf = candleWidthHalf - settingConfig.candleSpacing;

    CandleModel m;
    CandleModel? next;
    for (int i = start; i < end; i++) {
      m = list[i];
      if (!m.isValidMacdData) continue;
      final dx = offset - (i - start) * candleActualWidth;
      difPoints.add(Offset(dx, valueToDy(m.dif!, correct: false)));
      deaPoints.add(Offset(dx, valueToDy(m.dea!, correct: false)));

      next = list.getItem(i + 1);
      if (next?.macd != null && m.macd! > next!.macd!) {
        // 空心
        canvas.drawPath(
          Path()
            ..addRect(Rect.fromPoints(
              Offset(dx - candleHalf, zeroDy),
              Offset(dx + candleHalf, valueToDy(m.macd!, correct: false)),
            )),
          m.macd! > BagNum.zero
              ? settingConfig.defLongHollowBarPaint
              : settingConfig.defShortHollowBarPaint,
        );
      } else {
        // 实心
        canvas.drawLine(
          Offset(dx, zeroDy),
          Offset(dx, valueToDy(m.macd!)),
          m.macd! > BagNum.zero ? settingConfig.defLongBarPaint : settingConfig.defShortBarPaint,
        );
      }
    }

    canvas.drawPath(
      Path()..addPolygon(difPoints, false),
      Paint()
        ..color = indicator.difTips.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = indicator.lineWidth,
    );

    canvas.drawPath(
      Path()..addPolygon(deaPoints, false),
      Paint()
        ..color = indicator.deaTips.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = indicator.lineWidth,
    );
  }

  @override
  Size? paintTips(
    Canvas canvas, {
    CandleModel? model,
    Offset? offset,
    Rect? tipsRect,
  }) {
    model ??= offsetToCandle(offset);
    if (model == null || !model.isValidMacdData) return null;

    final precision = indicator.precision;
    final children = <TextSpan>[];

    children.add(TextSpan(
      text: formatNumber(
        model.dif?.toDecimal(),
        precision: indicator.difTips.getP(precision),
        cutInvalidZero: true,
        prefix: indicator.difTips.label,
        suffix: ' ',
      ),
      style: indicator.difTips.style,
    ));

    children.add(TextSpan(
      text: formatNumber(
        model.dea?.toDecimal(),
        precision: indicator.deaTips.getP(precision),
        cutInvalidZero: true,
        prefix: indicator.deaTips.label,
        suffix: ' ',
      ),
      style: indicator.deaTips.style,
    ));

    children.add(TextSpan(
      text: formatNumber(
        model.macd?.toDecimal(),
        precision: indicator.macdTips.getP(precision),
        cutInvalidZero: true,
        prefix: indicator.macdTips.label,
        suffix: ' ',
      ),
      style: indicator.macdTips.style,
    ));

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