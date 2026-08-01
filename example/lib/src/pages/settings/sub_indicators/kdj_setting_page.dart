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

class KDJSettingPage extends BaseIndicatorSettingPage {
  const KDJSettingPage({super.key, required this.controller});

  final FlexiKlineController controller;

  @override
  ConsumerState<KDJSettingPage> createState() => _KDJSettingPageState();
}

class _KDJSettingPageState
    extends BaseIndicatorSettingPageState<KDJSettingPage> {
  static const _kdjKey = ComputedIndicatorKey('kdj');

  late KDJParam _currentParam;
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
      _enabled = controller.subIndicatorKeys.contains(_kdjKey);
      final indicator =
          controller.configuredSubIndicator<KDJIndicator>(_kdjKey);
      if (indicator != null) {
        _currentParam = indicator.calcParam;
      } else {
        _currentParam = const KDJParam();
      }
    } catch (e) {
      _currentParam = const KDJParam();
      _enabled = false;
    }
  }

  @override
  String get indicatorName => 'KDJ';

  @override
  String get indicatorTitle => 'KDJ随机指标';

  @override
  List<Widget> buildSettingItems(FKTheme theme) {
    final calc = _currentParam.calculation;
    final lines = _currentParam.lines;
    final display = _currentParam.display;

    return [
      buildSectionTitle('计算参数', theme),
      buildNumberItem(
        title: 'K周期',
        value: calc.kPeriod.toDouble(),
        onChanged: (value) {
          setState(() {
            _currentParam = _currentParam.copyWith(
              calculation: calc.copyWith(kPeriod: value.toInt()),
            );
          });
        },
        theme: theme,
        min: 1,
        max: 100,
        decimalPlaces: 0,
      ),
      buildNumberItem(
        title: 'D周期',
        value: calc.dPeriod.toDouble(),
        onChanged: (value) {
          setState(() {
            _currentParam = _currentParam.copyWith(
              calculation: calc.copyWith(dPeriod: value.toInt()),
            );
          });
        },
        theme: theme,
        min: 1,
        max: 100,
        decimalPlaces: 0,
      ),
      buildNumberItem(
        title: 'J周期',
        value: calc.jPeriod.toDouble(),
        onChanged: (value) {
          setState(() {
            _currentParam = _currentParam.copyWith(
              calculation: calc.copyWith(jPeriod: value.toInt()),
            );
          });
        },
        theme: theme,
        min: 1,
        max: 100,
        decimalPlaces: 0,
      ),
      SizedBox(height: 8.r),
      buildSectionTitle('指标线设置', theme),
      _buildLineTableHeader(theme),
      _buildKDJLineRow(
        'K',
        lines.k,
        (c) => setState(() {
          _currentParam = _currentParam.copyWith(lines: lines.copyWith(k: c));
        }),
        theme,
      ),
      _buildKDJLineRow(
        'D',
        lines.d,
        (c) => setState(() {
          _currentParam = _currentParam.copyWith(lines: lines.copyWith(d: c));
        }),
        theme,
      ),
      _buildKDJLineRow(
        'J',
        lines.j,
        (c) => setState(() {
          _currentParam = _currentParam.copyWith(lines: lines.copyWith(j: c));
        }),
        theme,
      ),
      SizedBox(height: 8.r),
      buildSectionTitle('显示设置', theme),
      buildNumberItem(
        title: '数值精度',
        value: display.precision.toDouble(),
        onChanged: (value) {
          setState(() {
            _currentParam = _currentParam.copyWith(
              display: display.copyWith(precision: value.toInt()),
            );
          });
        },
        theme: theme,
        min: 0,
        max: 6,
        decimalPlaces: 0,
      ),
      buildSwitchItem(
        title: '在提示中显示周期',
        value: display.showPeriodInTips,
        onChanged: (value) {
          setState(() {
            _currentParam = _currentParam.copyWith(
              display: display.copyWith(showPeriodInTips: value),
            );
          });
        },
        theme: theme,
      ),
      SizedBox(height: 16.r),
    ];
  }

  Widget _buildLineTableHeader(FKTheme theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.r),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text('指标线', style: theme.t2s12w400),
          ),
          Expanded(
            flex: 2,
            child: Center(child: Text('线宽', style: theme.t2s12w400)),
          ),
          Expanded(
            flex: 2,
            child: Center(child: Text('颜色', style: theme.t2s12w400)),
          ),
        ],
      ),
    );
  }

  Widget _buildKDJLineRow(
    String name,
    KDJLineConfig config,
    ValueChanged<KDJLineConfig> onChanged,
    FKTheme theme,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.r, vertical: 2.r),
      padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 8.r),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: theme.dividerLine),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () =>
                      onChanged(config.copyWith(enabled: !config.enabled)),
                  child: Icon(
                    config.enabled
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: config.enabled ? theme.long : theme.t2,
                    size: 20.r,
                  ),
                ),
                SizedBox(width: 4.r),
                Flexible(
                  child: Text(
                    name,
                    style: TextStyle(
                      color: config.color,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: LineWidthSelector(
                value: config.width,
                onChanged: (width) {
                  onChanged(config.copyWith(width: width));
                },
                color: config.color,
                width: 72,
                height: 30,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: ColorSelector(
                value: config.color,
                onChanged: (color) {
                  onChanged(config.copyWith(color: color));
                },
                width: 72,
                height: 30,
              ),
            ),
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
          controller.configuredSubIndicator<KDJIndicator>(_kdjKey);
      if (oldIndicator != null) {
        final newIndicator = KDJIndicator(
          height: oldIndicator.height,
          padding: oldIndicator.padding,
          calcParam: _currentParam,
          tipsPadding: oldIndicator.tipsPadding,
          tickCount: oldIndicator.tickCount,
        );
        await controller.saveAndSetSubIndicator(newIndicator,
            enabled: _enabled);
      }
    } catch (e) {
      debugPrint('保存KDJ设置失败: $e');
    }
  }

  @override
  Future<void> resetToDefault() async {
    setState(() {
      _currentParam = const KDJParam();
    });
  }
}
