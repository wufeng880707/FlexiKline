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

import 'package:example/src/providers/kline_controller_state_provider.dart';
import 'package:example/src/theme/flexi_theme.dart';
import 'package:example/src/widgets/flexi_popup_menu_button.dart';
import 'package:flexi_kline/flexi_kline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChartTypeMenuButton extends ConsumerWidget {
  const ChartTypeMenuButton({
    super.key,
    required this.controller,
  });

  final FlexiKlineController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final state = ref.watch(klineStateProvider(controller));
    final current = state.chartType;

    return FlexiPopupMenuButton<FlexiChartType>(
      initialValue: current,
      color: theme.cardBg,
      iconColor: theme.t1,
      offset: Offset(0, 4.r),
      constraints: BoxConstraints(minWidth: 108.r),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.r),
        side: BorderSide(color: theme.dividerLine, width: 0.5.r),
      ),
      onSelected: (type) {
        ref.read(klineStateProvider(controller).notifier).setChartType(type);
      },
      itemBuilder: (context) {
        return FlexiChartType.supportedTypes
            .map(
              (type) => PopupMenuItem<FlexiChartType>(
                value: type,
                height: 30.r,
                padding: EdgeInsets.symmetric(horizontal: 8.r),
                child: _ChartTypeMenuItem(
                  type: type,
                  selected: type == current,
                ),
              ),
            )
            .toList(growable: false);
      },
      child: Icon(
        _chartTypeIcon(current),
        size: 20.r,
        color: theme.t1,
      ),
    );
  }
}

class _ChartTypeMenuItem extends ConsumerWidget {
  const _ChartTypeMenuItem({
    required this.type,
    required this.selected,
  });

  final FlexiChartType type;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final color = selected ? theme.long : theme.t1;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _chartTypeIcon(type),
          color: color,
          size: 18.r,
        ),
        SizedBox(width: 8.r),
        Text(
          _chartTypeLabel(type),
          style: theme.t1s14w500.copyWith(color: color),
        ),
      ],
    );
  }
}

String _chartTypeLabel(FlexiChartType type) {
  return switch (type) {
    FlexiBarChartType(style: ChartBarStyle.allSolid) => '全实心',
    FlexiBarChartType(style: ChartBarStyle.allHollow) => '全空心',
    FlexiBarChartType(style: ChartBarStyle.upHollow) => '上涨空心',
    FlexiBarChartType(style: ChartBarStyle.downHollow) => '下跌空心',
    FlexiBarChartType(style: ChartBarStyle.ohlc) => '美国线',
    FlexiLineChartType(style: ChartLineStyle.normal) => '线图',
    FlexiLineChartType(style: ChartLineStyle.updown) => '涨跌图',
  };
}

IconData _chartTypeIcon(FlexiChartType type) {
  return switch (type) {
    FlexiBarChartType(style: ChartBarStyle.allSolid) => Icons.candlestick_chart,
    FlexiBarChartType(style: ChartBarStyle.allHollow) =>
      Icons.candlestick_chart_outlined,
    FlexiBarChartType(style: ChartBarStyle.upHollow) =>
      Icons.candlestick_chart_outlined,
    FlexiBarChartType(style: ChartBarStyle.downHollow) =>
      Icons.candlestick_chart,
    FlexiBarChartType(style: ChartBarStyle.ohlc) => Icons.bar_chart_rounded,
    FlexiLineChartType(style: ChartLineStyle.normal) => Icons.show_chart,
    FlexiLineChartType(style: ChartLineStyle.updown) =>
      Icons.stacked_line_chart,
  };
}
