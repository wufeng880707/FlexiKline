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

import 'dart:ui';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';

import '../../framework/serializers.dart';

part 'ema_param.g.dart';

/// EMA 参数 - 直接对应 JSON 配置结构
@CopyWith()
@FlexiParamSerializable
final class EmaParam extends Equatable {
  // 基础配置
  final int maxLines;
  final List<EMALineConfig> lines;

  // 验证规则
  final EMAValidationConfig validation;

  // 显示配置
  final EMADisplayConfig display;

  const EmaParam({
    this.maxLines = 10,
    this.lines = const [],
    this.validation = const EMAValidationConfig(),
    this.display = const EMADisplayConfig(),
  });

  /// 从 JSON 配置创建 EmaParam
  factory EmaParam.fromJsonConfig(Map<String, dynamic> config) {
    final maxLines = config['maxLines'] ?? 10;
    final linesJson = config['lines'] as List? ?? [];
    final validationJson = config['validation'] as Map<String, dynamic>? ?? {};
    final displayJson = config['display'] as Map<String, dynamic>? ?? {};

    return EmaParam(
      maxLines: maxLines,
      lines: linesJson.map((lineJson) => EMALineConfig.fromJson(lineJson)).toList(),
      validation: EMAValidationConfig.fromJson(validationJson),
      display: EMADisplayConfig.fromJson(displayJson),
    );
  }

  /// 获取启用的 EMA 线条
  List<EMALineConfig> get enabledLines => lines.where((line) => line.enabled).toList();

  /// 获取所有有效的周期（大于0且启用的）
  List<int> get validPeriods =>
      enabledLines.where((line) => line.period > 0).map((line) => line.period).toList();

  /// 获取最大周期
  int? get maxPeriod {
    final periods = validPeriods;
    return periods.isEmpty ? null : periods.reduce((a, b) => a > b ? a : b);
  }

  /// 获取最小周期
  int? get minPeriod {
    final periods = validPeriods;
    return periods.isEmpty ? null : periods.reduce((a, b) => a < b ? a : b);
  }

  /// 验证周期是否有效
  bool isValidPeriod(int period) {
    return period >= validation.minPeriod && period <= validation.maxPeriod;
  }

  /// 检查周期是否重复
  bool isDuplicatePeriod(int period, {String? excludeId}) {
    if (validation.allowDuplicate) return false;
    return lines.any((line) => line.id != excludeId && line.enabled && line.period == period);
  }


  factory EmaParam.fromJson(Map<String, dynamic> json) => _$EmaParamFromJson(json);
  Map<String, dynamic> toJson() => _$EmaParamToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [maxLines, lines, validation, display];
}

/// 单条 EMA 线配置
@CopyWith()
@FlexiParamSerializable
final class EMALineConfig extends Equatable {
  final String id;
  final bool enabled;
  final int period;
  final Color color;
  final double width;

  const EMALineConfig({
    required this.id,
    this.enabled = true,
    required this.period,
    this.color = const Color(0xff2196f3),
    this.width = 1.0,
  });

  factory EMALineConfig.fromJson(Map<String, dynamic> json) => _$EMALineConfigFromJson(json);
  Map<String, dynamic> toJson() => _$EMALineConfigToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [id, enabled, period, color, width];
}

/// EMA 验证配置
@CopyWith()
@FlexiParamSerializable
final class EMAValidationConfig extends Equatable {
  final int minPeriod;
  final int maxPeriod;
  final bool allowDuplicate;

  const EMAValidationConfig({
    this.minPeriod = 1,
    this.maxPeriod = 1000,
    this.allowDuplicate = false,
  });

  factory EMAValidationConfig.fromJson(Map<String, dynamic> json) =>
      _$EMAValidationConfigFromJson(json);
  Map<String, dynamic> toJson() => _$EMAValidationConfigToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [minPeriod, maxPeriod, allowDuplicate];
}

/// EMA 显示配置
@CopyWith()
@FlexiParamSerializable
final class EMADisplayConfig extends Equatable {
  final double pointRadius;
  final bool showCrossPoint;
  final int precision;
  final bool showPeriodInTips;

  const EMADisplayConfig({
    this.pointRadius = 0.0,
    this.showCrossPoint = false,
    this.precision = 2,
    this.showPeriodInTips = true,
  });

  factory EMADisplayConfig.fromJson(Map<String, dynamic> json) => _$EMADisplayConfigFromJson(json);
  Map<String, dynamic> toJson() => _$EMADisplayConfigToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [pointRadius, showCrossPoint, precision, showPeriodInTips];
}
