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

import 'package:flexi_kline/flexi_kline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../constants/images.dart';
import '../../theme/flexi_theme.dart';
import '../../widgets/flexi_popup_menu_button.dart';
import '../../widgets/shrink_icon_button.dart';

final drawToolbarInitPosition = Offset(60.r, 200.r);

const List<double> flexiKlineLineWeightList = [1, 2, 3, 4];
const List<Color> flexiKlinePaintColors = [
  Colors.blueAccent,
  Colors.redAccent,
  // Colors.pinkAccent,
  Colors.purpleAccent,
  Colors.greenAccent,
  // Colors.yellowAccent,
  Colors.orangeAccent,
  // Colors.indigoAccent,
];

// 绘制工具条
class FlexiKlineDrawToolbar extends ConsumerWidget {
  const FlexiKlineDrawToolbar({
    super.key,
    required this.controller,
  });

  final FlexiKlineController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeProvider);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(6.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 2.r, vertical: 4.r),
      child: ValueListenableBuilder(
        valueListenable: controller.drawLineStyleListener,
        builder: (context, lineStyle, child) {
          lineStyle ??= controller.drawConfig.drawLine;
          Color paintColor = flexiKlinePaintColors.first;
          if (lineStyle.paint.color != paintColor &&
              flexiKlinePaintColors.contains(lineStyle.paint.color)) {
            paintColor = lineStyle.paint.color;
          }
          double strokeWidth = flexiKlineLineWeightList.first;
          if (lineStyle.paint.strokeWidth != strokeWidth &&
              flexiKlineLineWeightList.contains(lineStyle.paint.strokeWidth)) {
            strokeWidth = lineStyle.paint.strokeWidth;
          }
          LineType lineType = lineStyle.type;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.drag_indicator_rounded,
                size: 20.r,
              ),
              FlexiPopupMenuButton(
                initialValue: paintColor,
                padding: EdgeInsets.symmetric(horizontal: 4.r),
                onSelected: (Color color) {
                  controller.changeDrawLineStyle(color: color);
                },
                offset: Offset(-8.r, 0),
                itemBuilder: (context) {
                  return flexiKlinePaintColors.map((value) {
                    return PopupMenuItem(
                      key: ValueKey(value),
                      value: value,
                      height: 32.r,
                      child: SvgPicture.asset(
                        SvgRes.paintColor,
                        colorFilter: ColorFilter.mode(value, BlendMode.srcIn),
                      ),
                    );
                  }).toList();
                },
                child: SvgPicture.asset(
                  SvgRes.paintColor,
                  colorFilter: ColorFilter.mode(paintColor, BlendMode.srcIn),
                ),
              ),
              FlexiPopupMenuButton(
                initialValue: strokeWidth,
                onSelected: (double value) {
                  controller.changeDrawLineStyle(strokeWidth: value);
                },
                offset: Offset(-8.r, 0),
                itemBuilder: (context) {
                  return flexiKlineLineWeightList.map((value) {
                    return PopupMenuItem(
                      key: ValueKey(value),
                      value: value,
                      height: 32.r,
                      child: SvgPicture.asset(
                        'assets/svgs/line_weight_${cutInvalidZero(value)}.svg',
                        colorFilter:
                            ColorFilter.mode(theme.t1, BlendMode.srcIn),
                      ),
                    );
                  }).toList();
                },
                child: SvgPicture.asset(
                  'assets/svgs/line_weight_${cutInvalidZero(strokeWidth)}.svg',
                  colorFilter: ColorFilter.mode(theme.t1, BlendMode.srcIn),
                ),
              ),
              FlexiPopupMenuButton(
                initialValue: lineType,
                onSelected: (LineType type) {
                  controller.changeDrawLineStyle(lineType: type);
                },
                offset: Offset(-8.r, 0),
                itemBuilder: (context) {
                  return LineType.values.map((value) {
                    return PopupMenuItem(
                      key: ValueKey(value),
                      value: value,
                      height: 32.r,
                      child: SvgPicture.asset(
                        'assets/svgs/line_type_${value.name}.svg',
                        colorFilter:
                            ColorFilter.mode(theme.t1, BlendMode.srcIn),
                      ),
                    );
                  }).toList();
                },
                child: SvgPicture.asset(
                  'assets/svgs/line_type_${lineType.name}.svg',
                  colorFilter: ColorFilter.mode(theme.t1, BlendMode.srcIn),
                ),
              ),
              ShrinkIconButton(
                onPressed: () {
                  debugPrint('zp::: draw onTap Order');
                },
                content: SvgRes.visualOrder,
              ),
              ShrinkIconButton(
                onPressed: () {
                  debugPrint('zp::: draw onTap Lock');
                },
                content: SvgRes.unlock,
              ),
              ShrinkIconButton(
                onPressed: () {
                  debugPrint('zp::: draw onTap Delete');
                  controller.onDrawDelete();
                },
                content: SvgRes.delete,
              ),
            ],
          );
        },
      ),
    );
  }
}
