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

part 'kdj_param.g.dart';

/// KDJ 参数 - 直接对应 JSON 配置结构
@CopyWith()
@FlexiParamSerializable
final class KDJParam extends Equatable {
  // 计算参数
  final KDJCalculationConfig calculation;

  // 线条配置
  final KDJLinesConfig lines;

  // 显示配置
  final KDJDisplayConfig display;

  const KDJParam({
    this.calculation = const KDJCalculationConfig(),
    this.lines = const KDJLinesConfig(),
    this.display = const KDJDisplayConfig(),
  });

  /// 从 JSON 配置创建 KDJParam
  factory KDJParam.fromJsonConfig(Map<String, dynamic> config) {
    final calculationJson = config['calculation'] as Map<String, dynamic>? ?? {};
    final linesJson = config['lines'] as Map<String, dynamic>? ?? {};
    final displayJson = config['display'] as Map<String, dynamic>? ?? {};

    return KDJParam(
      calculation: KDJCalculationConfig.fromJson(calculationJson),
      lines: KDJLinesConfig.fromJson(linesJson),
      display: KDJDisplayConfig.fromJson(displayJson),
    );
  }

  /// 获取启用的线条列表
  List<KDJLineType> get enabledLines {
    final List<KDJLineType> enabled = [];
    if (lines.k.enabled) enabled.add(KDJLineType.k);
    if (lines.d.enabled) enabled.add(KDJLineType.d);
    if (lines.j.enabled) enabled.add(KDJLineType.j);
    return enabled;
  }

  /// 验证参数是否有效
  bool isValid(int len) =>
      calculation.kPeriod > 0 && calculation.kPeriod <= len && calculation.dPeriod > 0 && calculation.jPeriod > 0;

  factory KDJParam.fromJson(Map<String, dynamic> json) => _$KDJParamFromJson(json);
  Map<String, dynamic> toJson() => _$KDJParamToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [calculation, lines, display];
}

/// KDJ 线条类型枚举
enum KDJLineType { k, d, j }

/// KDJ 计算配置
@CopyWith()
@FlexiParamSerializable
final class KDJCalculationConfig extends Equatable {
  final int kPeriod;
  final int dPeriod;
  final int jPeriod;

  const KDJCalculationConfig({
    this.kPeriod = 9,
    this.dPeriod = 3,
    this.jPeriod = 3,
  });

  factory KDJCalculationConfig.fromJson(Map<String, dynamic> json) => _$KDJCalculationConfigFromJson(json);
  Map<String, dynamic> toJson() => _$KDJCalculationConfigToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [kPeriod, dPeriod, jPeriod];
}

/// 单条 KDJ 线配置
@CopyWith()
@FlexiParamSerializable
final class KDJLineConfig extends Equatable {
  final bool enabled;
  final Color color;
  final double width;

  const KDJLineConfig({
    this.enabled = true,
    this.color = const Color(0xff2196f3),
    this.width = 1.0,
  });

  factory KDJLineConfig.fromJson(Map<String, dynamic> json) => _$KDJLineConfigFromJson(json);
  Map<String, dynamic> toJson() => _$KDJLineConfigToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [enabled, color, width];
}

/// KDJ 线条配置
@CopyWith()
@FlexiParamSerializable
final class KDJLinesConfig extends Equatable {
  final KDJLineConfig k;
  final KDJLineConfig d;
  final KDJLineConfig j;

  const KDJLinesConfig({
    this.k = const KDJLineConfig(color: Color(0xffffff00)),
    this.d = const KDJLineConfig(color: Color(0xffff69b4)),
    this.j = const KDJLineConfig(color: Color(0xff9c27b0)),
  });

  factory KDJLinesConfig.fromJson(Map<String, dynamic> json) => _$KDJLinesConfigFromJson(json);
  Map<String, dynamic> toJson() => _$KDJLinesConfigToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [k, d, j];
}

/// KDJ 显示配置
@CopyWith()
@FlexiParamSerializable
final class KDJDisplayConfig extends Equatable {
  final double pointRadius;
  final bool showCrossPoint;
  final int precision;
  final bool showPeriodInTips;

  const KDJDisplayConfig({
    this.pointRadius = 0.0,
    this.showCrossPoint = false,
    this.precision = 2,
    this.showPeriodInTips = true,
  });

  factory KDJDisplayConfig.fromJson(Map<String, dynamic> json) => _$KDJDisplayConfigFromJson(json);
  Map<String, dynamic> toJson() => _$KDJDisplayConfigToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [pointRadius, showCrossPoint, precision, showPeriodInTips];
}
