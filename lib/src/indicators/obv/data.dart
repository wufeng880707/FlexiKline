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

part of 'obv.dart';

@visibleForTesting
extension on FlexiCandleModel {
  /// slot 布局: [obvValue, ma0, ma1, ...]
  List<double?>? getObvList(int dataIndex, [int? slotLen]) {
    List<double?>? list = getList<double>(dataIndex);
    if (list == null && slotLen != null && slotLen > 0) {
      list = List.filled(slotLen, null, growable: false);
      setList(dataIndex, list);
    }
    return list;
  }

  double? getObvValue(int dataIndex) => getObvList(dataIndex)?.firstOrNull;

  bool isValidObv(int dataIndex) => getObvValue(dataIndex) != null;

  MinMax? getObvMinmax(int dataIndex) {
    final list = getObvList(dataIndex);
    if (list == null) return null;
    return MinMax.getMinMaxByList(
      list.map((e) => e != null ? FlexiNum.fromNum(e) : null).toList(),
    );
  }
}

mixin ObvDataMixin<T extends OBVIndicator> on IndicatorCalculationScope<T> {
  OBVParam get calcParam => indicator.calcParam;

  void computeIndicatorData(Range range, {bool reset = false}) {
    calcuAndCacheObv(
      calcParam,
      start: range.start,
      end: range.end,
      reset: reset,
    );
  }

  /// 计算 OBV 主线。
  ///
  /// list 中 index 越大越旧。默认从区间最旧端取 `obv = volume` 播种后向新递推；
  /// [anchorIndex] 提供时（增量路径）以该处已存的 OBV 值为起点，
  /// 只重算 [start, anchorIndex) 的新端区间。
  void _calculateObv({
    required int slotLen,
    required int start,
    required int end,
    int? anchorIndex,
  }) {
    final list = klineData.list;
    final len = list.length;
    if (len < 2 || !klineData.checkStartAndEnd(start, end)) return;

    final closeOf = _closeDouble;
    final volOf = _volDouble;

    double obv;
    int oldest;
    if (anchorIndex != null) {
      // 增量：anchor 未被本次更新影响，其已存 OBV 即累计起点。
      final anchorObv = list[anchorIndex].getObvValue(dataIndex);
      if (anchorObv == null) return; // 锚点缺失，由调用方回退全量
      obv = anchorObv;
      oldest = anchorIndex;
    } else {
      // 全量：从区间最旧蜡烛开始，首根 OBV = volume。
      final validEnd = math.min(end, len);
      oldest = math.min(validEnd - 1, len - 1);
      obv = volOf(list[oldest]);
    }
    list[oldest].getObvList(dataIndex, slotLen)?[0] = obv;

    for (int i = oldest - 1; i >= start; i--) {
      final curClose = closeOf(list[i]);
      final prevClose = closeOf(list[i + 1]);
      final vol = volOf(list[i]);

      if (curClose > prevClose) {
        obv += vol;
      } else if (curClose < prevClose) {
        obv -= vol;
      }

      list[i].getObvList(dataIndex, slotLen)?[0] = obv;
    }
  }

  double Function(FlexiCandleModel) get _closeDouble => (m) => m.close.toDouble();

  double Function(FlexiCandleModel) get _volDouble => (m) => m.vol.toDouble();

  /// 在 OBV 主线计算完成后，计算 OBV 的 MA 线。
  ///
  /// 使用滚动和：`sum(i-1) = sum(i) - obv[i-1+period] + obv[i-1]`，
  /// 将每个窗口 O(period) 的重求和降为 O(1)。因 OBV 是累计量，
  /// 窗口移动时和的差分不受远处历史影响，结果与逐窗口求和一致。
  void _calculateObvMA({
    required List<OBVMALineConfig> enabledMALines,
    required int slotLen,
    required int start,
    required int end,
  }) {
    final list = klineData.list;
    final len = list.length;

    for (int j = 0; j < enabledMALines.length; j++) {
      final period = enabledMALines[j].period;
      final maSlotIndex = j + 1; // slot[0] 是 OBV 主线

      final validEnd = math.min(end, len - period + 1);
      if (validEnd < start) continue;

      // 求初始窗口 [validEnd-1, validEnd-1+period) 的和。
      double sum = 0;
      int count = 0;
      for (int k = 0; k < period; k++) {
        final idx = validEnd - 1 + k;
        if (idx >= len) break;
        final obvVal = list[idx].getObvValue(dataIndex);
        if (obvVal == null) break;
        sum += obvVal;
        count++;
      }
      if (count == period) {
        list[validEnd - 1].getObvList(dataIndex, slotLen)?[maSlotIndex] = sum / period;
      }

      // 向新端滚动：移出 obv[i+period]，加入 obv[i]。
      for (int i = validEnd - 2; i >= start; i--) {
        final outIdx = i + period;
        final outVal = outIdx < len ? list[outIdx].getObvValue(dataIndex) : null;
        final inVal = list[i].getObvValue(dataIndex);
        if (outVal == null || inVal == null) {
          // 滚动链断裂（seed 区/数据缺失），对该位置退回逐项求和。
          double s = 0;
          int c = 0;
          for (int k = 0; k < period; k++) {
            final idx = i + k;
            if (idx >= len) break;
            final v = list[idx].getObvValue(dataIndex);
            if (v == null) break;
            s += v;
            c++;
          }
          if (c == period) {
            list[i].getObvList(dataIndex, slotLen)?[maSlotIndex] = s / period;
          }
          continue;
        }
        sum = sum - outVal + inVal;
        list[i].getObvList(dataIndex, slotLen)?[maSlotIndex] = sum / period;
      }
    }
  }

  void calcuAndCacheObv(
    OBVParam param, {
    int? start,
    int? end,
    bool reset = false,
  }) {
    if (klineData.isEmpty || !param.obvLine.enabled) return;
    final slotLen = param.slotLen;
    final len = klineData.list.length;

    if (reset) {
      final s = start ?? klineData.start;
      final e = end ?? klineData.end;
      for (int i = s; i <= e && i < len; i++) {
        klineData.list[i].clean(dataIndex);
      }
    }

    final validStart = start ?? 0;
    final validEnd = end ?? len;

    // 局部脏区间且锚点可用时走增量：index[end] 未被本次更新影响。
    // 锚点无值时回退全量（首算/seed 区）。
    var incremental = false;
    if (!reset && validEnd < len) {
      final anchorObv = klineData.list[validEnd].getObvValue(dataIndex);
      incremental = anchorObv != null;
    }

    if (incremental) {
      _calculateObv(
        slotLen: slotLen,
        start: validStart,
        end: validEnd,
        anchorIndex: validEnd,
      );
    } else {
      // OBV 是累计计算，锚点不可用时全量计算。
      _calculateObv(
        slotLen: slotLen,
        start: 0,
        end: len,
      );
    }

    // 计算 MA 线（增量时只算脏区间；MA 值依赖 OBV 主线，区间内滚动即可）
    final enabledMALines = param.enabledMALines;
    if (enabledMALines.isNotEmpty) {
      _calculateObvMA(
        enabledMALines: enabledMALines,
        slotLen: slotLen,
        start: incremental ? math.max(validStart - 1, 0) : 0,
        end: incremental ? math.min(validEnd + 1, len) : len,
      );
    }
  }

  MinMax? calcuObvMinmax(
    OBVParam param, {
    int? start,
    int? end,
  }) {
    start ??= klineData.start;
    end ??= klineData.end;
    if (!param.obvLine.enabled || !klineData.checkStartAndEnd(start, end)) {
      return null;
    }

    final len = klineData.list.length;
    if (len < 2) return null;
    end = math.min(end - 1, len - 1);
    if (end < start) return null;

    if (!klineData.list[end].isValidObv(dataIndex)) {
      calcuAndCacheObv(param, start: 0, end: len);
    }

    MinMax? minmax;
    for (int i = end; i >= start; i--) {
      final m = klineData.list[i];
      final mm = m.getObvMinmax(dataIndex);
      if (mm == null) continue;
      minmax ??= mm;
      minmax.updateMinMax(mm);
    }

    return minmax;
  }
}
