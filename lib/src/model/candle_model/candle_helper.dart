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

part of 'candle_model.dart';

final class CalculateData {
  CalculateData._(this.dataList);
  CalculateData.init(
    int indicatorCount,
  ) : this._(List.filled(indicatorCount, null, growable: false));

  final List<dynamic> dataList;

  T? getData<T>(int index) {
    return dataList.getItem(index);
  }

  bool setData<T>(int index, T data) {
    if (!dataList.checkIndex(index)) return false;
    dataList[index] = data;
    return true;
  }
}

extension CandleModelExt on CandleModel {
  DateTime get dateTime {
    return DateTime.fromMillisecondsSinceEpoch(ts);
  }

  String formatDateTime(TimeBarConfig? timeBar) {
    return formatDateTimeByTimeBar(ts, timeBar: timeBar);
  }

  DateTime? nextUpdateDateTime(TimeBarConfig timeBar) {
    if (timeBar != null) {
      final currentDateTime = DateTime.fromMillisecondsSinceEpoch(ts, isUtc: timeBar.isUtc);
      
      // 如果有自定义计算器，优先使用
      if (timeBar.nextUpdateCalculator != null) {
        return timeBar.nextUpdateCalculator!(currentDateTime, timeBar.isUtc);
      }
      
      // 否则使用默认的毫秒数计算
      return DateTime.fromMillisecondsSinceEpoch(
        ts + timeBar.milliseconds,
        isUtc: timeBar.isUtc,
      );
    }
    return null;
  }

  bool get isLong => close >= open;

  Decimal get change => c - o;

  double get changeRate {
    if (change == Decimal.zero) return 0;
    return (change / o).toDouble();
  }

  Decimal get range => h - l;

  double rangeRate(CandleModel pre) {
    if (range == Decimal.zero) return 0;
    return (range / pre.c).toDouble();
  }

  CandleModel clone() {
    return CandleModel.fromJson(toJson());
  }
}

// --- RSI 扩展 ---
extension CandleRsiExt on CandleModel {
  // 假设RSI的dataIndex为5（如有不同请调整，需与全局一致）
  static const int _rsiIndex = 5;

  List<double?>? get rsiList => calcuData.getData(_rsiIndex);
  set rsiList(List<double?>? value) => calcuData.setData(_rsiIndex, value);

  bool get isValidRsiList => rsiList != null && rsiList!.any((e) => e != null);

  MinMax get rsiListMinmax {
    if (!isValidRsiList) return MinMax.zero;
    final values = rsiList!.whereType<double>().toList();
    if (values.isEmpty) return MinMax.zero;
    double min = values.reduce((a, b) => a < b ? a : b);
    double max = values.reduce((a, b) => a > b ? a : b);
    return MinMax(max: BagNum.fromNum(max), min: BagNum.fromNum(min));
  }

  void cleanRsi() {
    rsiList = null;
  }
}
