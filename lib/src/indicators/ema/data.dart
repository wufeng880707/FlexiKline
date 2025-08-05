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
extension CandleEmaExt on CandleModel {
  static const int _emaIndex = 6;
  List<BagNum?>? get emaList => calcuData.getData(_emaIndex);
  set emaList(List<BagNum?>? value) => calcuData.setData(_emaIndex, value);
  bool get isValidEmaList => emaList != null && emaList!.any((e) => e != null);
  void cleanEma() => emaList = null;
}

mixin EmaDataMixin<T extends EMAIndicator> on SinglePaintObjectBox<T> {
  List<ma_param.MaParam> get calcParams => indicator.calcParams;

  @override
  void precompute(Range range, {bool reset = false}) {
    calcuAndCacheEma(
      calcParams,
      start: range.start,
      end: range.end,
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

  void calcuAndCacheEma(
    List<ma_param.MaParam> params, {
    required int start,
    required int end,
    bool reset = false,
  }) {
    if (klineData.isEmpty || params.isEmpty) return;
    
    final list = klineData.list;
    final len = list.length;
    
    if (reset) {
      for (final m in list) {
        m.cleanEma();
      }
    }

    // 获取最大周期，确保有足够的数据
    final maxCount = ma_param.MaParam.getMaxCountByList(params);
    if (maxCount == null || len < maxCount) return;

    // klineData.list 是从新到旧的, 需要反转为从旧到新来计算.
    final closeValues = list.map((c) => c.close).toList().reversed.toList();

    // 为每个参数计算EMA
    final emaResults = <List<BagNum?>>[];
    for (final param in params) {
      final emaResult = _ema(closeValues, param.count);
      emaResults.add(emaResult);
    }

    // 将计算结果(从旧到新)反转回来, 以匹配原始list(从新到旧)的顺序.
    for (int i = 0; i < len; i++) {
      final emaValues = <BagNum?>[];
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
        list[i].emaList = emaValues;
      } else {
        if (reset) {
          list[i].emaList = null;
        }
      }
    }
  }

  MinMax? calcuEmaMinmax(
    List<ma_param.MaParam> params, {
    required int start,
    required int end,
  }) {
    if (params.isEmpty || !klineData.checkStartAndEnd(start, end)) {
      return null;
    }

    final len = klineData.list.length;
    final maxCount = ma_param.MaParam.getMaxCountByList(params);
    if (maxCount == null || len < maxCount) return null;

    // 确保 end 不越界
    final safeEnd = end.clamp(0, len - 1);

    // 确保数据已计算
    if (!klineData.list[safeEnd].isValidEmaList) {
      calcuAndCacheEma(params, start: 0, end: len);
    }

    MinMax? minmax;
    for (int i = start; i <= safeEnd; i++) {
      if (i >= len) break; // 额外安全检查
      final m = klineData.list[i];
      if (m.isValidEmaList) {
        for (final emaValue in m.emaList!) {
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