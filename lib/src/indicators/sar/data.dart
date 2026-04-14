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

part of 'sar.dart';

@visibleForTesting
extension CandleSarExt on FlexiCandleModel {
  List<FlexiNum?>? sarList(int dataIndex) => getList<FlexiNum>(dataIndex);

  FlexiNum? sarValue(int dataIndex) {
    final list = sarList(dataIndex);
    return (list != null && list.length == 2) ? list[0] : null;
  }

  int? sarFlag(int dataIndex) {
    final list = sarList(dataIndex);
    return (list != null && list.length == 2) ? list[1]?.toDouble().toInt() : null;
  }

  void setSar(int dataIndex, FlexiNum? sar, int? flag) {
    final list = getOrInitList<FlexiNum>(dataIndex, 2);
    list[0] = sar;
    list[1] = flag != null ? FlexiNum.fromNum(flag) : null;
  }

  bool isValidSarData(int dataIndex) => sarValue(dataIndex) != null && sarFlag(dataIndex) != null;

  void cleanSar(int dataIndex) => clean(dataIndex);
}

mixin SarDataMixin<T extends SARIndicator> on DataPaintObject<T> {
  SARParam get calcParam => indicator.calcParam;

  @override
  void precompute(Range range, {bool reset = false}) {
    calcuAndCacheSar(
      calcParam,
      start: range.start,
      end: range.end,
      reset: reset,
    );
  }

  /// 计算SAR指标值
  void _calculateSar(
    SARParam param, {
    required int start,
    required int end,
  }) {
    final len = klineData.list.length;
    if (!param.isValid(len) || !klineData.checkStartAndEnd(start, end)) return;
    logd('calculateSar [end:$end ~ start:$start] param:$param');

    end = end - 1;

    double af = param.periods.start;
    final step = param.periods.step;
    final maxAf = param.periods.max;
    FlexiNum? ep;
    bool isIncreasing = false;
    FlexiNum sar = FlexiNum.zero;
    FlexiNum minLow;
    FlexiNum maxHigh;
    int flag = 0;

    // 修正：正确初始化第一个SAR值和趋势判断
    if (end < len - 1) {
      // 从倒数第二根K线开始，判断初始趋势
      final current = klineData.list[end];
      final next = klineData.list[end + 1];

      // 判断初始趋势：如果当前最高价 > 下一根最高价，则为上涨趋势
      isIncreasing = current.high > next.high;

      if (isIncreasing) {
        // 上涨趋势：第一个SAR值为前一根K线的最低价
        sar = next.low;
        ep = current.high;
        flag = 1;
      } else {
        // 下跌趋势：第一个SAR值为前一根K线的最高价
        sar = next.high;
        ep = current.low;
        flag = -1;
      }
    } else {
      // 如果只有一根K线，默认为下跌趋势
      isIncreasing = false;
      sar = klineData.list[end].high;
      flag = -1;
    }

    for (int i = end; i >= start; i--) {
      final m = klineData.list[i];
      if (isIncreasing) {
        flag = 1; // 上涨
        if (ep == null || ep < m.high) {
          ep = m.high;
          af = math.min(af + step, maxAf);
        }
        sar = (ep - sar).mulNum(af) + sar;

        // 修正：确保SAR不超过前一根K线的最低价
        if (i < end) {
          minLow = klineData.list[i + 1].low;
          if (sar > minLow) {
            sar = minLow;
          }
        }

        if (sar > m.low) {
          sar = ep;
          // 重新初始化值
          flag = 0; // 开始下跌
          af = param.periods.start;
          ep = null;
          isIncreasing = false;
        }
      } else {
        flag = -1; // 下跌
        if (ep == null || ep > m.low) {
          ep = m.low;
          af = math.min(af + step, maxAf);
        }
        sar = (ep - sar).mulNum(af) + sar;

        // 修正：确保SAR不低于前一根K线的最高价
        if (i < end) {
          maxHigh = klineData.list[i + 1].high;
          if (sar < maxHigh) {
            sar = maxHigh;
          }
        }

        if (sar < m.high) {
          sar = ep;
          // 重新初始化值
          flag = 0; // 开始上涨
          af = param.periods.start;
          ep = null;
          isIncreasing = true;
        }
      }
      m.setSar(dataIndex, sar, flag);
    }
  }

  void calcuAndCacheSar(
    SARParam calcParam, {
    required int start,
    required int end,
    bool reset = false,
  }) {
    if (klineData.isEmpty) return;
    _calculateSar(
      calcParam,
      start: math.max(0, start - 1), // 补起上一次未算数据
      end: end,
    );
  }

  /// 计算并缓存SAR数据.
  /// 如果[start]和[end]指定了, 只计算[start] ~ [end]区间内的SAR值.
  /// 否则, 从当前可视区域的[start] ~ [end]开始计算.
  MinMax? calcuSarMinmax(
    SARParam param, {
    int? start,
    int? end,
  }) {
    start ??= klineData.start;
    end ??= klineData.end;
    if (!klineData.checkStartAndEnd(start, end)) {
      return null;
    }

    int endIndex = end - 1;
    if (end < start) return null;
    if (!klineData.list[endIndex].isValidSarData(dataIndex)) {
      calcuAndCacheSar(param, start: 0, end: klineData.list.length);
    }

    MinMax? minmax;
    for (int i = endIndex; i >= start; i--) {
      final m = klineData.list[i];
      final sarVal = m.sarValue(dataIndex);
      if (sarVal != null) {
        minmax ??= MinMax.same(sarVal);
        minmax.updateMinMaxBy(sarVal);
      }
    }
    return minmax;
  }
}
