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

part of 'macd.dart';

@visibleForTesting
extension CandleMacdExt on FlexiCandleModel {
  List<FlexiNum?>? macdList(int dataIndex) => getList<FlexiNum>(dataIndex);

  FlexiNum? macdDif(int dataIndex) {
    final list = macdList(dataIndex);
    return (list != null && list.isNotEmpty) ? list[0] : null;
  }

  FlexiNum? macdDea(int dataIndex) {
    final list = macdList(dataIndex);
    return (list != null && list.length > 1) ? list[1] : null;
  }

  FlexiNum? macdVal(int dataIndex) {
    final list = macdList(dataIndex);
    return (list != null && list.length > 2) ? list[2] : null;
  }

  bool isValidMacdData(int dataIndex) {
    final list = macdList(dataIndex);
    return list != null && list.length >= 3 && list[0] != null && list[1] != null && list[2] != null;
  }

  void cleanMacd(int dataIndex) => clean(dataIndex);
}

mixin MacdDataMixin<T extends MACDIndicator> on IndicatorCalculationScope<T> {
  MACDParam get calcParam => indicator.calcParam;

  void computeIndicatorData(Range range, {bool reset = false}) {
    calcuAndCacheMacd(
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

  void calcuAndCacheMacd(
    MACDParam param, {
    required int start,
    required int end,
    bool reset = false,
  }) {
    final list = klineData.list;
    final len = list.length;
    if (reset) {
      for (final m in list) {
        m.cleanMacd(dataIndex);
      }
    }

    // 📊 从配置中获取计算参数
    final s = param.s; // 短周期 EMA (如: 12)
    final l = param.l; // 长周期 EMA (如: 26)
    final m = param.m; // 信号周期 EMA (如: 9)

    // 📋 验证配置参数的有效性
    if (!param.isValid(len)) {
      // 参数无效时直接返回，避免无效计算
      return;
    }

    // updateLatest 等局部脏区间：以 [end] 处已存的内部锚点(emaS/emaL/dea)递推 [start, end)。
    if (!reset && end < len && _tryIncrementalMacd(param, start: start, end: end)) {
      return;
    }

    // klineData.list 是从新到旧的, 需要反转为从旧到新来计算.
    final closeValues = list.map((c) => c.close).toList().reversed.toList();

    // 1. 计算短期和长期EMA
    final emaS = _ema(closeValues, s);
    final emaL = _ema(closeValues, l);

    // 2. 计算DIF
    final difList = List<FlexiNum?>.filled(len, null);
    for (int i = 0; i < len; i++) {
      if (emaS[i] != null && emaL[i] != null) {
        difList[i] = emaS[i]! - emaL[i]!;
      }
    }

    // 3. 计算DEA (DIF的EMA)
    final deaList = _ema(difList, m);

    // 4. 计算MACD柱 (根据配置决定是否启用柱状图)
    final macdList = List<FlexiNum?>.filled(len, null);
    if (param.histogramEnabled) {
      for (int i = 0; i < len; i++) {
        final dif = difList[i];
        final dea = deaList[i];
        if (dif != null && dea != null) {
          macdList[i] = (dif - dea) * FlexiNum.two;
        }
      }
    }

    // 5. 将所有计算结果(从旧到新)反转回来, 以匹配原始list(从新到旧)的顺序.
    final finalDif = difList.reversed.toList();
    final finalDea = deaList.reversed.toList();
    final finalMacd = macdList.reversed.toList();
    final finalEmaS = emaS.reversed.toList();
    final finalEmaL = emaL.reversed.toList();

    // 6. 根据配置存储计算结果
    // 布局: [dif?, dea?, macd?, emaS, emaL, dea] —— 后三位为增量递推锚点，
    // 不受线条开关影响始终存储（0~2 位按配置可置 null）。
    for (int i = 0; i < len; i++) {
      final dif = finalDif[i];
      final dea = finalDea[i];
      final macd = finalMacd[i];
      final emaSValue = finalEmaS[i];
      final emaLValue = finalEmaL[i];

      final hasInternal = emaSValue != null && emaLValue != null;

      // 📊 根据线条配置决定是否存储相应数据
      final shouldStoreDif = param.difLine.enabled && dif != null;
      final shouldStoreDea = param.deaLine.enabled && dea != null;
      final shouldStoreMacd = param.histogramEnabled && macd != null;

      if (shouldStoreDif || shouldStoreDea || shouldStoreMacd || hasInternal) {
        list[i].setList<FlexiNum>(dataIndex, [
          shouldStoreDif ? dif : null,
          shouldStoreDea ? dea : null,
          shouldStoreMacd ? macd : null,
          emaSValue,
          emaLValue,
          dea,
        ]);
      } else if (reset) {
        list[i].clean(dataIndex);
      }
    }
  }

  /// 增量计算 [start, end) 区间的 MACD。
  ///
  /// list 按时间从新到旧排列，递推方向为旧→新（下标递减）：
  /// - `emaS[i] = close[i]*kS + emaS[i+1]*(1-kS)`（emaL 同理）
  /// - `dif[i] = emaS[i] - emaL[i]`
  /// - `dea[i] = dif[i]*kM + dea[i+1]*(1-kM)`
  /// - `macd[i] = (dif[i] - dea[i]) * 2`
  ///
  /// index [end] 未被本次更新影响，其已存锚点(emaS/emaL/dea)启动递推；
  /// 锚点缺失（seed 区/布局不符）时返回 false，由调用方回退全量。
  bool _tryIncrementalMacd(
    MACDParam param, {
    required int start,
    required int end,
  }) {
    final list = klineData.list;
    final anchorList = list[end].macdList(dataIndex);
    if (anchorList == null || anchorList.length < 6) return false;
    final anchorEmaS = anchorList[3];
    final anchorEmaL = anchorList[4];
    final anchorDea = anchorList[5];
    if (anchorEmaS == null || anchorEmaL == null || anchorDea == null) return false;

    final multS = FlexiNum.fromNum(2.0 / (param.s + 1));
    final multL = FlexiNum.fromNum(2.0 / (param.l + 1));
    final multM = FlexiNum.fromNum(2.0 / (param.m + 1));

    for (int i = end - 1; i >= start; i--) {
      final prevList = list[i + 1].macdList(dataIndex)!;
      final prevEmaS = prevList[3]!;
      final prevEmaL = prevList[4]!;
      final prevDea = prevList[5]!;

      final close = list[i].close;
      final emaSValue = close * multS + prevEmaS * (FlexiNum.one - multS);
      final emaLValue = close * multL + prevEmaL * (FlexiNum.one - multL);
      final dif = emaSValue - emaLValue;
      final dea = dif * multM + prevDea * (FlexiNum.one - multM);
      final macd = (dif - dea) * FlexiNum.two;

      final shouldStoreDif = param.difLine.enabled;
      final shouldStoreDea = param.deaLine.enabled;
      final shouldStoreMacd = param.histogramEnabled;

      list[i].setList<FlexiNum>(dataIndex, [
        shouldStoreDif ? dif : null,
        shouldStoreDea ? dea : null,
        shouldStoreMacd ? macd : null,
        emaSValue,
        emaLValue,
        dea,
      ]);
    }
    return true;
  }

  MinMax? calcuMacdMinmax(
    MACDParam param, {
    required int start,
    required int end,
  }) {
    if (!klineData.checkStartAndEnd(start, end)) {
      return null;
    }

    MinMax? minmax;
    for (int i = start; i < end; i++) {
      final m = klineData.list[i];
      if (m.macdList(dataIndex) != null) {
        final dif = m.macdDif(dataIndex);
        final dea = m.macdDea(dataIndex);
        final macd = m.macdVal(dataIndex);

        if (param.difLine.enabled && dif != null) {
          if (minmax == null) {
            minmax = MinMax(max: dif, min: dif);
          } else {
            minmax.updateMinMaxBy(dif);
          }
        }

        if (param.deaLine.enabled && dea != null) {
          if (minmax == null) {
            minmax = MinMax(max: dea, min: dea);
          } else {
            minmax.updateMinMaxBy(dea);
          }
        }

        if (param.histogramEnabled && macd != null) {
          if (minmax == null) {
            minmax = MinMax(max: macd, min: macd);
          } else {
            minmax.updateMinMaxBy(macd);
          }
        }

        // 📏 如果启用零轴线，确保包含零点在范围内
        if (param.showZeroLine && minmax != null) {
          minmax.updateMinMaxBy(FlexiNum.zero);
        }
      }
    }
    return minmax;
  }
}
