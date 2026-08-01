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

part of 'sar.dart';

/// SAR 抛物线指标
/// SAR 的计算需要参考每一日的最高价与最低价：
/// SAR(今日)：SAR (昨日) + AF (动能趋势指标) x [ (区间极值(波段内最极值) – SAR(昨日)]
@CopyWith()
@FlexiIndicatorSerializable
class SARIndicator extends ComputedIndicator {
  SARIndicator({
    super.zIndex = 0,
    required super.height,
    super.padding = defaultMainIndicatorPadding,

    /// SAR计算参数 - 包含所有配置
    this.calcParam = const SARParam(),
    required this.tipsPadding,
    this.tickCount = defaultSubTickCount,
  }) : super(key: const ComputedIndicatorKey('sar'));

  /// SAR计算参数 - 包含所有配置
  @override
  final SARParam calcParam;

  /// Tips 布局参数
  final EdgeInsets tipsPadding;

  /// YAxis刻度数量(注: 仅在key为subSarKey时有用)
  final int tickCount;

  @override
  ComputedPaintObject<SARIndicator> createPaintObject() {
    return SARPaintObject();
  }

  factory SARIndicator.fromJson(Map<String, dynamic> json) => _$SARIndicatorFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SARIndicatorToJson(this);
}

class SARPaintObject<T extends SARIndicator> extends ComputedPaintObject<T>
    with SarDataMixin, PaintYAxisTicksMixin, PaintYAxisTicksOnCrossMixin {
  SARPaintObject();

  bool? _isInsub;
  bool get isInSub => _isInsub ??= indicator.key == const ComputedIndicatorKey('sar');

  @override
  MinMax? computeVisibleMinMax(int start, int end) {
    if (!klineData.canPaintChart) return null;

    MinMax? sarMinmax = calcuSarMinmax(
      indicator.calcParam,
      start: start,
      end: end,
    );
    if (isInSub) {
      MinMax? candleMinmax = klineData.calculateMinmax(start, end);
      if (candleMinmax != null) return candleMinmax..updateMinMax(sarMinmax);
      if (sarMinmax != null) return sarMinmax..updateMinMax(candleMinmax);
      return null;
    } else {
      return sarMinmax;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    /// 绘制SAR图
    paintSarChart(canvas, size);

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
    /// onCross时, 绘制Y轴上的标记值(注: 仅对indicator.key为subSarKey时有效)
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

  void paintSarChart(Canvas canvas, Size size) {
    if (!klineData.canPaintChart) return;
    final list = klineData.list;
    final len = list.length;
    if (!indicator.calcParam.isValid(len)) return;
    int start = klineData.start;
    int end = (klineData.end + 1).clamp(start, len); // 多绘制一根蜡烛

    // 注：如果需要在子图中绘制简易蜡烛，可以在这里添加逻辑

    // 使用新的配置结构
    final appearance = indicator.calcParam.appearance;
    final paint = Paint()..style = PaintingStyle.fill;

    // 计算半径：使用配置的半径，但限制在最小和最大值之间
    final configRadius = appearance.pointRadius;
    final radius = configRadius.clamp(
      appearance.minRadius,
      appearance.maxRadius,
    );

    final offset = startCandleDx - candleWidthHalf;
    for (int i = start; i < end; i++) {
      final m = list[i];
      if (!m.isValidSarData(dataIndex)) continue;
      final dx = offset - (i - start) * candleActualWidth;

      // 根据配置决定使用涨跌色还是固定颜色
      if (appearance.useTrendColor) {
        if (m.sarFlag(dataIndex)! > 0) {
          paint.color = longColor;
        } else if (m.sarFlag(dataIndex)! < 0) {
          paint.color = shortColor;
        } else {
          paint.color = theme.textColor;
        }
      } else {
        paint.color = appearance.color;
      }

      final center = Offset(dx, valueToDy(m.sarValue(dataIndex)!, correct: false));

      // 绘制 SAR 点
      canvas.drawCircle(center, radius, paint);

      // 如果有边框宽度，绘制边框
      if (appearance.borderWidth > 0) {
        final borderPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = appearance.borderWidth
          ..color = paint.color.withOpacity(0.8);
        canvas.drawCircle(center, radius, borderPaint);
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
    if (model == null || !model.isValidSarData(dataIndex)) return null;

    final display = indicator.calcParam.display;
    final periods = indicator.calcParam.periods;

    // 构建 tips 文本
    String text;
    if (display.showPeriodInTips) {
      text = 'SAR(${periods.start.toStringAsFixed(2)}-${periods.max.toStringAsFixed(2)}): ';
    } else {
      text = 'SAR: ';
    }

    text += formatNumber(
      model.sarValue(dataIndex)?.toDecimal(),
      precision: display.precision,
      cutInvalidZero: true,
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
