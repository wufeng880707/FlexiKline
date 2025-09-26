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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'color_selector.dart';
import 'kline_style_selector.dart';
import 'line_width_selector.dart';

/// 线条样式枚举
enum LineStyle {
  solid, // 实线
  dashed, // 虚线
  dotted, // 点线
  dashdot, // 点划线
}

/// 组合选择器行组件
class StyleSelectorRow extends ConsumerWidget {
  const StyleSelectorRow({
    super.key,
    this.lineStyle,
    this.onLineStyleChanged,
    this.barStyle,
    this.onBarStyleChanged,
    required this.color,
    required this.onColorChanged,
    this.showLineStyle = true,
    this.showBarStyle = false,
    this.lineWidth,
    this.onLineWidthChanged,
  });

  final LineStyle? lineStyle;
  final ValueChanged<LineStyle>? onLineStyleChanged;
  final BarStyle? barStyle;
  final ValueChanged<BarStyle>? onBarStyleChanged;
  final Color color;
  final ValueChanged<Color> onColorChanged;
  final bool showLineStyle;
  final bool showBarStyle;
  final double? lineWidth;
  final ValueChanged<double>? onLineWidthChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showBarStyle && barStyle != null && onBarStyleChanged != null) ...[
          KLineStyleSelector(
            value: barStyle!,
            onChanged: onBarStyleChanged!,
            width: 120,
            height: 36,
          ),
          SizedBox(width: 8.r),
        ],
        if (lineWidth != null && onLineWidthChanged != null) ...[
          LineWidthSelector(
            value: lineWidth!,
            onChanged: onLineWidthChanged!,
            color: color,
            width: 100,
            height: 36,
          ),
          SizedBox(width: 8.r),
        ],
        ColorSelector(
          value: color,
          onChanged: onColorChanged,
          width: 32,
          height: 32,
        ),
      ],
    );
  }
}
