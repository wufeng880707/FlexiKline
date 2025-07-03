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

part of 'avl.dart';

@visibleForTesting
extension CandleAvlExt on CandleModel {
  // AVL 数据索引
  static const int _avlIndex = 10;

  List<BagNum?>? get _avlList => calcuData.getData(_avlIndex);
  set _avlList(List<BagNum?>? value) => calcuData.setData(_avlIndex, value);

  BagNum? get avl {
    final list = _avlList;
    if (list != null && list.isNotEmpty) return list[0];
    return null;
  }

  set avl(BagNum? value) {
    var list = _avlList;
    if (list == null || list.isEmpty) list = [null];
    list[0] = value;
    _avlList = list;
  }

  bool get isValidAvlData => avl != null;
  MinMax? get avlMinmax {
    if (!isValidAvlData) return null;
    return MinMax(max: avl!, min: avl!);
  }
}

mixin AvlDataMixin<T extends AVLIndicator> on SinglePaintObjectBox<T> {
  AVLParam get calcParam => indicator.calcParam;

  @override
  void precompute(Range range, {bool reset = false}) {
    calcuAndCacheAvl(
      calcParam,
      start: range.start,
      end: range.end,
      reset: reset,
    );
  }

  /// 计算AVL指标值
  void _calculateAvl(
    AVLParam param, {
    required int start,
    required int end,
  }) {
    final len = klineData.list.length;
    if (!param.isValid(len) || !klineData.checkStartAndEnd(start, end)) return;
    logd('calculateAvl [end:$end ~ start:$start]');

    final safeEnd = end.clamp(0, len);
    for (int i = start; i < safeEnd; i++) {
      final m = klineData.list[i];
      if (m.volCcy != null && !m.vol.isZero) {
        // AVL = 总成交金额 / 总成交股数
        m.avl = m.volCcy!.div(m.vol);
      }
    }
  }

  void calcuAndCacheAvl(
    AVLParam calcParam, {
    required int start,
    required int end,
    bool reset = false,
  }) {
    if (klineData.isEmpty) return;
    _calculateAvl(
      calcParam,
      start: start,
      end: end,
    );
  }

  /// 计算并缓存AVL数据.
  /// 如果[start]和[end]指定了, 只计算[start] ~ [end]区间内的AVL值.
  /// 否则, 从当前可视区域的[start] ~ [end]开始计算.
  MinMax? calcuAvlMinmax(
    AVLParam param, {
    int? start,
    int? end,
  }) {
    start ??= klineData.start;
    end ??= klineData.end;
    if (!klineData.checkStartAndEnd(start, end)) {
      return null;
    }

    MinMax? minmax;
    CandleModel m;
    for (int i = start; i <= end; i++) {
      m = klineData.list[i];
      if (m.isValidAvlData) {
        minmax ??= m.avlMinmax;
        minmax?.updateMinMax(m.avlMinmax);
      }
    }
    return minmax;
  }
}
