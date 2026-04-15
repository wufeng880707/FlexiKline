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

import 'package:flexi_kline/flexi_kline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final klineStateProvider =
    ChangeNotifierProvider.autoDispose.family<KlineStateNotifier, FlexiKlineController>(
  (ref, controller) => KlineStateNotifier(ref, controller),
  name: 'klineState',
);

class KlineStateNotifier extends ChangeNotifier {
  KlineStateNotifier(
    this.ref,
    this.controller,
  ) : super();

  final Ref ref;
  final FlexiKlineController controller;

  Set<IIndicatorKey> get supportMainIndicatorKeys => 
      controller.supportMainIndicatorKeys.where((key) => key != tradeMarkIndicatorKey).toSet();
  Set<IIndicatorKey> get supportSubIndicatorKeys => controller.supportSubIndicatorKeys.toSet();
  Set<IIndicatorKey> get mainIndicatorKeys => 
      controller.mainIndicatorKeys.where((key) => key != tradeMarkIndicatorKey).toSet();
  Set<IIndicatorKey> get subIndicatorKeys => controller.subIndicatorKeys.toSet();

  void onTapMainIndicator(IIndicatorKey key) {
    if (controller.mainIndicatorKeys.contains(key)) {
      controller.removeMainIndicator(key);
    } else {
      controller.addMainIndicator(key);
    }
    notifyListeners();
  }

  void onTapSubIndicator(IIndicatorKey key) {
    if (controller.subIndicatorKeys.contains(key)) {
      controller.removeSubIndicator(key);
    } else {
      controller.addSubIndicator(key);
    }
    notifyListeners();
  }

  /// 蜡烛图中是否展示最新价 - 使用直接访问方式
  bool get isShowLatestPrice {
    try {
      // 通过开放的candlePaintObject直接访问CandleIndicator，需要类型转换
      final candleIndicator = controller.getCandleIndicator<CandleIndicator>();
      return candleIndicator.latest.show;
    } catch (e) {
      return true;
    }
  }

  /// 设置蜡烛图中是否展示最新价 - 使用直接访问方式
  void setShowLatestPrice(bool isShow) {
    try {
      // 通过开放的candlePaintObject直接访问和修改CandleIndicator，需要类型转换
      final candleIndicator = controller.getCandleIndicator<CandleIndicator>();
      final updatedIndicator = candleIndicator.copyWith(
        latest: candleIndicator.latest.copyWith(show: isShow),
      );
      // 使用controller的updateIndicator方法更新
      controller.updateIndicator(updatedIndicator);
    } catch (e) {
      // 如果设置失败，忽略错误
    }
    notifyListeners();
  }

  /// 蜡烛图中是否展示倒计时 - 使用直接访问方式
  bool get isShowCountDown {
    try {
      // 通过开放的candlePaintObject直接访问CandleIndicator，需要类型转换
      final candleIndicator = controller.getCandleIndicator<CandleIndicator>();
      return candleIndicator.showCountDown;
    } catch (e) {
      return true;
    }
  }

  /// 设置蜡烛图中是否展示倒计时 - 使用直接访问方式
  void setShowCountDown(bool isShow) {
    try {
      // 通过开放的candlePaintObject直接访问和修改CandleIndicator，需要类型转换
      final candleIndicator = controller.getCandleIndicator<CandleIndicator>();
      final updatedIndicator = candleIndicator.copyWith(showCountDown: isShow);
      // 使用controller的updateIndicator方法更新
      controller.updateIndicator(updatedIndicator);
    } catch (e) {
      // 如果设置失败，忽略错误
    }
    notifyListeners();
  }

  /// 是否展示蜡烛图最高价 - 使用直接访问方式
  bool get isShowCandleHighPrice {
    try {
      // 通过开放的candlePaintObject直接访问CandleIndicator，需要类型转换
      final candleIndicator = controller.getCandleIndicator<CandleIndicator>();
      return candleIndicator.high.show;
    } catch (e) {
      return true;
    }
  }

  void setShowCandleHighPrice(bool isShow) {
    try {
      // 通过开放的candlePaintObject直接访问和修改CandleIndicator，需要类型转换
      final candleIndicator = controller.getCandleIndicator<CandleIndicator>();
      final updatedIndicator = candleIndicator.copyWith(
        high: candleIndicator.high.copyWith(show: isShow),
      );
      // 使用controller的updateIndicator方法更新
      controller.updateIndicator(updatedIndicator);
    } catch (e) {
      // 如果设置失败，忽略错误
    }
    notifyListeners();
  }

  /// 是否展示蜡烛图最低价 - 使用直接访问方式
  bool get isShowCandleLowPrice {
    try {
      // 通过开放的candlePaintObject直接访问CandleIndicator，需要类型转换
      final candleIndicator = controller.getCandleIndicator<CandleIndicator>();
      return candleIndicator.low.show;
    } catch (e) {
      return true;
    }
  }

  void setShowCandleLowPrice(bool isShow) {
    try {
      // 通过开放的candlePaintObject直接访问和修改CandleIndicator，需要类型转换
      final candleIndicator = controller.getCandleIndicator<CandleIndicator>();
      final updatedIndicator = candleIndicator.copyWith(
        low: candleIndicator.low.copyWith(show: isShow),
      );
      // 使用controller的updateIndicator方法更新
      controller.updateIndicator(updatedIndicator);
    } catch (e) {
      // 如果设置失败，忽略错误
    }
    notifyListeners();
  }

  /// 是否展示Y轴刻度
  bool get isShowYAxisTick {
    return controller.settingConfig.showYAxisTick;
  }

  /// 设置是否展示Y轴坐标刻度
  void setShowYAxisTick(bool isShow) {
    if (isShow == isShowYAxisTick) return;
    controller.settingConfig = controller.settingConfig.copyWith(
      showYAxisTick: isShow,
    );
    notifyListeners();
  }

  /// 是否展示买卖标记
  bool get isShowTradeMark {
    try {
      final tradeMarkIndicator = controller.getIndicator<TradeMarkIndicator>(tradeMarkIndicatorKey);
      return tradeMarkIndicator?.calcParam.show ?? false;
    } catch (e) {
      return false;
    }
  }

  /// 设置是否展示买卖标记
  void setShowTradeMark(bool isShow) {
    if (isShow == isShowTradeMark) return;

    final indicator = controller.getIndicator<TradeMarkIndicator>(
      tradeMarkIndicatorKey,
    );
    if (indicator != null) {
      final updated = indicator.copyWith(
        calcParam: indicator.calcParam.copyWith(show: isShow),
      );
      controller.updateIndicator(updated);
      notifyListeners();
    }
  }

  /// K线图样式（蜡烛柱样式）
  ChartBarStyle get chartBarStyle {
    try {
      final candle = controller.getCandleIndicator<CandleIndicator>();
      if (candle.chartType is FlexiBarChartType) {
        return (candle.chartType as FlexiBarChartType).style;
      }
      return ChartBarStyle.allSolid;
    } catch (_) {
      return ChartBarStyle.allSolid;
    }
  }

  void setChartBarStyle(ChartBarStyle style) {
    try {
      final candle = controller.getCandleIndicator<CandleIndicator>();
      final updated = candle.copyWith(
        chartType: FlexiChartType.bar(style),
      );
      controller.updateIndicator(updated);
      notifyListeners();
    } catch (_) {}
  }

  /// K线图类型（柱状图/线图/涨跌图）
  FlexiChartType get chartType {
    try {
      return controller.getCandleIndicator<CandleIndicator>().chartType;
    } catch (_) {
      return FlexiChartType.barSolid;
    }
  }

  void setChartType(FlexiChartType type) {
    try {
      final candle = controller.getCandleIndicator<CandleIndicator>();
      final updated = candle.copyWith(chartType: type);
      controller.updateIndicator(updated);
      notifyListeners();
    } catch (_) {}
  }

  /// 缩放至最小图表类型
  FlexiLineChartType? get minWidthLineType {
    try {
      return controller.getCandleIndicator<CandleIndicator>().minWidthLineType;
    } catch (_) {
      return null;
    }
  }

  void setMinWidthLineType(FlexiLineChartType? type) {
    try {
      final candle = controller.getCandleIndicator<CandleIndicator>();
      final updated = candle.copyWith(minWidthLineType: type);
      controller.updateIndicator(updated);
      notifyListeners();
    } catch (_) {}
  }

  /// 看涨颜色
  Color get longColor => controller.configuration.theme.long;

  /// 看跌颜色
  Color get shortColor => controller.configuration.theme.short;

  /// 缩放位置
  ScalePosition get scalePosition {
    return controller.gestureConfig.scalePosition;
  }

  void setScalePosition(ScalePosition position) {
    if (position == scalePosition) return;
    controller.gestureConfig = controller.gestureConfig.copyWith(
      scalePosition: position,
    );
    notifyListeners();
  }

  /// 是否支持长按操作
  bool get supportLongPress {
    return controller.gestureConfig.enableLongPress;
  }

  void setSupportLongPress(bool isSupport) {
    if (isSupport == supportLongPress) return;
    controller.gestureConfig = controller.gestureConfig.copyWith(
      enableLongPress: isSupport,
    );
    notifyListeners();
  }

  /// 惯性平移
  // 容忍参数
  String get toleranceDesc {
    final enable = controller.gestureConfig.enableInertialPan;
    if (enable) {
      final config = controller.gestureConfig.tolerance;
      return '${config.maxDuration} - ${config.distanceFactor} - ${config.curvestr}';
    }
    return '';
  }

  ToleranceConfig get tolerance {
    return controller.gestureConfig.tolerance;
  }

  bool get isInertialPan {
    return controller.gestureConfig.enableInertialPan;
  }

  void setInertialPan(
    bool isEnable, {
    int? maxDuration,
    double? distanceFactor,
  }) {
    if (isEnable) {
      if (isEnable != isInertialPan ||
          maxDuration != controller.gestureConfig.tolerance.maxDuration ||
          distanceFactor != controller.gestureConfig.tolerance.distanceFactor) {
        controller.gestureConfig = controller.gestureConfig.copyWith(
          enableInertialPan: isEnable,
          tolerance: controller.gestureConfig.tolerance.copyWith(
            maxDuration: maxDuration ?? controller.gestureConfig.tolerance.maxDuration,
            distanceFactor: distanceFactor ?? controller.gestureConfig.tolerance.distanceFactor,
          ),
        );
        notifyListeners();
      }
    } else if (isEnable != isInertialPan) {
      controller.gestureConfig = controller.gestureConfig.copyWith(
        enableInertialPan: isEnable,
      );
      notifyListeners();
    }
  }
}
