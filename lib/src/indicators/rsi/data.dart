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

part of 'rsi.dart';

@visibleForTesting
extension on FlexiCandleModel {
  List<double?>? getRsiList(int dataIndex, [int? paramLen]) {
    List<double?>? list = getList<double>(dataIndex);
    if (list == null && paramLen != null && paramLen > 0) {
      list = List.filled(paramLen, null, growable: false);
      setList(dataIndex, list);
    } else if (list != null && paramLen != null && list.length < paramLen) {
      // 布局扩展（新增锚点槽位）：保留已有 rsi 值，扩容到新长度。
      final grown = List<double?>.filled(paramLen, null, growable: false);
      for (int i = 0; i < list.length; i++) {
        grown[i] = list[i];
      }
      setList(dataIndex, grown);
      list = grown;
    }
    return list;
  }

  bool isValidRsi(int dataIndex) => getRsiList(dataIndex)?.any((e) => e != null) ?? false;

  MinMax? getRsiMinmax(int dataIndex) {
    final rsiList = getRsiList(dataIndex);
    if (rsiList == null) return null;
    return MinMax.getMinMaxByList(rsiList.map((e) => e != null ? FlexiNum.fromNum(e) : null).toList());
  }
}

/// RSI 多周期共用的 slot 布局工具。
///
/// slot 布局: [rsi0, rsi1, ..., avgGain0, avgLoss0, prevClose0, avgGain1, ...]。
/// 每条启用线占 4 个槽位：rsi 值、Wilder 平滑 avgGain/avgLoss、前收盘 prevClose，
/// 后三者为增量递推锚点（Wilder 平滑是有记忆的，重新播种会产生边界偏差）。
@visibleForTesting
extension RsiSlotExt on FlexiCandleModel {
  double? getRsiAnchor(int dataIndex, int lineIndex, int lineCount, int part) {
    final list = getList<double>(dataIndex);
    if (list == null) return null;
    final idx = lineCount + lineIndex * 3 + part;
    return idx < list.length ? list[idx] : null;
  }

  void setRsiAnchors(
    int dataIndex,
    int lineIndex,
    int lineCount, {
    required double? avgGain,
    required double? avgLoss,
    required double? prevClose,
  }) {
    final list = getRsiList(dataIndex, lineCount * 4);
    if (list == null) return;
    final base = lineCount + lineIndex * 3;
    if (base + 2 >= list.length) return;
    list[base] = avgGain;
    list[base + 1] = avgLoss;
    list[base + 2] = prevClose;
  }
}

mixin RsiDataMixin<T extends RSIIndicator> on IndicatorCalculationScope<T> {
  RsiParam get calcParam => indicator.calcParam;

  void computeIndicatorData(Range range, {bool reset = false}) {
    calcuAndCacheRsi(
      calcParam,
      start: range.start,
      end: range.end,
      reset: reset,
    );
  }

  /// 计算RSI指标值
  ///
  /// 增量路径：index [end] 处已存 avgGain/avgLoss/prevClose 锚点时恢复
  /// Wilder 平滑状态，只重算 [start, end)；否则从 end+count 用 SMA 播种。
  void _calculateRsi(
    int count, {
    required int paramIndex,
    required int paramLen,
    required int start,
    required int end,
  }) {
    final len = klineData.list.length;
    if (count >= len || !klineData.checkStartAndEnd(start, end)) return;
    logd('calculateRsi [end:$end ~ start:$start] count:$count');
    // end 可能为 len（全量区间），锚点/播种定位统一用包含语义的下标。
    final endIndex = math.min(end, len - 1);

    FlexiNum prevClose;
    FlexiNum? avgGain;
    FlexiNum? avgLoss;
    int i;
    bool haveAnchor = false;

    if (klineData.list[endIndex].getRsiList(dataIndex) == null) {
      // slot 尚未初始化（首算），初始化为空布局。
      klineData.list[endIndex].getRsiList(dataIndex, paramLen * 4);
    }

    // 尝试从 endIndex 处恢复 Wilder 状态（该位置未被 [start, end) 更新影响）。
    final anchorGain = klineData.list[endIndex].getRsiAnchor(dataIndex, paramIndex, paramLen, 0);
    final anchorLoss = klineData.list[endIndex].getRsiAnchor(dataIndex, paramIndex, paramLen, 1);
    final anchorPrev = klineData.list[endIndex].getRsiAnchor(dataIndex, paramIndex, paramLen, 2);
    if (anchorGain != null && anchorLoss != null && anchorPrev != null) {
      avgGain = FlexiNum.fromNum(anchorGain);
      avgLoss = FlexiNum.fromNum(anchorLoss);
      prevClose = FlexiNum.fromNum(anchorPrev);
      i = endIndex - 1;
      haveAnchor = true;
    } else {
      /// RSI要从end前的count+1个数据开始计算.
      final index = math.min(endIndex + count, len - 1);
      final m = klineData.list[index];
      prevClose = m.close;
      i = index - 1;
    }

    FlexiNum sumGain = FlexiNum.zero;
    FlexiNum sumLoss = FlexiNum.zero;
    FlexiNum diff;
    FlexiNum gain = FlexiNum.zero;
    FlexiNum loss = FlexiNum.zero;
    for (; i >= start; i--) {
      final m = klineData.list[i];

      diff = m.close - prevClose;
      prevClose = m.close;
      if (diff.signum > 0) {
        gain = diff;
        loss = FlexiNum.zero;
        if (!haveAnchor) sumGain = gain + sumGain;
      } else {
        loss = diff.abs();
        gain = FlexiNum.zero;
        if (!haveAnchor) sumLoss = loss + sumLoss;
      }

      final inSmaZone = !haveAnchor && i <= iSmaZoneLimit(count, end, len);
      if (haveAnchor || inSmaZone) {
        m.getRsiList(dataIndex, paramLen * 4);

        if (avgGain == null) {
          avgGain = sumGain.divNum(count);
        } else {
          avgGain = (avgGain.mulNum(count - 1) + gain).divNum(count);
        }
        if (avgLoss == null) {
          avgLoss = sumLoss.divNum(count);
        } else {
          avgLoss = (avgLoss.mulNum(count - 1) + loss).divNum(count);
        }

        final rsi = avgLoss == FlexiNum.zero
            ? 0.0
            : 100 - (100 / (1 + avgGain.div(avgLoss).toDouble()));
        m.getRsiList(dataIndex, paramLen * 4)![paramIndex] = rsi;
        m.setRsiAnchors(
          dataIndex,
          paramIndex,
          paramLen,
          avgGain: avgGain.toDouble(),
          avgLoss: avgLoss.toDouble(),
          prevClose: prevClose.toDouble(),
        );

        if (!haveAnchor) {
          diff = _calculateUpVal(i + count - 1);
          if (diff.signum > 0) {
            sumGain -= diff;
          } else {
            sumLoss -= diff.abs();
          }
        }
      }
    }
  }

  /// SMA 播种区内，位置 i 是否已进入"可写 rsi"的窗口（原逻辑 i <= index-count）。
  int iSmaZoneLimit(int count, int endIndex, int len) {
    final index = math.min(endIndex + count, len - 1);
    return index - count;
  }

  /// 计算[index]位置的RSI指标上升值
  FlexiNum _calculateUpVal(int index) {
    final list = klineData.list;
    if (index >= 0 && index < list.length - 1) {
      return list[index].close - list[index + 1].close;
    }
    return FlexiNum.zero;
  }

  void calcuAndCacheRsi(
    RsiParam param, {
    int? start,
    int? end,
    bool reset = false,
  }) {
    if (klineData.isEmpty || param.enabledLines.isEmpty) return;
    final enabledLines = param.enabledLines;
    final paramLen = enabledLines.length;
    for (int i = 0; i < paramLen; i++) {
      final lineConfig = enabledLines[i];
      _calculateRsi(
        lineConfig.period,
        paramIndex: i,
        paramLen: paramLen,
        start: math.max(0, (start ?? klineData.start) - lineConfig.period), // 补起上一次未算数据
        end: end ?? klineData.end,
      );
    }
  }

  MinMax? calcuRsiMinmax(
    RsiParam param, {
    int? start,
    int? end,
  }) {
    start ??= klineData.start;
    end ??= klineData.end;
    if (param.enabledLines.isEmpty || !klineData.checkStartAndEnd(start, end)) return null;
    final len = klineData.list.length;

    int? minPeriod = param.minPeriod;
    if (minPeriod == null || len < minPeriod) return null; // 数据不足，直接返回
    end = math.min(len - minPeriod - 1, end - 1);
    if (end < start) return null; // 区间非法，直接返回

    if (!klineData.list[end].isValidRsi(dataIndex)) {
      calcuAndCacheRsi(param, start: 0, end: len);
    }

    MinMax? minmax;
    for (int i = end; i >= start; i--) {
      final m = klineData.list[i];
      minmax ??= m.getRsiMinmax(dataIndex);
      minmax?.updateMinMax(m.getRsiMinmax(dataIndex));
    }

    // 如果启用参考线，需要考虑参考线的范围
    if (param.reference.enabled) {
      minmax ??= MinMax(
        min: FlexiNum.fromNum(param.reference.oversold),
        max: FlexiNum.fromNum(param.reference.overbought),
      );
      minmax.updateMinMax(MinMax(
        min: FlexiNum.fromNum(param.reference.oversold),
        max: FlexiNum.fromNum(param.reference.overbought),
      ));
    }

    return minmax;
  }
}
