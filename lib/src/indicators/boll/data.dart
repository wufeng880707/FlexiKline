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

part of 'boll.dart';

@visibleForTesting
extension CandleBollExt on CandleModel {
  // 假设BOLL的dataIndex为2（如有不同请调整）
  static const int _bollIndex = 2;

  List<BagNum?>? get _bollList => calcuData.getData(_bollIndex);
  set _bollList(List<BagNum?>? value) => calcuData.setData(_bollIndex, value);

  BagNum? get mb {
    final list = _bollList;
    if (list != null && list.length == 3) return list[0];
    return null;
  }
  set mb(BagNum? value) {
    var list = _bollList;
    if (list == null || list.length != 3) list = List.filled(3, null);
    list[0] = value;
    _bollList = list;
  }

  BagNum? get up {
    final list = _bollList;
    if (list != null && list.length == 3) return list[1];
    return null;
  }
  set up(BagNum? value) {
    var list = _bollList;
    if (list == null || list.length != 3) list = List.filled(3, null);
    list[1] = value;
    _bollList = list;
  }

  BagNum? get dn {
    final list = _bollList;
    if (list != null && list.length == 3) return list[2];
    return null;
  }
  set dn(BagNum? value) {
    var list = _bollList;
    if (list == null || list.length != 3) list = List.filled(3, null);
    list[2] = value;
    _bollList = list;
  }

  bool get isValidBollData => mb != null && up != null && dn != null;
  MinMax? get bollMinmax {
    if (!isValidBollData) return null;
    return MinMax(max: mb!, min: mb!)..updateMinMaxBy(up!)..updateMinMaxBy(dn!);
  }
}

mixin BollDataMixin<T extends BOLLIndicator> on SinglePaintObjectBox<T> {
  BOLLParam get calcParam => indicator.calcParam;

  @override
  void precompute(Range range, {bool reset = false}) {
    calcuAndCacheBoll(
      calcParam,
      start: range.start,
      end: range.end,
      reset: reset,
    );
  }

  /// 计算BOLL指标值
  void _calculateBoll(
    BOLLParam param, {
    required int start,
    required int end,
  }) {
    final len = klineData.list.length;
    if (param.n > len || !klineData.checkStartAndEnd(start, end)) return;
    logd('calculateBoll [end:$end ~ start:$start] n:${param.n}');

    end = math.min(len - param.n, end - 1);

    for (int i = end; i >= start; i--) {
      final m = klineData.list[i];
      if (i + param.n > len) continue;

      // 计算移动平均
      BagNum sum = m.close;
      for (int j = i + 1; j < i + param.n; j++) {
        sum += klineData.list[j].close;
      }
      final ma = sum.divNum(param.n);

      // 计算标准差
      double variance = (m.close.toDouble() - ma.toDouble()) * (m.close.toDouble() - ma.toDouble());
      for (int j = i + 1; j < i + param.n; j++) {
        variance += (klineData.list[j].close.toDouble() - ma.toDouble()) * (klineData.list[j].close.toDouble() - ma.toDouble());
      }
      final std = BagNum.fromNum(math.sqrt(variance / param.n));

      // 设置BOLL值
      m.mb = ma;
      m.up = ma + std * BagNum.fromNum(param.std);
      m.dn = ma - std * BagNum.fromNum(param.std);
    }
  }

  void calcuAndCacheBoll(
    BOLLParam calcParam, {
    required int start,
    required int end,
    bool reset = false,
  }) {
    if (klineData.isEmpty) return;
    _calculateBoll(
      calcParam,
      start: math.max(0, start - calcParam.n), // 补起上一次未算数据
      end: end,
    );
  }

  /// 计算并缓存BOLL数据.
  /// 如果[start]和[end]指定了, 只计算[start] ~ [end]区间内的BOLL值.
  /// 否则, 从当前可视区域的[start] ~ [end]开始计算.
  MinMax? calcuBollMinmax(
    BOLLParam param, {
    int? start,
    int? end,
  }) {
    start ??= klineData.start;
    end ??= klineData.end;
    if (!klineData.checkStartAndEnd(start, end)) {
      return null;
    }

    final len = klineData.list.length;
    end = math.min(len - param.n, end - 1);

    if (!klineData.list[end].isValidBollData) {
      calcuAndCacheBoll(param, start: 0, end: len);
    }

    MinMax? minmax;
    CandleModel m;
    for (int i = end; i >= start; i--) {
      m = klineData.list[i];
      if (m.isValidBollData) {
        minmax ??= m.bollMinmax;
        minmax?.updateMinMax(m.bollMinmax);
      }
    }
    return minmax;
  }
} 