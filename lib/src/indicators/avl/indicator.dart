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

part of 'avl.dart';

/// AVL 均价线指标
/// 均价线(AVL)AVL = 某日总成交金额/某日总成交股数其计算结果就是每股平均的成交价格。
/// AVL反映当日的真实股票价格情况，避免主力庄家的骗线图形。均价线是超级短线实战的一个重要研判工具。
@CopyWith()
@FlexiIndicatorSerializable
class AVLIndicator extends PaintObjectIndicator implements IPrecomputable {
  AVLIndicator({
    super.zIndex = 0,
    required super.height,
    super.padding = defaultMainIndicatorPadding,
    required this.calcParam,
    required this.line,
    required this.tips,
    required this.tipsPadding,
    this.tickCount = defaultSubTickCount,
  }) : super(key: const FlexiIndicatorKey('avl'));

  /// AVL计算参数
  @override
  final AVLParam calcParam;

  /// 绘制相关参数
  final LineConfig line;
  final TipsConfig tips;
  final EdgeInsets tipsPadding;

  /// YAxis刻度数量(注: 仅在key为subAvlKey时有用)
  final int tickCount;

  @override
  PaintObjectBox createPaintObject(
    IPaintContext context, {
    KlineEventBus? eventBus,
  }) {
    return AVLPaintObject(context: context, indicator: this);
  }

  factory AVLIndicator.fromJson(Map<String, dynamic> json) => _$AVLIndicatorFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AVLIndicatorToJson(this);
}

class AVLPaintObject<T extends AVLIndicator> extends PaintObjectBox<T>
    with AvlDataMixin, PaintYAxisTicksMixin, PaintYAxisTicksOnCrossMixin {
  AVLPaintObject({
    required super.context,
    required super.indicator,
  });

  bool? _isInsub;
  bool get isInSub => _isInsub ??= indicator.key.id == 'subAvl';

  @override
  MinMax? initState(int start, int end) {
    if (!klineData.canPaintChart) return null;

    MinMax? avlMinmax = calcuAvlMinmax(
      indicator.calcParam,
      start: start,
      end: end,
    );
    if (isInSub) {
      MinMax? candleMinmax = klineData.calculateMinmax(start, end);
      if (candleMinmax != null) return candleMinmax..updateMinMax(avlMinmax);
      if (avlMinmax != null) return avlMinmax..updateMinMax(candleMinmax);
      return null;
    } else {
      return avlMinmax;
    }
  }

  @override
  void paintChart(Canvas canvas, Size size) {
    /// 绘制AVL图
    paintAvlChart(canvas, size);

    if (isInSub && settingConfig.showYAxisTick) {
      paintYAxisTicks(
        canvas,
        size,
        tickCount: indicator.tickCount,
        precision: klineData.precision,
      );
    }
  }

  /// 重写[paintYAxisTicks]中的格式化刻度值.
  @override
  String fromatTicksValue(BagNum value, {required int precision}) {
    return formatPrice(
      value.toDecimal(),
      precision: precision,
      cutInvalidZero: false,
      showThousands: true,
    );
  }

  @override
  void onCross(Canvas canvas, Offset offset) {
    /// onCross时, 绘制Y轴上的标记值(注: 仅对indicator.key为subAvlKey时有效)
    if (isInSub) {
      paintYAxisTicksOnCross(
        canvas,
        offset,
        precision: klineData.precision,
      );
    }
  }

  /// 在onCross时, 重写[paintYAxisTicksOnCross]中的格式化刻度值
  @override
  String formatTicksValueOnCross(BagNum value, {required int precision}) {
    return formatPrice(
      value.toDecimal(),
      precision: precision,
      cutInvalidZero: false,
      showThousands: true,
    );
  }

  /// 绘制AVL线
  void paintAvlChart(Canvas canvas, Size size) {
    if (!klineData.canPaintChart) return;
    final list = klineData.list;
    final len = list.length;
    if (!indicator.calcParam.isValid(len)) return;
    int start = klineData.start;
    int end = (klineData.end + 1).clamp(start, len); // 多绘制一根蜡烛

    final List<Offset> points = [];
    final offset = startCandleDx - candleWidthHalf;

    CandleModel m;
    for (int i = start; i < end; i++) {
      m = list[i];
      if (!m.isValidAvlData) continue;
      final dx = offset - (i - start) * candleActualWidth;
      points.add(Offset(dx, valueToDy(m.avl!, correct: false)));
    }

    canvas.drawLineType(
      indicator.line.type,
      Path()..addPolygon(points, false),
      indicator.line.linePaint,
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
    if (model == null || !model.isValidAvlData) return null;

    final precision = klineData.req.precision;
    final text = formatNumber(
      model.avl!.toDecimal(),
      precision: indicator.tips.getP(precision),
      cutInvalidZero: true,
      prefix: indicator.tips.label,
    );
    tipsRect ??= drawableRect;
    return canvas.drawText(
      offset: tipsRect.topLeft,
      text: text,
      style: indicator.tips.style,
      drawDirection: DrawDirection.ltr,
      drawableRect: tipsRect,
      textAlign: TextAlign.left,
      padding: indicator.tipsPadding,
      maxLines: 1,
    );
  }
}
