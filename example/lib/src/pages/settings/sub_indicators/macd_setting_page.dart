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

import '../../../theme/flexi_theme.dart';
import '../common/base_indicator_setting_page.dart';
import '../common/color_selector.dart';
import '../common/kline_style_selector.dart';
import '../common/style_selector_row.dart';

class MACDSettingPage extends BaseIndicatorSettingPage {
  const MACDSettingPage({super.key});

  @override
  ConsumerState<MACDSettingPage> createState() => _MACDSettingPageState();
}

class _MACDSettingPageState extends BaseIndicatorSettingPageState<MACDSettingPage> {
  late MACDParam macdParam;

  // MACD参数
  late int shortPeriod; // 短周期
  late int longPeriod; // 长周期
  late int signalPeriod; // 移动平均周期

  // DIF线样式
  late LineStyle difLineStyle;
  late Color difColor;

  // DEA线样式
  late LineStyle deaLineStyle;
  late Color deaColor;

  // MACD柱状图样式
  late BarStyle macdBarStyle;
  late Color macdBullishColor; // 多头（增）
  late Color macdBearishColor; // 空头（减）

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  void _initializeSettings() {
    // 初始化MACD参数
    shortPeriod = 12;
    longPeriod = 26;
    signalPeriod = 9;

    // DIF线样式
    difLineStyle = LineStyle.solid;
    difColor = const Color(0xFFFFEB3B); // 黄色

    // DEA线样式
    deaLineStyle = LineStyle.solid;
    deaColor = const Color(0xFF9C27B0); // 紫色

    // MACD柱状图样式
    macdBarStyle = BarStyle.hollow;
    macdBullishColor = const Color(0xFF4CAF50); // 绿色（增）
    macdBearishColor = const Color(0xFFf44336); // 红色（减）

    macdParam = MACDParam(s: shortPeriod, l: longPeriod, m: signalPeriod);
  }

  @override
  String get indicatorName => 'MACD';

  @override
  String get indicatorTitle => 'MACD指数平滑异同移动平均线';

  @override
  List<Widget> buildSettingItems(FKTheme theme) {
    return [
      // 基础参数设置
      buildSectionTitle('基础参数', theme),
      buildNumberItem(
        title: '短周期',
        value: shortPeriod.toDouble(),
        onChanged: (value) {
          setState(() {
            shortPeriod = value.toInt();
          });
        },
        theme: theme,
        min: 1,
        max: 60,
        decimalPlaces: 0,
      ),

      buildNumberItem(
        title: '长周期',
        value: longPeriod.toDouble(),
        onChanged: (value) {
          setState(() {
            longPeriod = value.toInt();
          });
        },
        theme: theme,
        min: 1,
        max: 100,
        decimalPlaces: 0,
      ),

      buildNumberItem(
        title: '移动平均周期',
        value: signalPeriod.toDouble(),
        onChanged: (value) {
          setState(() {
            signalPeriod = value.toInt();
          });
        },
        theme: theme,
        min: 1,
        max: 50,
        decimalPlaces: 0,
      ),

      SizedBox(height: 16.r),

      // 指标线设置
      buildSectionTitle('指标线', theme),

      // DIF线设置
      _buildIndicatorLineRow(
        title: 'DIF',
        enabled: true,
        lineStyle: difLineStyle,
        color: difColor,
        onLineStyleChanged: (style) {
          setState(() {
            difLineStyle = style;
          });
        },
        onColorChanged: (color) {
          setState(() {
            difColor = color;
          });
        },
        theme: theme,
      ),

      SizedBox(height: 8.r),

      // DEA线设置
      _buildIndicatorLineRow(
        title: 'DEA',
        enabled: true,
        lineStyle: deaLineStyle,
        color: deaColor,
        onLineStyleChanged: (style) {
          setState(() {
            deaLineStyle = style;
          });
        },
        onColorChanged: (color) {
          setState(() {
            deaColor = color;
          });
        },
        theme: theme,
      ),

      SizedBox(height: 16.r),

      // MACD柱状图设置
      buildSectionTitle('MACD柱状图', theme),

      _buildMACDBarRow(
        title: 'MACD',
        barStyle: macdBarStyle,
        onBarStyleChanged: (style) {
          setState(() {
            macdBarStyle = style;
          });
        },
        theme: theme,
      ),

      SizedBox(height: 8.r),

      // 多头/空头颜色设置
      _buildBarColorRow(
        title: '多头（增）',
        color: macdBullishColor,
        onColorChanged: (color) {
          setState(() {
            macdBullishColor = color;
          });
        },
        theme: theme,
      ),

      SizedBox(height: 8.r),

      _buildBarColorRow(
        title: '空头（减）',
        color: macdBearishColor,
        onColorChanged: (color) {
          setState(() {
            macdBearishColor = color;
          });
        },
        theme: theme,
      ),

      SizedBox(height: 16.r),
    ];
  }

  /// 构建指标线行
  Widget _buildIndicatorLineRow({
    required String title,
    required bool enabled,
    required LineStyle lineStyle,
    required Color color,
    required ValueChanged<LineStyle> onLineStyleChanged,
    required ValueChanged<Color> onColorChanged,
    required FKTheme theme,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: theme.dividerLine),
      ),
      child: Row(
        children: [
          // 启用开关
          Icon(
            enabled ? Icons.check_box : Icons.check_box_outline_blank,
            color: enabled ? theme.long : theme.t2,
            size: 20.r,
          ),
          SizedBox(width: 8.r),

          // 标题
          Text(
            title,
            style: TextStyle(
              color: theme.t1,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),

          const Spacer(),

          // 样式选择器
          StyleSelectorRow(
            lineStyle: lineStyle,
            onLineStyleChanged: onLineStyleChanged,
            color: color,
            onColorChanged: onColorChanged,
            showLineStyle: true,
            showBarStyle: false,
          ),
        ],
      ),
    );
  }

  /// 构建MACD柱状图行
  Widget _buildMACDBarRow({
    required String title,
    required BarStyle barStyle,
    required ValueChanged<BarStyle> onBarStyleChanged,
    required FKTheme theme,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: theme.dividerLine),
      ),
      child: Row(
        children: [
          // 启用开关（MACD柱状图总是启用）
          Icon(
            Icons.check_box,
            color: theme.long,
            size: 20.r,
          ),
          SizedBox(width: 8.r),

          // 标题
          Text(
            title,
            style: TextStyle(
              color: theme.t1,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),

          const Spacer(),

          // 样式选择器
          Text(
            '样式',
            style: TextStyle(
              color: theme.t2,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(width: 8.r),

          BarStyleSelector(
            value: barStyle,
            onChanged: onBarStyleChanged,
            width: 80,
            height: 32,
          ),
        ],
      ),
    );
  }

  /// 构建柱状图颜色行
  Widget _buildBarColorRow({
    required String title,
    required Color color,
    required ValueChanged<Color> onColorChanged,
    required FKTheme theme,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: theme.dividerLine),
      ),
      child: Row(
        children: [
          SizedBox(width: 28.r), // 对齐空间

          // 标题
          Text(
            title,
            style: TextStyle(
              color: theme.t1,
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
            ),
          ),

          const Spacer(),

          // 颜色选择器
          Text(
            '颜色',
            style: TextStyle(
              color: theme.t2,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(width: 8.r),

          ColorSelector(
            value: color,
            onChanged: onColorChanged,
            width: 32,
            height: 32,
          ),
        ],
      ),
    );
  }

  @override
  Future<void> saveSettings() async {
    // 更新macdParam
    macdParam = MACDParam(s: shortPeriod, l: longPeriod, m: signalPeriod);

    // TODO: 保存到配置中，包括样式信息
    debugPrint('保存MACD设置:');
    debugPrint('  短周期: $shortPeriod, 长周期: $longPeriod, 移动平均周期: $signalPeriod');
    debugPrint('  DIF样式: $difLineStyle, 颜色: #${difColor.value.toRadixString(16).padLeft(8, '0')}');
    debugPrint('  DEA样式: $deaLineStyle, 颜色: #${deaColor.value.toRadixString(16).padLeft(8, '0')}');
    debugPrint('  MACD柱状图样式: $macdBarStyle');
    debugPrint('  多头颜色: #${macdBullishColor.value.toRadixString(16).padLeft(8, '0')}');
    debugPrint('  空头颜色: #${macdBearishColor.value.toRadixString(16).padLeft(8, '0')}');
  }

  @override
  Future<void> resetToDefault() async {
    setState(() {
      _initializeSettings();
    });
  }
}
