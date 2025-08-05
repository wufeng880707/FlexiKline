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
extension CandleMacdExt on CandleModel {
  static const int _macdIndex = 3;
  List<BagNum?>? get macdList => calcuData.getData(_macdIndex);
  set macdList(List<BagNum?>? value) => calcuData.setData(_macdIndex, value);
  BagNum? get dif => macdList?.getItem(0);
  BagNum? get dea => macdList?.getItem(1);
  BagNum? get macd => macdList?.getItem(2);
  bool get isValidMacdData => macdList != null && dif != null && dea != null && macd != null;
  void cleanMacd() => macdList = null;
}

mixin MacdDataMixin<T extends MACDIndicator> on PaintObjectBox<T> {
  MACDParam get calcParam => indicator.calcParam;

  @override
  void precompute(Range range, {bool reset = false}) {
    calcuAndCacheMacd(
      calcParam,
      reset: reset,
    );
  }

  /// 计算EMA，要求传入的`values`是按时间从旧到新排列的.
  List<BagNum?> _ema(List<BagNum?> values, int period) {
    final len = values.length;
    final result = List<BagNum?>.filled(len, null);
    if (len < period) return result;

    final multiplier = BagNum.fromNum(2.0 / (period + 1));

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
    BagNum sum = BagNum.zero;
    for (int i = firstValidIndex; i < firstValidIndex + period; i++) {
      sum += values[i]!;
    }
    result[firstValidIndex + period - 1] = sum.divNum(period);

    // 迭代计算后续的EMA值
    for (int i = firstValidIndex + period; i < len; i++) {
      final value = values[i];
      final prevEma = result[i - 1];
      if (value != null && prevEma != null) {
        result[i] = value * multiplier + prevEma * (BagNum.one - multiplier);
      } else if (prevEma != null) {
        // 如果当前值为空, 则沿用上一个EMA值.
        result[i] = prevEma;
      }
    }
    return result;
  }

  void calcuAndCacheMacd(
    MACDParam param, {
    bool reset = false,
  }) {
    final list = klineData.list;
    final len = list.length;
    if (reset) {
      for (final m in list) {
        m.cleanMacd();
      }
    }

    final s = param.s;
    final l = param.l;
    final m = param.m;

    if (len < l) return;

    // klineData.list 是从新到旧的, 需要反转为从旧到新来计算.
    final closeValues = list.map((c) => c.close).toList().reversed.toList();

    // 1. 计算短期和长期EMA
    final emaS = _ema(closeValues, s);
    final emaL = _ema(closeValues, l);

    // 2. 计算DIF
    final difList = List<BagNum?>.filled(len, null);
    for (int i = 0; i < len; i++) {
      if (emaS[i] != null && emaL[i] != null) {
        difList[i] = emaS[i]! - emaL[i]!;
      }
    }

    // 3. 计算DEA (DIF的EMA)
    final deaList = _ema(difList, m);

    // 4. 计算MACD柱
    final macdList = List<BagNum?>.filled(len, null);
    for (int i = 0; i < len; i++) {
      final dif = difList[i];
      final dea = deaList[i];
      if (dif != null && dea != null) {
        macdList[i] = (dif - dea) * BagNum.two;
      }
    }

    // 5. 将所有计算结果(从旧到新)反转回来, 以匹配原始list(从新到旧)的顺序.
    final finalDif = difList.reversed.toList();
    final finalDea = deaList.reversed.toList();
    final finalMacd = macdList.reversed.toList();

    // 6. 赋值
    for (int i = 0; i < len; i++) {
      if (finalDif[i] != null && finalDea[i] != null && finalMacd[i] != null) {
        list[i].macdList = [finalDif[i], finalDea[i], finalMacd[i]];
      } else {
        if (reset) {
          list[i].macdList = null;
        }
      }
    }
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
      if (m.isValidMacdData) {
        final dif = m.dif!;
        final dea = m.dea!;
        final macd = m.macd!;

        if (minmax == null) {
          minmax = MinMax(max: dif, min: dif);
        }
        minmax.updateMinMaxBy(dif);
        minmax.updateMinMaxBy(dea);
        minmax.updateMinMaxBy(macd);
      }
    }
    return minmax;
  }
}
