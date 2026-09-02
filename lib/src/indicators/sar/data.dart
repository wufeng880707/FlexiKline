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
    return (list != null && list.isNotEmpty) ? list[0] : null;
  }

  int? sarFlag(int dataIndex) {
    final list = sarList(dataIndex);
    return (list != null && list.length > 1) ? list[1]?.toDouble().toInt() : null;
  }

  /// SAR 计算的极值点（EP），增量递推的中间状态之一（反转帧为 null）。
  FlexiNum? sarEp(int dataIndex) {
    final list = sarList(dataIndex);
    return (list != null && list.length > 2) ? list[2] : null;
  }

  /// SAR 计算的加速因子（AF），增量递推的中间状态之一。
  double? sarAf(int dataIndex) {
    final list = sarList(dataIndex);
    return (list != null && list.length > 3) ? list[3]?.toDouble() : null;
  }

  /// 下一帧趋势方向（1=上涨 0=下跌），增量恢复用（flag=0 的反转帧无法从 flag 判断方向）。
  int? sarDir(int dataIndex) {
    final list = sarList(dataIndex);
    return (list != null && list.length > 4) ? list[4]?.toDouble().toInt() : null;
  }

  /// slot 布局: [sar, flag, ep, af, dir]，ep/af/dir 为增量递推锚点。
  void setSar(
    int dataIndex,
    FlexiNum? sar,
    int? flag, {
    FlexiNum? ep,
    double? af,
    int? dir,
  }) {
    final list = getOrInitList<FlexiNum>(dataIndex, 5);
    list[0] = sar;
    list[1] = flag != null ? FlexiNum.fromNum(flag) : null;
    list[2] = ep;
    list[3] = af != null ? FlexiNum.fromNum(af) : null;
    list[4] = dir != null ? FlexiNum.fromNum(dir) : null;
  }

  bool isValidSarData(int dataIndex) => sarValue(dataIndex) != null && sarFlag(dataIndex) != null;

  void cleanSar(int dataIndex) => clean(dataIndex);
}

mixin SarDataMixin<T extends SARIndicator> on IndicatorCalculationScope<T> {
  SARParam get calcParam => indicator.calcParam;

  void computeIndicatorData(Range range, {bool reset = false}) {
    calcuAndCacheSar(
      calcParam,
      start: range.start,
      end: range.end,
      reset: reset,
    );
  }

  /// 计算SAR指标值
  ///
  /// 增量路径：[anchorIndex] 处已存 [sar, flag, ep, af] 完整状态时，
  /// 从该状态恢复并只重算 [start, anchorIndex)；
  /// 否则（首算/锚点不完整）从 [end-1] 用相邻两根蜡烛初始化趋势后全段计算。
  void _calculateSar(
    SARParam param, {
    required int start,
    required int end,
    int? anchorIndex,
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
    int flag = 0;

    int i;
    // 初始化帧（本段最旧一根）：原算法在此帧不与前一根做 clamp（sar 即由前一根初始化而来）。
    // 增量路径无初始化帧，所有帧都 clamp（与等效全量重算一致）。
    int? initFrameIndex;
    if (anchorIndex != null && anchorIndex <= end && anchorIndex < len) {
      // 增量：从锚点恢复 sar/ep/af/dir 完整状态（ep 为 null 表示反转帧，合法）。
      final anchor = klineData.list[anchorIndex];
      final anchorSar = anchor.sarValue(dataIndex);
      final anchorAf = anchor.sarAf(dataIndex);
      final anchorDir = anchor.sarDir(dataIndex);
      if (anchorSar == null || anchorAf == null || anchorDir == null) {
        // 锚点状态不完整（旧布局/首算），回退全量初始化。
        return _calculateSarInit(param, start: start, end: end + 1);
      }
      sar = anchorSar;
      ep = anchor.sarEp(dataIndex);
      af = anchorAf;
      isIncreasing = anchorDir == 1;
      i = anchorIndex - 1;
    } else {
      // 全量初始化路径。
      initFrameIndex = end;
      if (end < len - 1) {
        final current = klineData.list[end];
        final next = klineData.list[end + 1];

        // 判断初始趋势：如果当前最高价 > 下一根最高价，则为上涨趋势
        isIncreasing = current.high > next.high;

        if (isIncreasing) {
          sar = next.low;
          ep = current.high;
          flag = 1;
        } else {
          sar = next.high;
          ep = current.low;
          flag = -1;
        }
      } else {
        isIncreasing = false;
        sar = klineData.list[end].high;
        flag = -1;
      }
      i = end;
    }

    for (; i >= start; i--) {
      final m = klineData.list[i];
      if (isIncreasing) {
        flag = 1; // 上涨
        if (ep == null || ep < m.high) {
          ep = m.high;
          af = math.min(af + step, maxAf);
        }
        sar = (ep - sar).mulNum(af) + sar;

        // 修正：确保SAR不超过前一根K线的最低价
        if (i != initFrameIndex) {
          final minLow = klineData.list[i + 1].low;
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
        if (i != initFrameIndex) {
          final maxHigh = klineData.list[i + 1].high;
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
      m.setSar(dataIndex, sar, flag, ep: ep, af: af, dir: isIncreasing ? 1 : 0);
    }
  }

  /// 全量初始化路径（增量锚点不可用时）。
  void _calculateSarInit(
    SARParam param, {
    required int start,
    required int end,
  }) {
    _calculateSar(param, start: start, end: end);
  }

  void calcuAndCacheSar(
    SARParam calcParam, {
    required int start,
    required int end,
    bool reset = false,
  }) {
    if (klineData.isEmpty) return;
    final len = klineData.list.length;
    // 局部脏区间且锚点状态完整时走增量：index[end] 未被本次更新影响。
    if (!reset && end < len) {
      _calculateSar(
        calcParam,
        start: start,
        end: end + 1,
        anchorIndex: end,
      );
      return;
    }
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
