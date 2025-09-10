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

part 'volume_param.g.dart';

/// 成交量柱配置
@CopyWith()
@JsonSerializable()
final class VolumeBarConfig extends Equatable {
  final bool useTrendColor;
  @ColorConverter()
  final Color bullishColor;
  @ColorConverter()
  final Color bearishColor;
  final double opacity;

  const VolumeBarConfig({
    this.useTrendColor = true,
    this.bullishColor = const Color(0xff4caf50),
    this.bearishColor = const Color(0xfff44336),
    this.opacity = 0.6,
  });

  /// 获取看涨颜色（带透明度）
  Color get bullishColorWithOpacity => bullishColor.withValues(alpha: opacity);
  
  /// 获取看跌颜色（带透明度）
  Color get bearishColorWithOpacity => bearishColor.withValues(alpha: opacity);

  factory VolumeBarConfig.fromJson(Map<String, dynamic> json) =>
      _$VolumeBarConfigFromJson(json);
  Map<String, dynamic> toJson() => _$VolumeBarConfigToJson(this);

  @override
  List<Object?> get props => [useTrendColor, bullishColor, bearishColor, opacity];
}

/// Volume 显示配置
@CopyWith()
@JsonSerializable()
final class VolumeDisplayConfig extends Equatable {
  final int precision;
  final bool showVolInTips;
  final bool compactDisplay;

  const VolumeDisplayConfig({
    this.precision = 0,
    this.showVolInTips = true,
    this.compactDisplay = true,
  });

  factory VolumeDisplayConfig.fromJson(Map<String, dynamic> json) =>
      _$VolumeDisplayConfigFromJson(json);
  Map<String, dynamic> toJson() => _$VolumeDisplayConfigToJson(this);

  @override
  List<Object?> get props => [precision, showVolInTips, compactDisplay];
}

/// Volume 参数主配置类
@CopyWith()
@FlexiParamSerializable
final class VolumeParam extends Equatable {
  final bool showInMain;
  final double heightRatio;
  final VolumeBarConfig volume;
  final VolumeDisplayConfig display;

  const VolumeParam({
    this.showInMain = true,
    this.heightRatio = 0.3,
    this.volume = const VolumeBarConfig(),
    this.display = const VolumeDisplayConfig(),
  });

  /// 从 JSON 配置创建 Volume 参数
  factory VolumeParam.fromJsonConfig(Map<String, dynamic> config) {
    return VolumeParam(
      showInMain: config['showInMain'] as bool? ?? true,
      heightRatio: (config['heightRatio'] as num?)?.toDouble() ?? 0.3,
      volume: VolumeBarConfig.fromJson(config['volume'] as Map<String, dynamic>? ?? {}),
      display: VolumeDisplayConfig.fromJson(config['display'] as Map<String, dynamic>? ?? {}),
    );
  }

  factory VolumeParam.fromJson(Map<String, dynamic> json) =>
      _$VolumeParamFromJson(json);
  Map<String, dynamic> toJson() => _$VolumeParamToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [showInMain, heightRatio, volume, display];
}
