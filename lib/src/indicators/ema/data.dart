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

part of 'ema.dart';

@visibleForTesting
extension CandleEmaExt on FlexiCandleModel {
  List<FlexiNum?>? getEmaList(int dataIndex) => getList<FlexiNum>(dataIndex);

  bool isValidEmaList(int dataIndex) => getEmaList(dataIndex)?.any((e) => e != null) ?? false;

  void cleanEma(int dataIndex) => clean(dataIndex);
}

mixin EmaDataMixin<T extends EMAIndicator> on IndicatorCalculationScope<T> {
  EmaParam get calcParam => indicator.calcParam;

  void computeIndicatorData(Range range, {bool reset = false}) {
    calcuAndCacheEma(
      calcParam,
      start: range.start,
      end: range.end,
      reset: reset,
    );
  }

  /// 计算EMA，要求传入的`values`是按时间从旧到新排列的.
  List<FlexiNum?> _ema(List<FlexiNum?> values, int period) {
    final len = values.length;
    final result = List<FlexiNum?>.filled(len, null);
    if (len < period) return result;

    final multiplier = FlexiNum.fromNum(2.0 / (period + 1));

    // 寻找第一个非空值作为计算起点
    int firstValidIndex = -1;
    for (int i = 0; i < len; i++) {
      if (values[i] != null) {
        firstValidIndex = i;
        break;
      }
    }

    if (firstValidIndex == -1 || len < firstValidIndex + period) {
      return result;
    }

    // 第一个EMA值是前`period`个数据的简单移动平均(SMA)
    FlexiNum sum = FlexiNum.zero;
    for (int i = firstValidIndex; i < firstValidIndex + period; i++) {
      sum += values[i]!;
    }
    result[firstValidIndex + period - 1] = sum.divNum(period);

    // 迭代计算后续的EMA值
    for (int i = firstValidIndex + period; i < len; i++) {
      final value = values[i];
      final prevEma = result[i - 1];
      if (value != null && prevEma != null) {
        result[i] = value * multiplier + prevEma * (FlexiNum.one - multiplier);
      } else if (prevEma != null) {
        // 如果当前值为空, 则沿用上一个EMA值.
        result[i] = prevEma;
      }
    }
    return result;
  }

  void calcuAndCacheEma(
    EmaParam param, {
    required int start,
    required int end,
    bool reset = false,
  }) {
    final enabledLines = param.enabledLines;
    if (klineData.isEmpty || enabledLines.isEmpty) return;

    final list = klineData.list;
    final len = list.length;

    if (reset) {
      for (final m in list) {
        m.cleanEma(dataIndex);
      }
    }

    // 获取最大周期，确保有足够的数据
    final maxPeriod = param.maxPeriod;
    if (maxPeriod == null || len < maxPeriod) return;

    // updateLatest 等局部脏区间：[end, len) 未被本次更新影响，其中 index=end 处
    // 已存的 EMA 可作为递推锚点，仅重算 [start, end)。
    if (!reset && end < len && _tryIncrementalEma(enabledLines, start: start, end: end)) {
      return;
    }

    // klineData.list 是从新到旧的, 需要反转为从旧到新来计算.
    final closeValues = list.map((c) => c.close).toList().reversed.toList();

    // 为每个启用的EMA线计算EMA
    final emaResults = <List<FlexiNum?>>[];
    for (final lineConfig in enabledLines) {
      if (lineConfig.period <= 0) continue; // 跳过无效周期
      final emaResult = _ema(closeValues, lineConfig.period);
      emaResults.add(emaResult);
    }

    // 将计算结果(从旧到新)反转回来, 以匹配原始list(从新到旧)的顺序.
    for (int i = 0; i < len; i++) {
      final emaValues = <FlexiNum?>[];
      bool hasValidData = false;

      for (int j = 0; j < emaResults.length; j++) {
        final reversedIndex = len - 1 - i;
        final emaValue = emaResults[j][reversedIndex];
        emaValues.add(emaValue);
        if (emaValue != null) {
          hasValidData = true;
        }
      }

      if (hasValidData) {
        list[i].setList(dataIndex, emaValues);
      } else {
        if (reset) {
          list[i].clean(dataIndex);
        }
      }
    }
  }

  /// 增量计算 [start, end) 区间的 EMA。
  ///
  /// list 按时间从新到旧排列，EMA 递推方向为旧→新（下标递减）：
  /// `ema[i] = close[i] * k + ema[i+1] * (1 - k)`。
  /// index [end] 是本次更新未触及的最旧一根变更蜡烛，其已存 EMA 值即递推锚点；
  /// 任一线在锚点处无值（seed 未到达或布局不符）时返回 false，由调用方回退全量。
  bool _tryIncrementalEma(
    List<EMALineConfig> enabledLines, {
    required int start,
    required int end,
  }) {
    final list = klineData.list;

    // 布局校验：全量路径只存储 period>0 的线，锚点列表长度必须一致。
    final validLines = [for (final line in enabledLines) if (line.period > 0) line];
    if (validLines.isEmpty) return false;
    final anchorList = list[end].getEmaList(dataIndex);
    if (anchorList == null || anchorList.length != validLines.length) return false;
    for (final anchor in anchorList) {
      if (anchor == null) return false;
    }

    final multipliers = [
      for (final line in validLines) FlexiNum.fromNum(2.0 / (line.period + 1)),
    ];

    // 从旧到新（下标递减）递推；每根蜡烛的锚点取下一根（更旧）刚写入或已存的值。
    for (int i = end - 1; i >= start; i--) {
      final prevList = list[i + 1].getEmaList(dataIndex)!;
      final close = list[i].close;
      final emaValues = <FlexiNum?>[
        for (int j = 0; j < validLines.length; j++)
          close * multipliers[j] + prevList[j]! * (FlexiNum.one - multipliers[j]),
      ];
      list[i].setList(dataIndex, emaValues);
    }
    return true;
  }

  MinMax? calcuEmaMinmax(
    EmaParam param, {
    required int start,
    required int end,
  }) {
    final enabledLines = param.enabledLines;
    if (enabledLines.isEmpty || !klineData.checkStartAndEnd(start, end)) {
      return null;
    }

    final len = klineData.list.length;
    final maxPeriod = param.maxPeriod;
    if (maxPeriod == null || len < maxPeriod) return null;

    // 确保 end 在有效范围内
    end = end.clamp(0, len);

    // 确保数据已计算，使用安全的索引检查
    final checkIndex = (end > 0 ? end - 1 : 0).clamp(0, len - 1);
    if (!klineData.list[checkIndex].isValidEmaList(dataIndex)) {
      calcuAndCacheEma(param, start: 0, end: len);
    }

    MinMax? minmax;
    for (int i = start; i < end; i++) {
      final m = klineData.list[i];
      if (m.isValidEmaList(dataIndex)) {
        for (final emaValue in m.getEmaList(dataIndex)!) {
          if (emaValue != null) {
            minmax ??= MinMax(max: emaValue, min: emaValue);
            minmax.updateMinMaxBy(emaValue);
          }
        }
      }
    }
    return minmax;
  }
}
