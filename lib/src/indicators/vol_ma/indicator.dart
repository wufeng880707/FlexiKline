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

part of 'vol_ma.dart';

/// VolMa 移动平均指标线
@CopyWith()
class VolMaIndicator extends ComputedIndicator {
  VolMaIndicator({
    super.zIndex = 0,
    super.height = defaultSubIndicatorHeight,
    super.padding = defaultSubIndicatorPadding,
    required this.calcParam,
    required this.tipsPadding,
    this.ticksCount = defaultSubTickCount,
  }) : super(key: const ComputedIndicatorKey('volMa'));

  @override
  final VolMaParam calcParam;
  final EdgeInsets tipsPadding;
  final int ticksCount;

  dynamic getCalcParam() => calcParam;

  @override
  ComputedPaintObject<VolMaIndicator> createPaintObject() {
    return VolMaPaintObject();
  }
}

class VolMaPaintObject<T extends VolMaIndicator> extends ComputedPaintObject<T>
    with VolmaDataMixin, PaintYAxisTicksMixin, PaintYAxisTicksOnCrossMixin {
  VolMaPaintObject();

  @override
  MinMax? computeVisibleMinMax(int start, int end) {
    if (!klineData.canPaintChart) return null;

    final volMinmax = calculateVolMinmax(
      start: start,
      end: end,
    );

    final maMinmax = calcuVolMaMinmax(
      indicator.calcParam,
      start: start,
      end: end,
    );

    if (volMinmax != null) {
      return volMinmax..updateMinMax(maMinmax);
    } else if (maMinmax != null) {
      return maMinmax..updateMinMax(volMinmax);
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    /// 绘制Volume柱状图
    paintVolumeChart(canvas, size);

    /// 绘制VOLMA指标线
    paintVolMALine(canvas, size);

    if (settingConfig.showYAxisTick) {
      /// 绘制Y轴刻度值
      paintYAxisTicks(
        canvas,
        size,
        tickCount: indicator.ticksCount,
        precision: indicator.calcParam.display.precision,
      );
    }
  }

  @override
  void paintCross(Canvas canvas, Offset offset, {FlexiCandleModel? model}) {
    /// onCross时, 绘制Y轴上的标记值
    paintYAxisTicksOnCross(
      canvas,
      offset,
      precision: indicator.calcParam.display.precision,
    );
  }

  /// 绘制Volume柱状图
  void paintVolumeChart(Canvas canvas, Size size) {
    if (!klineData.canPaintChart) return;
    final list = klineData.list;
    int start = klineData.start;
    int end = klineData.end;

    final offset = startCandleDx - candleWidthHalf;
    final dyBottom = chartRect.bottom;
    final volumeConfig = indicator.calcParam.volume;

    // 使用和K线图相同的宽度
    final barWidth = candleWidth;

    // 绘制成交量柱
    final bullishPaint = Paint()
      ..color = (volumeConfig.useTrendColor
          ? volumeConfig.bullishColorWithOpacity
          : longColor.withValues(alpha: volumeConfig.opacity))
      ..style = PaintingStyle.stroke
      ..strokeWidth = barWidth;

    final bearishPaint = Paint()
      ..color = (volumeConfig.useTrendColor
          ? volumeConfig.bearishColorWithOpacity
          : shortColor.withValues(alpha: volumeConfig.opacity))
      ..style = PaintingStyle.stroke
      ..strokeWidth = barWidth;

    for (var i = start; i < end; i++) {
      final model = list[i];
      final dx = offset - (i - start) * candleActualWidth;
      final dy = valueToDy(model.vol);
      final isLong = model.close >= model.open;

      // 绘制成交量柱
      canvas.drawLine(
        Offset(dx, dy),
        Offset(dx, dyBottom),
        isLong ? bullishPaint : bearishPaint,
      );
    }
  }

  /// 绘制VOLMA指标线
  void paintVolMALine(Canvas canvas, Size size) {
    if (!klineData.canPaintChart) return;
    final enabledLines = indicator.calcParam.enabledLines;
    if (enabledLines.isEmpty) return;
    final list = klineData.list;
    int start = klineData.start;
    int end = (klineData.end + 1).clamp(start, list.length); // 多绘制一根蜡烛

    final offset = startCandleDx - candleWidthHalf;
    for (int j = 0; j < enabledLines.length; j++) {
      final lineConfig = enabledLines[j];
      FlexiNum? val;
      final List<Offset> points = [];
      for (int i = start; i < end; i++) {
        val = list[i].getVolMaList(dataIndex)?.getItem(j);
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
            ..color = lineConfig.colorWithOpacity
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
                ..color = lineConfig.colorWithOpacity
                ..style = PaintingStyle.fill,
            );
          }
        }
      }
    }
  }

  /// VOLMA 绘制tips区域
  @override
  Size? paintTips(
    Canvas canvas, {
    FlexiCandleModel? model,
    Offset? offset,
    Rect? tipsRect,
  }) {
    model ??= offsetToCandle(offset);
    if (model == null) return null;
    final children = <TextSpan>[];
    final param = indicator.calcParam;
    final precision = param.display.precision;

    /// Vol Tips文本（如果启用）
    if (param.display.showVolInTips) {
      final text = formatNumber(
        model.vol.toDecimal(),
        precision: precision,
        cutInvalidZero: true,
        prefix: 'VOL: ',
        suffix: '  ',
      );
      children.add(TextSpan(
        text: text,
        style: TextStyle(color: theme.textColor, fontSize: 12),
      ));
    }

    final volMaList = model.getVolMaList(dataIndex);
    if (volMaList != null) {
      final enabledLines = param.enabledLines;

      /// Ma Tips文本
      FlexiNum? val;
      for (int i = 0; i < volMaList.length && i < enabledLines.length; i++) {
        val = volMaList.getItem(i);
        if (val == null) continue;
        final lineConfig = enabledLines[i];

        String label = 'MAVOL';
        if (param.display.showPeriodInTips) {
          label = 'MAVOL${lineConfig.period}';
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
    }

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
