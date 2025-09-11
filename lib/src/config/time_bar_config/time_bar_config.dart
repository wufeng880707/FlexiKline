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
import 'package:flexi_formatter/date_time.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../flexi_kline.dart';

part 'time_bar_config.g.dart';

/// 可配置的时间粒度
@CopyWith()
@FlexiConfigSerializable
class TimeBarConfig {
  const TimeBarConfig({
    required this.key,
    required this.bar,
    required this.milliseconds,
    required this.multiplier,
    required this.timeUnit,
    required this.showName,
    this.isUtc = false,
    this.locale = 'en',
    this.sortOrder = 0,
    this.intraDay = false,
    this.nextUpdateCalculator,
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
  final TimeUnit timeUnit;

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

  /// 自定义下一个更新时间计算器
  @JsonKey(
    fromJson: _nextUpdateCalculatorFromJson,
    toJson: _nextUpdateCalculatorToJson,
    includeFromJson: false,
    includeToJson: false,
  )
  final DateTime Function(DateTime currentTime, bool isUtc)? nextUpdateCalculator;

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

/// 从JSON转换nextUpdateCalculator
DateTime Function(DateTime currentTime, bool isUtc)? _nextUpdateCalculatorFromJson(dynamic json) {
  // 函数类型无法序列化，返回null
  return null;
}

/// 转换nextUpdateCalculator到JSON
dynamic _nextUpdateCalculatorToJson(
    DateTime Function(DateTime currentTime, bool isUtc)? calculator) {
  // 函数类型无法序列化，返回null
  return null;
}
