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

part of 'ema.dart';

@CopyWith()
@FlexiIndicatorSerializable
class EMAIndicator extends SinglePaintObjectIndicator implements IPrecomputable {
  EMAIndicator({
    super.zIndex = 0,
    required super.height,
    super.padding = defaultMainIndicatorPadding,
    required this.calcParams,
    required this.tipsPadding,
    required this.lineWidth,
  }) : super(key: const FlexiIndicatorKey('ema'));

  /// EMA参数列表
  final List<MaParam> calcParams;
  final EdgeInsets tipsPadding;
  final double lineWidth;

  @override
  SinglePaintObjectBox createPaintObject(
    IPaintContext context, {
    KlineEventBus? eventBus,
  }) {
    return EMAPaintObject(context: context, indicator: this);
  }

  factory EMAIndicator.fromJson(Map<String, dynamic> json) => _$EMAIndicatorFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$EMAIndicatorToJson(this);
}

class EMAPaintObject<T extends EMAIndicator> extends SinglePaintObjectBox<T> with EmaDataMixin<T> {
  EMAPaintObject({
    required super.context,
    required super.indicator,
  });

  @override
  MinMax? initState({required int start, required int end}) {
    if (!klineData.canPaintChart) return null;
    return calcuEmaMinmax(
      indicator.calcParams,
      start: start,
      end: end,
    );
  }

  @override
  void paintChart(Canvas canvas, Size size) {
    paintEMALine(canvas, size);
  }

  /// 绘制EMA线
  void paintEMALine(Canvas canvas, Size size) {
    if (!klineData.canPaintChart) return;
    final list = klineData.list;
    int start = klineData.start;
    int end = (klineData.end + 1).clamp(start, list.length); // 多绘制一根蜡烛
    final offset = startCandleDx - candleWidthHalf;
    for (int j = 0; j < indicator.calcParams.length; j++) {
      BagNum? val;
      final List<Offset> points = [];
      for (int i = start; i < end; i++) {
        val = list[i].emaList?.getItem(j);
        if (val == null) continue;
        points.add(Offset(
          offset - (i - start) * candleActualWidth,
          valueToDy(val, correct: false),
        ));
      }
      if (points.isNotEmpty) {
        canvas.drawPath(
          Path()..addPolygon(points, false),
          Paint()
            ..color = indicator.calcParams[j].tips.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = indicator.lineWidth,
        );
      }
    }
  }

  @override
  Size? paintTips(
    Canvas canvas, {
    CandleModel? model,
    Offset? offset,
    Rect? tipsRect,
  }) {
    model ??= offsetToCandle(offset);
    if (model == null || !model.isValidEmaList) return null;
    final children = <TextSpan>[];
    BagNum? val;
    for (int i = 0; i < model.emaList!.length; i++) {
      val = model.emaList?.getItem(i);
      if (val == null) continue;
      final param = indicator.calcParams.getItem(i);
      if (param == null) continue;
      final text = formatNumber(
        val.toDecimal(),
        precision: param.tips.getP(klineData.precision),
        cutInvalidZero: true,
        prefix: param.tips.label,
        suffix: '  ',
      );
      children.add(TextSpan(
        text: text,
        style: param.tips.style,
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

  @override
  void onCross(Canvas canvas, Offset offset) {
    // EMA不需要特殊十字线处理，可留空
  }
}
