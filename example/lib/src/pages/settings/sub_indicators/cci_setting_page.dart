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
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../providers/kline_controller_state_provider.dart';
import '../../../theme/flexi_theme.dart';
import '../common/base_indicator_setting_page.dart';
import '../common/color_selector.dart';
import '../common/line_width_selector.dart';
import '../common/style_selector_row.dart';

class CCISettingPage extends BaseIndicatorSettingPage {
  const CCISettingPage({
    super.key,
    required this.controller,
  });

  final FlexiKlineController controller;

  @override
  ConsumerState<CCISettingPage> createState() => _CCISettingPageState();
}

class _CCISettingPageState
    extends BaseIndicatorSettingPageState<CCISettingPage> {
  static const _cciKey = DataIndicatorKey('cci');

  static const _defaultParam = CCIParam(
    lines: [
      CCILineConfig(
        id: 'cci14',
        enabled: true,
        period: 14,
        color: Color(0xFF00BCD4),
        width: 1.0,
      ),
    ],
  );

  late CCIParam _currentParam;
  late bool _enabled;
  final List<TextEditingController> _periodControllers = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  @override
  void dispose() {
    for (final c in _periodControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncPeriodControllers() {
    final lines = _currentParam.lines;
    while (_periodControllers.length < lines.length) {
      _periodControllers.add(TextEditingController());
    }
    while (_periodControllers.length > lines.length) {
      _periodControllers.removeLast().dispose();
    }
    for (int i = 0; i < lines.length; i++) {
      final text = '${lines[i].period}';
      if (_periodControllers[i].text != text) {
        _periodControllers[i].text = text;
      }
    }
  }

  void _loadCurrentSettings() {
    final klineState = ref.read(klineStateProvider(widget.controller));
    final controller = klineState.controller;
    try {
      _enabled = controller.mainIndicatorKeys.contains(_cciKey) ||
          controller.subIndicatorKeys.contains(_cciKey);
      final indicator = controller.getIndicator<CCIIndicator>(_cciKey);
      if (indicator != null && indicator.calcParam.lines.isNotEmpty) {
        _currentParam = indicator.calcParam;
      } else {
        _currentParam = _defaultParam;
      }
    } catch (e) {
      _currentParam = _defaultParam;
      _enabled = false;
    }
    _syncPeriodControllers();
  }

  @override
  String get indicatorName => 'CCI';

  @override
  String get indicatorTitle => 'CCI顺势指标';

  @override
  List<Widget> buildSettingItems(FKTheme theme) {
    final lines = _currentParam.lines;
    final refCfg = _currentParam.reference;

    return [
      buildSectionTitle('CCI线条设置', theme),

      _buildLineTableHeader(theme),

      ...lines.asMap().entries.map((entry) {
        final index = entry.key;
        final line = entry.value;
        return _buildCCILineRow(index, line, theme);
      }),

      SizedBox(height: 8.r),

      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.r),
        child: ElevatedButton.icon(
          onPressed: _addNewLine,
          icon: const Icon(Icons.add),
          label: const Text('添加新的CCI线'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.long.withValues(alpha: 0.1),
            foregroundColor: theme.long,
            elevation: 0,
            side: BorderSide(color: theme.long),
          ),
        ),
      ),

      SizedBox(height: 16.r),

      buildSectionTitle('参考线设置', theme),
      buildSwitchItem(
        title: '显示超买超卖线',
        subtitle: '显示+100和-100的参考线',
        value: refCfg.enabled,
        onChanged: (value) {
          setState(() {
            _currentParam = _currentParam.copyWith(
              reference: refCfg.copyWith(enabled: value),
            );
          });
        },
        theme: theme,
      ),

      if (refCfg.enabled) ...[
        buildNumberItem(
          title: '超买线位置',
          value: refCfg.overbought,
          onChanged: (value) {
            setState(() {
              _currentParam = _currentParam.copyWith(
                reference: refCfg.copyWith(overbought: value),
              );
            });
          },
          theme: theme,
          min: 50,
          max: 300,
          decimalPlaces: 0,
        ),
        buildNumberItem(
          title: '超卖线位置',
          value: refCfg.oversold,
          onChanged: (value) {
            setState(() {
              _currentParam = _currentParam.copyWith(
                reference: refCfg.copyWith(oversold: value),
              );
            });
          },
          theme: theme,
          min: -300,
          max: -50,
          decimalPlaces: 0,
        ),
        _buildRefLineRow(theme),
      ],

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
            child: Center(child: Text('参数值', style: theme.t2s12w400)),
          ),
          Expanded(
            flex: 2,
            child: Center(child: Text('线宽', style: theme.t2s12w400)),
          ),
          Expanded(
            flex: 2,
            child: Center(child: Text('颜色', style: theme.t2s12w400)),
          ),
          SizedBox(width: 24.r),
        ],
      ),
    );
  }

  Widget _buildCCILineRow(int index, CCILineConfig line, FKTheme theme) {
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
                  onTap: () => _toggleLine(index),
                  child: Icon(
                    line.enabled
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: line.enabled ? theme.long : theme.t2,
                    size: 20.r,
                  ),
                ),
                SizedBox(width: 4.r),
                Flexible(
                  child: Text(
                    'CCI${index + 1}',
                    style: TextStyle(
                      color: line.color,
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
              child: SizedBox(
                width: 56.r,
                height: 32.r,
                child: TextField(
                  controller: _periodControllers[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: theme.t1s14w400,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.r,
                      vertical: 6.r,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.r),
                      borderSide: BorderSide(color: theme.dividerLine),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.r),
                      borderSide: BorderSide(color: theme.dividerLine),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.r),
                      borderSide: BorderSide(color: theme.long),
                    ),
                    filled: true,
                    fillColor: theme.pageBg,
                    isDense: true,
                  ),
                  onChanged: (text) {
                    final val = int.tryParse(text);
                    if (val != null && val > 0) {
                      _updateLineQuietly(
                        index,
                        line.copyWith(period: val),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: LineWidthSelector(
                value: line.width,
                onChanged: (width) {
                  _updateLine(index, line.copyWith(width: width));
                },
                color: line.color,
                width: 72,
                height: 30,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: ColorSelector(
                value: line.color,
                onChanged: (color) {
                  _updateLine(index, line.copyWith(color: color));
                },
                width: 72,
                height: 30,
              ),
            ),
          ),
          SizedBox(
            width: 24.r,
            child: _currentParam.lines.length > 1
                ? GestureDetector(
                    onTap: () => _removeLine(index),
                    child: Icon(
                      Icons.remove_circle_outline,
                      color: theme.short,
                      size: 20.r,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildRefLineRow(FKTheme theme) {
    final refCfg = _currentParam.reference;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: theme.dividerLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '参考线样式',
            style: TextStyle(
              color: theme.t1,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.r),
          Wrap(
            spacing: 8.r,
            runSpacing: 8.r,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StyleSelectorRow(
                showLineStyle: false,
                lineWidth: refCfg.lineWidth,
                onLineWidthChanged: (width) {
                  setState(() {
                    _currentParam = _currentParam.copyWith(
                      reference: refCfg.copyWith(lineWidth: width),
                    );
                  });
                },
                color: refCfg.color,
                onColorChanged: (color) {
                  setState(() {
                    _currentParam = _currentParam.copyWith(
                      reference: refCfg.copyWith(color: color),
                    );
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleLine(int index) {
    final lines = List<CCILineConfig>.from(_currentParam.lines);
    lines[index] = lines[index].copyWith(enabled: !lines[index].enabled);
    setState(() {
      _currentParam = _currentParam.copyWith(lines: lines);
    });
  }

  void _updateLineQuietly(int index, CCILineConfig newLine) {
    final lines = List<CCILineConfig>.from(_currentParam.lines);
    lines[index] = newLine;
    _currentParam = _currentParam.copyWith(lines: lines);
  }

  void _updateLine(int index, CCILineConfig newLine) {
    final lines = List<CCILineConfig>.from(_currentParam.lines);
    lines[index] = newLine;
    setState(() {
      _currentParam = _currentParam.copyWith(lines: lines);
    });
  }

  void _removeLine(int index) {
    final lines = List<CCILineConfig>.from(_currentParam.lines);
    lines.removeAt(index);
    setState(() {
      _currentParam = _currentParam.copyWith(lines: lines);
      _syncPeriodControllers();
    });
  }

  void _addNewLine() {
    final lines = List<CCILineConfig>.from(_currentParam.lines);
    final maxPeriod = lines.isEmpty
        ? 0
        : lines.map((e) => e.period).reduce((a, b) => a > b ? a : b);
    final newPeriod = maxPeriod + 6;

    lines.add(
      CCILineConfig(
        id: 'cci_$newPeriod',
        enabled: true,
        period: newPeriod,
        color: _getNextColor(lines.length),
        width: 1.0,
      ),
    );

    setState(() {
      _currentParam = _currentParam.copyWith(lines: lines);
      _syncPeriodControllers();
    });
  }

  Color _getNextColor(int lineCount) {
    const colors = [
      Color(0xFF00BCD4),
      Color(0xFFFF9800),
      Color(0xFF9C27B0),
      Color(0xFF4CAF50),
      Color(0xFFf44336),
      Color(0xFF2196F3),
      Color(0xFF795548),
      Color(0xFF607D8B),
    ];
    return colors[lineCount % colors.length];
  }

  @override
  Future<void> saveSettings() async {
    try {
      final klineState = ref.read(klineStateProvider(widget.controller));
      final controller = klineState.controller;
      if (_enabled) {
        final oldIndicator = controller.getIndicator<CCIIndicator>(_cciKey);
        if (oldIndicator != null) {
          final newIndicator = CCIIndicator(
            height: oldIndicator.height,
            padding: oldIndicator.padding,
            calcParam: _currentParam,
            tipsPadding: oldIndicator.tipsPadding,
            tickCount: oldIndicator.tickCount,
          );
          controller.updateIndicator(newIndicator);
        }
      }
    } catch (e) {
      debugPrint('保存CCI设置失败: $e');
    }
  }

  @override
  Future<void> resetToDefault() async {
    setState(() {
      _currentParam = _defaultParam;
      _syncPeriodControllers();
    });
  }
}
