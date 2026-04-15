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
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../framework/serializers.dart';

part 'obv_param.g.dart';

/// OBV 主线配置
@CopyWith()
@JsonSerializable()
final class OBVLineConfig extends Equatable {
  final bool enabled;
  @ColorConverter()
  final Color color;
  final double width;

  const OBVLineConfig({
    this.enabled = true,
    this.color = const Color(0xFFFF9800),
    this.width = 1.0,
  });

  factory OBVLineConfig.fromJson(Map<String, dynamic> json) =>
      _$OBVLineConfigFromJson(json);
  Map<String, dynamic> toJson() => _$OBVLineConfigToJson(this);

  @override
  List<Object?> get props => [enabled, color, width];
}

/// OBV MA 线配置
@CopyWith()
@JsonSerializable()
final class OBVMALineConfig extends Equatable {
  final String id;
  final bool enabled;
  final int period;
  @ColorConverter()
  final Color color;
  final double width;

  const OBVMALineConfig({
    required this.id,
    this.enabled = true,
    required this.period,
    required this.color,
    this.width = 1.0,
  });

  factory OBVMALineConfig.fromJson(Map<String, dynamic> json) =>
      _$OBVMALineConfigFromJson(json);
  Map<String, dynamic> toJson() => _$OBVMALineConfigToJson(this);

  @override
  List<Object?> get props => [id, enabled, period, color, width];
}

/// OBV 显示配置
@CopyWith()
@JsonSerializable()
final class OBVDisplayConfig extends Equatable {
  final int precision;
  final bool showMAInTips;

  const OBVDisplayConfig({
    this.precision = 2,
    this.showMAInTips = true,
  });

  factory OBVDisplayConfig.fromJson(Map<String, dynamic> json) =>
      _$OBVDisplayConfigFromJson(json);
  Map<String, dynamic> toJson() => _$OBVDisplayConfigToJson(this);

  @override
  List<Object?> get props => [precision, showMAInTips];
}

/// OBV 参数主配置类
///
/// OBV（On-Balance Volume）能量潮指标：
/// - 主线：累计成交量（收盘价上涨加、下跌减）
/// - MA 线：OBV 的移动平均线，用于平滑和信号确认
@CopyWith()
@FlexiParamSerializable
final class OBVParam extends Equatable {
  final OBVLineConfig obvLine;
  final int maxMALines;
  final List<OBVMALineConfig> maLines;
  final OBVDisplayConfig display;

  const OBVParam({
    this.obvLine = const OBVLineConfig(),
    this.maxMALines = 5,
    this.maLines = const [],
    this.display = const OBVDisplayConfig(),
  });

  List<OBVMALineConfig> get enabledMALines =>
      maLines.where((line) => line.enabled).toList();

  /// slot 布局: [obvValue, ma0, ma1, ...]
  /// slot 长度 = 1 (OBV 主线) + enabledMALines.length
  int get slotLen => 1 + enabledMALines.length;

  int? get maxMAPeriod {
    final enabled = enabledMALines;
    if (enabled.isEmpty) return null;
    return enabled.map((l) => l.period).reduce((a, b) => a > b ? a : b);
  }

  factory OBVParam.fromJson(Map<String, dynamic> json) =>
      _$OBVParamFromJson(json);
  Map<String, dynamic> toJson() => _$OBVParamToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [obvLine, maxMALines, maLines, display];
}
