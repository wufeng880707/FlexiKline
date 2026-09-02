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

@visibleForTesting
extension CandleBollExt on FlexiCandleModel {
  List<FlexiNum?>? bollList(int dataIndex) => getList<FlexiNum>(dataIndex);

  FlexiNum? bollMb(int dataIndex) {
    final list = bollList(dataIndex);
    if (list != null && list.length >= 3) return list[0];
    return null;
  }

  FlexiNum? bollUp(int dataIndex) {
    final list = bollList(dataIndex);
    if (list != null && list.length >= 3) return list[1];
    return null;
  }

  FlexiNum? bollDn(int dataIndex) {
    final list = bollList(dataIndex);
    if (list != null && list.length >= 3) return list[2];
    return null;
  }

  bool isValidBollData(int dataIndex) =>
      bollMb(dataIndex) != null && bollUp(dataIndex) != null && bollDn(dataIndex) != null;

  MinMax? bollMinmax(int dataIndex) {
    if (!isValidBollData(dataIndex)) return null;
    return MinMax(max: bollMb(dataIndex)!, min: bollMb(dataIndex)!)
      ..updateMinMaxBy(bollUp(dataIndex)!)
      ..updateMinMaxBy(bollDn(dataIndex)!);
  }
}

mixin BollDataMixin<T extends BOLLIndicator> on IndicatorCalculationScope<T> {
  BOLLParam get calcParam => indicator.calcParam;

  void computeIndicatorData(Range range, {bool reset = false}) {
    calcuAndCacheBoll(
      calcParam,
      start: range.start,
      end: range.end,
      reset: reset,
    );
  }

  /// 计算BOLL指标值
  ///
  /// 使用滚动和/滚动平方和：`sum(i-1) = sum(i) - close(i-1+period) + close(i-1)`，
  /// 标准差用 `sqrt((sumSq - n*ma²)/n)`，将每根 O(period) 的重求和降为 O(1)。
  /// 该式在浮点下的舍入与逐项求和略有差异（<1e-9 量级），对显示精度无影响。
  void _calculateBoll(
    BOLLParam param, {
    required int start,
    required int end,
  }) {
    final len = klineData.list.length;
    final period = param.periods.period;
    if (period > len || !klineData.checkStartAndEnd(start, end)) return;
    logd('calculateBoll [end:$end ~ start:$start] period:$period');

    end = math.min(len - period, end - 1);
    if (end < start) return;

    // 初始化 [end, end+period) 窗口的和与平方和。
    final double initSum;
    final double initSumSq;
    {
      double s = 0;
      double sq = 0;
      for (int j = end; j < end + period; j++) {
        final c = klineData.list[j].close.toDouble();
        s += c;
        sq += c * c;
      }
      initSum = s;
      initSumSq = sq;
    }

    double sum = initSum;
    double sumSq = initSumSq;
    final double n = period.toDouble();
    for (int i = end; i >= start; i--) {
      final m = klineData.list[i];
      if (i != end) {
        // 滚动：移出 close(i+period)，加入 close(i)。
        final outC = klineData.list[i + period].close.toDouble();
        final inC = m.close.toDouble();
        sum = sum - outC + inC;
        sumSq = sumSq - outC * outC + inC * inC;
      }

      final maDouble = sum / n;
      final ma = FlexiNum.fromNum(maDouble);
      final variance = (sumSq - n * maDouble * maDouble) / n;
      // 浮点误差可能使方差略为负数。
      final std = FlexiNum.fromNum(math.sqrt(variance < 0 ? 0 : variance));

      // 设置BOLL值
      final list = m.getOrInitList<FlexiNum>(dataIndex, 3);
      list[0] = ma;
      list[1] = ma + std * FlexiNum.fromNum(param.periods.stdDev);
      list[2] = ma - std * FlexiNum.fromNum(param.periods.stdDev);
    }
  }

  void calcuAndCacheBoll(
    BOLLParam calcParam, {
    required int start,
    required int end,
    bool reset = false,
  }) {
    if (klineData.isEmpty) return;
    _calculateBoll(
      calcParam,
      start: math.max(0, start - calcParam.periods.period), // 补起上一次未算数据
      end: end,
    );
  }

  /// 计算并缓存BOLL数据.
  /// 如果[start]和[end]指定了, 只计算[start] ~ [end]区间内的BOLL值.
  /// 否则, 从当前可视区域的[start] ~ [end]开始计算.
  MinMax? calcuBollMinmax(
    BOLLParam param, {
    int? start,
    int? end,
  }) {
    start ??= klineData.start;
    end ??= klineData.end;
    if (!klineData.checkStartAndEnd(start, end)) {
      return null;
    }

    final len = klineData.list.length;
    final period = param.periods.period;
    end = math.min(len - period, end - 1);

    if (!klineData.list[end].isValidBollData(dataIndex)) {
      calcuAndCacheBoll(param, start: 0, end: len);
    }

    MinMax? minmax;
    FlexiCandleModel m;
    for (int i = end; i >= start; i--) {
      m = klineData.list[i];
      if (m.isValidBollData(dataIndex)) {
        minmax ??= m.bollMinmax(dataIndex);
        minmax?.updateMinMax(m.bollMinmax(dataIndex));
      }
    }
    return minmax;
  }
}
