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

part of 'cci.dart';

@visibleForTesting
extension on FlexiCandleModel {
  List<double?>? getCciList(int dataIndex, [int? paramLen]) {
    List<double?>? list = getList<double>(dataIndex);
    if (list == null && paramLen != null && paramLen > 0) {
      list = List.filled(paramLen, null, growable: false);
      setList(dataIndex, list);
    }
    return list;
  }

  bool isValidCci(int dataIndex) => getCciList(dataIndex)?.any((e) => e != null) ?? false;

  MinMax? getCciMinmax(int dataIndex) {
    final cciList = getCciList(dataIndex);
    if (cciList == null) return null;
    return MinMax.getMinMaxByList(
      cciList.map((e) => e != null ? FlexiNum.fromNum(e) : null).toList(),
    );
  }

  double get tp =>
      (double.parse(high.toString()) + double.parse(low.toString()) + double.parse(close.toString())) / 3.0;
}

mixin CciDataMixin<T extends CCIIndicator> on ComputedPaintObject<T> {
  CCIParam get calcParam => indicator.calcParam;

  @override
  void compute(Range range, {bool reset = false}) {
    calcuAndCacheCci(
      calcParam,
      start: range.start,
      end: range.end,
      reset: reset,
    );
  }

  /// CCI = (TP - SMA(TP, N)) / (0.015 * MD)
  /// TP = (High + Low + Close) / 3
  /// SMA(TP, N) = N 周期 TP 的简单移动平均
  /// MD = (1/N) * SUM(|TP_i - SMA(TP, N)|) for last N periods
  ///
  /// 在 list 中, index 越大越旧, index 越小越新.
  /// 位置 i 的 CCI 需要 [i, i+1, ..., i+count-1] 共 count 个 TP 值.
  void _calculateCci(
    int count, {
    required int paramIndex,
    required int paramLen,
    required int start,
    required int end,
  }) {
    final len = klineData.list.length;
    if (count >= len || !klineData.checkStartAndEnd(start, end)) return;
    logd('calculateCci [end:$end ~ start:$start] count:$count');

    final list = klineData.list;
    final validEnd = math.min(end, len - count);
    if (validEnd < start) return;

    final tpCache = List<double>.filled(count, 0.0);

    for (int i = validEnd; i >= start; i--) {
      double sumTp = 0.0;
      for (int k = 0; k < count; k++) {
        final tp = list[i + k].tp;
        tpCache[k] = tp;
        sumTp += tp;
      }
      final smaTp = sumTp / count;

      double sumDev = 0.0;
      for (int k = 0; k < count; k++) {
        sumDev += (tpCache[k] - smaTp).abs();
      }
      final md = sumDev / count;

      final cci = md == 0.0 ? 0.0 : (tpCache[0] - smaTp) / (0.015 * md);
      list[i].getCciList(dataIndex, paramLen)?[paramIndex] = cci;
    }
  }

  void calcuAndCacheCci(
    CCIParam param, {
    int? start,
    int? end,
    bool reset = false,
  }) {
    if (klineData.isEmpty || param.enabledLines.isEmpty) return;
    final enabledLines = param.enabledLines;
    final paramLen = enabledLines.length;

    if (reset) {
      final s = start ?? klineData.start;
      final e = end ?? klineData.end;
      for (int i = s; i <= e && i < klineData.list.length; i++) {
        klineData.list[i].clean(dataIndex);
      }
    }

    for (int i = 0; i < paramLen; i++) {
      final lineConfig = enabledLines[i];
      _calculateCci(
        lineConfig.period,
        paramIndex: i,
        paramLen: paramLen,
        start: math.max(0, (start ?? klineData.start) - lineConfig.period),
        end: end ?? klineData.end,
      );
    }
  }

  MinMax? calcuCciMinmax(
    CCIParam param, {
    int? start,
    int? end,
  }) {
    start ??= klineData.start;
    end ??= klineData.end;
    if (param.enabledLines.isEmpty || !klineData.checkStartAndEnd(start, end)) {
      return null;
    }
    final len = klineData.list.length;

    final minPeriod = param.minPeriod;
    if (minPeriod == null || len < minPeriod) return null;
    end = math.min(len - minPeriod - 1, end - 1);
    if (end < start) return null;

    if (!klineData.list[end].isValidCci(dataIndex)) {
      calcuAndCacheCci(param, start: 0, end: len);
    }

    MinMax? minmax;
    for (int i = end; i >= start; i--) {
      final m = klineData.list[i];
      minmax ??= m.getCciMinmax(dataIndex);
      minmax?.updateMinMax(m.getCciMinmax(dataIndex));
    }

    if (param.reference.enabled) {
      final refMinMax = MinMax(
        min: FlexiNum.fromNum(param.reference.oversold),
        max: FlexiNum.fromNum(param.reference.overbought),
      );
      minmax ??= refMinMax;
      minmax.updateMinMax(refMinMax);
    }

    return minmax;
  }
}
