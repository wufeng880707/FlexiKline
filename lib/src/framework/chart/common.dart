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

part of 'indicator.dart';

/// K线图绘制类型
sealed class ChartType {
  const ChartType();

  /// 全实心蜡烛图
  static const barSolid = BarChartType(ChartBarStyle.allSolid);

  /// 全空心蜡烛图
  static const barHollow = BarChartType(ChartBarStyle.allHollow);

  /// 上涨空心蜡烛图
  static const barUpHollow = BarChartType(ChartBarStyle.upHollow);

  /// 下跌空心蜡烛图
  static const barDownHollow = BarChartType(ChartBarStyle.downHollow);

  /// OHLC美国线
  static const barOhlc = BarChartType(ChartBarStyle.ohlc);

  /// 普通折线图
  static const lineNormal = LineChartType(LineChartStyle.normal);

  /// 涨跌线图
  static const lineUpDown = LineChartType(LineChartStyle.upDown);

  /// 创建蜡烛图类型
  ///
  /// [style] 蜡烛图样式，默认为 [ChartBarStyle.allSolid]
  factory ChartType.bar([ChartBarStyle style = ChartBarStyle.allSolid]) {
    return BarChartType(style);
  }

  /// 创建线图类型
  ///
  /// [style] 线图样式，默认为 [LineChartStyle.normal]
  factory ChartType.line([LineChartStyle style = LineChartStyle.normal]) {
    return LineChartType(style);
  }

  /// 是否为线图类型
  bool get isLine => this is LineChartType;

  /// 是否为蜡烛图类型
  bool get isBar => this is BarChartType;
}

/// 蜡烛图类型，包含蜡烛图样式
final class BarChartType extends ChartType {
  const BarChartType(this.style);

  final ChartBarStyle style;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BarChartType && style == other.style;

  @override
  int get hashCode => style.hashCode;
}

/// 线图类型，包含线图样式
final class LineChartType extends ChartType {
  const LineChartType(this.style);

  final LineChartStyle style;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LineChartType && style == other.style;

  @override
  int get hashCode => style.hashCode;
}

/// K线柱状图的绘制样式
enum ChartBarStyle {
  allSolid, // 全实心
  allHollow, // 全空心
  upHollow, // 上涨空心
  downHollow, // 下跌空心
  ohlc; // Open-high-low-close chart(美国线)

  bool get isHollowUp => this == upHollow || this == allHollow;

  bool get isHollowDown => this == downHollow || this == allHollow;
}

/// K线线图的绘制样式
enum LineChartStyle {
  normal, // 普通折线
  upDown; // 涨跌线
}

/// Indicator绘制模式
///
/// 注: PaintMode仅当Indicator加入MultiPaintObjectIndicator后起作用,
/// 代表当前Indicator的绘制是否是独立绘制的, 还是依赖于MultiPaintObjectIndicator
enum PaintMode {
  /// 组合模式, Indicator会联合其他子Indicator一起绘制, 坐标系共享.
  combine,

  /// 独立模式下, Indicator会按自己height和minmax独立绘制.
  alone;

  bool get isCombine => this == PaintMode.combine;
}

/// 绘制位置
///
/// 主要是指定TimeIndicator的绘制位置
enum DrawPosition {
  // top, // 不支持
  middle,
  bottom,
}

/// 缩放位置
///
/// 将绘制区域宽度三等分, [auto] 会根据当前缩放开始时的焦点位置, 自行决定缩放位置.
enum ScalePosition {
  auto,
  left,
  middle,
  right,
}

abstract interface class IIndicatorKey {
  String get id;
  String get label;
}

final class FlexiIndicatorKey implements IIndicatorKey {
  const FlexiIndicatorKey(
    this.id, {
    String? label,
  }) : label = label ?? id;

  @override
  final String id;

  @override
  final String label;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FlexiIndicatorKey && runtimeType == other.runtimeType && id == other.id;
  }

  @override
  int get hashCode {
    return runtimeType.hashCode ^ id.hashCode;
  }

  @override
  String toString() {
    return '$id:$label';
  }
}

const unknownIndicatorKey = FlexiIndicatorKey('unknown');

typedef IndicatorBuilder<T extends Indicator> = T Function(
  Map<String, dynamic>?,
);

const mainIndicatorKey = FlexiIndicatorKey('main', label: 'Main');
const candleIndicatorKey = FlexiIndicatorKey('candle', label: 'Candle');
const timeIndicatorKey = FlexiIndicatorKey('time', label: 'Time');

/// 可预计算接口
/// 实现 [IPrecomputable] 接口, 即代表当前对象是可以进行预计算.
abstract interface class IPrecomputable {
  dynamic get calcParam;
}

const mainIndicatorSlot = -1;

/// 指标图的绘制边界接口
abstract interface class IPaintBoundingBox {
  void resetPaintBounding({int? slot});

  /// 当前指标图画笔可以绘制的范围
  Rect get drawableRect;

  /// 当前指标图绘制区域
  Rect get chartRect;

  /// 当前指标图顶部绘制区域
  Rect get topRect;

  /// 当前指标图底部绘制区域
  Rect get bottomRect;
}

/// 指标图的绘制数据初始化接口
abstract interface class IPaintDataInit {
  /// 最大值/最小值
  MinMax get minMax;

  /// 数据预计算
  /// 1. 仅在数据源[KlineData]发生变化时回调.
  void precompute(Range range, {bool reset = false});

  void setMinMax(MinMax val);
}

/// 指标图的绘制接口/指标图的Cross事件绘制接口
abstract interface class IPaintObject {
  /// 计算指标需要的数据, 并返回 [start ~ end) 之间MinMax.
  MinMax? initState(int start, int end);

  /// 绘制指标图
  void paintChart(Canvas canvas, Size size);

  /// 在所有指标图绘制结束后额外的绘制
  void paintExtraAboveChart(Canvas canvas, Size size);

  /// 绘制Cross上的刻度值
  void onCross(Canvas canvas, Offset offset);

  /// 绘制顶部tips信息
  Size? paintTips(
    Canvas canvas, {
    CandleModel? model,
    Offset? offset,
    Rect? tipsRect,
  });
}
