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
  static const int _emaIndex = 2;
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

  void calcuAndCacheEma(
    List<ma_param.MaParam> params, {
    required int start,
    required int end,
    bool reset = false,
  }) {
    if (klineData.isEmpty) return;
    // EMA计算逻辑（略，按原有实现迁移）
    // ...
  }

  MinMax? calcuEmaMinmax(
    List<ma_param.MaParam> params, {
    required int start,
    required int end,
  }) {
    // 计算EMA区间最值（略，按原有实现迁移）
    // ...
    return null;
  }
} 