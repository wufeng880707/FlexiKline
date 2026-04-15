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

part 'cci_param.g.dart';

/// CCI 线条配置
@CopyWith()
@JsonSerializable()
final class CCILineConfig extends Equatable {
  final String id;
  final bool enabled;
  final int period;
  @ColorConverter()
  final Color color;
  final double width;

  const CCILineConfig({
    required this.id,
    this.enabled = true,
    required this.period,
    required this.color,
    this.width = 1.0,
  });

  factory CCILineConfig.fromJson(Map<String, dynamic> json) =>
      _$CCILineConfigFromJson(json);
  Map<String, dynamic> toJson() => _$CCILineConfigToJson(this);

  @override
  List<Object?> get props => [id, enabled, period, color, width];
}

/// CCI 参考线配置
@CopyWith()
@JsonSerializable()
final class CCIReferenceConfig extends Equatable {
  final bool enabled;
  final double overbought;
  final double oversold;
  final double lineWidth;
  @ColorConverter()
  final Color color;
  final double dashWidth;

  const CCIReferenceConfig({
    this.enabled = true,
    this.overbought = 100.0,
    this.oversold = -100.0,
    this.lineWidth = 0.5,
    this.color = const Color(0x66666666),
    this.dashWidth = 2.0,
  });

  factory CCIReferenceConfig.fromJson(Map<String, dynamic> json) =>
      _$CCIReferenceConfigFromJson(json);
  Map<String, dynamic> toJson() => _$CCIReferenceConfigToJson(this);

  @override
  List<Object?> get props =>
      [enabled, overbought, oversold, lineWidth, color, dashWidth];
}

/// CCI 显示配置
@CopyWith()
@JsonSerializable()
final class CCIDisplayConfig extends Equatable {
  final double pointRadius;
  final int precision;
  final bool showPeriodInTips;
  final bool showReferenceValue;

  const CCIDisplayConfig({
    this.pointRadius = 0.0,
    this.precision = 2,
    this.showPeriodInTips = true,
    this.showReferenceValue = true,
  });

  factory CCIDisplayConfig.fromJson(Map<String, dynamic> json) =>
      _$CCIDisplayConfigFromJson(json);
  Map<String, dynamic> toJson() => _$CCIDisplayConfigToJson(this);

  @override
  List<Object?> get props =>
      [pointRadius, precision, showPeriodInTips, showReferenceValue];
}

/// CCI 参数主配置类
@CopyWith()
@FlexiParamSerializable
final class CCIParam extends Equatable {
  final int maxLines;
  final List<CCILineConfig> lines;
  final CCIReferenceConfig reference;
  final CCIDisplayConfig display;

  const CCIParam({
    this.maxLines = 10,
    required this.lines,
    this.reference = const CCIReferenceConfig(),
    this.display = const CCIDisplayConfig(),
  });

  List<CCILineConfig> get enabledLines =>
      lines.where((line) => line.enabled).toList();

  int? get maxPeriod {
    final enabled = enabledLines;
    if (enabled.isEmpty) return null;
    return enabled.map((line) => line.period).reduce((a, b) => a > b ? a : b);
  }

  int? get minPeriod {
    final enabled = enabledLines;
    if (enabled.isEmpty) return null;
    return enabled.map((line) => line.period).reduce((a, b) => a < b ? a : b);
  }

  factory CCIParam.fromJson(Map<String, dynamic> json) =>
      _$CCIParamFromJson(json);
  Map<String, dynamic> toJson() => _$CCIParamToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [maxLines, lines, reference, display];
}
