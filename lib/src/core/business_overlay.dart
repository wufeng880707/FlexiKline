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

part of 'core.dart';

/// 业务叠加层交互绑定
///
/// 参照 [DrawBinding] 模式，独立管理 Business Overlay 的交互状态。
/// 职责：
/// 1. 对象管理（增/删/改/查）
/// 2. 状态机管理（Normal / Editing / Dragging）
/// 3. hitTest 路由（根据命中区域分发操作）
/// 4. 拖拽手势分发
/// 5. 独立重绘控制
/// 6. 回调机制
mixin BusinessOverlayBinding on KlineBindingBase, SettingBinding, StateBinding, ChartBinding {
  @override
  void init() {
    super.init();
    logd('init businessOverlay');
  }

  @override
  void dispose() {
    super.dispose();
    logd('dispose businessOverlay');
    _boState.dispose();
    _repaintBusinessOverlay.dispose();
    _boManager.clear();
  }

  // ========== Manager ==========

  final BusinessOverlayManager _boManager = BusinessOverlayManager();

  List<BusinessOverlayObject> get businessOverlayObjects => _boManager.objects;
  bool get hasBusinessOverlay => _boManager.hasObject;

  void addBusinessOverlay(BusinessOverlayObject object) {
    _boManager.add(object);
    _markRepaintBusinessOverlay();
  }

  void addBusinessOverlays(Iterable<BusinessOverlayObject> objects) {
    _boManager.addAll(objects);
    _markRepaintBusinessOverlay();
  }

  /// 原地更新对象，并保持当前编辑/拖拽状态
  void updateBusinessOverlay(BusinessOverlayObject object) {
    _boManager.update(object);
    final state = _boState.value;
    if (state.object?.id == object.id) {
      if (state.isEditing) {
        _boState.value = BOEditing(object);
      } else if (state.isDragging) {
        _boState.value = BODragging(object);
      }
    }
    _markRepaintBusinessOverlay();
  }

  void removeBusinessOverlay(String id) {
    final state = _boState.value;
    if (state.object?.id == id) {
      _boState.value = const BONormal();
    }
    _boManager.remove(id);
    _markRepaintBusinessOverlay();
  }

  void removeBusinessOverlayByType(BusinessOverlayType type) {
    final state = _boState.value;
    if (state.object != null && state.object!.type == type) {
      _boState.value = const BONormal();
    }
    _boManager.removeByType(type);
    _markRepaintBusinessOverlay();
  }

  void clearBusinessOverlays() {
    _boState.value = const BONormal();
    _boManager.clear();
    _markRepaintBusinessOverlay();
  }

  // ========== State ==========

  final ValueNotifier<BusinessOverlayState> _boState =
      ValueNotifier(const BONormal());

  ValueListenable<BusinessOverlayState> get businessOverlayStateListener => _boState;
  BusinessOverlayState get businessOverlayState => _boState.value;

  // ========== Repaint ==========

  final ValueNotifier<int> _repaintBusinessOverlay = ValueNotifier(0);
  Listenable get repaintBusinessOverlay => _repaintBusinessOverlay;

  void _markRepaintBusinessOverlay() {
    _repaintBusinessOverlay.value++;
  }

  // ========== Callback ==========

  /// 业务叠加层操作回调
  BusinessOverlayActionCallback? onBusinessOverlayAction;

  // ========== PaintContext ==========

  BusinessOverlayPaintContext? _buildPaintContext() {
    final main = mainPaintObject;
    if (main.chartRect.isEmpty) return null;
    return BusinessOverlayPaintContext(
      chartRect: main.chartRect,
      precision: curKlineData.precision,
      valueToDy: (value) => main.valueToDy(value, correct: false),
      dyToValue: (dy) => main.dyToValue(dy, check: false),
    );
  }

  // ========== Tap → Select / Deselect / Action ==========

  /// 点击处理（在手势分发链中被 onTapUp 调用）
  ///
  /// 返回 true 表示事件已被消费。
  bool onBusinessOverlayTap(Offset position) {
    if (_boManager.isEmpty) return false;
    final ctx = _buildPaintContext();
    if (ctx == null) return false;

    final state = _boState.value;

    // 处于 Editing 态：先检测当前选中对象的控件
    if (state.isEditing) {
      final editObj = state.object!;
      final hit = editObj.hitTest(position, ctx);
      if (hit != null) {
        switch (hit.area) {
          case BusinessOverlayHitArea.close:
            onBusinessOverlayAction?.call(editObj, BusinessOverlayAction.close, null);
            _boState.value = const BONormal();
            _markRepaintBusinessOverlay();
            return true;
          case BusinessOverlayHitArea.tpSl:
            onBusinessOverlayAction?.call(editObj, BusinessOverlayAction.tpSl, null);
            return true;
          case BusinessOverlayHitArea.menu:
            onBusinessOverlayAction?.call(editObj, BusinessOverlayAction.menu, null);
            return true;
          case BusinessOverlayHitArea.dragHandle:
          case BusinessOverlayHitArea.line:
          case BusinessOverlayHitArea.label:
            // 命中自身非控件区域 → 保持 Editing
            return true;
        }
      }
    }

    // 全局 hitTest
    final hit = _boManager.hitTest(position, ctx);
    if (hit != null) {
      final obj = _boManager.findById(hit.objectId);
      if (obj != null) {
        // 命中控件区域 → 直接分发
        if (hit.area == BusinessOverlayHitArea.close) {
          onBusinessOverlayAction?.call(obj, BusinessOverlayAction.close, null);
          if (state.object?.id == obj.id) {
            _boState.value = const BONormal();
          }
          _markRepaintBusinessOverlay();
          return true;
        }
        // 命中对象 → 进入 Editing
        _boState.value = BOEditing(obj);
        _markRepaintBusinessOverlay();
        return true;
      }
    }

    // 点击空白 → 退出 Editing（消费事件，阻止 cross 触发）
    if (state.isEditing) {
      _boState.value = const BONormal();
      _markRepaintBusinessOverlay();
      return true;
    }

    return false;
  }

  /// 外部主动取消编辑
  void deselectBusinessOverlay() {
    _boState.value = const BONormal();
    _markRepaintBusinessOverlay();
  }

  // ========== Drag ==========

  bool get isDraggingBusinessOverlay => _boState.value.isDragging;

  /// 拖拽开始：仅当处于 Editing 态时生效
  ///
  /// 编辑态下，任意手势起点均视为对当前选中对象的拖拽意图，
  /// 无需精确命中对象（规避触摸偏差导致 hitTest 失败的问题）。
  bool onBusinessDragStart(Offset position) {
    final state = _boState.value;
    if (!state.isEditing) return false;

    final ctx = _buildPaintContext();
    if (ctx == null) return false;

    final obj = state.object!;

    // 先尝试 hitTest 检测命中区域
    final hit = obj.hitTest(position, ctx);

    // close / tpSl / menu 按钮不触发拖拽，交由 tap 处理
    const nonDraggableAreas = {
      BusinessOverlayHitArea.close,
      BusinessOverlayHitArea.tpSl,
      BusinessOverlayHitArea.menu,
    };
    if (hit != null && nonDraggableAreas.contains(hit.area)) return false;

    // 编辑态下，命中或未命中（手指在线附近）均允许拖拽
    obj.onDragStart(position, ctx);
    _boState.value = BODragging(obj);
    _markRepaintBusinessOverlay();
    return true;
  }

  void onBusinessDragUpdate(Offset position, Offset delta) {
    final state = _boState.value;
    if (!state.isDragging) return;
    state.object!.onDragUpdate(position, delta, mainRect);
    _markRepaintBusinessOverlay();
  }

  void onBusinessDragEndAction() {
    final state = _boState.value;
    if (!state.isDragging) return;

    final ctx = _buildPaintContext();
    final obj = state.object!;
    final newValue = ctx != null ? obj.onDragEnd(ctx) : null;

    if (newValue != null) {
      onBusinessOverlayAction?.call(obj, BusinessOverlayAction.editPrice, newValue);
    }

    _boState.value = BOEditing(obj);
    _markRepaintBusinessOverlay();
  }

  void onBusinessDragCancel() {
    final state = _boState.value;
    if (!state.isDragging) return;
    state.object!.onDragCancel();
    _boState.value = BOEditing(state.object!);
    _markRepaintBusinessOverlay();
  }

  // ========== Paint ==========

  void paintBusinessOverlay(Canvas canvas, Size size) {
    if (_boManager.isEmpty) return;

    final ctx = _buildPaintContext();
    if (ctx == null) return;

    canvas.save();
    canvas.clipRect(mainRect);

    final state = _boState.value;
    final editingId = state.object?.id;

    // 先绘制普通态对象，编辑/拖拽对象最后绘制（始终在最上层）
    for (final obj in _boManager.objects) {
      if (obj.id != editingId) {
        obj.paintNormal(canvas, ctx);
      }
    }

    if (editingId != null) {
      final editingObj = _boManager.findById(editingId);
      if (editingObj != null) {
        if (state.isDragging) {
          editingObj.paintDragging(canvas, ctx);
        } else {
          editingObj.paintEditing(canvas, ctx);
        }
      }
    }

    canvas.restore();
  }
}
