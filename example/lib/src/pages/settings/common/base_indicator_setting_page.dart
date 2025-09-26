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

// import 'package:flexi_kline/flexi_kline.dart'; // Unused import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/flexi_theme.dart';

/// 指标设置页面基类
abstract class BaseIndicatorSettingPage extends ConsumerStatefulWidget {
  const BaseIndicatorSettingPage({super.key});
}

/// 指标设置页面基础状态类
abstract class BaseIndicatorSettingPageState<T extends BaseIndicatorSettingPage>
    extends ConsumerState<T> {
  /// 获取指标名称
  String get indicatorName;

  /// 获取指标标题
  String get indicatorTitle;

  /// 构建设置项
  List<Widget> buildSettingItems(FKTheme theme);

  /// 保存设置
  Future<void> saveSettings();

  /// 重置为默认值
  Future<void> resetToDefault();

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    return Scaffold(
      backgroundColor: theme.pageBg,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(
          '$indicatorTitle设置',
          style: theme.t1s18w600,
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: resetToDefault,
            child: Text(
              '重置',
              style: theme.t1s14w400,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: buildSettingItems(theme),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsetsDirectional.all(16.r),
            child: ElevatedButton(
              onPressed: () async {
                await saveSettings();
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.long,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 48.r),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                '保存设置',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建分组标题
  Widget buildSectionTitle(String title, FKTheme theme) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: 16.r,
        end: 16.r,
        top: 16.r,
        bottom: 8.r,
      ),
      child: Text(
        title,
        style: theme.t2s14w400,
      ),
    );
  }

  /// 构建颜色选择项
  Widget buildColorItem({
    required String title,
    required Color color,
    required ValueChanged<Color> onChanged,
    required FKTheme theme,
  }) {
    return ListTile(
      title: Text(
        title,
        style: theme.t1s16w400,
      ),
      trailing: GestureDetector(
        onTap: () => _showColorPicker(color, onChanged),
        child: Container(
          width: 32.r,
          height: 32.r,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: theme.dividerLine),
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ),
    );
  }

  /// 构建数值输入项
  Widget buildNumberItem({
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
    required FKTheme theme,
    double min = 1,
    double max = 100,
    int? decimalPlaces,
  }) {
    return ListTile(
      title: Text(
        title,
        style: theme.t1s16w400,
      ),
      trailing: SizedBox(
        width: 80.r,
        child: TextFormField(
          initialValue: decimalPlaces != null
              ? value.toStringAsFixed(decimalPlaces)
              : value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1),
          keyboardType: TextInputType.numberWithOptions(
            decimal: decimalPlaces != null && decimalPlaces > 0,
          ),
          textAlign: TextAlign.center,
          style: theme.t1s14w400,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide(color: theme.dividerLine),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide(color: theme.dividerLine),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide(color: theme.long),
            ),
            contentPadding: EdgeInsetsDirectional.symmetric(
              horizontal: 8.r,
              vertical: 8.r,
            ),
          ),
          onChanged: (value) {
            final numValue = double.tryParse(value);
            if (numValue != null && numValue >= min && numValue <= max) {
              onChanged(numValue);
            }
          },
        ),
      ),
    );
  }

  /// 构建开关项
  Widget buildSwitchItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required FKTheme theme,
    String? subtitle,
  }) {
    return ListTile(
      title: Text(
        title,
        style: theme.t1s16w400,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: theme.t2s12w400,
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: theme.long,
      ),
    );
  }

  /// 构建分割线
  Widget buildDivider(FKTheme theme) {
    return Container(
      height: 0.5.r,
      margin: EdgeInsetsDirectional.symmetric(horizontal: 16.r),
      color: theme.dividerLine,
    );
  }

  /// 显示颜色选择器
  void _showColorPicker(Color currentColor, ValueChanged<Color> onChanged) {
    // 简单的颜色选择器实现
    final colors = [
      Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
      Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
      Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
      Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
      Colors.brown, Colors.grey, Colors.blueGrey, Colors.black,
    ];
    
    showDialog(
      context: context,
      builder: (context) {
        final theme = ref.read(themeProvider);
        return AlertDialog(
          backgroundColor: theme.cardBg,
          title: Text(
            '选择颜色',
            style: TextStyle(
              color: theme.t1,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SizedBox(
            width: 280.r,
            child: Wrap(
              spacing: 8.r,
              runSpacing: 8.r,
              children: colors.map((color) {
                final isSelected = color == currentColor;
                return GestureDetector(
                  onTap: () {
                    onChanged(color);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 32.r,
                    height: 32.r,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color: isSelected ? theme.long : theme.dividerLine,
                        width: isSelected ? 2.r : 1.r,
                      ),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: _getContrastColor(color),
                            size: 16.r,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
  
  /// 获取对比色
  Color _getContrastColor(Color backgroundColor) {
    final brightness = backgroundColor.computeLuminance();
    return brightness > 0.5 ? Colors.black : Colors.white;
  }
}
