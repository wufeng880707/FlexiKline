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

/// 业务叠加层对象类型
enum BusinessOverlayType {
  pendingOrder,
  position,
}

/// 命中区域类型
enum BusinessOverlayHitArea {
  line,
  label,
  dragHandle,
  close,
  tpSl,
  menu,
}

/// 命中测试结果
class BusinessOverlayHitResult {
  const BusinessOverlayHitResult({
    required this.objectId,
    required this.area,
    this.extra,
  });

  final String objectId;
  final BusinessOverlayHitArea area;

  /// 附加数据（如 TP/SL 命中时标识哪条线）
  final Object? extra;
}

/// 业务叠加层操作类型
enum BusinessOverlayAction {
  editPrice,
  close,
  delete,
  tpSl,
  menu,
}

/// 业务叠加层操作回调
typedef BusinessOverlayActionCallback = void Function(
  BusinessOverlayObject object,
  BusinessOverlayAction action,
  FlexiNum? newValue,
);

/// 业务叠加层对象基类
///
/// 参照 [DrawObject] 模式，但数据来自外部 API 而非用户绘制。
/// 每个对象对应图表上一条价格横线（如委托订单线、持仓开仓线）。
abstract class BusinessOverlayObject {
  /// 唯一标识
  String get id;

  /// 对象类型
  BusinessOverlayType get type;

  // ---- 渲染 ----

  /// 绘制正常态（非选中/非拖拽）
  void paintNormal(Canvas canvas, BusinessOverlayPaintContext ctx);

  /// 绘制选中/编辑态（显示拖拽手柄、操作按钮等）
  void paintEditing(Canvas canvas, BusinessOverlayPaintContext ctx);

  /// 绘制拖拽中态
  void paintDragging(Canvas canvas, BusinessOverlayPaintContext ctx);

  // ---- HitTest ----

  /// 命中测试
  ///
  /// 返回命中结果，null 表示未命中。
  /// [ctx] 提供坐标转换能力。
  BusinessOverlayHitResult? hitTest(
    Offset position,
    BusinessOverlayPaintContext ctx,
  );

  // ---- Drag ----

  void onDragStart(Offset position, BusinessOverlayPaintContext ctx);
  void onDragUpdate(Offset position, Offset delta, Rect chartRect);
  FlexiNum? onDragEnd(BusinessOverlayPaintContext ctx);
  void onDragCancel();
}
