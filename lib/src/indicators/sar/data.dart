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

part of 'sar.dart';

@visibleForTesting
extension CandleSarExt on CandleModel {
  // 假设SAR的dataIndex为4（如有不同请调整）
  static const int _sarIndex = 4;

  List<BagNum?>? get _sarList => calcuData.getData(_sarIndex);
  set _sarList(List<BagNum?>? value) => calcuData.setData(_sarIndex, value);

  BagNum? get sar {
    final list = _sarList;
    if (list != null && list.length == 2) return list[0];
    return null;
  }
  set sar(BagNum? value) {
    var list = _sarList;
    if (list == null || list.length != 2) list = List.filled(2, null);
    list[0] = value;
    _sarList = list;
  }

  int? get sarFlag {
    final list = _sarList;
    if (list != null && list.length == 2) return list[1]?.toDouble().toInt();
    return null;
  }
  set sarFlag(int? value) {
    var list = _sarList;
    if (list == null || list.length != 2) list = List.filled(2, null);
    list[1] = value != null ? BagNum.fromNum(value) : null;
    _sarList = list;
  }

  bool get isValidSarData => sar != null && sarFlag != null;
  
  void cleanSar() {
    _sarList = null;
  }
}

mixin SarDataMixin<T extends SARIndicator> on SinglePaintObjectBox<T> {
  SARParam get calcParam => indicator.calcParam;

  @override
  void precompute(Range range, {bool reset = false}) {
    calcuAndCacheSar(
      calcParam,
      start: range.start,
      end: range.end,
      reset: reset,
    );
  }

  /// 计算SAR指标值
  void _calculateSar(
    SARParam param, {
    required int start,
    required int end,
  }) {
    final len = klineData.list.length;
    if (!param.isValid(len) || !klineData.checkStartAndEnd(start, end)) return;
    logd('calculateSar [end:$end ~ start:$start] param:$param');

    end = end - 1;

    double af = param.startAf;
    final step = param.step;
    final maxAf = param.maxAf;
    BagNum? ep;
    bool isIncreasing = false;
    BagNum sar = BagNum.zero;
    BagNum minLow;
    BagNum maxHigh;
    CandleModel m;
    int flag = 0;
    
    for (int i = end; i >= start; i--) {
      m = klineData.list[i];
      if (isIncreasing) {
        flag = 1; // 上涨
        if (ep == null || ep < m.high) {
          ep = m.high;
          af = math.min(af + step, maxAf);
        }
        sar = (ep - sar).mulNum(af) + sar;
        minLow = m.low.calcuMin(klineData.list[math.min(i + 1, end)].low);
        if (sar > m.low) {
          sar = ep;
          // 重新初始化值
          flag = 0; // 开始上涨.
          af = param.startAf;
          ep = null;
          isIncreasing = !isIncreasing;
        } else if (sar > minLow) {
          sar = minLow;
        }
      } else {
        flag = -1; // 下跌
        if (ep == null || ep > m.low) {
          ep = m.low;
          af = math.min(af + step, maxAf);
        }
        sar = (ep - sar).mulNum(af) + sar;
        maxHigh = m.high.calcuMax(klineData.list[math.min(i + 1, end)].high);
        if (sar < m.high) {
          sar = ep;
          // 重新初始化值
          flag = 0; // 开始下跌.
          af = 0;
          ep = null;
          isIncreasing = !isIncreasing;
        } else if (sar < maxHigh) {
          sar = maxHigh;
        }
      }
      m.sarFlag = flag;
      m.sar = sar;
    }
  }

  void calcuAndCacheSar(
    SARParam calcParam, {
    required int start,
    required int end,
    bool reset = false,
  }) {
    if (klineData.isEmpty) return;
    _calculateSar(
      calcParam,
      start: math.max(0, start - 1), // 补起上一次未算数据
      end: end,
    );
  }

  /// 计算并缓存SAR数据.
  /// 如果[start]和[end]指定了, 只计算[start] ~ [end]区间内的SAR值.
  /// 否则, 从当前可视区域的[start] ~ [end]开始计算.
  MinMax? calcuSarMinmax(
    SARParam param, {
    int? start,
    int? end,
  }) {
    start ??= klineData.start;
    end ??= klineData.end;
    if (!klineData.checkStartAndEnd(start, end)) {
      return null;
    }

    int endIndex = end - 1;
    if (end < start) return null;
    if (!klineData.list[endIndex].isValidSarData) {
      calcuAndCacheSar(param, start: 0, end: klineData.list.length);
    }

    MinMax? minmax;
    CandleModel m;
    for (int i = endIndex; i >= start; i--) {
      m = klineData.list[i];
      if (m.sar != null) {
        minmax ??= MinMax.same(m.sar!);
        minmax.updateMinMaxBy(m.sar!);
      }
    }
    return minmax;
  }
} 