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

mixin KdjDataMixin<T extends KDJIndicator> on ComputedPaintObject<T> {
  KDJParam get calcParam => indicator.calcParam;

  @override
  void compute(Range range, {bool reset = false}) {
    calcuAndCacheKdj(
      calcParam,
      start: range.start,
      end: range.end,
      reset: reset,
    );
  }

  /// 计算KDJ指标值
  void _calculateKdj(
    KDJParam param, {
    required int start,
    required int end,
  }) {
    final len = klineData.list.length;
    final kPeriod = param.calculation.kPeriod;
    if (kPeriod > len || !klineData.checkStartAndEnd(start, end)) return;
    print('calculateKdj [end:$end ~ start:$start] kPeriod:$kPeriod');

    end = math.min(len - kPeriod, end - 1);

    for (int i = end; i >= start; i--) {
      final m = klineData.list[i];
      if (i + kPeriod > len) continue;

      // 计算RSV
      FlexiNum high = m.high;
      FlexiNum low = m.low;
      for (int j = i + 1; j < i + kPeriod; j++) {
        final candle = klineData.list[j];
        if (candle.high > high) high = candle.high;
        if (candle.low < low) low = candle.low;
      }

      final rsv = high == low ? FlexiNum.fromNum(50) : ((m.close - low) / (high - low)) * FlexiNum.fromNum(100);

      // 计算K值
      FlexiNum k = FlexiNum.fromNum(50);
      if (i < len - 1) {
        final prevK = klineData.list[i + 1].kdjK(dataIndex) ?? FlexiNum.fromNum(50);
        k = (prevK * FlexiNum.fromNum(param.calculation.dPeriod - 1) + rsv) /
            FlexiNum.fromNum(param.calculation.dPeriod);
      } else {
        k = rsv;
      }

      // 计算D值
      FlexiNum d = FlexiNum.fromNum(50);
      if (i < len - 1) {
        final prevD = klineData.list[i + 1].kdjD(dataIndex) ?? FlexiNum.fromNum(50);
        d = (prevD * FlexiNum.fromNum(param.calculation.jPeriod - 1) + k) / FlexiNum.fromNum(param.calculation.jPeriod);
      } else {
        d = k;
      }

      // 计算J值
      final j = k * FlexiNum.fromNum(3) - d * FlexiNum.fromNum(2);

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
