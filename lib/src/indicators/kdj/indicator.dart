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

part of 'kdj.dart';

///
/// KDJ 随机震荡指标
/// 当日K值=2/3×前一日K值+1/3×当日RSV
/// 当日D值=2/3×前一日D值+1/3×当日K值
/// 若无前一日K 值与D值，则可分别用50来代替。
/// J值=3*当日K值-2*当日D值
@CopyWith()
class KDJIndicator extends PaintObjectIndicator implements IPrecomputable {
  KDJIndicator({
    super.zIndex = 0,
    required super.height,
    super.padding = defaultSubIndicatorPadding,
    this.calcParam = const KDJParam(),
    required this.tipsPadding,
    this.tickCount = defaultSubTickCount,
  }) : super(key: const FlexiIndicatorKey('kdj'));

  /// KDJ 参数（包含所有配置）
  @override
  final KDJParam calcParam;

  /// Tips 相关参数（仅用于显示）
  final EdgeInsets tipsPadding;
  final int tickCount;

  @override
  PaintObjectBox createPaintObject(IPaintContext context) {
    return KDJPaintObject(context: context, indicator: this);
  }
}

class KDJPaintObject<T extends KDJIndicator> extends PaintObjectBox<T>
    with KdjDataMixin, PaintYAxisTicksMixin, PaintYAxisTicksOnCrossMixin {
  KDJPaintObject({
    required super.context,
    required super.indicator,
  });

  @override
  MinMax? initState(int start, int end) {
    if (!klineData.canPaintChart) return null;

    return calcuKdjMinmax(
      indicator.calcParam,
      start: start,
      end: end,
    );
  }

  @override
  void paintChart(Canvas canvas, Size size) {
    /// 绘制KDJ线
    paintKDJLine(canvas, size);

    /// 绘制Y轴刻度值
    if (settingConfig.showYAxisTick) {
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
  String formatTicksValue(BagNum value, {required int precision}) {
    return formatNumber(
      value.toDecimal(),
      precision: precision,
      cutInvalidZero: false,
    );
  }

  @override
  void onCross(Canvas canvas, Offset offset) {
    /// onCross时, 绘制Y轴上的标记值
    paintYAxisTicksOnCross(
      canvas,
      offset,
      precision: indicator.calcParam.display.precision,
    );
  }

  /// 在onCross时, 重写[paintYAxisTicksOnCross]中的格式化刻度值
  @override
  String formatTicksValueOnCross(BagNum value, {required int precision}) {
    return formatNumber(
      value.toDecimal(),
      precision: precision,
      cutInvalidZero: false,
    );
  }

  void paintKDJLine(Canvas canvas, Size size) {
    if (!klineData.canPaintChart) return;
    final list = klineData.list;
    final len = list.length;
    if (!indicator.calcParam.isValid(len)) return;
    int start = klineData.start;
    int end = (klineData.end + 1).clamp(start, len); // 多绘制一根蜡烛

    final enabledLines = indicator.calcParam.enabledLines;
    if (enabledLines.isEmpty) return;

    final offset = startCandleDx - candleWidthHalf;

    // 分别绘制 K、D、J 线
    for (final lineType in enabledLines) {
      final List<Offset> points = [];
      KDJLineConfig lineConfig;
      
      switch (lineType) {
        case KDJLineType.k:
          lineConfig = indicator.calcParam.lines.k;
          break;
        case KDJLineType.d:
          lineConfig = indicator.calcParam.lines.d;
          break;
        case KDJLineType.j:
          lineConfig = indicator.calcParam.lines.j;
          break;
      }

      // 收集点位
      for (int i = start; i < end; i++) {
        final m = list[i];
        if (!m.isValidKdjData) continue;
        
        BagNum? value;
        switch (lineType) {
          case KDJLineType.k:
            value = m.k;
            break;
          case KDJLineType.d:
            value = m.d;
            break;
          case KDJLineType.j:
            value = m.j;
            break;
        }
        
        if (value != null) {
          final point = Offset(
            offset - (i - start) * candleActualWidth,
            valueToDy(value, correct: false),
          );
          points.add(point);
          
          // 📍 绘制节点（如果配置了 pointRadius > 0）
          if (indicator.calcParam.display.pointRadius > 0) {
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

      // 📈 绘制线条
      if (points.isNotEmpty) {
        canvas.drawPath(
          Path()..addPolygon(points, false),
          Paint()
            ..color = lineConfig.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = lineConfig.width,
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
    if (model == null || !model.isValidKdjData) return null;

    final children = <TextSpan>[];
    final enabledLines = indicator.calcParam.enabledLines;
    final precision = indicator.calcParam.display.precision;
    final showPeriod = indicator.calcParam.display.showPeriodInTips;
    
    for (final lineType in enabledLines) {
      BagNum? value;
      KDJLineConfig lineConfig;
      String label;
      
      switch (lineType) {
        case KDJLineType.k:
          value = model.k;
          lineConfig = indicator.calcParam.lines.k;
          label = showPeriod ? 'K(${indicator.calcParam.calculation.kPeriod})' : 'K';
          break;
        case KDJLineType.d:
          value = model.d;
          lineConfig = indicator.calcParam.lines.d;
          label = showPeriod ? 'D(${indicator.calcParam.calculation.dPeriod})' : 'D';
          break;
        case KDJLineType.j:
          value = model.j;
          lineConfig = indicator.calcParam.lines.j;
          label = showPeriod ? 'J(${indicator.calcParam.calculation.jPeriod})' : 'J';
          break;
      }
      
      if (value != null) {
        final text = formatNumber(
          value.toDecimal(),
          precision: precision,
          cutInvalidZero: true,
          prefix: '$label:',
          suffix: '  ',
        );
        children.add(TextSpan(
          text: text,
          style: TextStyle(color: lineConfig.color),
        ));
      }
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
