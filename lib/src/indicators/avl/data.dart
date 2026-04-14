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
extension CandleAvlExt on FlexiCandleModel {
  /// 直接计算AVL均价线：(开盘价 + 最高价 + 最低价 + 收盘价) / 4
  /// 不使用缓存，每次都实时计算
  FlexiNum get avl => (open + high + low + close).divNum(4);

  bool get isValidAvlData => true; // AVL总是可以计算的
  
  MinMax get avlMinmax => MinMax(max: avl, min: avl);
}

mixin AvlDataMixin<T extends AVLIndicator> on DataPaintObject<T> {
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


  void calcuAndCacheAvl(
    AVLParam calcParam, {
    required int start,
    required int end,
    bool reset = false,
  }) {
    // AVL现在是实时计算的，不需要预计算和缓存
    logd('calcuAndCacheAvl: AVL使用实时计算，无需预处理');
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

    final len = klineData.list.length;
    if (len == 0) return null;
    
    // 确保 start 和 end 在有效范围内
    start = start.clamp(0, len - 1);
    end = end.clamp(0, len - 1);
    
    MinMax? minmax;
    for (int i = start; i <= end; i++) {
      final m = klineData.list[i];
      if (m.isValidAvlData) {
        minmax ??= m.avlMinmax;
        minmax.updateMinMax(m.avlMinmax);
      }
    }
    return minmax;
  }
}
