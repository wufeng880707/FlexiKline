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

import 'package:flexi_kline/flexi_kline.dart' hide KlineStateNotifier;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../providers/kline_controller_state_provider.dart';
import '../theme/flexi_theme.dart';
import '../utils/dialog_manager.dart';
import '../widgets/right_arrow.dart';

class KlineSettingPage extends ConsumerStatefulWidget {
  const KlineSettingPage({
    super.key,
    required this.controller,
  });

  final FlexiKlineController controller;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _KlineSettingPageState();
}

class _KlineSettingPageState extends ConsumerState<KlineSettingPage> {
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final klineState = ref.watch(klineStateProvider(widget.controller));
    return Scaffold(
      backgroundColor: theme.pageBg,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(
          'FlexiKline 设置',
          style: theme.t1s18w600,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========== 图表展示 ==========
              ExpansionTile(
                title: Text('图表展示', style: theme.t1s18w500),
                initiallyExpanded: true,
                children: [
                  _buildChartBarStyleTile(theme, klineState),
                  _buildChartTypeTile(theme, klineState),
                  _buildMinWidthLineTypeTile(theme, klineState),
                  _buildSecondaryChartTypeTile(theme, klineState),
                  _buildColorTile(
                    theme,
                    title: '看涨',
                    color: klineState.longColor,
                  ),
                  _buildColorTile(
                    theme,
                    title: '看跌',
                    color: klineState.shortColor,
                  ),
                ],
              ),
              Container(height: 0.5.r, color: theme.dividerLine),

              // ========== 图表交互 ==========
              ExpansionTile(
                title: Text('图表交互', style: theme.t1s18w500),
                initiallyExpanded: true,
                children: [
                  ListTile(
                    onTap: () => _showScalePositionDialog(klineState),
                    title: Text('缩放位置', style: theme.t1s16w400),
                    trailing: RightArrow(
                      value: _scalePositionLabel(klineState.scalePosition),
                    ),
                  ),
                  SwitchListTile(
                    value: klineState.supportLongPress,
                    onChanged: (value) {
                      klineState.setSupportLongPress(value);
                    },
                    title: Text('是否支持长按', style: theme.t1s16w400),
                    subtitle: Text(
                      '例如: 长按可展示Tooltips',
                      style: theme.t2s12w400,
                    ),
                  ),
                  ListTile(
                    onTap: () => showInertialPanParamSettingDialog(),
                    title: Text('惯性平移', style: theme.t1s16w400),
                    trailing: RightArrow(
                      value: klineState.toleranceDesc,
                    ),
                  ),
                ],
              ),
              Container(height: 0.5.r, color: theme.dividerLine),
              SizedBox(height: 20.r),
            ],
          ),
        ),
      ),
    );
  }

  // ========== K线图样式（全实心/全空心/上涨空心/下跌空心/美国线）==========

  Widget _buildChartBarStyleTile(FKTheme theme, KlineStateNotifier state) {
    return ListTile(
      onTap: () => _showChartBarStyleDialog(state),
      title: Text('K线图样式', style: theme.t1s16w400),
      trailing: RightArrow(value: _barStyleLabel(state.chartBarStyle)),
    );
  }

  void _showChartBarStyleDialog(KlineStateNotifier state) {
    _showSelectionSheet<ChartBarStyle>(
      title: 'K线图样式',
      items: ChartBarStyle.values,
      current: state.chartBarStyle,
      labelBuilder: _barStyleLabel,
      iconBuilder: _barStyleIcon,
      onSelected: state.setChartBarStyle,
    );
  }

  String _barStyleLabel(ChartBarStyle style) {
    return switch (style) {
      ChartBarStyle.allSolid => '全实心',
      ChartBarStyle.allHollow => '全空心',
      ChartBarStyle.upHollow => '上涨空心',
      ChartBarStyle.downHollow => '下跌空心',
      ChartBarStyle.ohlc => '美国线',
    };
  }

  IconData _barStyleIcon(ChartBarStyle style) {
    return switch (style) {
      ChartBarStyle.allSolid => Icons.candlestick_chart,
      ChartBarStyle.allHollow => Icons.candlestick_chart_outlined,
      ChartBarStyle.upHollow => Icons.candlestick_chart,
      ChartBarStyle.downHollow => Icons.candlestick_chart_outlined,
      ChartBarStyle.ohlc => Icons.bar_chart,
    };
  }

  // ========== K线图类型（柱状图/线图/涨跌图）==========

  Widget _buildChartTypeTile(FKTheme theme, KlineStateNotifier state) {
    return ListTile(
      onTap: () => _showChartTypeDialog(state),
      title: Text('K线图类型', style: theme.t1s16w400),
      trailing: RightArrow(value: _chartTypeLabel(state.chartType)),
    );
  }

  void _showChartTypeDialog(KlineStateNotifier state) {
    final types = <FlexiChartType>[
      FlexiChartType.barSolid,
      FlexiChartType.lineNormal,
      FlexiChartType.lineUpdown,
    ];
    _showSelectionSheet<FlexiChartType>(
      title: 'K线图类型',
      items: types,
      current: state.chartType,
      labelBuilder: _chartTypeLabel,
      iconBuilder: _chartTypeIcon,
      onSelected: state.setChartType,
    );
  }

  String _chartTypeLabel(FlexiChartType type) {
    if (type is FlexiBarChartType) return '柱状图';
    if (type is FlexiLineChartType) {
      return type.style == ChartLineStyle.updown ? '涨跌图' : '线图';
    }
    return '未知';
  }

  IconData _chartTypeIcon(FlexiChartType type) {
    if (type is FlexiBarChartType) return Icons.candlestick_chart;
    if (type is FlexiLineChartType) {
      return type.style == ChartLineStyle.updown
          ? Icons.trending_up
          : Icons.show_chart;
    }
    return Icons.help_outline;
  }

  // ========== 缩放至最小图表类型 ==========

  Widget _buildMinWidthLineTypeTile(
    FKTheme theme,
    KlineStateNotifier state,
  ) {
    final current = state.minWidthLineType;
    final label = current == null
        ? '跟随主图'
        : (current.style == ChartLineStyle.updown ? '涨跌图' : '线图');
    return ListTile(
      onTap: () => _showMinWidthLineTypeDialog(state),
      title: Text('缩放至最小图表类型', style: theme.t1s16w400),
      trailing: RightArrow(value: label),
    );
  }

  void _showMinWidthLineTypeDialog(KlineStateNotifier state) {
    final items = <FlexiLineChartType?>[
      null,
      FlexiLineChartType.normal,
      FlexiLineChartType.updown,
    ];
    final labels = <FlexiLineChartType?, String>{
      null: '跟随主图',
      FlexiLineChartType.normal: '线图',
      FlexiLineChartType.updown: '涨跌图',
    };
    _showSelectionSheet<FlexiLineChartType?>(
      title: '缩放至最小图表类型',
      items: items,
      current: state.minWidthLineType,
      labelBuilder: (t) => labels[t] ?? '未知',
      iconBuilder: (t) {
        if (t == null) return Icons.auto_awesome;
        return t.style == ChartLineStyle.updown
            ? Icons.trending_up
            : Icons.show_chart;
      },
      onSelected: state.setMinWidthLineType,
    );
  }

  // ========== 秒级K线图类型 ==========

  Widget _buildSecondaryChartTypeTile(
    FKTheme theme,
    KlineStateNotifier state,
  ) {
    final current = state.minWidthLineType;
    final label = current == null
        ? '线图'
        : (current.style == ChartLineStyle.updown ? '涨跌图' : '线图');
    return ListTile(
      onTap: () {},
      title: Text('秒级K线图类型', style: theme.t1s16w400),
      trailing: RightArrow(value: label),
    );
  }

  // ========== 看涨/看跌颜色 ==========

  Widget _buildColorTile(
    FKTheme theme, {
    required String title,
    required Color color,
  }) {
    return ListTile(
      title: Text(title, style: theme.t1s16w400),
      trailing: Container(
        width: 28.r,
        height: 28.r,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4.r),
        ),
      ),
    );
  }

  // ========== 缩放位置 ==========

  String _scalePositionLabel(ScalePosition pos) {
    return switch (pos) {
      ScalePosition.auto => '自动',
      ScalePosition.left => '左侧',
      ScalePosition.right => '右侧',
      ScalePosition.middle => '中间',
    };
  }

  void _showScalePositionDialog(KlineStateNotifier state) {
    _showSelectionSheet<ScalePosition>(
      title: '缩放位置',
      items: ScalePosition.values,
      current: state.scalePosition,
      labelBuilder: _scalePositionLabel,
      onSelected: state.setScalePosition,
    );
  }

  // ========== 通用选择弹窗 ==========

  void _showSelectionSheet<T>({
    required String title,
    required List<T> items,
    required T current,
    required String Function(T) labelBuilder,
    IconData Function(T)? iconBuilder,
    required void Function(T) onSelected,
  }) {
    DialogManager().showBottomDialog(
      dialogTag: 'select_$title',
      builder: (context) {
        final theme = ref.watch(themeProvider);
        return Container(
          width: ScreenUtil().screenWidth,
          margin: EdgeInsetsDirectional.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: 16.r,
                  vertical: 12.r,
                ),
                child: Text(title, style: theme.t1s20w700),
              ),
              ...items.map((item) {
                final isSelected = item == current;
                return ListTile(
                  leading: iconBuilder != null
                      ? Icon(iconBuilder(item), size: 24.r)
                      : null,
                  title: Text(
                    labelBuilder(item),
                    style: isSelected
                        ? theme.t1s14w400.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : theme.t1s14w400,
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check,
                          size: 24.r,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    onSelected(item);
                    SmartDialog.dismiss(tag: 'select_$title');
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // ========== 惯性平移设置 ==========

  void showInertialPanParamSettingDialog() {
    DialogManager().showBottomDialog(
      builder: (context) {
        final theme = ref.watch(themeProvider);
        final klineState = ref.watch(klineStateProvider(widget.controller));
        return Container(
          width: ScreenUtil().screenWidth,
          margin: EdgeInsetsDirectional.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: 16.r,
                  vertical: 12.r,
                ),
                child: Text('惯性平移设置', style: theme.t1s20w700),
              ),
              SwitchListTile(
                value: klineState.isInertialPan,
                onChanged: (value) {
                  klineState.setInertialPan(value);
                },
                title: Text('是否启用惯性平移', style: theme.t1s16w400),
              ),
              ListTile(
                onTap: () => showInertialPanParamSettingDialog(),
                title: Text('最大持续时间', style: theme.t1s16w400),
                trailing: RightArrow(
                  value: '${klineState.tolerance.maxDuration}ms',
                ),
              ),
              ListTile(
                onTap: () => showInertialPanParamSettingDialog(),
                title: Text('平移因子', style: theme.t1s16w400),
                subtitle: Text(
                  '范围:[0~1]; 值越大, 惯性平移距离越长',
                  style: theme.t2s12w400,
                ),
                trailing: RightArrow(
                  value: '${klineState.tolerance.distanceFactor}',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
