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
import '../common/style_selector_row.dart';

class OBVSettingPage extends BaseIndicatorSettingPage {
  const OBVSettingPage({
    super.key,
    required this.controller,
  });

  final FlexiKlineController controller;

  @override
  ConsumerState<OBVSettingPage> createState() => _OBVSettingPageState();
}

class _OBVSettingPageState
    extends BaseIndicatorSettingPageState<OBVSettingPage> {
  static const _obvKey = DataIndicatorKey('obv');

  static const _defaultParam = OBVParam(
    obvLine: OBVLineConfig(
      enabled: true,
      color: Color(0xFFFF9800),
      width: 1.0,
    ),
  );

  late OBVParam _currentParam;
  final List<TextEditingController> _maPeriodControllers = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  @override
  void dispose() {
    for (final c in _maPeriodControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncMAPeriodControllers() {
    final maLines = _currentParam.maLines;
    while (_maPeriodControllers.length < maLines.length) {
      _maPeriodControllers.add(TextEditingController());
    }
    while (_maPeriodControllers.length > maLines.length) {
      _maPeriodControllers.removeLast().dispose();
    }
    for (int i = 0; i < maLines.length; i++) {
      final text = '${maLines[i].period}';
      if (_maPeriodControllers[i].text != text) {
        _maPeriodControllers[i].text = text;
      }
    }
  }

  void _loadCurrentSettings() {
    final klineState = ref.read(klineStateProvider(widget.controller));
    final controller = klineState.controller;
    try {
      final indicator = controller.getIndicator<OBVIndicator>(_obvKey);
      if (indicator != null) {
        _currentParam = indicator.calcParam;
      } else {
        _currentParam = _defaultParam;
      }
    } catch (e) {
      _currentParam = _defaultParam;
    }
    _syncMAPeriodControllers();
  }

  @override
  String get indicatorName => 'OBV';

  @override
  String get indicatorTitle => 'OBV能量潮';

  @override
  List<Widget> buildSettingItems(FKTheme theme) {
    final obvLine = _currentParam.obvLine;
    final maLines = _currentParam.maLines;

    return [
      buildSectionTitle('OBV主线设置', theme),

      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
        child: Row(
          children: [
            Checkbox(
              value: obvLine.enabled,
              onChanged: (val) {
                setState(() {
                  _currentParam = _currentParam.copyWith(
                    obvLine: obvLine.copyWith(enabled: val ?? true),
                  );
                });
              },
            ),
            Text(
              'OBV 主线',
              style: TextStyle(
                color: theme.t1,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            StyleSelectorRow(
              lineWidth: obvLine.width,
              color: obvLine.color,
              onLineWidthChanged: (width) {
                setState(() {
                  _currentParam = _currentParam.copyWith(
                    obvLine: obvLine.copyWith(width: width),
                  );
                });
              },
              onColorChanged: (color) {
                setState(() {
                  _currentParam = _currentParam.copyWith(
                    obvLine: obvLine.copyWith(color: color),
                  );
                });
              },
            ),
          ],
        ),
      ),

      SizedBox(height: 16.r),

      buildSectionTitle('OBV均线设置', theme),

      if (maLines.isNotEmpty) _buildMATableHeader(theme),

      ...maLines.asMap().entries.map((entry) {
        final index = entry.key;
        final maLine = entry.value;
        return _buildMALineRow(index, maLine, theme);
      }),

      SizedBox(height: 8.r),

      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.r),
        child: ElevatedButton.icon(
          onPressed: _addNewMALine,
          icon: const Icon(Icons.add),
          label: const Text('添加OBV均线'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.long.withValues(alpha: 0.1),
            foregroundColor: theme.long,
            elevation: 0,
            side: BorderSide(color: theme.long),
          ),
        ),
      ),

      SizedBox(height: 16.r),

      buildSectionTitle('显示配置', theme),

      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 4.r),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('精度', style: TextStyle(color: theme.t1, fontSize: 14.sp)),
            SizedBox(
              width: 60.r,
              child: DropdownButton<int>(
                value: _currentParam.display.precision,
                isExpanded: true,
                items: [0, 1, 2, 3, 4]
                    .map((p) => DropdownMenuItem(value: p, child: Text('$p')))
                    .toList(),
                onChanged: (val) {
                  if (val == null) return;
                  setState(() {
                    _currentParam = _currentParam.copyWith(
                      display: _currentParam.display.copyWith(precision: val),
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),

      buildSwitchItem(
        title: '在Tips中显示MA值',
        value: _currentParam.display.showMAInTips,
        onChanged: (val) {
          setState(() {
            _currentParam = _currentParam.copyWith(
              display: _currentParam.display.copyWith(showMAInTips: val),
            );
          });
        },
        theme: theme,
      ),
    ];
  }

  Widget _buildMATableHeader(FKTheme theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 4.r),
      child: Row(
        children: [
          SizedBox(width: 40.r, child: Text('启用', style: TextStyle(color: theme.t2, fontSize: 12.sp))),
          Expanded(flex: 2, child: Text('周期', style: TextStyle(color: theme.t2, fontSize: 12.sp))),
          Expanded(flex: 2, child: Text('颜色/线宽', style: TextStyle(color: theme.t2, fontSize: 12.sp))),
          SizedBox(width: 40.r),
        ],
      ),
    );
  }

  Widget _buildMALineRow(int index, OBVMALineConfig maLine, FKTheme theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 4.r),
      child: Row(
        children: [
          SizedBox(
            width: 40.r,
            child: Checkbox(
              value: maLine.enabled,
              onChanged: (val) {
                final newList = List<OBVMALineConfig>.from(_currentParam.maLines);
                newList[index] = maLine.copyWith(enabled: val ?? true);
                setState(() {
                  _currentParam = _currentParam.copyWith(maLines: newList);
                });
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 36.r,
              child: TextField(
                controller: _maPeriodControllers[index],
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 8.r),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.r)),
                  hintText: 'MA周期',
                  hintStyle: TextStyle(color: theme.t3, fontSize: 12.sp),
                ),
                style: TextStyle(color: theme.t1, fontSize: 13.sp),
                onChanged: (val) {
                  final period = int.tryParse(val);
                  if (period != null && period > 0) {
                    final newList = List<OBVMALineConfig>.from(_currentParam.maLines);
                    newList[index] = maLine.copyWith(period: period);
                    _currentParam = _currentParam.copyWith(maLines: newList);
                  }
                },
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: StyleSelectorRow(
              lineWidth: maLine.width,
              color: maLine.color,
              onLineWidthChanged: (width) {
                final newList = List<OBVMALineConfig>.from(_currentParam.maLines);
                newList[index] = maLine.copyWith(width: width);
                setState(() {
                  _currentParam = _currentParam.copyWith(maLines: newList);
                });
              },
              onColorChanged: (color) {
                final newList = List<OBVMALineConfig>.from(_currentParam.maLines);
                newList[index] = maLine.copyWith(color: color);
                setState(() {
                  _currentParam = _currentParam.copyWith(maLines: newList);
                });
              },
            ),
          ),
          SizedBox(
            width: 40.r,
            child: IconButton(
              icon: Icon(Icons.delete_outline, color: theme.t3, size: 20.r),
              onPressed: () => _removeMALine(index),
            ),
          ),
        ],
      ),
    );
  }

  void _addNewMALine() {
    final maLines = _currentParam.maLines;
    if (maLines.length >= _currentParam.maxMALines) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('最多添加${_currentParam.maxMALines}条MA线')),
      );
      return;
    }

    final existingPeriods = maLines.map((l) => l.period).toSet();
    final defaultPeriods = [5, 10, 20, 30, 60];
    int newPeriod = 5;
    for (final p in defaultPeriods) {
      if (!existingPeriods.contains(p)) {
        newPeriod = p;
        break;
      }
    }

    const colors = [
      Color(0xFF2196F3),
      Color(0xFFF44336),
      Color(0xFF4CAF50),
      Color(0xFF9C27B0),
      Color(0xFFFF5722),
    ];
    final colorIndex = maLines.length % colors.length;

    final newLine = OBVMALineConfig(
      id: 'obv_ma${maLines.length}',
      enabled: true,
      period: newPeriod,
      color: colors[colorIndex],
      width: 1.0,
    );

    setState(() {
      _currentParam = _currentParam.copyWith(
        maLines: [...maLines, newLine],
      );
      _syncMAPeriodControllers();
    });
  }

  void _removeMALine(int index) {
    final newList = List<OBVMALineConfig>.from(_currentParam.maLines)
      ..removeAt(index);
    setState(() {
      _currentParam = _currentParam.copyWith(maLines: newList);
      _syncMAPeriodControllers();
    });
  }

  @override
  Future<void> saveSettings() async {
    final klineState = ref.read(klineStateProvider(widget.controller));
    final controller = klineState.controller;
    final indicator = controller.getIndicator<OBVIndicator>(_obvKey);
    if (indicator != null) {
      controller.updateIndicator(
        indicator.copyWith(calcParam: _currentParam),
      );
    }
  }

  @override
  Future<void> resetToDefault() async {
    setState(() {
      _currentParam = _defaultParam;
      _syncMAPeriodControllers();
    });
  }
}
