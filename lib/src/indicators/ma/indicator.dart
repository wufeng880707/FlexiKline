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

part of 'ma.dart';

/// MA 移动平均指标线
@CopyWith()
class MAIndicator extends DataIndicator implements IPrecomputable {
  MAIndicator({
    super.zIndex = 0,
    required super.height,
    super.padding = defaultMainIndicatorPadding,
    this.calcParam = const MaParam(),
    required this.tipsPadding,
  }) : super(key: const DataIndicatorKey('ma'));

  /// MA 参数（包含所有配置）
  @override
  final MaParam calcParam;
  
  /// Tips 相关参数（仅用于显示）
  final EdgeInsets tipsPadding;

  @override
  DataPaintObject<MAIndicator> createPaintObject() {
    return MAPaintObject();
  }

}

class MAPaintObject<T extends MAIndicator> extends DataPaintObject<T> with MaDataMixin {
  MAPaintObject();

  @override
  MinMax? computeVisibleMinMax(int start, int end) {
    if (!klineData.canPaintChart) return null;

    return calcuMaMinmax(
      indicator.calcParam,
      start: start,
      end: end,
    );
  }

  @override
  void paintChart(Canvas canvas, Size size) {
    paintMALine(canvas, size);
  }

  @override
  void onCross(Canvas canvas, Offset offset) {
    ///
  }

  /// 绘制MA指标线
  void paintMALine(Canvas canvas, Size size) {
    if (!klineData.canPaintChart) return;
    final enabledLines = indicator.calcParam.enabledLines;
    if (enabledLines.isEmpty) return;
    final list = klineData.list;
    int start = klineData.start;
    int end = (klineData.end + 1).clamp(start, list.length); // 多绘制一根蜡烛

    final offset = startCandleDx - candleWidthHalf;
    for (int j = 0; j < enabledLines.length; j++) {
      final lineConfig = enabledLines[j];
      if (lineConfig.period <= 0) continue; // 跳过无效周期
      FlexiNum? val;
      final List<Offset> points = [];
      for (int i = start; i < end; i++) {
        val = list[i].getMaList(dataIndex)?.getItem(j);
        if (val == null) continue;
        final point = Offset(
          offset - (i - start) * candleActualWidth,
          valueToDy(val, correct: false),
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


  /// MA 绘制tips区域
  @override
  Size? paintTips(
    Canvas canvas, {
    FlexiCandleModel? model,
    Offset? offset,
    Rect? tipsRect,
  }) {
    model ??= offsetToCandle(offset);
    if (model == null || !model.isValidMaList(dataIndex)) return null;

    final children = <TextSpan>[];
    final enabledLines = indicator.calcParam.enabledLines;
    final maList = model.getMaList(dataIndex)!;
    
    for (int i = 0; i < enabledLines.length && i < maList.length; i++) {
      final lineConfig = enabledLines[i];
      if (lineConfig.period <= 0) continue; // 跳过无效周期
      
      final val = maList.getItem(i);
      if (val == null) continue;

      // 📊 根据配置决定显示内容
      final displayPeriod = indicator.calcParam.display.showPeriodInTips;
      final prefix = displayPeriod ? 'MA${lineConfig.period}:' : 'MA:';
      
      final text = formatNumber(
        val.toDecimal(),
        precision: indicator.calcParam.display.precision,
        cutInvalidZero: true,
        prefix: prefix,
        suffix: '  ',
      );
      children.add(TextSpan(
        text: text,
        style: TextStyle(color: lineConfig.color),
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
