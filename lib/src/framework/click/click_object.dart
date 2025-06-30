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

import 'package:flutter/material.dart';

/// 点击区域信息
class ClickArea {
  const ClickArea({
    required this.rect,
    this.data,
    this.onTap,
  });

  final Rect rect;
  final Map<String, dynamic>? data;
  final VoidCallback? onTap;

  bool contains(Offset position) => rect.contains(position);
}

/// 可点击功能的 mixin
/// 提供点击区域管理和点击事件处理的基础功能
mixin ClickableMixin {
  final List<ClickArea> _clickAreas = [];

  /// 获取所有点击区域
  List<ClickArea> get clickAreas => List.unmodifiable(_clickAreas);

  /// 添加点击区域
  void addClickArea(ClickArea area) {
    _clickAreas.add(area);
  }

  /// 清空点击区域
  void clearClickAreas() {
    _clickAreas.clear();
  }

  /// 处理点击事件
  /// 子类可以重写此方法提供自定义的点击处理逻辑
  bool handleClick(Offset position) {
    for (final area in _clickAreas) {
      if (area.contains(position)) {
        // 执行点击回调
        area.onTap?.call();
        return true;
      }
    }
    return false;
  }
}
