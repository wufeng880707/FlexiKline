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

import 'package:example/src/pages/settings/common/color_selector.dart';
import 'package:example/src/pages/settings/common/line_width_selector.dart';
import 'package:flexi_kline/flexi_kline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/flexi_theme.dart';
import '../common/base_indicator_setting_page.dart';
import '../common/style_selector_row.dart';

class AVLSettingPage extends BaseIndicatorSettingPage {
  const AVLSettingPage({super.key});

  @override
  ConsumerState<AVLSettingPage> createState() => _AVLSettingPageState();
}

class _AVLSettingPageState extends BaseIndicatorSettingPageState<AVLSettingPage> {
  late AVLParam avlParam;

  // AVL线条设置
  late bool enabled;
  late Color lineColor;
  late double lineWidth;
  late LineStyle lineStyle;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  void _initializeSettings() {
    // 初始化AVL参数
    enabled = true;
    lineColor = const Color(0xFFFFEB3B); // 黄色
    lineWidth = 1.5;
    lineStyle = LineStyle.solid;

    avlParam = const AVLParam();
  }

  @override
  String get indicatorName => 'AVL';

  @override
  String get indicatorTitle => 'AVL均价线';

  @override
  List<Widget> buildSettingItems(FKTheme theme) {
    return [
      // 基础设置
      buildSectionTitle('基础设置', theme),
      buildSwitchItem(
        title: '显示AVL指标',
        subtitle: '显示或隐藏均价线指标',
        value: enabled,
        onChanged: (value) {
          setState(() {
            enabled = value;
          });
        },
        theme: theme,
      ),

      SizedBox(height: 16.r),

      if (enabled) ...[
        // 均价线设置
        buildSectionTitle('均价线样式', theme),

        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: theme.cardBg,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: theme.dividerLine),
          ),
          child: // 控制器行
              Row(
            children: [
              Text(
                'AVL',
                style: TextStyle(
                  color: theme.t1,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              // 线宽选择器
              LineWidthSelector(
                value: lineWidth,
                onChanged: (width) {
                  setState(() {
                    lineWidth = width;
                  });
                },
                color: lineColor,
                width: 80,
                height: 32,
              ),

              SizedBox(width: 26.r),

              // 颜色选择器 - 透明覆盖层实现
              ColorSelector(
                value: lineColor,
                onChanged: (color) {
                  setState(() {
                    lineColor = color;
                  });
                },
                width: 80,
                height: 32,
              ),
            ],
          ),
        ),

        SizedBox(height: 16.r),

        // 说明文字
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: theme.long.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: theme.long.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.long,
                size: 16.r,
              ),
              SizedBox(width: 8.r),
              Expanded(
                child: Text(
                  'AVL均价线：显示当前价格的平均值线，帮助判断价格趋势',
                  style: TextStyle(
                    color: theme.long,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],

      SizedBox(height: 16.r),
    ];
  }

  @override
  Future<void> saveSettings() async {
    debugPrint('保存AVL设置:');
    debugPrint('  启用: $enabled');
    if (enabled) {
      debugPrint('  线条颜色: ${lineColor.toString()}');
      debugPrint('  线条宽度: $lineWidth');
      debugPrint('  线条样式: $lineStyle');
    }
  }

  @override
  Future<void> resetToDefault() async {
    setState(() {
      _initializeSettings();
    });
  }
}
