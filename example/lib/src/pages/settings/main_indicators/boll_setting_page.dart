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

import '../../../providers/kline_controller_state_provider.dart';
import '../../../providers/indicator_config_controller_ext.dart';
import '../../../theme/flexi_theme.dart';
import '../common/base_indicator_setting_page.dart';
import '../common/color_selector.dart';
import '../common/line_width_selector.dart';

class BOLLSettingPage extends BaseIndicatorSettingPage {
  const BOLLSettingPage({
    super.key,
    required this.controller,
  });

  final FlexiKlineController controller;

  @override
  ConsumerState<BOLLSettingPage> createState() => _BOLLSettingPageState();
}

class _BOLLSettingPageState
    extends BaseIndicatorSettingPageState<BOLLSettingPage> {
  static const _bollKey = ComputedIndicatorKey('boll');

  late BOLLParam _currentParam;
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    final klineState = ref.read(klineStateProvider(widget.controller));
    final controller = klineState.controller;

    try {
      _enabled = controller.mainIndicatorKeys.contains(_bollKey);

      final indicator =
          controller.configuredMainIndicator<BOLLIndicator>(_bollKey);
      if (indicator != null) {
        _currentParam = indicator.calcParam;
      } else {
        _currentParam = const BOLLParam();
      }
    } catch (e) {
      debugPrint('获取BOLL配置失败: $e');
      _currentParam = const BOLLParam();
      _enabled = false;
    }
  }

  @override
  String get indicatorName => 'BOLL';

  @override
  String get indicatorTitle => 'BOLL布林线';

  @override
  List<Widget> buildSettingItems(FKTheme theme) {
    final periods = _currentParam.periods;
    final linesConfig = _currentParam.lines;
    final fillConfig = _currentParam.fill;

    return [
      buildSectionTitle('基础参数', theme),
      buildNumberItem(
        title: '计算周期',
        value: periods.period.toDouble(),
        onChanged: (value) {
          setState(() {
            _currentParam = _currentParam.copyWith(
              periods: periods.copyWith(period: value.toInt()),
            );
          });
        },
        theme: theme,
        min: 5,
        max: 100,
        decimalPlaces: 0,
      ),
      buildNumberItem(
        title: '标准差倍数',
        value: periods.stdDev,
        onChanged: (value) {
          setState(() {
            _currentParam = _currentParam.copyWith(
              periods: periods.copyWith(stdDev: value),
            );
          });
        },
        theme: theme,
        min: 0.5,
        max: 5.0,
        decimalPlaces: 1,
      ),
      SizedBox(height: 16.r),
      buildSectionTitle('线条设置', theme),
      _buildBollLineRow(
        title: '上轨(UB)',
        lineConfig: linesConfig.ub,
        onChanged: (newLine) {
          setState(() {
            _currentParam = _currentParam.copyWith(
              lines: linesConfig.copyWith(ub: newLine),
            );
          });
        },
        theme: theme,
      ),
      SizedBox(height: 4.r),
      _buildBollLineRow(
        title: '中轨(BOLL)',
        lineConfig: linesConfig.boll,
        onChanged: (newLine) {
          setState(() {
            _currentParam = _currentParam.copyWith(
              lines: linesConfig.copyWith(boll: newLine),
            );
          });
        },
        theme: theme,
      ),
      SizedBox(height: 4.r),
      _buildBollLineRow(
        title: '下轨(LB)',
        lineConfig: linesConfig.lb,
        onChanged: (newLine) {
          setState(() {
            _currentParam = _currentParam.copyWith(
              lines: linesConfig.copyWith(lb: newLine),
            );
          });
        },
        theme: theme,
      ),
      SizedBox(height: 16.r),
      buildSectionTitle('填充设置', theme),
      buildSwitchItem(
        title: '显示轨道填充',
        subtitle: '在上轨和下轨之间显示填充区域',
        value: fillConfig.enabled,
        onChanged: (value) {
          setState(() {
            _currentParam = _currentParam.copyWith(
              fill: fillConfig.copyWith(enabled: value),
            );
          });
        },
        theme: theme,
      ),
      if (fillConfig.enabled) ...[
        buildColorItem(
          title: '填充颜色',
          color: fillConfig.color,
          onChanged: (color) {
            setState(() {
              _currentParam = _currentParam.copyWith(
                fill: fillConfig.copyWith(color: color),
              );
            });
          },
          theme: theme,
        ),
        ListTile(
          title: Text('填充透明度', style: theme.t1s16w400),
          trailing: SizedBox(
            width: 160.r,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Slider(
                    value: fillConfig.opacity,
                    min: 0.05,
                    max: 0.5,
                    divisions: 18,
                    label: '${(fillConfig.opacity * 100).toInt()}%',
                    onChanged: (value) {
                      setState(() {
                        _currentParam = _currentParam.copyWith(
                          fill: fillConfig.copyWith(opacity: value),
                        );
                      });
                    },
                    activeColor: theme.long,
                  ),
                ),
                Text(
                  '${(fillConfig.opacity * 100).toInt()}%',
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

  Widget _buildBollLineRow({
    required String title,
    required BOLLLineConfig lineConfig,
    required ValueChanged<BOLLLineConfig> onChanged,
    required FKTheme theme,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.r),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: theme.dividerLine),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              onChanged(lineConfig.copyWith(enabled: !lineConfig.enabled));
            },
            child: Icon(
              lineConfig.enabled
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
              color: lineConfig.enabled ? theme.long : theme.t2,
              size: 20.r,
            ),
          ),
          SizedBox(width: 8.r),
          Text(
            title,
            style: TextStyle(
              color: lineConfig.color,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          LineWidthSelector(
            value: lineConfig.width,
            onChanged: (width) {
              onChanged(lineConfig.copyWith(width: width));
            },
            color: lineConfig.color,
            width: 80,
            height: 32,
          ),
          SizedBox(width: 8.r),
          ColorSelector(
            value: lineConfig.color,
            onChanged: (color) {
              onChanged(lineConfig.copyWith(color: color));
            },
            width: 80,
            height: 32,
          ),
        ],
      ),
    );
  }

  @override
  Future<void> saveSettings() async {
    try {
      final klineState = ref.read(klineStateProvider(widget.controller));
      final controller = klineState.controller;

      final oldIndicator =
          controller.configuredMainIndicator<BOLLIndicator>(_bollKey);
      if (oldIndicator != null) {
        final newIndicator = BOLLIndicator(
          height: oldIndicator.height,
          padding: oldIndicator.padding,
          calcParam: _currentParam,
          tipsPadding: oldIndicator.tipsPadding,
          tickCount: oldIndicator.tickCount,
        );
        await controller.saveAndSetMainIndicator(newIndicator,
            enabled: _enabled);
        debugPrint('BOLL指标参数已更新');
      }
    } catch (e) {
      debugPrint('保存BOLL设置失败: $e');
    }
  }

  @override
  Future<void> resetToDefault() async {
    setState(() {
      _currentParam = const BOLLParam();
    });
  }
}
