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

mixin MacdDataMixin<T extends MACDIndicator> on SinglePaintObjectBox<T> {
  MACDParam get calcParam => indicator.calcParam;

  @override
  void precompute(Range range, {bool reset = false}) {
    calcuAndCacheMacd(
      calcParam,
      reset: reset,
    );
  }

  List<BagNum?> _ema(List<BagNum?> values, int period) {
    final len = values.length;
    final result = List<BagNum?>.filled(len, null);
    if (len < period) return result;

    final multiplier = BagNum.fromNum(2.0 / (period + 1));

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

    BagNum sum = BagNum.zero;
    for (int i = firstValidIndex; i < firstValidIndex + period; i++) {
      sum += values[i]!;
    }
    result[firstValidIndex + period - 1] = sum.divNum(period);

    for (int i = firstValidIndex + period; i < len; i++) {
      final value = values[i];
      final prevEma = result[i - 1];
      if (value != null && prevEma != null) {
        result[i] = value * multiplier + prevEma * (BagNum.one - multiplier);
      } else if (prevEma != null) {
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

    final closeValues = list.map((c) => c.close).toList();

    final emaS = _ema(closeValues, s);
    final emaL = _ema(closeValues, l);

    final difList = List<BagNum?>.filled(len, null);
    for (int i = 0; i < len; i++) {
      if (emaS[i] != null && emaL[i] != null) {
        difList[i] = emaS[i]! - emaL[i]!;
      }
    }

    final deaList = _ema(difList, m);

    for (int i = 0; i < len; i++) {
      final dif = difList[i];
      final dea = deaList[i];
      if (dif != null && dea != null) {
        final macd = (dif - dea) * BagNum.two;
        list[i].macdList = [dif, dea, macd];
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
          minmax.updateMinMaxBy(dea);
          minmax.updateMinMaxBy(macd);
        } else {
          minmax.updateMinMaxBy(dif);
          minmax.updateMinMaxBy(dea);
          minmax.updateMinMaxBy(macd);
        }
      }
    }
    return minmax;
  }
}
