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

part 'avl_param.g.dart';

/// AVL 参数 - 直接对应 JSON 配置结构
@CopyWith()
@FlexiParamSerializable
final class AVLParam extends Equatable {
  // 外观配置
  final AVLAppearanceConfig appearance;
  
  // 显示配置
  final AVLDisplayConfig display;

  const AVLParam({
    this.appearance = const AVLAppearanceConfig(),
    this.display = const AVLDisplayConfig(),
  });

  /// 从 JSON 配置创建 AVLParam
  factory AVLParam.fromJsonConfig(Map<String, dynamic> config) {
    final appearanceJson = config['appearance'] as Map<String, dynamic>? ?? {};
    final displayJson = config['display'] as Map<String, dynamic>? ?? {};

    return AVLParam(
      appearance: AVLAppearanceConfig.fromJson(appearanceJson),
      display: AVLDisplayConfig.fromJson(displayJson),
    );
  }

  /// 验证参数是否有效
  bool isValid(int len) => len > 0;

  factory AVLParam.fromJson(Map<String, dynamic> json) => _$AVLParamFromJson(json);
  Map<String, dynamic> toJson() => _$AVLParamToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [appearance, display];
}

/// AVL 外观配置
@CopyWith()
@FlexiParamSerializable
final class AVLAppearanceConfig extends Equatable {
  final Color color;
  final double lineWidth;
  final double dashWidth;

  const AVLAppearanceConfig({
    this.color = const Color(0xffff5722),
    this.lineWidth = 1.0,
    this.dashWidth = 0.0,
  });

  factory AVLAppearanceConfig.fromJson(Map<String, dynamic> json) => _$AVLAppearanceConfigFromJson(json);
  Map<String, dynamic> toJson() => _$AVLAppearanceConfigToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [color, lineWidth, dashWidth];
}

/// AVL 显示配置
@CopyWith()
@FlexiParamSerializable
final class AVLDisplayConfig extends Equatable {
  final int precision;
  final bool showInTips;
  final String tipsLabel;

  const AVLDisplayConfig({
    this.precision = 2,
    this.showInTips = true,
    this.tipsLabel = 'AVL',
  });

  factory AVLDisplayConfig.fromJson(Map<String, dynamic> json) => _$AVLDisplayConfigFromJson(json);
  Map<String, dynamic> toJson() => _$AVLDisplayConfigToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [precision, showInTips, tipsLabel];
} 