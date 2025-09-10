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

part 'rsi_param.g.dart';

/// RSI 线条配置
@CopyWith()
@JsonSerializable()
final class RSILineConfig extends Equatable {
  final String id;
  final bool enabled;
  final int period;
  @ColorConverter()
  final Color color;
  final double width;

  const RSILineConfig({
    required this.id,
    this.enabled = true,
    required this.period,
    required this.color,
    this.width = 1.0,
  });

  factory RSILineConfig.fromJson(Map<String, dynamic> json) =>
      _$RSILineConfigFromJson(json);
  Map<String, dynamic> toJson() => _$RSILineConfigToJson(this);

  @override
  List<Object?> get props => [id, enabled, period, color, width];
}

/// RSI 验证配置
@CopyWith()
@JsonSerializable()
final class RSIValidationConfig extends Equatable {
  final int minPeriod;
  final int maxPeriod;
  final bool allowDuplicate;

  const RSIValidationConfig({
    this.minPeriod = 1,
    this.maxPeriod = 1000,
    this.allowDuplicate = false,
  });

  factory RSIValidationConfig.fromJson(Map<String, dynamic> json) =>
      _$RSIValidationConfigFromJson(json);
  Map<String, dynamic> toJson() => _$RSIValidationConfigToJson(this);

  @override
  List<Object?> get props => [minPeriod, maxPeriod, allowDuplicate];
}

/// RSI 参考线配置
@CopyWith()
@JsonSerializable()
final class RSIReferenceConfig extends Equatable {
  final bool enabled;
  final double overbought;
  final double oversold;
  final double lineWidth;
  @ColorConverter()
  final Color color;
  final double dashWidth;

  const RSIReferenceConfig({
    this.enabled = true,
    this.overbought = 70.0,
    this.oversold = 30.0,
    this.lineWidth = 0.5,
    this.color = const Color(0x66666666),
    this.dashWidth = 2.0,
  });

  factory RSIReferenceConfig.fromJson(Map<String, dynamic> json) =>
      _$RSIReferenceConfigFromJson(json);
  Map<String, dynamic> toJson() => _$RSIReferenceConfigToJson(this);

  @override
  List<Object?> get props => [enabled, overbought, oversold, lineWidth, color, dashWidth];
}

/// RSI 显示配置
@CopyWith()
@JsonSerializable()
final class RSIDisplayConfig extends Equatable {
  final double pointRadius;
  final bool showCrossPoint;
  final int precision;
  final bool showPeriodInTips;
  final bool showReferenceValue;

  const RSIDisplayConfig({
    this.pointRadius = 0.0,
    this.showCrossPoint = false,
    this.precision = 2,
    this.showPeriodInTips = true,
    this.showReferenceValue = true,
  });

  factory RSIDisplayConfig.fromJson(Map<String, dynamic> json) =>
      _$RSIDisplayConfigFromJson(json);
  Map<String, dynamic> toJson() => _$RSIDisplayConfigToJson(this);

  @override
  List<Object?> get props => [pointRadius, showCrossPoint, precision, showPeriodInTips, showReferenceValue];
}

/// RSI 参数主配置类
@CopyWith()
@FlexiParamSerializable
final class RsiParam extends Equatable {
  final int maxLines;
  final List<RSILineConfig> lines;
  final RSIValidationConfig validation;
  final RSIReferenceConfig reference;
  final RSIDisplayConfig display;

  const RsiParam({
    this.maxLines = 10,
    required this.lines,
    this.validation = const RSIValidationConfig(),
    this.reference = const RSIReferenceConfig(),
    this.display = const RSIDisplayConfig(),
  });

  /// 获取启用的 RSI 线条配置
  List<RSILineConfig> get enabledLines => lines.where((line) => line.enabled).toList();

  /// 获取所有启用线条的最大周期
  int? get maxPeriod {
    final enabled = enabledLines;
    if (enabled.isEmpty) return null;
    return enabled.map((line) => line.period).reduce((a, b) => a > b ? a : b);
  }

  /// 获取所有启用线条的最小周期
  int? get minPeriod {
    final enabled = enabledLines;
    if (enabled.isEmpty) return null;
    return enabled.map((line) => line.period).reduce((a, b) => a < b ? a : b);
  }

  /// 从 JSON 配置创建 RSI 参数
  factory RsiParam.fromJsonConfig(Map<String, dynamic> config) {
    final linesData = config['lines'] as List<dynamic>? ?? [];
    final lines = linesData.map((line) => RSILineConfig.fromJson(line as Map<String, dynamic>)).toList();

    return RsiParam(
      maxLines: config['maxLines'] as int? ?? 10,
      lines: lines,
      validation: RSIValidationConfig.fromJson(config['validation'] as Map<String, dynamic>? ?? {}),
      reference: RSIReferenceConfig.fromJson(config['reference'] as Map<String, dynamic>? ?? {}),
      display: RSIDisplayConfig.fromJson(config['display'] as Map<String, dynamic>? ?? {}),
    );
  }

  factory RsiParam.fromJson(Map<String, dynamic> json) =>
      _$RsiParamFromJson(json);
  Map<String, dynamic> toJson() => _$RsiParamToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [maxLines, lines, validation, reference, display];
}
