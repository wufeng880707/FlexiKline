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

import 'package:flexi_kline/src/constant.dart';
import 'package:flutter/material.dart';

import '../core/export.dart';
import 'object.dart';

/// 指标基础配置
/// tipsHeight: 绘制区域顶部提示信息区域的高度
/// padding: 绘制区域的边界设定
abstract class Indicator {
  Indicator({
    required this.key,
    this.tipsHeight = 0.0,
    this.padding = EdgeInsets.zero,
  });
  final Key key;
  double tipsHeight;
  EdgeInsets padding;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is Indicator) {
      return other.runtimeType == runtimeType && other.key == key;
    }
    return false;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }

  static bool canUpdate(Indicator oldIndicator, Indicator newIndicator) {
    return oldIndicator.runtimeType == newIndicator.runtimeType &&
        oldIndicator.key == newIndicator.key;
  }

  static bool isMultiIndicator(Indicator indicator) {
    return indicator is MultiPaintObjectIndicator;
  }
}

/// 绘制对象的配置
/// 通过Indicator去创建PaintObject接口
/// 缓存Indicator对应创建的paintObject.
abstract class PaintObjectIndicator extends Indicator {
  PaintObjectIndicator({
    required super.key,
    super.tipsHeight,
    super.padding,
  });

  PaintObject? _paintObject;
  PaintObject? get paintObject => _paintObject;
  @protected
  set paintObject(val) {
    _paintObject = val;
  }

  void update(Indicator newVal) {
    tipsHeight = newVal.tipsHeight;
    padding = newVal.padding;
  }

  @protected
  @factory
  PaintObject createPaintObject(
    KlineBindingBase controller,
  );
}

/// 多个绘制Indicator的配置.
/// children 维护具体的Indicator配置.
class MultiPaintObjectIndicator extends PaintObjectIndicator {
  MultiPaintObjectIndicator({
    required super.key,
    super.tipsHeight,
    super.padding,
    this.children = const <PaintObjectIndicator>[],
  });

  final List<PaintObjectIndicator> children;

  @override
  PaintObject createPaintObject(KlineBindingBase controller) {
    for (var indicator in children) {
      // 保证子Indicator的布局参数与父布局一置.
      indicator.update(this);
    }
    paintObject = MultiPaintObject(controller: controller, indicator: this);
    return paintObject!;
  }

  void appendIndicator(PaintObjectIndicator indicator) {
    if (!children.contains(indicator)) {
      children.add(indicator);
    }
  }

  deleteIndicator(ValueKey key) {}
}
