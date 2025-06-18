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

import 'package:example/core/extensions/ex_context.dart';
import 'package:example/features/theme/export.dart';
import 'package:flexi_kline/flexi_kline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TimerBarSelectDialog extends ConsumerWidget {
  static const String dialogTag = "TimerBarSelectDialog";
  const TimerBarSelectDialog({
    super.key,
    required this.controller,
    required this.onTapTimeBar,
    required this.preferTimeBarList,
    required this.supportTimBarList,
  });

  final FlexiKlineController controller;
  final ValueChanged<TimeBar> onTapTimeBar;
  final List<TimeBar> preferTimeBarList;
  final List<TimeBar> supportTimBarList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = context.trans;
    final theme = ref.watch(themeFKProvider);
    final screenWidth = ScreenUtil().screenWidth;
    final timeBarWidth = (screenWidth - 2 * 16.r - 4 * 12.r) / 5;
    return Container(
      width: screenWidth,
      margin: EdgeInsetsDirectional.all(16.r),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.r),
            Text(s.preferredIntervals, style: theme.t1s20w700),
            SizedBox(height: 10.r),
            _buildPreferTimeBarList(context, ref, barWidth: timeBarWidth),
            SizedBox(height: 20.r),
            Text(s.intervals, style: theme.t1s20w700),
            SizedBox(height: 10.r),
            _buildAllTimeBarList(context, ref, barWidth: timeBarWidth),
            SizedBox(height: 10.r),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferTimeBarList(BuildContext context, WidgetRef ref, {required double barWidth}) {
    return ValueListenableBuilder(
      valueListenable: controller.timeBarListener,
      builder: (context, value, child) {
        final theme = ref.read(themeFKProvider);
        return Wrap(
          alignment: WrapAlignment.start,
          spacing: 12.r,
          runSpacing: 8.r,
          children:
              (supportTimBarList.isEmpty ? TimeBar.values : supportTimBarList).map((bar) {
                final selected = value == bar;
                return SizedBox(
                  width: barWidth,
                  child: TextButton(
                    key: ValueKey(bar),
                    style: theme.outlinedBtnStyle(showOutlined: selected),
                    onPressed: () => onTapTimeBar(bar),
                    child: FittedBox(
                      child: Text(
                        bar.bar,
                        style: theme.t2s12w400.copyWith(
                          color: theme.t1,
                          fontWeight: selected ? FontWeight.bold : null,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        );
      },
    );
  }

  Widget _buildAllTimeBarList(BuildContext context, WidgetRef ref, {required double barWidth}) {
    return ValueListenableBuilder(
      valueListenable: controller.timeBarListener,
      builder: (context, value, child) {
        final theme = ref.read(themeFKProvider);
        return Wrap(
          alignment: WrapAlignment.start,
          spacing: 12.r,
          runSpacing: 8.r,
          children:
              TimeBar.values.map((bar) {
                final selected = value == bar;
                return SizedBox(
                  width: barWidth,
                  child: TextButton(
                    key: ValueKey(bar),
                    style: theme.outlinedBtnStyle(showOutlined: selected),
                    onPressed: () => onTapTimeBar(bar),
                    child: FittedBox(
                      child: Text(
                        bar.bar,
                        style: theme.t2s12w400.copyWith(
                          color: theme.t1,
                          fontWeight: selected ? FontWeight.bold : null,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        );
      },
    );
  }
}
