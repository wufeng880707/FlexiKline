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

import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'binding_base.dart';
import 'interface.dart';
import 'setting.dart';

mixin GridBinding on KlineBindingBase, SettingBinding implements IConfig {
  @override
  void initBinding() {
    super.initBinding();
    logd('init grid');
  }

  @override
  void dispose() {
    super.dispose();
    logd('dispose grid');
  }

  void markRepaintGrid() => repaintGridBg.value++;
  ValueNotifier<int> repaintGridBg = ValueNotifier(0);

  void paintGridBg(Canvas canvas, Size size) {
    paintMainGrid(canvas, size);
    paintSubGrid(canvas, size);
  }

  void paintMainGrid(Canvas canvas, Size size) {
    /// 绘制主图Grid gridCount*gridCount 坐标
    final yAxisStep = mainRectWidth / gridCount;
    final xAxisStep = mainDrawBottom / gridCount;
    final paintX = gridXAxisLinePaint;
    final paintY = gridYAxisLinePaint;
    double dx = 0;
    double dy = 0;
    canvas.drawLine(
      Offset(0, dy),
      Offset(mainRectWidth, dy),
      paintX,
    );
    for (int i = 1; i < gridCount; i++) {
      dx = i * yAxisStep;
      dy = i * xAxisStep;
      // 绘制xAsix线
      canvas.drawLine(
        Offset(0, dy),
        Offset(mainRectWidth, dy),
        paintX,
      );
      // 绘制YAsix线
      canvas.drawLine(
        Offset(dx, 0),
        Offset(dx, mainDrawBottom),
        paintY,
      );
    }
    canvas.drawLine(
      Offset(0, mainDrawBottom),
      Offset(mainRectWidth, mainDrawBottom),
      paintX,
    );
  }

  void paintSubGrid(Canvas canvas, Size size) {
    /// 绘制副图Grid X轴线
    final yAxisStep = mainRectWidth / gridCount;
    final paintX = gridXAxisLinePaint;
    final paintY = gridYAxisLinePaint;
    final subTop = subRect.top;

    double dx = 0;
    double dy = 0;

    // 绘制起始线.
    canvas.drawLine(
      Offset(0, subTop),
      Offset(mainRectWidth, subTop),
      paintX,
    );

    final list = subIndicatorHeightList;
    double height = 0.0;
    for (int i = 0; i < list.length; i++) {
      height += list[i];
      dy = subTop + height;
      // 绘制XAsix线
      canvas.drawLine(
        Offset(0, dy),
        Offset(mainRectWidth, dy),
        paintX,
      );
    }

    ///绘制副图Grid Y轴线
    final subBottom = subRect.bottom;
    for (int i = 1; i < gridCount; i++) {
      dx = i * yAxisStep;
      // 绘制YAsix线
      canvas.drawLine(
        Offset(dx, subTop),
        Offset(dx, subBottom),
        paintY,
      );
    }
  }
}
