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
import '../common/color_selector.dart';
import '../common/kline_style_selector.dart';
import '../common/style_selector_row.dart';

class MACDSettingPage extends BaseIndicatorSettingPage {
  // 需要传入 controller，不能使用 const 构造。
  // ignore: prefer_const_constructors_in_immutables
  MACDSettingPage({
    super.key,
    required this.controller,
  });

  final FlexiKlineController controller;

  @override
  ConsumerState<MACDSettingPage> createState() => _MACDSettingPageState();
}

class _MACDSettingPageState
    extends BaseIndicatorSettingPageState<MACDSettingPage> {
  static const _macdKey = DataIndicatorKey('macd');

  late MACDParam _currentParam;
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
      _enabled = controller.mainIndicatorKeys.contains(_macdKey) ||
          controller.subIndicatorKeys.contains(_macdKey);
      final indicator = controller.getIndicator<MACDIndicator>(_macdKey);
      if (indicator != null) {
        _currentParam = indicator.calcParam;
      } else {
        _currentParam = const MACDParam(s: 12, l: 26, m: 9);
      }
    } catch (e) {
      debugPrint('获取MACD配置失败: $e');
      _currentParam = const MACDParam(s: 12, l: 26, m: 9);
      _enabled = false;
    }
  }

  static BarStyle _barStyleFromHistogram(HistogramStyle style) =>
      style == HistogramStyle.hollow ? BarStyle.hollow : BarStyle.filled;

  static HistogramStyle _histogramStyleFromBarStyle(BarStyle style) =>
      style == BarStyle.hollow ? HistogramStyle.hollow : HistogramStyle.solid;

  void _applyHistogramStyle(HistogramStyle style) {
    setState(() {
      _currentParam = _currentParam.copyWith(
        bullishIncreasing:
            _currentParam.bullishIncreasing.copyWith(style: style),
        bullishDecreasing:
            _currentParam.bullishDecreasing.copyWith(style: style),
        bearishIncreasing:
            _currentParam.bearishIncreasing.copyWith(style: style),
        bearishDecreasing:
            _currentParam.bearishDecreasing.copyWith(style: style),
      );
    });
  }

  @override
  String get indicatorName => 'MACD';

  @override
  String get indicatorTitle => 'MACD指数平滑异同移动平均线';

  @override
  List<Widget> buildSettingItems(FKTheme theme) {
    return [
      buildSectionTitle('基础参数', theme),
      KeyedSubtree(
        key: ValueKey('macd_s_${_currentParam.s}'),
        child: buildNumberItem(
          title: '短周期',
          value: _currentParam.s.toDouble(),
          onChanged: (value) {
            setState(() {
              _currentParam = _currentParam.copyWith(s: value.toInt());
            });
          },
          theme: theme,
          min: 1,
          max: 60,
          decimalPlaces: 0,
        ),
      ),
      KeyedSubtree(
        key: ValueKey('macd_l_${_currentParam.l}'),
        child: buildNumberItem(
          title: '长周期',
          value: _currentParam.l.toDouble(),
          onChanged: (value) {
            setState(() {
              _currentParam = _currentParam.copyWith(l: value.toInt());
            });
          },
          theme: theme,
          min: 1,
          max: 100,
          decimalPlaces: 0,
        ),
      ),
      KeyedSubtree(
        key: ValueKey('macd_m_${_currentParam.m}'),
        child: buildNumberItem(
          title: '移动平均周期',
          value: _currentParam.m.toDouble(),
          onChanged: (value) {
            setState(() {
              _currentParam = _currentParam.copyWith(m: value.toInt());
            });
          },
          theme: theme,
          min: 1,
          max: 50,
          decimalPlaces: 0,
        ),
      ),
      SizedBox(height: 16.r),
      buildSectionTitle('指标线', theme),
      _buildIndicatorLineRow(
        title: 'DIF',
        lineConfig: _currentParam.difLine,
        onEnabledChanged: (enabled) {
          setState(() {
            _currentParam = _currentParam.copyWith(
              difLine: _currentParam.difLine.copyWith(enabled: enabled),
            );
          });
        },
        onLineWidthChanged: (width) {
          setState(() {
            _currentParam = _currentParam.copyWith(
              difLine: _currentParam.difLine.copyWith(width: width),
            );
          });
        },
        onColorChanged: (color) {
          setState(() {
            _currentParam = _currentParam.copyWith(
              difLine: _currentParam.difLine.copyWith(color: color),
            );
          });
        },
        theme: theme,
      ),
      SizedBox(height: 8.r),
      _buildIndicatorLineRow(
        title: 'DEA',
        lineConfig: _currentParam.deaLine,
        onEnabledChanged: (enabled) {
          setState(() {
            _currentParam = _currentParam.copyWith(
              deaLine: _currentParam.deaLine.copyWith(enabled: enabled),
            );
          });
        },
        onLineWidthChanged: (width) {
          setState(() {
            _currentParam = _currentParam.copyWith(
              deaLine: _currentParam.deaLine.copyWith(width: width),
            );
          });
        },
        onColorChanged: (color) {
          setState(() {
            _currentParam = _currentParam.copyWith(
              deaLine: _currentParam.deaLine.copyWith(color: color),
            );
          });
        },
        theme: theme,
      ),
      SizedBox(height: 16.r),
      buildSectionTitle('MACD柱状图', theme),
      _buildMACDBarRow(
        title: 'MACD',
        histogramEnabled: _currentParam.histogramEnabled,
        barStyle: _barStyleFromHistogram(_currentParam.bullishIncreasing.style),
        onHistogramEnabledChanged: (enabled) {
          setState(() {
            _currentParam =
                _currentParam.copyWith(histogramEnabled: enabled);
          });
        },
        onBarStyleChanged: (style) {
          _applyHistogramStyle(_histogramStyleFromBarStyle(style));
        },
        theme: theme,
      ),
      SizedBox(height: 8.r),
      _buildBarColorRow(
        title: '多头（增）',
        color: _currentParam.bullishIncreasing.color,
        onColorChanged: (color) {
          setState(() {
            _currentParam = _currentParam.copyWith(
              bullishIncreasing:
                  _currentParam.bullishIncreasing.copyWith(color: color),
              bullishDecreasing:
                  _currentParam.bullishDecreasing.copyWith(color: color),
            );
          });
        },
        theme: theme,
      ),
      SizedBox(height: 8.r),
      _buildBarColorRow(
        title: '空头（减）',
        color: _currentParam.bearishIncreasing.color,
        onColorChanged: (color) {
          setState(() {
            _currentParam = _currentParam.copyWith(
              bearishIncreasing:
                  _currentParam.bearishIncreasing.copyWith(color: color),
              bearishDecreasing:
                  _currentParam.bearishDecreasing.copyWith(color: color),
            );
          });
        },
        theme: theme,
      ),
      SizedBox(height: 16.r),
    ];
  }

  Widget _buildIndicatorLineRow({
    required String title,
    required MACDLineConfig lineConfig,
    required ValueChanged<bool> onEnabledChanged,
    required ValueChanged<double> onLineWidthChanged,
    required ValueChanged<Color> onColorChanged,
    required FKTheme theme,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.r, vertical: 2.r),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: theme.dividerLine),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onEnabledChanged(!lineConfig.enabled),
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
              color: theme.t1,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          StyleSelectorRow(
            showLineStyle: false,
            color: lineConfig.color,
            onColorChanged: onColorChanged,
            lineWidth: lineConfig.width,
            onLineWidthChanged: onLineWidthChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildMACDBarRow({
    required String title,
    required bool histogramEnabled,
    required BarStyle barStyle,
    required ValueChanged<bool> onHistogramEnabledChanged,
    required ValueChanged<BarStyle> onBarStyleChanged,
    required FKTheme theme,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.r, vertical: 2.r),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: theme.dividerLine),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onHistogramEnabledChanged(!histogramEnabled),
            child: Icon(
              histogramEnabled
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
              color: histogramEnabled ? theme.long : theme.t2,
              size: 20.r,
            ),
          ),
          SizedBox(width: 8.r),
          Text(
            title,
            style: TextStyle(
              color: theme.t1,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
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

  Widget _buildBarColorRow({
    required String title,
    required Color color,
    required ValueChanged<Color> onColorChanged,
    required FKTheme theme,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.r, vertical: 2.r),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: theme.dividerLine),
      ),
      child: Row(
        children: [
          SizedBox(width: 28.r),
          Text(
            title,
            style: TextStyle(
              color: theme.t1,
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
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
    try {
      final klineState = ref.read(klineStateProvider(widget.controller));
      final controller = klineState.controller;
      if (_enabled) {
        final oldIndicator = controller.getIndicator<MACDIndicator>(_macdKey);
        if (oldIndicator != null) {
          final newIndicator = MACDIndicator(
            height: oldIndicator.height,
            padding: oldIndicator.padding,
            calcParam: _currentParam,
            difTips: oldIndicator.difTips,
            deaTips: oldIndicator.deaTips,
            macdTips: oldIndicator.macdTips,
            tipsPadding: oldIndicator.tipsPadding,
            tickCount: oldIndicator.tickCount,
          );
          controller.updateIndicator(newIndicator);
        }
      }
    } catch (e) {
      debugPrint('保存MACD设置失败: $e');
    }
  }

  @override
  Future<void> resetToDefault() async {
    setState(() {
      _currentParam = const MACDParam(s: 12, l: 26, m: 9);
    });
  }
}
