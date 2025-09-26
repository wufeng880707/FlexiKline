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
import '../common/style_selector_row.dart';

class RSISettingPage extends BaseIndicatorSettingPage {
  const RSISettingPage({super.key});

  @override
  ConsumerState<RSISettingPage> createState() => _RSISettingPageState();
}

class _RSISettingPageState extends BaseIndicatorSettingPageState<RSISettingPage> {
  late RsiParam rsiParam;
  late List<RSILineConfig> rsiLines;
  late List<LineStyle> lineStyles;

  // 参考线设置
  late bool showRefLines;
  late double overboughtLevel; // 超买线
  late double oversoldLevel; // 超卖线
  late Color refLineColor;
  late LineStyle refLineStyle;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  void _initializeSettings() {
    // 初始化RSI线条
    rsiLines = [
      const RSILineConfig(
        id: 'rsi_6',
        enabled: true,
        period: 6,
        color: Color(0xFF2196F3),
        width: 1.5,
      ),
      const RSILineConfig(
        id: 'rsi_12',
        enabled: true,
        period: 12,
        color: Color(0xFFFF9800),
        width: 1.5,
      ),
      const RSILineConfig(
        id: 'rsi_24',
        enabled: false,
        period: 24,
        color: Color(0xFF9C27B0),
        width: 1.5,
      ),
    ];

    lineStyles = [
      LineStyle.solid,
      LineStyle.solid,
      LineStyle.solid,
    ];

    // 参考线设置
    showRefLines = true;
    overboughtLevel = 70.0;
    oversoldLevel = 30.0;
    refLineColor = const Color(0xFF757575);
    refLineStyle = LineStyle.dashed;

    rsiParam = RsiParam(lines: rsiLines);
  }

  @override
  String get indicatorName => 'RSI';

  @override
  String get indicatorTitle => 'RSI相对强弱指标';

  @override
  List<Widget> buildSettingItems(FKTheme theme) {
    return [
      // RSI线条设置
      buildSectionTitle('RSI线条设置', theme),

      // 表格头部
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
        child: Row(
          children: [
            SizedBox(width: 40.r),
            Text(
              '指标线',
              style: TextStyle(color: theme.t2, fontSize: 14.sp),
            ),
            SizedBox(width: 60.r),
            Text(
              '周期',
              style: TextStyle(color: theme.t2, fontSize: 14.sp),
            ),
            const Spacer(),
            Text(
              '线宽',
              style: TextStyle(color: theme.t2, fontSize: 14.sp),
            ),
            SizedBox(width: 40.r),
            Text(
              '样式',
              style: TextStyle(color: theme.t2, fontSize: 14.sp),
            ),
          ],
        ),
      ),

      // RSI线列表
      ...rsiLines.asMap().entries.map((entry) {
        final index = entry.key;
        final line = entry.value;
        final lineStyle = lineStyles[index];

        return _buildRSILineRow(index, line, lineStyle, theme);
      }),

      SizedBox(height: 8.r),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.r),
        child: ElevatedButton.icon(
          onPressed: _addNewLine,
          icon: const Icon(Icons.add),
          label: const Text('添加新的RSI线'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.long.withOpacity(0.1),
            foregroundColor: theme.long,
            elevation: 0,
            side: BorderSide(color: theme.long),
          ),
        ),
      ),

      SizedBox(height: 16.r),

      // 参考线设置
      buildSectionTitle('参考线设置', theme),
      buildSwitchItem(
        title: '显示超买超卖线',
        subtitle: '显示70和30的参考线',
        value: showRefLines,
        onChanged: (value) {
          setState(() {
            showRefLines = value;
          });
        },
        theme: theme,
      ),

      if (showRefLines) ...[
        buildNumberItem(
          title: '超买线位置',
          value: overboughtLevel,
          onChanged: (value) {
            setState(() {
              overboughtLevel = value;
            });
          },
          theme: theme,
          min: 60,
          max: 90,
          decimalPlaces: 0,
        ),
        buildNumberItem(
          title: '超卖线位置',
          value: oversoldLevel,
          onChanged: (value) {
            setState(() {
              oversoldLevel = value;
            });
          },
          theme: theme,
          min: 10,
          max: 40,
          decimalPlaces: 0,
        ),
        _buildRefLineRow(theme),
      ],

      SizedBox(height: 16.r),
    ];
  }

  Widget _buildRSILineRow(int index, RSILineConfig line, LineStyle lineStyle, FKTheme theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.r, vertical: 2.r),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: theme.dividerLine),
      ),
      child: Row(
        children: [
          // 启用开关
          GestureDetector(
            onTap: () => _toggleLine(index),
            child: Icon(
              line.enabled ? Icons.check_box : Icons.check_box_outline_blank,
              color: line.enabled ? theme.long : theme.t2,
              size: 20.r,
            ),
          ),
          SizedBox(width: 8.r),

          // RSI标题
          Text(
            'RSI',
            style: TextStyle(
              color: theme.t1,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 60.r),

          // 周期值
          SizedBox(
            width: 40.r,
            child: Text(
              '${line.period}',
              style: TextStyle(
                color: theme.t1,
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const Spacer(),

          // 线宽显示
          GestureDetector(
            onTap: () => _showLineWidthPicker(index, line.width, theme),
            child: Container(
              width: 60.r,
              height: 28.r,
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerLine),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Center(
                child: CustomPaint(
                  size: Size(30.r, line.width * 2),
                  painter: LineWidthPainter(
                    width: line.width,
                    color: line.color,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: 8.r),

          // 样式选择器
          StyleSelectorRow(
            lineStyle: lineStyle,
            onLineStyleChanged: (style) {
              setState(() {
                lineStyles[index] = style;
              });
            },
            color: line.color,
            onColorChanged: (color) {
              setState(() {
                rsiLines[index] = line.copyWith(color: color);
              });
            },
            showLineStyle: true,
            showBarStyle: false,
          ),
        ],
      ),
    );
  }

  Widget _buildRefLineRow(FKTheme theme) {
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
            '参考线样式',
            style: TextStyle(
              color: theme.t1,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          StyleSelectorRow(
            lineStyle: refLineStyle,
            onLineStyleChanged: (style) {
              setState(() {
                refLineStyle = style;
              });
            },
            color: refLineColor,
            onColorChanged: (color) {
              setState(() {
                refLineColor = color;
              });
            },
            showLineStyle: true,
            showBarStyle: false,
          ),
        ],
      ),
    );
  }

  void _toggleLine(int index) {
    setState(() {
      final line = rsiLines[index];
      rsiLines[index] = line.copyWith(enabled: !line.enabled);
    });
  }

  void _addNewLine() {
    final maxPeriod = rsiLines.map((e) => e.period).reduce((a, b) => a > b ? a : b);
    final newPeriod = maxPeriod + 6;

    setState(() {
      rsiLines.add(RSILineConfig(
        id: 'rsi_$newPeriod',
        enabled: true,
        period: newPeriod,
        color: _getNextColor(),
        width: 1.5,
      ));
      lineStyles.add(LineStyle.solid);
    });
  }

  Color _getNextColor() {
    const colors = [
      Color(0xFF2196F3),
      Color(0xFFFF9800),
      Color(0xFF9C27B0),
      Color(0xFF4CAF50),
      Color(0xFFf44336),
      Color(0xFF00BCD4),
      Color(0xFF795548),
      Color(0xFF607D8B),
    ];
    return colors[rsiLines.length % colors.length];
  }

  void _showLineWidthPicker(int index, double currentWidth, FKTheme theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardBg,
        title: Text(
          '选择线宽',
          style: TextStyle(
            color: theme.t1,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0].map((width) {
            return ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 8.r),
              leading: CustomPaint(
                size: Size(40.r, width * 2),
                painter: LineWidthPainter(
                  width: width,
                  color: theme.t1,
                ),
              ),
              title: Text(
                '${width.toStringAsFixed(1)}px',
                style: TextStyle(color: theme.t1, fontSize: 14.sp),
              ),
              trailing:
                  currentWidth == width ? Icon(Icons.check, color: theme.long, size: 16.r) : null,
              onTap: () {
                setState(() {
                  final line = rsiLines[index];
                  rsiLines[index] = line.copyWith(width: width);
                });
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Future<void> saveSettings() async {
    // 更新rsiParam
    rsiParam = RsiParam(lines: rsiLines);

    debugPrint('保存RSI设置:');
    for (int i = 0; i < rsiLines.length; i++) {
      final line = rsiLines[i];
      final style = lineStyles[i];
      debugPrint('  RSI${line.period}: enabled=${line.enabled}, width=${line.width}, style=$style');
    }
    debugPrint('  显示参考线: $showRefLines');
    if (showRefLines) {
      debugPrint('  超买线: $overboughtLevel, 超卖线: $oversoldLevel');
    }
  }

  @override
  Future<void> resetToDefault() async {
    setState(() {
      _initializeSettings();
    });
  }
}

/// 线宽绘制器
class LineWidthPainter extends CustomPainter {
  const LineWidthPainter({
    required this.width,
    required this.color,
  });

  final double width;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    final startPoint = Offset(0, size.height / 2);
    final endPoint = Offset(size.width, size.height / 2);

    canvas.drawLine(startPoint, endPoint, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
