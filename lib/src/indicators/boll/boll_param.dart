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

part 'boll_param.g.dart';

/// BOLL 参数 - 直接对应 JSON 配置结构
@CopyWith()
@FlexiParamSerializable
final class BOLLParam extends Equatable {
  // 周期参数
  final BOLLPeriodsConfig periods;

  // 线条配置
  final BOLLLinesConfig lines;

  // 填充配置
  final BOLLFillConfig fill;

  // 显示配置
  final BOLLDisplayConfig display;

  const BOLLParam({
    this.periods = const BOLLPeriodsConfig(),
    this.lines = const BOLLLinesConfig(),
    this.fill = const BOLLFillConfig(),
    this.display = const BOLLDisplayConfig(),
  });

  /// 从 JSON 配置创建 BOLLParam
  factory BOLLParam.fromJsonConfig(Map<String, dynamic> config) {
    final periodsJson = config['periods'] as Map<String, dynamic>? ?? {};
    final linesJson = config['lines'] as Map<String, dynamic>? ?? {};
    final fillJson = config['fill'] as Map<String, dynamic>? ?? {};
    final displayJson = config['display'] as Map<String, dynamic>? ?? {};

    return BOLLParam(
      periods: BOLLPeriodsConfig.fromJson(periodsJson),
      lines: BOLLLinesConfig.fromJson(linesJson),
      fill: BOLLFillConfig.fromJson(fillJson),
      display: BOLLDisplayConfig.fromJson(displayJson),
    );
  }

  /// 获取启用的线条列表
  List<BOLLLineType> get enabledLines {
    final List<BOLLLineType> enabled = [];
    if (lines.ub.enabled) enabled.add(BOLLLineType.ub);
    if (lines.boll.enabled) enabled.add(BOLLLineType.boll);
    if (lines.lb.enabled) enabled.add(BOLLLineType.lb);
    return enabled;
  }

  /// 验证参数是否有效
  bool isValid(int len) => periods.period > 0 && periods.period <= len && periods.stdDev > 0;

  factory BOLLParam.fromJson(Map<String, dynamic> json) => _$BOLLParamFromJson(json);
  Map<String, dynamic> toJson() => _$BOLLParamToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [periods, lines, fill, display];
}

/// BOLL 线条类型枚举
enum BOLLLineType { ub, boll, lb }

/// BOLL 周期配置
@CopyWith()
@FlexiParamSerializable
final class BOLLPeriodsConfig extends Equatable {
  final int period;
  final double stdDev;

  const BOLLPeriodsConfig({
    this.period = 20,
    this.stdDev = 2.0,
  });

  factory BOLLPeriodsConfig.fromJson(Map<String, dynamic> json) => _$BOLLPeriodsConfigFromJson(json);
  Map<String, dynamic> toJson() => _$BOLLPeriodsConfigToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [period, stdDev];
}

/// 单条 BOLL 线配置
@CopyWith()
@FlexiParamSerializable
final class BOLLLineConfig extends Equatable {
  final bool enabled;
  final Color color;
  final double width;

  const BOLLLineConfig({
    this.enabled = true,
    this.color = const Color(0xff2196f3),
    this.width = 1.0,
  });

  factory BOLLLineConfig.fromJson(Map<String, dynamic> json) => _$BOLLLineConfigFromJson(json);
  Map<String, dynamic> toJson() => _$BOLLLineConfigToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [enabled, color, width];
}

/// BOLL 线条配置
@CopyWith()
@FlexiParamSerializable
final class BOLLLinesConfig extends Equatable {
  final BOLLLineConfig ub;
  final BOLLLineConfig boll;
  final BOLLLineConfig lb;

  const BOLLLinesConfig({
    this.ub = const BOLLLineConfig(color: Color(0xffffff00)),
    this.boll = const BOLLLineConfig(color: Color(0xffff69b4)),
    this.lb = const BOLLLineConfig(color: Color(0xff9c27b0)),
  });

  factory BOLLLinesConfig.fromJson(Map<String, dynamic> json) => _$BOLLLinesConfigFromJson(json);
  Map<String, dynamic> toJson() => _$BOLLLinesConfigToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [ub, boll, lb];
}

/// BOLL 填充配置
@CopyWith()
@FlexiParamSerializable
final class BOLLFillConfig extends Equatable {
  final bool enabled;
  final Color color;
  final double opacity;

  const BOLLFillConfig({
    this.enabled = true,
    this.color = const Color(0x1a4caf50),
    this.opacity = 0.1,
  });

  factory BOLLFillConfig.fromJson(Map<String, dynamic> json) => _$BOLLFillConfigFromJson(json);
  Map<String, dynamic> toJson() => _$BOLLFillConfigToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [enabled, color, opacity];
}

/// BOLL 显示配置
@CopyWith()
@FlexiParamSerializable
final class BOLLDisplayConfig extends Equatable {
  final double pointRadius;
  final bool showCrossPoint;
  final int precision;
  final bool showPeriodInTips;

  const BOLLDisplayConfig({
    this.pointRadius = 0.0,
    this.showCrossPoint = false,
    this.precision = 2,
    this.showPeriodInTips = true,
  });

  factory BOLLDisplayConfig.fromJson(Map<String, dynamic> json) => _$BOLLDisplayConfigFromJson(json);
  Map<String, dynamic> toJson() => _$BOLLDisplayConfigToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [pointRadius, showCrossPoint, precision, showPeriodInTips];
}
