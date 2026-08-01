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

part of 'boll.dart';

/// BOLL 布林带指标
class BOLLIndicator extends ComputedIndicator {
  BOLLIndicator({
    super.zIndex = 0,
    required super.height,
    super.padding = defaultMainIndicatorPadding,
    this.calcParam = const BOLLParam(),
    required this.tipsPadding,
    this.tickCount = defaultSubTickCount,
  }) : super(key: const ComputedIndicatorKey('boll'));

  /// BOLL计算参数 - 包含所有配置
  @override
  final BOLLParam calcParam;

  /// Tips 布局参数
  final EdgeInsets tipsPadding;

  /// YAxis刻度数量(注: 仅在key为subBollKey时有用)
  final int tickCount;

  @override
  ComputedPaintObject<BOLLIndicator> createPaintObject() {
    return BOLLPaintObject();
  }
}

class BOLLPaintObject<T extends BOLLIndicator> extends ComputedPaintObject<T>
    with BollDataMixin, PaintYAxisTicksMixin, PaintYAxisTicksOnCrossMixin {
  BOLLPaintObject();

  bool? _isInsub;
  bool get isInSub => _isInsub ??= indicator.key.id == 'subBoll';

  @override
  MinMax? computeVisibleMinMax(int start, int end) {
    if (!klineData.canPaintChart) return null;

    MinMax? bollMinmax = calcuBollMinmax(
      indicator.calcParam,
      start: start,
      end: end,
    );
    if (isInSub) {
      MinMax? candleMinmax = klineData.calculateMinmax(start, end);
      if (candleMinmax != null) return candleMinmax..updateMinMax(bollMinmax);
      if (bollMinmax != null) return bollMinmax..updateMinMax(candleMinmax);
      return null;
    } else {
      return bollMinmax;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    /// 绘制BOLL图
    paintBollChart(canvas, size);

    if (isInSub && settingConfig.showYAxisTick) {
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
  void paintCross(Canvas canvas, Offset offset, {FlexiCandleModel? model}) {
    /// onCross时, 绘制Y轴上的标记值(注: 仅对indicator.key为subBollKey时有效)
    if (isInSub) {
      paintYAxisTicksOnCross(
        canvas,
        offset,
        precision: indicator.calcParam.display.precision,
      );
    }
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

  /// 绘制BOLL线
  void paintBollChart(Canvas canvas, Size size) {
    if (!klineData.canPaintChart) return;
    final list = klineData.list;
    final len = list.length;
    if (!indicator.calcParam.isValid(len)) return;
    int start = klineData.start;
    int end = (klineData.end + 1).clamp(start, len); // 多绘制一根蜡烛

    // 如果在子指标中，可以在这里添加额外的绘制逻辑

    final enabledLines = indicator.calcParam.enabledLines;
    if (enabledLines.isEmpty) return;

    // 收集各线条的点位
    final Map<BOLLLineType, List<Offset>> linePoints = {};
    for (final lineType in enabledLines) {
      linePoints[lineType] = [];
    }

    final offset = startCandleDx - candleWidthHalf;

    for (int i = start; i < end; i++) {
      final m = list[i];
      if (!m.isValidBollData(dataIndex)) continue;
      final dx = offset - (i - start) * candleActualWidth;

      for (final lineType in enabledLines) {
        FlexiNum? value;
        switch (lineType) {
          case BOLLLineType.ub:
            value = m.bollUp(dataIndex);
            break;
          case BOLLLineType.boll:
            value = m.bollMb(dataIndex);
            break;
          case BOLLLineType.lb:
            value = m.bollDn(dataIndex);
            break;
        }
        if (value != null) {
          linePoints[lineType]!.add(Offset(dx, valueToDy(value, correct: false)));
        }
      }
    }

    // 绘制背景填充（如果启用）
    if (indicator.calcParam.fill.enabled &&
        linePoints[BOLLLineType.ub]?.isNotEmpty == true &&
        linePoints[BOLLLineType.lb]?.isNotEmpty == true) {
      final ubPoints = linePoints[BOLLLineType.ub]!;
      final lbPoints = linePoints[BOLLLineType.lb]!;

      final fillPath = Path();
      fillPath.addPolygon([...ubPoints, ...lbPoints.reversed], true);

      canvas.drawPath(
        fillPath,
        Paint()
          ..color = indicator.calcParam.fill.color.withOpacity(indicator.calcParam.fill.opacity)
          ..style = PaintingStyle.fill,
      );
    }

    // 绘制各条线
    for (final lineType in enabledLines) {
      final points = linePoints[lineType]!;
      if (points.isEmpty) continue;

      BOLLLineConfig lineConfig;
      switch (lineType) {
        case BOLLLineType.ub:
          lineConfig = indicator.calcParam.lines.ub;
          break;
        case BOLLLineType.boll:
          lineConfig = indicator.calcParam.lines.boll;
          break;
        case BOLLLineType.lb:
          lineConfig = indicator.calcParam.lines.lb;
          break;
      }

      // 绘制线条
      canvas.drawPath(
        Path()..addPolygon(points, false),
        Paint()
          ..color = lineConfig.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = lineConfig.width,
      );

      // 绘制节点（如果配置了节点半径）
      if (indicator.calcParam.display.pointRadius > 0) {
        final pointPaint = Paint()
          ..color = lineConfig.color
          ..style = PaintingStyle.fill;

        for (final point in points) {
          canvas.drawCircle(point, indicator.calcParam.display.pointRadius, pointPaint);
        }
      }
    }
  }

  /// BOLL 绘制tips区域
  @override
  Size? paintTips(
    Canvas canvas, {
    FlexiCandleModel? model,
    Offset? offset,
    Rect? tipsRect,
  }) {
    model ??= offsetToCandle(offset);
    if (model == null || !model.isValidBollData(dataIndex)) return null;

    final enabledLines = indicator.calcParam.enabledLines;
    if (enabledLines.isEmpty) return null;

    final precision = indicator.calcParam.display.precision;
    final children = <TextSpan>[];

    // 动态构建 tips 文本
    for (final lineType in enabledLines) {
      FlexiNum? value;
      String label;
      Color color;

      switch (lineType) {
        case BOLLLineType.ub:
          value = model.bollUp(dataIndex);
          label = 'UB';
          color = indicator.calcParam.lines.ub.color;
          break;
        case BOLLLineType.boll:
          value = model.bollMb(dataIndex);
          label = 'BOLL';
          color = indicator.calcParam.lines.boll.color;
          break;
        case BOLLLineType.lb:
          value = model.bollDn(dataIndex);
          label = 'LB';
          color = indicator.calcParam.lines.lb.color;
          break;
      }

      if (value != null) {
        // 根据配置决定是否显示周期信息
        final displayLabel =
            indicator.calcParam.display.showPeriodInTips ? '$label(${indicator.calcParam.periods.period})' : label;

        children.add(TextSpan(
          text: formatNumber(
            value.toDecimal(),
            precision: precision,
            cutInvalidZero: true,
            prefix: '$displayLabel: ',
            suffix: ' ',
          ),
          style: TextStyle(color: color),
        ));
      }
    }

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
