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
  /// 计算 AVL 值：(open + close + high + low) / 4
  BagNum? get avl {
    if (o == Decimal.zero && c == Decimal.zero && h == Decimal.zero && l == Decimal.zero) {
      return null;
    }
    final open = BagNum.fromDecimal(o);
    final close = BagNum.fromDecimal(c);
    final high = BagNum.fromDecimal(h);
    final low = BagNum.fromDecimal(l);
    return open.add(close).add(high).add(low).div(BagNum.fromNum(4));
  }

  bool get isValidAvlData => avl != null;
  
  MinMax? get avlMinmax {
    if (!isValidAvlData) return null;
    return MinMax(max: avl!, min: avl!);
  }
}

mixin AvlDataMixin<T extends AVLIndicator> on SinglePaintObjectBox<T> {
  /// 计算AVL指标的最小最大值
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

    // 确保 end 不越界
    final len = klineData.list.length;
    final safeEnd = end.clamp(0, len - 1);

    MinMax? minmax;
    for (int i = start; i <= safeEnd; i++) {
      if (i >= len) break; // 额外安全检查
      final m = klineData.list[i];
      if (m.isValidAvlData) {
        minmax ??= m.avlMinmax;
        minmax?.updateMinMax(m.avlMinmax);
      }
    }
    return minmax;
  }
}
