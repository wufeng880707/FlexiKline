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

part of 'volume.dart';

@CopyWith()
class VolumeIndicator extends DataIndicator {
  VolumeIndicator({
    super.zIndex = 0,
    required super.height,
    super.padding = defaultMainIndicatorPadding,
    required this.calcParam,
    required this.tipsPadding,
    this.tickCount = defaultSubTickCount,
  }) : super(key: const DataIndicatorKey('volume'), paintMode: PaintMode.alone);

  @override
  final VolumeParam calcParam;
  final EdgeInsets tipsPadding;
  final int tickCount;

  dynamic getCalcParam() => calcParam;

  /// 控制参数(Volume可用于主图和副图, 以下开关控制在主/副图的展示效果)
  // final bool showYAxisTick;
  // final bool showCrossMark;
  // final bool showTips;
  // final bool useTint;

  @override
  DataPaintObject<VolumeIndicator> createPaintObject() {
    return VolumePaintObject();
  }

}

class VolumePaintObject<T extends VolumeIndicator> extends DataPaintObject<T>
    with VolumeDataMixin<T>, PaintYAxisTicksMixin, PaintYAxisTicksOnCrossMixin {
  VolumePaintObject();

  @override
  MinMax? computeVisibleMinMax(int start, int end) {
    if (!klineData.canPaintChart) return null;

    final minmax = calculateVolMinmax(
      start: start,
      end: end,
    );
    minmax?.minToZero();
    return minmax;
  }

  @override
  void paintChart(Canvas canvas, Size size) {
    /// 绘制Volume柱状图
    paintVolumeChart(canvas, size);

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
  String formatTicksValue(FlexiNum value, {required int precision}) {
    return formatNumber(
      value.toDecimal(),
      precision: precision,
      cutInvalidZero: true,
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
  String formatTicksValueOnCross(FlexiNum value, {required int precision}) {
    return formatNumber(
      value.toDecimal(),
      precision: precision,
      cutInvalidZero: true,
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
      ..color = volumeConfig.useTrendColor 
          ? volumeConfig.bullishColorWithOpacity 
          : longColor.withValues(alpha: volumeConfig.opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = barWidth;

    final bearishPaint = Paint()
      ..color = volumeConfig.useTrendColor 
          ? volumeConfig.bearishColorWithOpacity 
          : shortColor.withValues(alpha: volumeConfig.opacity)
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

  /// 绘制tips区域信息
  /// 1. 正常展示最新一根蜡烛交易量
  /// 2. 当Cross时, 展示命中的蜡烛交易量
  @override
  Size? paintTips(
    Canvas canvas, {
    FlexiCandleModel? model,
    Offset? offset,
    Rect? tipsRect,
  }) {
    model ??= offsetToCandle(offset);
    if (model == null) return null;
    final param = indicator.calcParam;

    // 如果不显示成交量在Tips中，返回null
    if (!param.display.showVolInTips) return null;

    final text = formatNumber(
      model.vol.toDecimal(),
      precision: param.display.precision,
      cutInvalidZero: true,
      prefix: 'VOL: ',
    );

    tipsRect ??= drawableRect;
    return canvas.drawText(
      offset: tipsRect.topLeft,
      text: text,
      style: TextStyle(color: theme.textColor, fontSize: 12),
      drawDirection: DrawDirection.ltr,
      drawableRect: tipsRect,
      textAlign: TextAlign.left,
      padding: indicator.tipsPadding,
      maxLines: 1,
    );
  }
}
