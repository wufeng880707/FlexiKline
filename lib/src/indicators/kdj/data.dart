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

@visibleForTesting
extension CandleKdjExt on FlexiCandleModel {
  List<FlexiNum?>? kdjList(int dataIndex) => getList<FlexiNum>(dataIndex);

  FlexiNum? kdjK(int dataIndex) {
    final list = kdjList(dataIndex);
    if (list != null && list.length >= 3) return list[0];
    return null;
  }

  FlexiNum? kdjD(int dataIndex) {
    final list = kdjList(dataIndex);
    if (list != null && list.length >= 3) return list[1];
    return null;
  }

  FlexiNum? kdjJ(int dataIndex) {
    final list = kdjList(dataIndex);
    if (list != null && list.length >= 3) return list[2];
    return null;
  }

  bool isValidKdjData(int dataIndex) => kdjK(dataIndex) != null && kdjD(dataIndex) != null && kdjJ(dataIndex) != null;

  MinMax? kdjMinmax(int dataIndex) {
    if (!isValidKdjData(dataIndex)) return null;
    return MinMax(max: kdjK(dataIndex)!, min: kdjK(dataIndex)!)
      ..updateMinMaxBy(kdjD(dataIndex)!)
      ..updateMinMaxBy(kdjJ(dataIndex)!);
  }
}

mixin KdjDataMixin<T extends KDJIndicator> on IndicatorCalculationScope<T> {
  KDJParam get calcParam => indicator.calcParam;

  void computeIndicatorData(Range range, {bool reset = false}) {
    calcuAndCacheKdj(
      calcParam,
      start: range.start,
      end: range.end,
      reset: reset,
    );
  }

  /// 计算KDJ指标值
  ///
  /// 窗口 high/low 使用单调双端队列（O(N)）代替每根蜡烛的 O(kPeriod) 重扫。
  /// 队列元素为 [index, value]：maxQueue 维护窗口内递减的 high 候选，
  /// minQueue 维护窗口内递增的 low 候选；窗口 [i, i+kPeriod) 向新端滑动。
  void _calculateKdj(
    KDJParam param, {
    required int start,
    required int end,
  }) {
    final list = klineData.list;
    final len = list.length;
    final kPeriod = param.calculation.kPeriod;
    if (kPeriod > len || !klineData.checkStartAndEnd(start, end)) return;
    logd('calculateKdj [end:$end ~ start:$start] kPeriod:$kPeriod');

    end = math.min(len - kPeriod, end - 1);
    if (end < start) return;

    // 常量外提：避免循环内重复装箱。
    final fifty = FlexiNum.fromNum(50);
    final hundred = FlexiNum.fromNum(100);
    final dDiv = FlexiNum.fromNum(param.calculation.dPeriod);
    final dMinus1 = FlexiNum.fromNum(param.calculation.dPeriod - 1);
    final jDiv = FlexiNum.fromNum(param.calculation.jPeriod);
    final jMinus1 = FlexiNum.fromNum(param.calculation.jPeriod - 1);
    final three = FlexiNum.fromNum(3);
    final two = FlexiNum.fromNum(2);

    // 增量窗口 high/low：窗口 [i, i+kPeriod) 与上一窗口只差两端各一个元素。
    // 仅当被移出端元素恰为当前极值时才重扫窗口（平均 O(1)，最坏 O(kPeriod)）。
    FlexiNum high = list[end].high;
    FlexiNum low = list[end].low;
    for (int j = end + 1; j < end + kPeriod; j++) {
      final candle = list[j];
      if (candle.high > high) high = candle.high;
      if (candle.low < low) low = candle.low;
    }

    for (int i = end; i >= start; i--) {
      final m = list[i];

      if (i != end) {
        // 滑动到 [i, i+kPeriod)：新进 i，移出 i+kPeriod。
        final entered = list[i];
        if (entered.high > high) high = entered.high;
        if (entered.low < low) low = entered.low;

        final left = list[i + kPeriod];
        if (left.high == high || left.low == low) {
          // 被移出的元素是极值，窗口极值失效，重扫。
          high = entered.high;
          low = entered.low;
          for (int j = i + 1; j < i + kPeriod; j++) {
            final candle = list[j];
            if (candle.high > high) high = candle.high;
            if (candle.low < low) low = candle.low;
          }
        }
      }

      final rsv = high == low ? fifty : ((m.close - low) / (high - low)) * hundred;

      // 计算K值
      FlexiNum k;
      if (i < len - 1) {
        final prevK = list[i + 1].kdjK(dataIndex) ?? fifty;
        k = (prevK * dMinus1 + rsv) / dDiv;
      } else {
        k = rsv;
      }

      // 计算D值
      FlexiNum d;
      if (i < len - 1) {
        final prevD = list[i + 1].kdjD(dataIndex) ?? fifty;
        d = (prevD * jMinus1 + k) / jDiv;
      } else {
        d = k;
      }

      // 计算J值
      final j = k * three - d * two;

      // 设置KDJ值
      final kdjSlot = m.getOrInitList<FlexiNum>(dataIndex, 3);
      kdjSlot[0] = k;
      kdjSlot[1] = d;
      kdjSlot[2] = j;
    }
  }

  void calcuAndCacheKdj(
    KDJParam calcParam, {
    required int start,
    required int end,
    bool reset = false,
  }) {
    if (klineData.isEmpty) return;
    _calculateKdj(
      calcParam,
      start: math.max(0, start - calcParam.calculation.kPeriod), // 补起上一次未算数据
      end: end,
    );
  }

  /// 计算并缓存KDJ数据.
  /// 如果[start]和[end]指定了, 只计算[start] ~ [end]区间内的KDJ值.
  /// 否则, 从当前可视区域的[start] ~ [end]开始计算.
  MinMax? calcuKdjMinmax(
    KDJParam param, {
    int? start,
    int? end,
  }) {
    start ??= klineData.start;
    end ??= klineData.end;
    if (!klineData.checkStartAndEnd(start, end)) {
      return null;
    }

    final len = klineData.list.length;
    final kPeriod = param.calculation.kPeriod;
    end = math.min(len - kPeriod, end - 1);

    if (!klineData.list[end].isValidKdjData(dataIndex)) {
      calcuAndCacheKdj(param, start: 0, end: len);
    }

    MinMax? minmax;
    FlexiCandleModel m;
    for (int i = end; i >= start; i--) {
      m = klineData.list[i];
      if (m.isValidKdjData(dataIndex)) {
        minmax ??= m.kdjMinmax(dataIndex);
        minmax?.updateMinMax(m.kdjMinmax(dataIndex));
      }
    }
    return minmax;
  }
}
