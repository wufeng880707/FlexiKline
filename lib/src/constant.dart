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

import 'package:flutter/painting.dart';

/// 默认数据格式化精度
const int defaultPrecision = 4;

// 默认Decimal除法精度
const int defaultScaleOnInfinitePrecision = 17;

// 默认主区指标高度
const double defaultMainIndicatorHeight = 300;

// 默认时间指标高度
const double defaultTimeIndicatorHeight = 30;

// 默认副图指标高度
const double defaultSubIndicatorHeight = 60;

// 默认指标图Padding
const EdgeInsets defaultSubIndicatorPadding = EdgeInsets.only(top: 12);

// 默认主图区域Padding
const EdgeInsets defaultMainIndicatorPadding = EdgeInsets.only(
  top: 5, // 顶部留白
  bottom: 5, // 底部留白, 5: 最低价字体高度的一半, 保证最低价文本不会绘制到边线上.
);

// 默认主图区域最小Size
const Size defaultMainRectMinSize = Size(20, 20);
const Rect defaultCanvasRectMinRect = Rect.fromLTWH(0, 0, 20, 20);

// 默认主图指标最大数量
const int defaultMainChartIndicatorMaxCount = 3;

// 默认副图指标最大数量
const int defaultSubChartIndicatorMaxCount = 3;

// 默认副图指标刻度数量: 高中低=>top, middle, bottom
const int defaultSubTickCount = 3;

// 默认指标线图的宽度
const double defaultIndicatorLineWidth = 1;

// 默认文本配置
const double defaulTextSize = 20;

// 默认文本区域Padding
const EdgeInsets defaultTextPading = EdgeInsets.all(2);

// 默认文本高度
const double defaultTextHeight = 1;

// 默认文本高度多行模式
const double defaultMultiTextHeight = 1.4;

// 默认Tips文本高度
const double defaultTipsTextHeight = 1.2;

// 默认指标图TipsHeight
// const double defaultIndicatorTipsHeight = 15;

// 默认Tips文本区域的Padding: 左边缩进8个单位
const EdgeInsets defaultTipsPadding = EdgeInsets.only(left: 8);

/// 计算模式
/// [fast] 使用(IEEE 754 二进制浮点数算术标准)计算指标数据. (用double类型计算)
/// [accurate] 使用Decimal基于十进制算术的精确计算指标数据. (用Decimal类型计算)
enum ComputeMode {
  fast,
  accurate,
}

/// 内置TooltipLabel
enum TooltipLabel {
  time,
  open,
  high,
  low,
  close,
  chg,
  chgRate,
  range,
  amount,
  turnover;
}

const Map<TooltipLabel, String> defaultTooltipLables = {
  TooltipLabel.time: 'Time',
  TooltipLabel.open: 'Open',
  TooltipLabel.high: 'High',
  TooltipLabel.low: 'Low',
  TooltipLabel.close: 'Close',
  TooltipLabel.chg: 'Chg',
  TooltipLabel.chgRate: '%Chg',
  TooltipLabel.range: 'Range',
  TooltipLabel.amount: 'Amount',
  TooltipLabel.turnover: 'Turnover',
};

enum ThousandUnit {
  /// trillion
  trillion('T'),

  /// billion
  billion('B'),

  /// million
  million('M'),

  /// thousand
  thousand('K'),

  /// less than thousand
  less('');

  final String value;
  const ThousandUnit(this.value);
}

enum RoundMode {
  round,
  floor,
  ceil,
  truncate,
}
