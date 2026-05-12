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

part of 'business_overlay.dart';

/// 业务叠加层对象管理器
///
/// 管理所有 [BusinessOverlayObject] 的增删改查和碰撞检测。
class BusinessOverlayManager {
  final List<BusinessOverlayObject> _objects = [];

  List<BusinessOverlayObject> get objects => List.unmodifiable(_objects);
  bool get hasObject => _objects.isNotEmpty;
  bool get isEmpty => _objects.isEmpty;

  void add(BusinessOverlayObject object) {
    _objects.add(object);
  }

  void addAll(Iterable<BusinessOverlayObject> objects) {
    _objects.addAll(objects);
  }

  void remove(String id) {
    _objects.removeWhere((o) => o.id == id);
  }

  /// 原地更新对象（保留顺序，找不到时追加）
  void update(BusinessOverlayObject object) {
    final index = _objects.indexWhere((o) => o.id == object.id);
    if (index >= 0) {
      _objects[index] = object;
    } else {
      _objects.add(object);
    }
  }

  void removeByType(BusinessOverlayType type) {
    _objects.removeWhere((o) => o.type == type);
  }

  void clear() {
    _objects.clear();
  }

  BusinessOverlayObject? findById(String id) {
    for (final obj in _objects) {
      if (obj.id == id) return obj;
    }
    return null;
  }

  /// 逆序遍历 hitTest（后添加的优先级更高）
  BusinessOverlayHitResult? hitTest(
    Offset position,
    BusinessOverlayPaintContext ctx,
  ) {
    for (int i = _objects.length - 1; i >= 0; i--) {
      final result = _objects[i].hitTest(position, ctx);
      if (result != null) return result;
    }
    return null;
  }
}
