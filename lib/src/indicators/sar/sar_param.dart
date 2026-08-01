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

import '../../framework/serializers.dart';

part 'sar_param.g.dart';

/// SAR 参数 - 直接对应 JSON 配置结构
@CopyWith()
@FlexiParamSerializable
final class SARParam extends Equatable {
  // 周期参数
  final SARPeriodsConfig periods;

  // 外观配置
  final SARAppearanceConfig appearance;

  // 显示配置
  final SARDisplayConfig display;

  const SARParam({
    this.periods = const SARPeriodsConfig(),
    this.appearance = const SARAppearanceConfig(),
    this.display = const SARDisplayConfig(),
  });

  /// 从 JSON 配置创建 SARParam
  factory SARParam.fromJsonConfig(Map<String, dynamic> config) {
    final periodsJson = config['periods'] as Map<String, dynamic>? ?? {};
    final appearanceJson = config['appearance'] as Map<String, dynamic>? ?? {};
    final displayJson = config['display'] as Map<String, dynamic>? ?? {};

    return SARParam(
      periods: SARPeriodsConfig.fromJson(periodsJson),
      appearance: SARAppearanceConfig.fromJson(appearanceJson),
      display: SARDisplayConfig.fromJson(displayJson),
    );
  }

  /// 验证参数是否有效
  bool isValid(int len) => len > 1 && periods.start > 0 && periods.max > periods.start && periods.step > 0;

  // 为了兼容旧代码，保留这些getter
  double get startAf => periods.start;
  double get step => periods.step;
  double get maxAf => periods.max;

  factory SARParam.fromJson(Map<String, dynamic> json) => _$SARParamFromJson(json);
  Map<String, dynamic> toJson() => _$SARParamToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [periods, appearance, display];
}

/// SAR 周期配置
@CopyWith()
@FlexiParamSerializable
final class SARPeriodsConfig extends Equatable {
  final double start;
  final double max;
  final double step;

  const SARPeriodsConfig({
    this.start = 0.02,
    this.max = 0.6,
    this.step = 0.02,
  });

  factory SARPeriodsConfig.fromJson(Map<String, dynamic> json) => _$SARPeriodsConfigFromJson(json);
  Map<String, dynamic> toJson() => _$SARPeriodsConfigToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [start, max, step];
}

/// SAR 外观配置
@CopyWith()
@FlexiParamSerializable
final class SARAppearanceConfig extends Equatable {
  final Color color;
  final double pointRadius;
  final double borderWidth;
  final double minRadius;
  final double maxRadius;
  final bool useTrendColor;

  const SARAppearanceConfig({
    this.color = const Color(0xff9c27b0),
    this.pointRadius = 2.0,
    this.borderWidth = 0.5,
    this.minRadius = 1.0,
    this.maxRadius = 4.0,
    this.useTrendColor = true,
  });

  factory SARAppearanceConfig.fromJson(Map<String, dynamic> json) => _$SARAppearanceConfigFromJson(json);
  Map<String, dynamic> toJson() => _$SARAppearanceConfigToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [color, pointRadius, borderWidth, minRadius, maxRadius, useTrendColor];
}

/// SAR 显示配置
@CopyWith()
@FlexiParamSerializable
final class SARDisplayConfig extends Equatable {
  final int precision;
  final bool showPeriodInTips;

  const SARDisplayConfig({
    this.precision = 4,
    this.showPeriodInTips = false,
  });

  factory SARDisplayConfig.fromJson(Map<String, dynamic> json) => _$SARDisplayConfigFromJson(json);
  Map<String, dynamic> toJson() => _$SARDisplayConfigToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [precision, showPeriodInTips];
}
