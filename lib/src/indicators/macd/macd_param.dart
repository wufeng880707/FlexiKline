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

import 'dart:math' as math;
import 'dart:ui';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../framework/serializers.dart';

part 'macd_param.g.dart';

/// MACD 参数 - 直接对应 JSON 配置结构
@CopyWith()
@FlexiParamSerializable
final class MACDParam extends Equatable {
  // 计算参数 - 对应 JSON 的 periods
  final int s; // short period
  final int l; // long period
  final int m; // signal period

  // 线条配置 - 对应 JSON 的 lines
  final MACDLineConfig difLine;
  final MACDLineConfig deaLine;

  // 柱状图配置 - 对应 JSON 的 histogram
  final bool histogramEnabled;
  final MACDHistogramState bullishIncreasing;
  final MACDHistogramState bullishDecreasing;
  final MACDHistogramState bearishIncreasing;
  final MACDHistogramState bearishDecreasing;

  // 显示配置 - 对应 JSON 的 display
  final int precision;
  final bool showZeroLine;
  final Color zeroLineColor;
  final double zeroLineWidth;

  const MACDParam({
    required this.s,
    required this.l,
    required this.m,
    this.difLine = const MACDLineConfig(color: Color(0xffffff00)),
    this.deaLine = const MACDLineConfig(color: Color(0xff9c27b0)),
    this.histogramEnabled = true,
    this.bullishIncreasing = const MACDHistogramState(
      color: Color(0xff4caf50),
      style: HistogramStyle.hollow,
    ),
    this.bullishDecreasing = const MACDHistogramState(
      color: Color(0xff4caf50),
      style: HistogramStyle.solid,
    ),
    this.bearishIncreasing = const MACDHistogramState(
      color: Color(0xfff44336),
      style: HistogramStyle.hollow,
    ),
    this.bearishDecreasing = const MACDHistogramState(
      color: Color(0xfff44336),
      style: HistogramStyle.solid,
    ),
    this.precision = 2,
    this.showZeroLine = true,
    this.zeroLineColor = const Color(0xff666666),
    this.zeroLineWidth = 0.5,
  });

  /// 从 JSON 配置创建 MACDParam
  factory MACDParam.fromJsonConfig(Map<String, dynamic> config) {
    final periods = config['periods'] as Map<String, dynamic>? ?? {};
    final lines = config['lines'] as Map<String, dynamic>? ?? {};
    final histogram = config['histogram'] as Map<String, dynamic>? ?? {};
    final display = config['display'] as Map<String, dynamic>? ?? {};

    return MACDParam(
      s: periods['short'] ?? 12,
      l: periods['long'] ?? 26,
      m: periods['signal'] ?? 9,
      difLine: lines['dif'] != null
          ? MACDLineConfig.fromJson(lines['dif'])
          : const MACDLineConfig(color: Color(0xffffff00)),
      deaLine: lines['dea'] != null
          ? MACDLineConfig.fromJson(lines['dea'])
          : const MACDLineConfig(color: Color(0xff9c27b0)),
      histogramEnabled: histogram['enabled'] ?? true,
      bullishIncreasing: _parseHistogramState(
          histogram, ['bullish', 'increasing'], const Color(0xff4caf50), HistogramStyle.hollow),
      bullishDecreasing: _parseHistogramState(
          histogram, ['bullish', 'decreasing'], const Color(0xff4caf50), HistogramStyle.solid),
      bearishIncreasing: _parseHistogramState(
          histogram, ['bearish', 'increasing'], const Color(0xfff44336), HistogramStyle.hollow),
      bearishDecreasing: _parseHistogramState(
          histogram, ['bearish', 'decreasing'], const Color(0xfff44336), HistogramStyle.solid),
      precision: display['precision'] ?? 2,
      showZeroLine: display['showZeroLine'] ?? true,
      zeroLineColor:
          Color(int.tryParse(display['zeroLineColor']?.toString() ?? '0xff666666') ?? 0xff666666),
      zeroLineWidth: (display['zeroLineWidth'] ?? 0.5).toDouble(),
    );
  }

  static MACDHistogramState _parseHistogramState(Map<String, dynamic> histogram, List<String> path,
      Color defaultColor, HistogramStyle defaultStyle) {
    dynamic current = histogram;
    for (String key in path) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        return MACDHistogramState(color: defaultColor, style: defaultStyle);
      }
    }

    if (current is Map<String, dynamic>) {
      return MACDHistogramState(
        color:
            Color(int.tryParse(current['color']?.toString() ?? '0xff4caf50') ?? defaultColor.value),
        style: HistogramStyle.fromString(current['style']?.toString() ?? 'solid'),
      );
    }

    return MACDHistogramState(color: defaultColor, style: defaultStyle);
  }

  bool isValid(int len) {
    return l > 0 && s > 0 && l > s && m > 0 && paramCount <= len;
  }

  int get paramCount => math.max(l, s) + m;

  factory MACDParam.fromJson(Map<String, dynamic> json) => _$MACDParamFromJson(json);
  Map<String, dynamic> toJson() => _$MACDParamToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [
        s,
        l,
        m,
        difLine,
        deaLine,
        histogramEnabled,
        bullishIncreasing,
        bullishDecreasing,
        bearishIncreasing,
        bearishDecreasing,
        precision,
        showZeroLine,
        zeroLineColor,
        zeroLineWidth,
      ];
}

/// MACD 线条配置（简化版）
@CopyWith()
@FlexiParamSerializable
final class MACDLineConfig extends Equatable {
  final bool enabled;
  final Color color;
  final double width;

  const MACDLineConfig({
    this.enabled = true,
    this.color = const Color(0xff2196f3),
    this.width = 1.0,
  });

  factory MACDLineConfig.fromJson(Map<String, dynamic> json) => _$MACDLineConfigFromJson(json);
  Map<String, dynamic> toJson() => _$MACDLineConfigToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [enabled, color, width];
}

/// 柱状图样式枚举
enum HistogramStyle {
  hollow,
  solid;

  static HistogramStyle fromString(String style) {
    switch (style.toLowerCase()) {
      case 'hollow':
        return HistogramStyle.hollow;
      default:
        return HistogramStyle.solid;
    }
  }
}

/// MACD 柱状图状态配置（简化版）
@CopyWith()
@FlexiParamSerializable
final class MACDHistogramState extends Equatable {
  final Color color;
  final HistogramStyle style;

  const MACDHistogramState({
    this.color = const Color(0xff4caf50),
    this.style = HistogramStyle.solid,
  });

  factory MACDHistogramState.fromJson(Map<String, dynamic> json) =>
      _$MACDHistogramStateFromJson(json);
  Map<String, dynamic> toJson() => _$MACDHistogramStateToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [color, style];
}
