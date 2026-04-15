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
import '../../../theme/flexi_theme.dart';
import '../common/base_indicator_setting_page.dart';

class SARSettingPage extends BaseIndicatorSettingPage {
  const SARSettingPage({
    super.key,
    required this.controller,
  });

  final FlexiKlineController controller;

  @override
  ConsumerState<SARSettingPage> createState() => _SARSettingPageState();
}

class _SARSettingPageState
    extends BaseIndicatorSettingPageState<SARSettingPage> {
  static const _sarKey = DataIndicatorKey('sar');

  late SARParam _currentParam;
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
      _enabled = controller.mainIndicatorKeys.contains(_sarKey) ||
          controller.subIndicatorKeys.contains(_sarKey);

      final indicator = controller.getIndicator<SARIndicator>(_sarKey);
      if (indicator != null) {
        _currentParam = indicator.calcParam;
      } else {
        _currentParam = const SARParam();
      }
    } catch (e) {
      debugPrint('获取SAR配置失败: $e');
      _currentParam = const SARParam();
      _enabled = false;
    }
  }

  @override
  String get indicatorName => 'SAR';

  @override
  String get indicatorTitle => 'SAR抛物线转向指标';

  @override
  List<Widget> buildSettingItems(FKTheme theme) {
    final periods = _currentParam.periods;
    final appearance = _currentParam.appearance;

    return [
      buildSectionTitle('加速因子参数', theme),

      buildNumberItem(
        title: '初始加速因子',
        value: periods.start,
        onChanged: (value) {
          setState(() {
            _currentParam = _currentParam.copyWith(
              periods: periods.copyWith(start: value),
            );
          });
        },
        theme: theme,
        min: 0.01,
        max: 0.1,
        decimalPlaces: 2,
      ),

      buildNumberItem(
        title: '加速步长',
        value: periods.step,
        onChanged: (value) {
          setState(() {
            _currentParam = _currentParam.copyWith(
              periods: periods.copyWith(step: value),
            );
          });
        },
        theme: theme,
        min: 0.01,
        max: 0.1,
        decimalPlaces: 2,
      ),

      buildNumberItem(
        title: '最大加速因子',
        value: periods.max,
        onChanged: (value) {
          setState(() {
            _currentParam = _currentParam.copyWith(
              periods: periods.copyWith(max: value),
            );
          });
        },
        theme: theme,
        min: 0.1,
        max: 0.5,
        decimalPlaces: 2,
      ),

      SizedBox(height: 16.r),

      buildSectionTitle('外观设置', theme),

      buildColorItem(
        title: 'SAR点颜色',
        color: appearance.color,
        onChanged: (color) {
          setState(() {
            _currentParam = _currentParam.copyWith(
              appearance: appearance.copyWith(color: color),
            );
          });
        },
        theme: theme,
      ),

      buildSwitchItem(
        title: '使用涨跌色',
        subtitle: '根据趋势方向显示不同颜色',
        value: appearance.useTrendColor,
        onChanged: (value) {
          setState(() {
            _currentParam = _currentParam.copyWith(
              appearance: appearance.copyWith(useTrendColor: value),
            );
          });
        },
        theme: theme,
      ),

      buildNumberItem(
        title: '点半径',
        value: appearance.pointRadius,
        onChanged: (value) {
          setState(() {
            _currentParam = _currentParam.copyWith(
              appearance: appearance.copyWith(pointRadius: value),
            );
          });
        },
        theme: theme,
        min: 1.0,
        max: 10.0,
        decimalPlaces: 1,
      ),

      buildNumberItem(
        title: '边框宽度',
        value: appearance.borderWidth,
        onChanged: (value) {
          setState(() {
            _currentParam = _currentParam.copyWith(
              appearance: appearance.copyWith(borderWidth: value),
            );
          });
        },
        theme: theme,
        min: 0.0,
        max: 5.0,
        decimalPlaces: 1,
      ),

      SizedBox(height: 16.r),

      buildSectionTitle('显示设置', theme),

      buildNumberItem(
        title: '数值精度',
        value: _currentParam.display.precision.toDouble(),
        onChanged: (value) {
          setState(() {
            _currentParam = _currentParam.copyWith(
              display: _currentParam.display.copyWith(
                precision: value.toInt(),
              ),
            );
          });
        },
        theme: theme,
        min: 0,
        max: 8,
        decimalPlaces: 0,
      ),

      SizedBox(height: 16.r),
    ];
  }

  @override
  Future<void> saveSettings() async {
    try {
      final klineState = ref.read(klineStateProvider(widget.controller));
      final controller = klineState.controller;

      if (_enabled) {
        final oldIndicator =
            controller.getIndicator<SARIndicator>(_sarKey);
        if (oldIndicator != null) {
          final newIndicator = SARIndicator(
            height: oldIndicator.height,
            padding: oldIndicator.padding,
            calcParam: _currentParam,
            tipsPadding: oldIndicator.tipsPadding,
            tickCount: oldIndicator.tickCount,
          );
          controller.updateIndicator(newIndicator);
          debugPrint('SAR指标参数已更新');
        }
      }
    } catch (e) {
      debugPrint('保存SAR设置失败: $e');
    }
  }

  @override
  Future<void> resetToDefault() async {
    setState(() {
      _currentParam = const SARParam();
    });
  }
}
