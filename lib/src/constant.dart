import 'package:flutter/material.dart';

/// 默认数据格式化精度
const int defaultPrecision = 6;

/// 时间粒度，默认值1m
/// 如 [1m/3m/5m/15m/30m/1H/2H/4H]
/// 香港时间开盘价k线：[6H/12H/1D/2D/3D/1W/1M/3M]
/// UTC时间开盘价k线：[/6Hutc/12Hutc/1Dutc/2Dutc/3Dutc/1Wutc/1Mutc/3Mutc]
enum TimeBar {
  time(1000, 'time'),
  s1(1000, '1s'),
  m1(Duration.millisecondsPerMinute, '1m'),
  m3(3 * Duration.millisecondsPerMinute, '3m'),
  m5(5 * Duration.millisecondsPerMinute, '5m'),
  m15(15 * Duration.millisecondsPerMinute, '15m'),
  m30(30 * Duration.millisecondsPerMinute, '30m'),
  H1(Duration.millisecondsPerHour, '1H'),
  H2(2 * Duration.millisecondsPerHour, '2H'),
  H4(4 * Duration.millisecondsPerHour, '4H'),
  H6(6 * Duration.millisecondsPerHour, '6H'),
  H12(12 * Duration.millisecondsPerHour, '12H'),
  D1(Duration.millisecondsPerDay, '1D'),
  D2(2 * Duration.millisecondsPerDay, '2D'),
  D3(3 * Duration.millisecondsPerDay, '3D'),
  W1(7 * Duration.millisecondsPerDay, '1W'),
  M1(30 * Duration.millisecondsPerDay, '1M'), // ?
  M3(90 * Duration.millisecondsPerDay, '3M'), // ?
  utc6H(6 * Duration.millisecondsPerHour, '6Hutc'),
  utc12H(12 * Duration.millisecondsPerHour, '12Hutc'),
  utc1D(Duration.millisecondsPerDay, '1Dutc'),
  utc2D(2 * Duration.millisecondsPerDay, '2Dutc'),
  utc3D(3 * Duration.millisecondsPerDay, '3Dutc'),
  utc1W(7 * Duration.millisecondsPerDay, '1Wutc'),
  utc1M(30 * Duration.millisecondsPerDay, '1Mutc'),
  utc3M(90 * Duration.millisecondsPerDay, '1Mutc');

  const TimeBar(this.milliseconds, this.bar);

  final int milliseconds;
  final String bar;

  bool get isUtc {
    return name.contains('utc') || bar.contains('utc');
  }

  static TimeBar? convert(String bar) {
    try {
      return TimeBar.values.firstWhere(
        (e) => e.bar == bar || e.name == bar,
      );
    } on Error catch (error) {
      debugPrintStack(stackTrace: error.stackTrace);
      return null;
    }
  }
}

List<String> i18nCandleEnKeys = [
  'Time',
  'Open',
  'High',
  'Low',
  'Close',
  'Chg',
  '%Chg',
  // 'Range',
  'Amount',
  // 'Turnover'
];
