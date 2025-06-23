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

  void calcuAndCacheMacd(
    MACDParam param, {
    required int start,
    required int end,
    bool reset = false,
  }) {
    if (klineData.isEmpty) return;
    // MACD计算逻辑（略，按原有实现迁移）
    // ...
  }

  MinMax? calcuMacdMinmax(
    MACDParam param, {
    required int start,
    required int end,
  }) {
    // 计算MACD区间最值（略，按原有实现迁移）
    // ...
    return null;
  }
} 