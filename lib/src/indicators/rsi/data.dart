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

mixin RsiDataMixin<T extends RSIIndicator> on PaintObjectBox<T> {
  @override
  List<RsiParam> get calcParams => indicator.calcParams;

  @override
  void precompute(Range range, {bool reset = false}) {
    calcuAndCacheRsi(
      calcParams,
      start: range.start,
      end: range.end,
      reset: reset,
    );
  }

  /// 计算RSI指标值
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

    /// RSI要从end前的count+1个数据开始计算.
    final index = math.min(end + count, len - 1);

    CandleModel m = klineData.list[index];
    BagNum prevClose = m.close;
    BagNum sumGain = BagNum.zero;
    BagNum sumLoss = BagNum.zero;
    BagNum? avgGain;
    BagNum? avgLoss;
    BagNum diff;
    BagNum gain = BagNum.zero;
    BagNum loss = BagNum.zero;
    for (int i = index - 1; i >= start; i--) {
      m = klineData.list[i];

      diff = m.close - prevClose;
      prevClose = m.close;
      if (diff.signum > 0) {
        gain = diff;
        loss = BagNum.zero;
        sumGain = gain + sumGain;
      } else {
        loss = diff.abs();
        gain = BagNum.zero;
        sumLoss = loss + sumLoss;
      }

      if (i <= index - count) {
        m.rsiList ??= List.filled(paramLen, null, growable: false);

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

        m.rsiList![paramIndex] =
            avgLoss == BagNum.zero ? 0 : 100 - (100 / (1 + avgGain.div(avgLoss).toDouble()));

        diff = _calculateUpVal(i + count - 1);
        if (diff.signum > 0) {
          sumGain -= diff;
        } else {
          sumLoss -= diff.abs();
        }
      }
    }
  }

  /// 计算[index]位置的RSI指标上升值
  BagNum _calculateUpVal(int index) {
    final list = klineData.list;
    if (index >= 0 && index < list.length - 1) {
      return list[index].close - list[index + 1].close;
    }
    return BagNum.zero;
  }

  void calcuAndCacheRsi(
    List<RsiParam> calcParams, {
    int? start,
    int? end,
    bool reset = false,
  }) {
    if (klineData.isEmpty || calcParams.isEmpty) return;
    final paramLen = calcParams.length;
    for (int i = 0; i < paramLen; i++) {
      _calculateRsi(
        calcParams[i].count,
        paramIndex: i,
        paramLen: paramLen,
        start: math.max(0, (start ?? klineData.start) - calcParams[i].count), // 补起上一次未算数据
        end: end ?? klineData.end,
      );
    }
  }

  MinMax? calcuRsiMinmax(
    List<RsiParam> calcParams, {
    int? start,
    int? end,
  }) {
    start ??= klineData.start;
    end ??= klineData.end;
    if (calcParams.isEmpty || !klineData.checkStartAndEnd(start, end)) return null;
    final len = klineData.list.length;

    int minCount = RsiParam.getMinCountByList(calcParams)!;
    if (len < minCount) return null; // 数据不足，直接返回
    end = math.min(len - minCount - 1, end - 1);
    if (end < start) return null; // 区间非法，直接返回

    if (!klineData.list[end].isValidRsiList) {
      calcuAndCacheRsi(calcParams, start: 0, end: len);
    }

    MinMax? minmax;
    CandleModel m;
    for (int i = end; i >= start; i--) {
      m = klineData.list[i];
      minmax ??= m.rsiListMinmax;
      minmax?.updateMinMax(m.rsiListMinmax);
    }
    return minmax;
  }
}
