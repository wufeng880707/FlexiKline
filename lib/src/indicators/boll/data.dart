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

mixin BollDataMixin<T extends BOLLIndicator> on ComputedPaintObject<T> {
  BOLLParam get calcParam => indicator.calcParam;

  @override
  void compute(Range range, {bool reset = false}) {
    calcuAndCacheBoll(
      calcParam,
      start: range.start,
      end: range.end,
      reset: reset,
    );
  }

  /// 计算BOLL指标值
  void _calculateBoll(
    BOLLParam param, {
    required int start,
    required int end,
  }) {
    final len = klineData.list.length;
    final period = param.periods.period;
    if (period > len || !klineData.checkStartAndEnd(start, end)) return;
    print('calculateBoll [end:$end ~ start:$start] period:$period');

    end = math.min(len - period, end - 1);

    for (int i = end; i >= start; i--) {
      final m = klineData.list[i];
      if (i + period > len) continue;

      // 计算移动平均
      FlexiNum sum = m.close;
      for (int j = i + 1; j < i + period; j++) {
        sum += klineData.list[j].close;
      }
      final ma = sum.divNum(period);

      // 计算标准差
      double variance = (m.close.toDouble() - ma.toDouble()) * (m.close.toDouble() - ma.toDouble());
      for (int j = i + 1; j < i + period; j++) {
        variance +=
            (klineData.list[j].close.toDouble() - ma.toDouble()) * (klineData.list[j].close.toDouble() - ma.toDouble());
      }
      final std = FlexiNum.fromNum(math.sqrt(variance / period));

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
