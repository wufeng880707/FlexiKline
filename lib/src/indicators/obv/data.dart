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

mixin ObvDataMixin<T extends OBVIndicator> on DataPaintObject<T> {
  OBVParam get calcParam => indicator.calcParam;

  @override
  void precompute(Range range, {bool reset = false}) {
    calcuAndCacheObv(
      calcParam,
      start: range.start,
      end: range.end,
      reset: reset,
    );
  }

  /// OBV 计算：
  /// - close > prevClose => OBV = prevOBV + volume
  /// - close < prevClose => OBV = prevOBV - volume
  /// - close == prevClose => OBV = prevOBV
  ///
  /// 在 list 中，index 越大越旧，index 越小越新。
  /// 需从最旧的数据开始累加。
  void _calculateObv({
    required int slotLen,
    required int start,
    required int end,
  }) {
    final list = klineData.list;
    final len = list.length;
    if (len < 2 || !klineData.checkStartAndEnd(start, end)) return;

    final validEnd = math.min(end, len);
    final validStart = math.max(start, 0);

    // 从最旧的蜡烛开始（index 大→小 即 旧→新）
    // 首根蜡烛 OBV = volume
    final oldest = math.min(validEnd - 1, len - 1);
    final closeOf = _closeDouble;
    final volOf = _volDouble;

    double obv = volOf(list[oldest]);
    list[oldest].getObvList(dataIndex, slotLen)?[0] = obv;

    for (int i = oldest - 1; i >= validStart; i--) {
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

  double Function(FlexiCandleModel) get _closeDouble =>
      (m) => double.parse(m.close.toString());

  double Function(FlexiCandleModel) get _volDouble =>
      (m) => double.parse(m.vol.toString());

  /// 在 OBV 主线计算完成后，计算 OBV 的 MA 线
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

      for (int i = validEnd - 1; i >= start; i--) {
        double sum = 0;
        int count = 0;
        for (int k = 0; k < period; k++) {
          final idx = i + k;
          if (idx >= len) break;
          final obvVal = list[idx].getObvValue(dataIndex);
          if (obvVal == null) break;
          sum += obvVal;
          count++;
        }
        if (count == period) {
          list[i].getObvList(dataIndex, slotLen)?[maSlotIndex] = sum / period;
        }
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

    if (reset) {
      final s = start ?? klineData.start;
      final e = end ?? klineData.end;
      for (int i = s; i <= e && i < klineData.list.length; i++) {
        klineData.list[i].clean(dataIndex);
      }
    }

    // OBV 是累计计算，需要全量计算
    _calculateObv(
      slotLen: slotLen,
      start: 0,
      end: klineData.list.length,
    );

    // 计算 MA 线
    final enabledMALines = param.enabledMALines;
    if (enabledMALines.isNotEmpty) {
      _calculateObvMA(
        enabledMALines: enabledMALines,
        slotLen: slotLen,
        start: 0,
        end: klineData.list.length,
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
