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

part of 'kdj.dart';

@visibleForTesting
extension CandleKdjExt on CandleModel {
  // 假设KDJ的dataIndex为3（如有不同请调整）
  static const int _kdjIndex = 7;

  List<BagNum?>? get _kdjList => calcuData.getData(_kdjIndex);
  set _kdjList(List<BagNum?>? value) => calcuData.setData(_kdjIndex, value);

  BagNum? get k {
    final list = _kdjList;
    if (list != null && list.length == 3) return list[0];
    return null;
  }

  set k(BagNum? value) {
    var list = _kdjList;
    if (list == null || list.length != 3) list = List.filled(3, null);
    list[0] = value;
    _kdjList = list;
  }

  BagNum? get d {
    final list = _kdjList;
    if (list != null && list.length == 3) return list[1];
    return null;
  }

  set d(BagNum? value) {
    var list = _kdjList;
    if (list == null || list.length != 3) list = List.filled(3, null);
    list[1] = value;
    _kdjList = list;
  }

  BagNum? get j {
    final list = _kdjList;
    if (list != null && list.length == 3) return list[2];
    return null;
  }

  set j(BagNum? value) {
    var list = _kdjList;
    if (list == null || list.length != 3) list = List.filled(3, null);
    list[2] = value;
    _kdjList = list;
  }

  bool get isValidKdjData => k != null && d != null && j != null;
  MinMax? get kdjMinmax {
    if (!isValidKdjData) return null;
    return MinMax(max: k!, min: k!)
      ..updateMinMaxBy(d!)
      ..updateMinMaxBy(j!);
  }
}

mixin KdjDataMixin<T extends KDJIndicator> on PaintObjectBox<T> {
  KDJParam get calcParam => indicator.calcParam;

  @override
  void precompute(Range range, {bool reset = false}) {
    calcuAndCacheKdj(
      calcParam,
      start: range.start,
      end: range.end,
      reset: reset,
    );
  }

  /// 计算KDJ指标值
  void _calculateKdj(
    KDJParam param, {
    required int start,
    required int end,
  }) {
    final len = klineData.list.length;
    if (param.n > len || !klineData.checkStartAndEnd(start, end)) return;
    logd('calculateKdj [end:$end ~ start:$start] n:${param.n}');

    end = math.min(len - param.n, end - 1);

    for (int i = end; i >= start; i--) {
      final m = klineData.list[i];
      if (i + param.n > len) continue;

      // 计算RSV
      BagNum high = m.high;
      BagNum low = m.low;
      for (int j = i + 1; j < i + param.n; j++) {
        final candle = klineData.list[j];
        if (candle.high > high) high = candle.high;
        if (candle.low < low) low = candle.low;
      }

      final rsv =
          high == low ? BagNum.fromNum(50) : ((m.close - low) / (high - low)) * BagNum.fromNum(100);

      // 计算K值
      BagNum k = BagNum.fromNum(50);
      if (i < len - 1) {
        final prevK = klineData.list[i + 1].k ?? BagNum.fromNum(50);
        k = (prevK * BagNum.fromNum(param.m1 - 1) + rsv) / BagNum.fromNum(param.m1);
      } else {
        k = rsv;
      }

      // 计算D值
      BagNum d = BagNum.fromNum(50);
      if (i < len - 1) {
        final prevD = klineData.list[i + 1].d ?? BagNum.fromNum(50);
        d = (prevD * BagNum.fromNum(param.m2 - 1) + k) / BagNum.fromNum(param.m2);
      } else {
        d = k;
      }

      // 计算J值
      final j = k * BagNum.fromNum(3) - d * BagNum.fromNum(2);

      // 设置KDJ值
      m.k = k;
      m.d = d;
      m.j = j;
    }
  }

  void calcuAndCacheKdj(
    KDJParam calcParam, {
    required int start,
    required int end,
    bool reset = false,
  }) {
    if (klineData.isEmpty) return;
    _calculateKdj(
      calcParam,
      start: math.max(0, start - calcParam.n), // 补起上一次未算数据
      end: end,
    );
  }

  /// 计算并缓存KDJ数据.
  /// 如果[start]和[end]指定了, 只计算[start] ~ [end]区间内的KDJ值.
  /// 否则, 从当前可视区域的[start] ~ [end]开始计算.
  MinMax? calcuKdjMinmax(
    KDJParam param, {
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

    if (!klineData.list[end].isValidKdjData) {
      calcuAndCacheKdj(param, start: 0, end: len);
    }

    MinMax? minmax;
    CandleModel m;
    for (int i = end; i >= start; i--) {
      m = klineData.list[i];
      if (m.isValidKdjData) {
        minmax ??= m.kdjMinmax;
        minmax?.updateMinMax(m.kdjMinmax);
      }
    }
    return minmax;
  }
}
