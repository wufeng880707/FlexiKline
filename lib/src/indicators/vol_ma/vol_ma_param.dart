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

part 'vol_ma_param.g.dart';

/// VOL_MA 线条配置
@CopyWith()
@JsonSerializable()
final class VolMALineConfig extends Equatable {
  final String id;
  final bool enabled;
  final int period;
  @ColorConverter()
  final Color color;
  final double width;
  final double opacity;

  const VolMALineConfig({
    required this.id,
    this.enabled = true,
    required this.period,
    required this.color,
    this.width = 1.0,
    this.opacity = 0.8,
  });

  /// 获取带透明度的颜色
  Color get colorWithOpacity => color.withValues(alpha: opacity);

  factory VolMALineConfig.fromJson(Map<String, dynamic> json) => _$VolMALineConfigFromJson(json);
  Map<String, dynamic> toJson() => _$VolMALineConfigToJson(this);

  @override
  List<Object?> get props => [id, enabled, period, color, width, opacity];
}

/// VOL_MA 验证配置
@CopyWith()
@JsonSerializable()
final class VolMAValidationConfig extends Equatable {
  final int minPeriod;
  final int maxPeriod;
  final bool allowDuplicate;

  const VolMAValidationConfig({
    this.minPeriod = 1,
    this.maxPeriod = 1000,
    this.allowDuplicate = false,
  });

  factory VolMAValidationConfig.fromJson(Map<String, dynamic> json) => _$VolMAValidationConfigFromJson(json);
  Map<String, dynamic> toJson() => _$VolMAValidationConfigToJson(this);

  @override
  List<Object?> get props => [minPeriod, maxPeriod, allowDuplicate];
}

/// 成交量柱配置
@CopyWith()
@JsonSerializable()
final class VolMAVolumeConfig extends Equatable {
  final bool useTrendColor;
  @ColorConverter()
  final Color bullishColor;
  @ColorConverter()
  final Color bearishColor;
  final double opacity;

  const VolMAVolumeConfig({
    this.useTrendColor = true,
    this.bullishColor = const Color(0xff4caf50),
    this.bearishColor = const Color(0xfff44336),
    this.opacity = 0.6,
  });

  /// 获取看涨颜色（带透明度）
  Color get bullishColorWithOpacity => bullishColor.withValues(alpha: opacity);

  /// 获取看跌颜色（带透明度）
  Color get bearishColorWithOpacity => bearishColor.withValues(alpha: opacity);

  factory VolMAVolumeConfig.fromJson(Map<String, dynamic> json) => _$VolMAVolumeConfigFromJson(json);
  Map<String, dynamic> toJson() => _$VolMAVolumeConfigToJson(this);

  @override
  List<Object?> get props => [useTrendColor, bullishColor, bearishColor, opacity];
}

/// VOL_MA 显示配置
@CopyWith()
@JsonSerializable()
final class VolMADisplayConfig extends Equatable {
  final double pointRadius;
  final bool showCrossPoint;
  final int precision;
  final bool showPeriodInTips;
  final bool showVolInTips;

  const VolMADisplayConfig({
    this.pointRadius = 0.0,
    this.showCrossPoint = false,
    this.precision = 0,
    this.showPeriodInTips = true,
    this.showVolInTips = true,
  });

  factory VolMADisplayConfig.fromJson(Map<String, dynamic> json) => _$VolMADisplayConfigFromJson(json);
  Map<String, dynamic> toJson() => _$VolMADisplayConfigToJson(this);

  @override
  List<Object?> get props => [pointRadius, showCrossPoint, precision, showPeriodInTips, showVolInTips];
}

/// VOL_MA 参数主配置类
@CopyWith()
@FlexiParamSerializable
final class VolMaParam extends Equatable {
  final int maxLines;
  final List<VolMALineConfig> lines;
  final VolMAValidationConfig validation;
  final VolMAVolumeConfig volume;
  final VolMADisplayConfig display;

  const VolMaParam({
    this.maxLines = 10,
    required this.lines,
    this.validation = const VolMAValidationConfig(),
    this.volume = const VolMAVolumeConfig(),
    this.display = const VolMADisplayConfig(),
  });

  /// 获取启用的 VOL_MA 线条配置
  List<VolMALineConfig> get enabledLines => lines.where((line) => line.enabled).toList();

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

  /// 从 JSON 配置创建 VOL_MA 参数
  factory VolMaParam.fromJsonConfig(Map<String, dynamic> config) {
    final linesData = config['lines'] as List<dynamic>? ?? [];
    final lines = linesData.map((line) => VolMALineConfig.fromJson(line as Map<String, dynamic>)).toList();

    return VolMaParam(
      maxLines: config['maxLines'] as int? ?? 10,
      lines: lines,
      validation: VolMAValidationConfig.fromJson(config['validation'] as Map<String, dynamic>? ?? {}),
      volume: VolMAVolumeConfig.fromJson(config['volume'] as Map<String, dynamic>? ?? {}),
      display: VolMADisplayConfig.fromJson(config['display'] as Map<String, dynamic>? ?? {}),
    );
  }

  factory VolMaParam.fromJson(Map<String, dynamic> json) => _$VolMaParamFromJson(json);
  Map<String, dynamic> toJson() => _$VolMaParamToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [maxLines, lines, validation, volume, display];
}
