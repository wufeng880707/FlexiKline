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
/// 均价线(AVL) = (开盘价 + 最高价 + 最低价 + 收盘价) / 4
/// 适用于24小时连续交易的加密货币市场，使用四价平均提供更全面的价格信息
@CopyWith()
@FlexiIndicatorSerializable
class AVLIndicator extends ComputedIndicator {
  AVLIndicator({
    super.zIndex = 0,
    required super.height,
    super.padding = defaultMainIndicatorPadding,
    this.calcParam = const AVLParam(),
    required this.tipsPadding,
    this.tickCount = defaultSubTickCount,
  }) : super(key: const ComputedIndicatorKey('avl'));

  /// AVL计算参数 - 包含所有配置
  @override
  final AVLParam calcParam;

  /// Tips 布局参数
  final EdgeInsets tipsPadding;

  /// YAxis刻度数量(注: 仅在key为subAvlKey时有用)
  final int tickCount;

  @override
  ComputedPaintObject<AVLIndicator> createPaintObject() {
    return AVLPaintObject();
  }

  @override
  IndicatorCalculator createCalculator(int dataIndex) => _AVLCalculator(this, dataIndex);

  factory AVLIndicator.fromJson(Map<String, dynamic> json) => _$AVLIndicatorFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AVLIndicatorToJson(this);
}

class _AVLCalculator extends ComputedIndicatorCalculator<AVLIndicator> with AvlDataMixin<AVLIndicator> {
  _AVLCalculator(super.indicator, super.dataIndex);
}

class AVLPaintObject<T extends AVLIndicator> extends ComputedPaintObject<T>
    with AvlDataMixin, PaintYAxisTicksMixin, PaintYAxisTicksOnCrossMixin {
  AVLPaintObject();

  bool? _isInsub;
  bool get isInSub => _isInsub ??= indicator.key.id == 'subAvl';

  @override
  MinMax? computeVisibleMinMax(int start, int end) {
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
  void paint(Canvas canvas, Size size) {
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
  String formatTicksValue(FlexiNum value, {required int precision}) {
    return formatPrice(
      value.toDecimal(),
      precision: precision,
      cutInvalidZero: false,
    );
  }

  @override
  void paintCross(Canvas canvas, Offset offset, {FlexiCandleModel? model}) {
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
  String formatTicksValueOnCross(FlexiNum value, {required int precision}) {
    return formatPrice(
      value.toDecimal(),
      precision: precision,
      cutInvalidZero: false,
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

    final appearance = indicator.calcParam.appearance;
    final List<Offset> points = [];
    final offset = startCandleDx - candleWidthHalf;

    for (int i = start; i < end; i++) {
      final m = list[i];
      if (!m.isValidAvlData) continue;
      final dx = offset - (i - start) * candleActualWidth;
      points.add(Offset(dx, valueToDy(m.avl!, correct: false)));
    }

    if (points.isEmpty) return;

    // 创建线条画笔
    final linePaint = Paint()
      ..color = appearance.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = appearance.lineWidth;

    // 绘制线条
    final path = Path()..addPolygon(points, false);

    if (appearance.dashWidth > 0) {
      // 绘制虚线 - 使用简单的实现
      final pathMetrics = path.computeMetrics();
      for (final metric in pathMetrics) {
        double distance = 0.0;
        bool draw = true;
        while (distance < metric.length) {
          final nextDistance = (distance + appearance.dashWidth).clamp(0.0, metric.length);
          if (draw) {
            final segment = metric.extractPath(distance, nextDistance);
            canvas.drawPath(segment, linePaint);
          }
          distance = nextDistance;
          draw = !draw;
        }
      }
    } else {
      // 绘制实线
      canvas.drawPath(path, linePaint);
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
    if (model == null || !model.isValidAvlData) return null;

    final display = indicator.calcParam.display;
    if (!display.showInTips) return null;

    final text = formatNumber(
      model.avl!.toDecimal(),
      precision: display.precision,
      cutInvalidZero: true,
      prefix: '${display.tipsLabel}: ',
    );

    tipsRect ??= drawableRect;
    return canvas.drawText(
      offset: tipsRect.topLeft,
      text: text,
      style: TextStyle(
        color: theme.textColor,
        fontSize: 12,
      ),
      drawDirection: DrawDirection.ltr,
      drawableRect: tipsRect,
      textAlign: TextAlign.left,
      padding: indicator.tipsPadding,
      maxLines: 1,
    );
  }
}
