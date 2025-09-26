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
import '../common/style_selector_row.dart';
import '../common/base_indicator_setting_page.dart';

class BOLLSettingPage extends BaseIndicatorSettingPage {
  const BOLLSettingPage({super.key});

  @override
  ConsumerState<BOLLSettingPage> createState() => _BOLLSettingPageState();
}

class _BOLLSettingPageState extends BaseIndicatorSettingPageState<BOLLSettingPage> {
  late BOLLParam bollParam;
  
  // BOLL参数
  late int period;       // 周期
  late double multiplier; // 标准差倍数
  
  // 线条样式
  late LineStyle upLineStyle;    // 上轨线样式
  late LineStyle mbLineStyle;    // 中轨线样式
  late LineStyle dnLineStyle;    // 下轨线样式
  
  // 颜色设置
  late Color upColor;    // 上轨颜色
  late Color mbColor;    // 中轨颜色
  late Color dnColor;    // 下轨颜色
  
  // 填充设置
  late bool showFill;    // 是否显示填充
  late Color fillColor;  // 填充颜色
  late double fillOpacity; // 填充透明度

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  void _initializeSettings() {
    // 初始化BOLL参数
    period = 20;
    multiplier = 2.0;
    
    // 线条样式
    upLineStyle = LineStyle.solid;
    mbLineStyle = LineStyle.solid;
    dnLineStyle = LineStyle.solid;
    
    // 颜色设置
    upColor = const Color(0xFFFF5722); // 上轨红色
    mbColor = const Color(0xFF2196F3); // 中轨蓝色
    dnColor = const Color(0xFF4CAF50); // 下轨绿色
    
    // 填充设置
    showFill = true;
    fillColor = const Color(0xFF2196F3);
    fillOpacity = 0.1;
    
    bollParam = BOLLParam(
      periods: BOLLPeriodsConfig(period: period, stdDev: multiplier),
    );
  }

  @override
  String get indicatorName => 'BOLL';

  @override
  String get indicatorTitle => 'BOLL布林线';

  @override
  List<Widget> buildSettingItems(FKTheme theme) {
    return [
      // 基础参数设置
      buildSectionTitle('基础参数', theme),
      buildNumberItem(
        title: '计算周期',
        value: period.toDouble(),
        onChanged: (value) {
          setState(() {
            period = value.toInt();
          });
        },
        theme: theme,
        min: 5,
        max: 100,
        decimalPlaces: 0,
      ),
      
      buildNumberItem(
        title: '标准差倍数',
        value: multiplier,
        onChanged: (value) {
          setState(() {
            multiplier = value;
          });
        },
        theme: theme,
        min: 0.5,
        max: 5.0,
        decimalPlaces: 1,
      ),
      
      SizedBox(height: 16.r),
      
      // 线条设置
      buildSectionTitle('线条设置', theme),
      
      // 上轨设置
      _buildLineRow(
        title: '上轨(UP)',
        lineStyle: upLineStyle,
        color: upColor,
        onLineStyleChanged: (style) {
          setState(() {
            upLineStyle = style;
          });
        },
        onColorChanged: (color) {
          setState(() {
            upColor = color;
          });
        },
        theme: theme,
      ),
      
      SizedBox(height: 8.r),
      
      // 中轨设置
      _buildLineRow(
        title: '中轨(MB)',
        lineStyle: mbLineStyle,
        color: mbColor,
        onLineStyleChanged: (style) {
          setState(() {
            mbLineStyle = style;
          });
        },
        onColorChanged: (color) {
          setState(() {
            mbColor = color;
          });
        },
        theme: theme,
      ),
      
      SizedBox(height: 8.r),
      
      // 下轨设置
      _buildLineRow(
        title: '下轨(DN)',
        lineStyle: dnLineStyle,
        color: dnColor,
        onLineStyleChanged: (style) {
          setState(() {
            dnLineStyle = style;
          });
        },
        onColorChanged: (color) {
          setState(() {
            dnColor = color;
          });
        },
        theme: theme,
      ),
      
      SizedBox(height: 16.r),
      
      // 填充设置
      buildSectionTitle('填充设置', theme),
      buildSwitchItem(
        title: '显示轨道填充',
        subtitle: '在上轨和下轨之间显示填充区域',
        value: showFill,
        onChanged: (value) {
          setState(() {
            showFill = value;
          });
        },
        theme: theme,
      ),
      
      if (showFill) ...[
        buildColorItem(
          title: '填充颜色',
          color: fillColor,
          onChanged: (color) {
            setState(() {
              fillColor = color;
            });
          },
          theme: theme,
        ),
        
        ListTile(
          title: Text(
            '填充透明度',
            style: theme.t1s16w400,
          ),
          trailing: SizedBox(
            width: 120.r,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Slider(
                    value: fillOpacity,
                    min: 0.05,
                    max: 0.5,
                    divisions: 18,
                    label: '${(fillOpacity * 100).toInt()}%',
                    onChanged: (value) {
                      setState(() {
                        fillOpacity = value;
                      });
                    },
                    activeColor: theme.long,
                  ),
                ),
                Text(
                  '${(fillOpacity * 100).toInt()}%',
                  style: theme.t1s12w400,
                ),
              ],
            ),
          ),
        ),
      ],
      
      SizedBox(height: 16.r),
    ];
  }

  /// 构建线条设置行
  Widget _buildLineRow({
    required String title,
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

  @override
  Future<void> saveSettings() async {
    // 更新bollParam
    bollParam = BOLLParam(
      periods: BOLLPeriodsConfig(period: period, stdDev: multiplier),
    );
    
    debugPrint('保存BOLL设置:');
    debugPrint('  周期: $period, 标准差倍数: $multiplier');
    debugPrint('  上轨样式: $upLineStyle, 颜色: #${upColor.value.toRadixString(16).padLeft(8, '0')}');
    debugPrint('  中轨样式: $mbLineStyle, 颜色: #${mbColor.value.toRadixString(16).padLeft(8, '0')}');
    debugPrint('  下轨样式: $dnLineStyle, 颜色: #${dnColor.value.toRadixString(16).padLeft(8, '0')}');
    debugPrint('  显示填充: $showFill');
    if (showFill) {
      debugPrint('  填充颜色: #${fillColor.value.toRadixString(16).padLeft(8, '0')}, 透明度: $fillOpacity');
    }
  }

  @override
  Future<void> resetToDefault() async {
    setState(() {
      _initializeSettings();
    });
  }
}
