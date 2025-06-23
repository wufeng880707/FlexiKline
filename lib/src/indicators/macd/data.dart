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
  bool get isValidMacdData => macdList != null && macdList!.any((e) => e != null);
  void cleanMacd() => macdList = null;
}

mixin MacdDataMixin<T extends MACDIndicator> on SinglePaintObjectBox<T> {
  MACDParam get calcParam => indicator.calcParam;

  @override
  void precompute(Range range, {bool reset = false}) {
    calcuAndCacheMacd(
      calcParam,
      start: range.start,
      end: range.end,
      reset: reset,
    );
  }

  /// 计算EMA (指数移动平均线)
  BagNum _calculateEMA(int index, int period) {
    if (index >= klineData.list.length) return BagNum.zero;
    
    final m = klineData.list[index];
    if (index == klineData.list.length - 1) {
      return m.close;
    }
    
    final prevEMA = _calculateEMA(index + 1, period);
    final multiplier = BagNum.fromNum(2.0 / (period + 1));
    return m.close * multiplier + prevEMA * (BagNum.one - multiplier);
  }

  /// 计算MACD指标值
  void _calculateMacd(
    MACDParam param, {
    required int start,
    required int end,
  }) {
    final len = klineData.list.length;
    if (param.l > len || !klineData.checkStartAndEnd(start, end)) return;
    logd('calculateMacd [end:$end ~ start:$start] s:${param.s}, l:${param.l}, m:${param.m}');

    end = math.min(len - param.l, end - 1);

    for (int i = end; i >= start; i--) {
      final m = klineData.list[i];
      if (i + param.l > len) continue;

      // 计算短期和长期EMA
      final emaShort = _calculateEMA(i, param.s);
      final emaLong = _calculateEMA(i, param.l);
      
      // 计算DIF (差离值)
      final dif = emaShort - emaLong;
      
      // 计算DEA (信号线)
      BagNum dea;
      if (i == len - 1) {
        dea = dif;
      } else {
        final prevDEA = klineData.list[i + 1].dea ?? dif;
        final multiplier = BagNum.fromNum(2.0 / (param.m + 1));
        dea = dif * multiplier + prevDEA * (BagNum.one - multiplier);
      }
      
      // 计算MACD (柱状图)
      final macd = (dif - dea) * BagNum.fromNum(2);
      
      // 设置MACD值
      m.macdList = [dif, dea, macd];
    }
  }

  void calcuAndCacheMacd(
    MACDParam param, {
    required int start,
    required int end,
    bool reset = false,
  }) {
    if (klineData.isEmpty) return;
    _calculateMacd(
      param,
      start: math.max(0, start - param.l), // 补起上一次未算数据
      end: end,
    );
  }

  /// 计算并缓存MACD数据.
  /// 如果[start]和[end]指定了, 只计算[start] ~ [end]区间内的MACD值.
  /// 否则, 从当前可视区域的[start] ~ [end]开始计算.
  MinMax? calcuMacdMinmax(
    MACDParam param, {
    int? start,
    int? end,
  }) {
    start ??= klineData.start;
    end ??= klineData.end;
    if (!klineData.checkStartAndEnd(start, end)) {
      return null;
    }

    final len = klineData.list.length;
    end = math.min(len - param.l, end - 1);

    if (!klineData.list[end].isValidMacdData) {
      calcuAndCacheMacd(param, start: 0, end: len);
    }

    MinMax? minmax;
    CandleModel m;
    for (int i = end; i >= start; i--) {
      m = klineData.list[i];
      if (m.isValidMacdData) {
        final dif = m.dif!;
        final dea = m.dea!;
        final macd = m.macd!;
        
        minmax ??= MinMax(max: dif, min: dif);
        minmax?.updateMinMaxBy(dea);
        minmax?.updateMinMaxBy(macd);
      }
    }
    return minmax;
  }
} 