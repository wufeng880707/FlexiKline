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

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../flexi_kline.dart';

part 'time_bar_config.g.dart';

/// 时间间隔
enum Timespan {
  second,
  minute,
  hour,
  day,
  week,
  month,
  quarter,
  year;
}

/// 可配置的时间粒度
@CopyWith()
@FlexiConfigSerializable
class TimeBarConfig {
  const TimeBarConfig({
    required this.key,
    required this.bar,
    required this.milliseconds,
    required this.multiplier,
    required this.timespan,
    required this.showName,
    this.isUtc = false,
    this.locale = 'en',
    this.sortOrder = 0,
    this.intraDay = false,
  });

  /// 唯一标识符
  final String key;

  /// 请求参数（如 '1m', '5m', '1H'）
  final String bar;

  /// 毫秒数
  final int milliseconds;

  /// 倍数
  final int multiplier;

  /// 时间间隔类型
  final Timespan timespan;

  /// 显示名称
  final String showName;

  /// 是否为UTC时间
  final bool isUtc;

  /// 语言标识
  final String locale;

  /// 排序顺序
  final int sortOrder;

  /// 是不是分时图
  final bool intraDay;

  @override
  String toString() => bar;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeBarConfig && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;

  factory TimeBarConfig.fromJson(Map<String, dynamic> json) => _$TimeBarConfigFromJson(json);

  Map<String, dynamic> toJson() => _$TimeBarConfigToJson(this);
}

// /// 时间粒度配置管理器
// class TimeBarConfigManager {
//   static final TimeBarConfigManager _instance = TimeBarConfigManager._internal();
//   factory TimeBarConfigManager() => _instance;
//   TimeBarConfigManager._internal();
//
//   final Map<String, TimeBarConfig> _configs = {};
//   final Map<String, Map<String, String>> _exchangeMappings = {};
//   final Map<String, Map<String, String>> _localeMappings = {};
//
//   /// 注册时间粒度配置
//   void registerTimeBar(TimeBarConfig config) {
//     _configs[config.key] = config;
//   }
//
//   /// 注册交易所映射
//   void registerExchangeMapping(String exchange, Map<String, String> mapping) {
//     _exchangeMappings[exchange] = mapping;
//   }
//
//   /// 注册多语言映射
//   void registerLocaleMapping(String locale, Map<String, String> mapping) {
//     _localeMappings[locale] = mapping;
//   }
//
//   /// 根据key获取配置
//   TimeBarConfig? getTimeBarByKey(String key) {
//     return _configs[key];
//   }
//
//   /// 根据bar参数获取配置
//   TimeBarConfig? getTimeBarByBar(String bar, {String? exchange}) {
//     if (exchange != null && _exchangeMappings.containsKey(exchange)) {
//       final mapping = _exchangeMappings[exchange]!;
//       final mappedBar = mapping[bar] ?? bar;
//       try {
//         return _configs.values.firstWhere(
//           (config) => config.bar == mappedBar,
//         );
//       } catch (e) {
//         try {
//           return _configs.values.firstWhere(
//             (config) => config.bar == bar,
//           );
//         } catch (e) {
//           return null;
//         }
//       }
//     }
//
//     try {
//       return _configs.values.firstWhere(
//         (config) => config.bar == bar,
//       );
//     } catch (e) {
//       return null;
//     }
//   }
//
//   /// 获取指定交易所的所有时间粒度
//   List<TimeBarConfig> getTimeBarsByExchange(String exchange) {
//     return _configs.values
//         .where((config) => config.exchange == exchange || config.exchange == 'default')
//         .toList()
//       ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
//   }
//
//   /// 获取指定语言的所有时间粒度
//   List<TimeBarConfig> getTimeBarsByLocale(String locale) {
//     return _configs.values
//         .where((config) => config.locale == locale || config.locale == 'en')
//         .toList()
//       ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
//   }
//
//   /// 获取显示名称（支持多语言）
//   String getShowName(TimeBarConfig config, {String? locale}) {
//     final targetLocale = locale ?? config.locale;
//     if (targetLocale != 'en' && _localeMappings.containsKey(targetLocale)) {
//       final mapping = _localeMappings[targetLocale]!;
//       return mapping[config.key] ?? config.showName;
//     }
//     return config.showName;
//   }
//
//   /// 转换bar参数（支持多交易所）
//   String convertBar(String bar, {String? fromExchange, String? toExchange}) {
//     if (fromExchange == null || toExchange == null || fromExchange == toExchange) {
//       return bar;
//     }
//
//     final fromMapping = _exchangeMappings[fromExchange];
//     final toMapping = _exchangeMappings[toExchange];
//
//     if (fromMapping == null || toMapping == null) {
//       return bar;
//     }
//
//     // 先转换为标准格式
//     String standardBar = fromMapping[bar] ?? bar;
//
//     // 再转换为目标交易所格式
//     for (final entry in toMapping.entries) {
//       if (entry.value == standardBar) {
//         return entry.key;
//       }
//     }
//
//     return standardBar;
//   }

// /// 初始化默认配置
// void initializeDefaultConfigs() {
//   // 注册默认时间粒度配置
//   final defaultConfigs = [
//     const TimeBarConfig(
//       key: 'intraDay',
//       bar: '15m',
//       milliseconds: Duration.millisecondsPerMinute * 15,
//       multiplier: 15,
//       timespan: Timespan.minute,
//       showName: 'Time',
//       sortOrder: 0,
//     ),
//     const TimeBarConfig(
//       key: 'm1',
//       bar: '1m',
//       milliseconds: Duration.millisecondsPerMinute,
//       multiplier: 1,
//       timespan: Timespan.minute,
//       showName: '1m',
//       sortOrder: 1,
//     ),
//     const TimeBarConfig(
//       key: 'm3',
//       bar: '3m',
//       milliseconds: Duration.millisecondsPerMinute * 3,
//       multiplier: 3,
//       timespan: Timespan.minute,
//       showName: '3m',
//       sortOrder: 2,
//     ),
//     const TimeBarConfig(
//       key: 'm5',
//       bar: '5m',
//       milliseconds: Duration.millisecondsPerMinute * 5,
//       multiplier: 5,
//       timespan: Timespan.minute,
//       showName: '5m',
//       sortOrder: 3,
//     ),
//     const TimeBarConfig(
//       key: 'm15',
//       bar: '15m',
//       milliseconds: Duration.millisecondsPerMinute * 15,
//       multiplier: 15,
//       timespan: Timespan.minute,
//       showName: '15m',
//       sortOrder: 4,
//     ),
//     const TimeBarConfig(
//       key: 'm30',
//       bar: '30m',
//       milliseconds: Duration.millisecondsPerMinute * 30,
//       multiplier: 30,
//       timespan: Timespan.minute,
//       showName: '30m',
//       sortOrder: 5,
//     ),
//     const TimeBarConfig(
//       key: 'H1',
//       bar: '1H',
//       milliseconds: Duration.millisecondsPerHour,
//       multiplier: 1,
//       timespan: Timespan.hour,
//       showName: '1H',
//       sortOrder: 6,
//     ),
//     const TimeBarConfig(
//       key: 'H2',
//       bar: '2H',
//       milliseconds: Duration.millisecondsPerHour * 2,
//       multiplier: 2,
//       timespan: Timespan.hour,
//       showName: '2H',
//       sortOrder: 7,
//     ),
//     const TimeBarConfig(
//       key: 'H4',
//       bar: '4H',
//       milliseconds: Duration.millisecondsPerHour * 4,
//       multiplier: 4,
//       timespan: Timespan.hour,
//       showName: '4H',
//       sortOrder: 8,
//     ),
//     const TimeBarConfig(
//       key: 'H6',
//       bar: '6H',
//       milliseconds: Duration.millisecondsPerHour * 6,
//       multiplier: 6,
//       timespan: Timespan.hour,
//       showName: '6H',
//       sortOrder: 9,
//     ),
//     const TimeBarConfig(
//       key: 'H12',
//       bar: '12H',
//       milliseconds: Duration.millisecondsPerHour * 12,
//       multiplier: 12,
//       timespan: Timespan.hour,
//       showName: '12H',
//       sortOrder: 10,
//     ),
//     const TimeBarConfig(
//       key: 'D1',
//       bar: '1D',
//       milliseconds: Duration.millisecondsPerDay,
//       multiplier: 1,
//       timespan: Timespan.day,
//       showName: '1D',
//       sortOrder: 11,
//     ),
//     const TimeBarConfig(
//       key: 'D2',
//       bar: '2D',
//       milliseconds: Duration.millisecondsPerDay * 2,
//       multiplier: 2,
//       timespan: Timespan.day,
//       showName: '2D',
//       sortOrder: 12,
//     ),
//     const TimeBarConfig(
//       key: 'D3',
//       bar: '3D',
//       milliseconds: Duration.millisecondsPerDay * 3,
//       multiplier: 3,
//       timespan: Timespan.day,
//       showName: '3D',
//       sortOrder: 13,
//     ),
//     const TimeBarConfig(
//       key: 'W1',
//       bar: '1W',
//       milliseconds: Duration.millisecondsPerDay * 7,
//       multiplier: 7,
//       timespan: Timespan.week,
//       showName: '1W',
//       sortOrder: 14,
//     ),
//     const TimeBarConfig(
//       key: 'M1',
//       bar: '1M',
//       milliseconds: Duration.millisecondsPerDay * 30,
//       multiplier: 1,
//       timespan: Timespan.month,
//       showName: '1M',
//       sortOrder: 15,
//     ),
//     const TimeBarConfig(
//       key: 'M3',
//       bar: '3M',
//       milliseconds: Duration.millisecondsPerDay * 90,
//       multiplier: 3,
//       timespan: Timespan.month,
//       showName: '3M',
//       sortOrder: 16,
//     ),
//     // UTC时间配置
//     const TimeBarConfig(
//       key: 'utc6H',
//       bar: '6Hutc',
//       milliseconds: Duration.millisecondsPerHour * 6,
//       multiplier: 6,
//       timespan: Timespan.hour,
//       showName: '6Hutc',
//       isUtc: true,
//       sortOrder: 17,
//     ),
//     const TimeBarConfig(
//       key: 'utc12H',
//       bar: '12Hutc',
//       milliseconds: Duration.millisecondsPerHour * 12,
//       multiplier: 12,
//       timespan: Timespan.hour,
//       showName: '12Hutc',
//       isUtc: true,
//       sortOrder: 18,
//     ),
//     const TimeBarConfig(
//       key: 'utc1D',
//       bar: '1Dutc',
//       milliseconds: Duration.millisecondsPerDay,
//       multiplier: 1,
//       timespan: Timespan.day,
//       showName: '1Dutc',
//       isUtc: true,
//       sortOrder: 19,
//     ),
//     const TimeBarConfig(
//       key: 'utc2D',
//       bar: '2Dutc',
//       milliseconds: Duration.millisecondsPerDay * 2,
//       multiplier: 2,
//       timespan: Timespan.day,
//       showName: '2Dutc',
//       isUtc: true,
//       sortOrder: 20,
//     ),
//     const TimeBarConfig(
//       key: 'utc3D',
//       bar: '3Dutc',
//       milliseconds: Duration.millisecondsPerDay * 3,
//       multiplier: 3,
//       timespan: Timespan.day,
//       showName: '3Dutc',
//       isUtc: true,
//       sortOrder: 21,
//     ),
//     const TimeBarConfig(
//       key: 'utc1W',
//       bar: '1Wutc',
//       milliseconds: Duration.millisecondsPerDay * 7,
//       multiplier: 7,
//       timespan: Timespan.week,
//       showName: '1Wutc',
//       isUtc: true,
//       sortOrder: 22,
//     ),
//     const TimeBarConfig(
//       key: 'utc1M',
//       bar: '1Mutc',
//       milliseconds: Duration.millisecondsPerDay * 30,
//       multiplier: 1,
//       timespan: Timespan.month,
//       showName: '1Mutc',
//       isUtc: true,
//       sortOrder: 23,
//     ),
//     const TimeBarConfig(
//       key: 'utc3M',
//       bar: '3Mutc',
//       milliseconds: Duration.millisecondsPerDay * 90,
//       multiplier: 3,
//       timespan: Timespan.month,
//       showName: '3Mutc',
//       isUtc: true,
//       sortOrder: 24,
//     ),
//   ];
//
// for (final config in defaultConfigs) {
//   registerTimeBar(config);
// }

//     // 注册交易所映射
//     registerExchangeMapping('binance', {
//       '1m': '1m',
//       '3m': '3m',
//       '5m': '5m',
//       '15m': '15m',
//       '30m': '30m',
//       '1h': '1H',
//       '2h': '2H',
//       '4h': '4H',
//       '6h': '6H',
//       '8h': '8H',
//       '12h': '12H',
//       '1d': '1D',
//       '3d': '3D',
//       '1w': '1W',
//       '1M': '1M',
//     });
//
//     registerExchangeMapping('okx', {
//       '1m': '1m',
//       '3m': '3m',
//       '5m': '5m',
//       '15m': '15m',
//       '30m': '30m',
//       '1H': '1H',
//       '2H': '2H',
//       '4H': '4H',
//       '6H': '6H',
//       '12H': '12H',
//       '1D': '1D',
//       '1W': '1W',
//       '1M': '1M',
//     });
//
//     // 注册多语言映射
//     registerLocaleMapping('zh', {
//       'intraDay': '分时',
//       'm1': '1分钟',
//       'm3': '3分钟',
//       'm5': '5分钟',
//       'm15': '15分钟',
//       'm30': '30分钟',
//       'H1': '1小时',
//       'H2': '2小时',
//       'H4': '4小时',
//       'H6': '6小时',
//       'H12': '12小时',
//       'D1': '1天',
//       'D2': '2天',
//       'D3': '3天',
//       'W1': '1周',
//       'M1': '1月',
//       'M3': '3月',
//     });
//
//     registerLocaleMapping('ja', {
//       'intraDay': '分時',
//       'm1': '1分',
//       'm3': '3分',
//       'm5': '5分',
//       'm15': '15分',
//       'm30': '30分',
//       'H1': '1時間',
//       'H2': '2時間',
//       'H4': '4時間',
//       'H6': '6時間',
//       'H12': '12時間',
//       'D1': '1日',
//       'D2': '2日',
//       'D3': '3日',
//       'W1': '1週間',
//       'M1': '1月',
//       'M3': '3月',
//     });
//   }
// }
//
// /// 全局时间粒度配置管理器实例
// final timeBarConfigManager = TimeBarConfigManager();
//
// /// 兼容旧的TimeBar枚举的扩展方法
// extension TimeBarConfigExt on TimeBarConfig {
//   bool get isUtc => this.isUtc;
//
//   static TimeBarConfig? convert(String bar, {String? exchange}) {
//     return timeBarConfigManager.getTimeBarByBar(bar, exchange: exchange);
//   }
// }
