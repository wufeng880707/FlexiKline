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

  void syncBusinessOverlays(
    Iterable<BusinessOverlayObject> objects, {
    BusinessOverlayType? type,
  }) {
    _boManager.sync(objects, type: type);
    _refreshBusinessOverlayState();
    _markRepaintBusinessOverlay();
  }

  /// 原地更新对象，并保持当前编辑/拖拽状态
  void updateBusinessOverlay(BusinessOverlayObject object) {
    _boManager.update(object);
    _refreshBusinessOverlayState();
    _markRepaintBusinessOverlay();
  }

  void _refreshBusinessOverlayState() {
    final state = _boState.value;
    final objectId = state.object?.id;
    if (objectId == null) return;

    final object = _boManager.findById(objectId);
    if (object == null) {
      _boState.value = const BONormal();
      _businessOverlayDragHit = null;
      return;
    }

    if (state.object != object) {
      if (state.isEditing) {
        _boState.value = BOEditing(object);
      } else if (state.isDragging) {
        _boState.value = BODragging(object);
      }
    }
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

  final ValueNotifier<BusinessOverlayState> _boState = ValueNotifier(const BONormal());

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

  BusinessOverlayHitResult? _businessOverlayDragHit;

  void _emitBusinessOverlayAction(
    BusinessOverlayObject object,
    BusinessOverlayAction action, {
    FlexiNum? newValue,
    BusinessOverlayHitResult? hitResult,
    Object? dragTarget,
  }) {
    onBusinessOverlayAction?.call(
      BusinessOverlayActionEvent(
        object: object,
        action: action,
        newValue: newValue,
        hitResult: hitResult,
        dragTarget: dragTarget,
      ),
    );
  }

  // ========== PaintContext ==========

  BusinessOverlayPaintContext? _buildPaintContext() {
    final main = mainPaintObject;
    if (main.chartRect.isEmpty) return null;
    return BusinessOverlayPaintContext(
      chartRect: main.chartRect,
      precision: klineData.precision,
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
            _emitBusinessOverlayAction(
              editObj,
              BusinessOverlayAction.close,
              hitResult: hit,
            );
            _boState.value = const BONormal();
            _markRepaintBusinessOverlay();
            return true;
          case BusinessOverlayHitArea.tpSl:
            _emitBusinessOverlayAction(
              editObj,
              BusinessOverlayAction.tpSl,
              hitResult: hit,
            );
            return true;
          case BusinessOverlayHitArea.menu:
            _emitBusinessOverlayAction(
              editObj,
              BusinessOverlayAction.menu,
              hitResult: hit,
            );
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
          _emitBusinessOverlayAction(
            obj,
            BusinessOverlayAction.close,
            hitResult: hit,
          );
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

  /// 拖拽开始命中测试：只判断当前编辑对象是否可拖，不改变状态。
  bool hitTestBusinessOverlayDragStart(Offset position) {
    final state = _boState.value;
    if (!state.isEditing) return false;

    final ctx = _buildPaintContext();
    if (ctx == null) return false;

    final obj = state.object!;
    final hit = obj.hitTest(position, ctx);
    return hit != null && obj.canStartDrag(hit);
  }

  /// 拖拽开始：仅当处于 Editing 态且命中当前对象可拖区域时生效。
  bool onBusinessOverlayDragStart(GestureData data) {
    final state = _boState.value;
    if (!state.isEditing) return false;

    final ctx = _buildPaintContext();
    if (ctx == null) return false;

    final obj = state.object!;
    final position = data.offset;

    final hit = obj.hitTest(position, ctx);
    if (hit == null || !obj.canStartDrag(hit)) return false;

    obj.onDragStart(position, ctx);
    _businessOverlayDragHit = hit;
    _boState.value = BODragging(obj);
    _markRepaintBusinessOverlay();
    return true;
  }

  void onBusinessOverlayDragUpdate(GestureData data) {
    final state = _boState.value;
    if (!state.isDragging) return;
    state.object!.onDragUpdate(data.offset, data.delta, mainRect);
    _markRepaintBusinessOverlay();
  }

  void onBusinessOverlayDragEndAction() {
    final state = _boState.value;
    if (!state.isDragging) return;

    final ctx = _buildPaintContext();
    final obj = state.object!;
    final objectId = obj.id;
    final result = ctx != null ? obj.onDragEnd(ctx) : null;

    if (result?.value != null) {
      _emitBusinessOverlayAction(
        obj,
        BusinessOverlayAction.editPrice,
        newValue: result!.value,
        hitResult: _businessOverlayDragHit,
        dragTarget: result.target ?? _businessOverlayDragHit?.extra,
      );
    }

    final latestObject = _boManager.findById(objectId);
    _businessOverlayDragHit = null;
    _boState.value = latestObject != null ? BOEditing(latestObject) : const BONormal();
    _markRepaintBusinessOverlay();
  }

  void onBusinessOverlayDragCancel() {
    final state = _boState.value;
    if (!state.isDragging) return;
    state.object!.onDragCancel();
    _businessOverlayDragHit = null;
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
