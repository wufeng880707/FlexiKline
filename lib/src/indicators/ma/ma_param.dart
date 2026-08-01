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

part 'ma_param.g.dart';

/// MA 参数 - 直接对应 JSON 配置结构
@CopyWith()
@FlexiParamSerializable
final class MaParam extends Equatable {
  // 基础配置
  final int maxLines;
  final List<MALineConfig> lines;

  // 验证规则
  final MAValidationConfig validation;

  // 显示配置
  final MADisplayConfig display;

  // 默认颜色池
  final List<Color> defaultColors;

  const MaParam({
    this.maxLines = 10,
    this.lines = const [],
    this.validation = const MAValidationConfig(),
    this.display = const MADisplayConfig(),
    this.defaultColors = const [
      Color(0xffffff00),
      Color(0xffff69b4),
      Color(0xff9c27b0),
      Color(0xff4caf50),
      Color(0xff26a69a),
      Color(0xff9575cd),
      Color(0xffaed581),
      Color(0xffff8a65),
      Color(0xff42a5f5),
      Color(0xfff44336),
    ],
  });

  /// 从 JSON 配置创建 MaParam
  factory MaParam.fromJsonConfig(Map<String, dynamic> config) {
    final maxLines = config['maxLines'] ?? 10;
    final linesJson = config['lines'] as List? ?? [];
    final validationJson = config['validation'] as Map<String, dynamic>? ?? {};
    final displayJson = config['display'] as Map<String, dynamic>? ?? {};
    final defaultColorsJson = config['defaultColors'] as List? ?? [];

    return MaParam(
      maxLines: maxLines,
      lines: linesJson.map((lineJson) => MALineConfig.fromJson(lineJson)).toList(),
      validation: MAValidationConfig.fromJson(validationJson),
      display: MADisplayConfig.fromJson(displayJson),
      defaultColors:
          defaultColorsJson.map((colorStr) => Color(int.tryParse(colorStr.toString()) ?? 0xff2196f3)).toList(),
    );
  }

  /// 获取启用的 MA 线条
  List<MALineConfig> get enabledLines => lines.where((line) => line.enabled).toList();

  /// 获取所有有效的周期（大于0且启用的）
  List<int> get validPeriods => enabledLines.where((line) => line.period > 0).map((line) => line.period).toList();

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

  /// 获取下一个可用的颜色
  Color getNextAvailableColor() {
    final usedColors = lines.map((line) => line.color).toSet();
    for (final color in defaultColors) {
      if (!usedColors.contains(color)) {
        return color;
      }
    }
    return defaultColors.first; // 如果所有颜色都用完了，返回第一个
  }

  factory MaParam.fromJson(Map<String, dynamic> json) => _$MaParamFromJson(json);
  Map<String, dynamic> toJson() => _$MaParamToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [maxLines, lines, validation, display, defaultColors];
}

/// 单条 MA 线配置
@CopyWith()
@FlexiParamSerializable
final class MALineConfig extends Equatable {
  final String id;
  final bool enabled;
  final int period;
  final Color color;
  final double width;

  const MALineConfig({
    required this.id,
    this.enabled = true,
    required this.period,
    this.color = const Color(0xff2196f3),
    this.width = 1.0,
  });

  factory MALineConfig.fromJson(Map<String, dynamic> json) => _$MALineConfigFromJson(json);
  Map<String, dynamic> toJson() => _$MALineConfigToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [id, enabled, period, color, width];
}

/// MA 验证配置
@CopyWith()
@FlexiParamSerializable
final class MAValidationConfig extends Equatable {
  final int minPeriod;
  final int maxPeriod;
  final bool allowDuplicate;

  const MAValidationConfig({
    this.minPeriod = 1,
    this.maxPeriod = 1000,
    this.allowDuplicate = false,
  });

  factory MAValidationConfig.fromJson(Map<String, dynamic> json) => _$MAValidationConfigFromJson(json);
  Map<String, dynamic> toJson() => _$MAValidationConfigToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [minPeriod, maxPeriod, allowDuplicate];
}

/// MA 显示配置
@CopyWith()
@FlexiParamSerializable
final class MADisplayConfig extends Equatable {
  final double pointRadius;
  final bool showCrossPoint;
  final int precision;
  final bool showPeriodInTips;

  const MADisplayConfig({
    this.pointRadius = 0.0,
    this.showCrossPoint = false,
    this.precision = 2,
    this.showPeriodInTips = true,
  });

  factory MADisplayConfig.fromJson(Map<String, dynamic> json) => _$MADisplayConfigFromJson(json);
  Map<String, dynamic> toJson() => _$MADisplayConfigToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [pointRadius, showCrossPoint, precision, showPeriodInTips];
}
