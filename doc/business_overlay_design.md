# FlexiKline 业务叠加层架构设计

## 1. 背景

FlexiKline 需要支持多种业务驱动的可视化叠加层，叠加在 K 线主图上：

| 叠加层类型 | 数据来源 | 交互需求 | 示例 |
|-----------|---------|---------|------|
| 历史成交标记 | 历史订单 API | 纯展示 | 买/卖圆形标记 |
| 委托订单 | 实时订单 API | 拖拽改价 → 回调修改订单 | 水平价格线 + 标签 |
| 持仓止盈止损 | 持仓 API | 拖拽设价 → 回调设置 TP/SL | 水平价格线 + 区间色块 |
| 信号箭头（未来） | 策略引擎 | 纯展示 | 上/下箭头 |

这些叠加层的共同特点：
- 数据来自**外部业务系统**，不是 K 线技术计算
- 叠加在主图上，跟随 K 线缩放/平移
- 不影响 Y 轴价格范围
- 部分需要**拖拽交互**，且交互结果需要回调给业务层

## 2. 现有架构分析

### 2.1 指标体系（Indicator）

```
Indicator (配置)
├── NormalIndicator    → NormalPaintObject    (蜡烛、时间轴等基础指标)
├── DataIndicator      → DataPaintObject      (MA、RSI、MACD 等技术指标，precompute 写入 slot)
└── BusinessIndicator  → BusinessPaintObject  (业务驱动指标，不占 slot)
```

- `DataIndicator` / `DataPaintObject`：数据通过 `precompute()` 从 K 线数据计算得出
- `BusinessIndicator` / `BusinessPaintObject`：数据由外部业务逻辑提供
- **PaintObject 没有手势入口**，只有 `paintChart` / `paintTips` / `onCross`

### 2.2 绘图工具层（Draw）

```
DrawBinding (手势处理)
└── OverlayDrawObjectManager
    └── DrawObject (绘制 + 交互)
        ├── hitTest()
        ├── onUpdateDrawPoint()
        ├── drawing() / draw()
        └── Overlay (持久化模型)
```

- 完整的手势框架：hitTest → 拖拽 → 磁吸 → 确认
- 为**用户手绘图形**设计，有创建流程（startDraw → 放置点 → 确认）
- Overlay 数据持久化到本地存储

### 2.3 手势分发优先级

```
用户手势
  → Draw 层（Drawing/Editing 状态）
  → Draw 层 hitTest（Prepared/Exited 状态，检查已有 Overlay）
  → Chart 层（平移/缩放/Cross）
```

## 3. 方案设计

### 3.1 基础设施：业务数据注入机制

**已实现**。在 `IPaintContext` 和 `KlineBindingBase` 中增加通用的业务数据注入：

```dart
// IPaintContext 接口
T? getBusinessData<T>(IIndicatorKey key);

// KlineBindingBase 实现
void setBusinessData<T extends Object>(IIndicatorKey key, T data);
void removeBusinessData(IIndicatorKey key);
```

- `lib/` 层框架无关，不依赖任何状态管理库
- `example/` 层（或业务层）使用 Riverpod 等管理数据，通过 `setBusinessData` 注入
- `BusinessPaintObject` 在 `paintChart` 中通过 `getBusinessData` 获取数据

数据流：

```
业务层 (Riverpod Provider)
  │
  │  原始数据 → 按 timeBar 分组
  │
  ▼
controller.setBusinessData(key, groupedData)
  │
  │  Map 引用替换，identical 检查避免无意义重绘
  │
  ▼
BusinessPaintObject.paintChart()
  │
  │  context.getBusinessData<T>(key) → O(1) 查找
  │
  ▼
Canvas 绘制（只遍历可见范围）
```

### 3.2 展示型叠加层：BusinessIndicator

适用于：历史成交标记、信号箭头等**纯展示**场景。

```dart
// 定义 Indicator（只管样式配置）
class TradeMarkIndicator extends BusinessIndicator {
  final TradeMarkParam calcParam;  // 样式参数
  // 不持有业务数据
}

// 定义 PaintObject（纯绘制）
class TradeMarkPaintObject extends BusinessPaintObject<TradeMarkIndicator> {
  @override
  void paintChart(Canvas canvas, Size size) {
    final data = _context.getBusinessData<Map<int, CandleTradeMarks>>(key);
    // 绘制逻辑...
  }
}
```

### 3.3 交互型叠加层：IInteractiveBusinessPainter

适用于：委托订单拖拽改价、止盈止损拖拽设价等**需要拖拽交互**的场景。

#### 3.3.1 接口定义

在 `BusinessPaintObject` 基础上，定义可选的交互接口：

```dart
/// 可交互的业务指标绘制接口
///
/// BusinessPaintObject 按需实现此接口即可获得拖拽交互能力。
/// 未实现此接口的 BusinessPaintObject 保持纯展示行为。
abstract interface class IInteractiveBusinessPainter {
  /// 命中测试
  ///
  /// 返回命中元素的标识（如 orderId、positionId），null 表示未命中。
  /// 框架不关心返回值的具体类型，只透传给后续的 drag 回调。
  Object? hitTest(Offset position);

  /// 拖拽开始
  void onDragStart(Object hitTarget, Offset position);

  /// 拖拽更新
  ///
  /// [hitTarget] 命中的元素标识
  /// [position] 当前指针位置
  /// [delta] 相对上一次的偏移量
  void onDragUpdate(Object hitTarget, Offset position, Offset delta);

  /// 拖拽结束
  ///
  /// 实现者应在此方法中通过回调通知业务层最终的价格/值。
  void onDragEnd(Object hitTarget);

  /// 拖拽取消（如手势被其他层拦截）
  void onDragCancel(Object hitTarget);
}
```

#### 3.3.2 手势分发扩展

在现有手势分发链中插入 Business 层的优先级：

```
用户手势
  → Draw 层（Drawing/Editing 状态）
  → Draw 层 hitTest（检查已有手绘 Overlay）
  → Business 层 hitTest（检查可交互的业务叠加层）  ← 新增
  → Chart 层（平移/缩放/Cross）
```

实现方式：在 `ChartBinding` 或新增 `BusinessInteractionBinding` 中：

```dart
/// 遍历所有 mainPaintObject 的 children，
/// 找到实现了 IInteractiveBusinessPainter 的 PaintObject 进行 hitTest
Object? _hitTestBusinessOverlay(Offset position) {
  for (final paintObject in mainPaintObject.paintableChildren) {
    if (paintObject is IInteractiveBusinessPainter) {
      final target = (paintObject as IInteractiveBusinessPainter).hitTest(position);
      if (target != null) return target;
    }
  }
  return null;
}
```

在 `touch_gesture_detector.dart` / `non_touch_gesture_detector.dart` 中，
在 Draw 层 hitTest 失败后、Chart 层处理前，增加 Business 层的检查。

#### 3.3.3 业务回调机制

外部通过 controller 注册回调，接收拖拽结果：

```dart
/// 业务叠加层拖拽结束回调
///
/// [key] 指标Key，用于区分是委托订单还是止盈止损
/// [hitTarget] 命中元素标识（orderId / positionId）
/// [newValue] 拖拽后的新价格值 (FlexiNum)
typedef BusinessDragEndCallback = void Function(
  IIndicatorKey key,
  Object hitTarget,
  FlexiNum newValue,
);

// 在 controller 上注册
controller.onBusinessDragEnd = (key, hitTarget, newValue) {
  if (key == pendingOrderIndicatorKey) {
    ref.read(orderApiProvider).modifyOrderPrice(
      orderId: hitTarget as String,
      newPrice: newValue.toDouble(),
    );
  }
};
```

#### 3.3.4 委托订单示例

```dart
// lib/ 层
const pendingOrderIndicatorKey = BusinessIndicatorKey('pendingOrder');

class PendingOrderIndicator extends BusinessIndicator {
  PendingOrderIndicator({
    this.calcParam = const PendingOrderParam(),
  }) : super(key: pendingOrderIndicatorKey, height: 0, padding: EdgeInsets.zero);

  final PendingOrderParam calcParam;

  @override
  BusinessPaintObject createPaintObject() => PendingOrderPaintObject();
}

class PendingOrderPaintObject extends BusinessPaintObject<PendingOrderIndicator>
    implements IInteractiveBusinessPainter {

  // 当前正在拖拽的订单信息
  String? _draggingOrderId;
  double? _draggingDy;

  @override
  void paintChart(Canvas canvas, Size size) {
    final orders = _context.getBusinessData<List<PendingOrderData>>(
      pendingOrderIndicatorKey,
    );
    if (orders == null) return;

    for (final order in orders) {
      final dy = valueToDy(order.price);
      // 如果正在拖拽此订单，使用拖拽中的 dy
      final actualDy = (_draggingOrderId == order.id) ? _draggingDy ?? dy : dy;
      _drawPriceLine(canvas, actualDy, order);
    }
  }

  @override
  Object? hitTest(Offset position) {
    final orders = _context.getBusinessData<List<PendingOrderData>>(...);
    if (orders == null) return null;
    for (final order in orders) {
      final dy = valueToDy(order.price);
      if ((position.dy - dy).abs() < hitDistance) {
        return order.id; // 返回 orderId 作为命中标识
      }
    }
    return null;
  }

  @override
  void onDragStart(Object hitTarget, Offset position) {
    _draggingOrderId = hitTarget as String;
    _draggingDy = position.dy;
  }

  @override
  void onDragUpdate(Object hitTarget, Offset position, Offset delta) {
    _draggingDy = position.dy;
    _context.requestRepaint(); // 触发重绘显示拖拽中的位置
  }

  @override
  void onDragEnd(Object hitTarget) {
    if (_draggingDy != null) {
      final newPrice = dyToValue(_draggingDy!);
      // 通过 controller 的回调通知业务层
      // controller.onBusinessDragEnd?.call(key, hitTarget, newPrice);
    }
    _draggingOrderId = null;
    _draggingDy = null;
  }

  @override
  void onDragCancel(Object hitTarget) {
    _draggingOrderId = null;
    _draggingDy = null;
  }
}
```

```dart
// example/ 层 (Riverpod)
ref.listen(pendingOrdersProvider(instId), (prev, next) {
  controller.setBusinessData(pendingOrderIndicatorKey, next);
});

controller.onBusinessDragEnd = (key, target, newPrice) {
  if (key == pendingOrderIndicatorKey) {
    ref.read(orderApiProvider).modifyPrice(
      orderId: target as String,
      price: newPrice.toDouble(),
    );
  }
};
```

## 4. 架构全景

```
┌─────────────────────────────────────────────────────────┐
│                    FlexiKlineWidget                       │
│                                                           │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ Stack                                                │  │
│  │  ├── Grid Layer       (repaintGrid)                  │  │
│  │  ├── Chart Layer      (repaintChart)                 │  │
│  │  │    ├── CandlePaintObject                          │  │
│  │  │    ├── MaPaintObject                              │  │
│  │  │    ├── TradeMarkPaintObject  [BusinessPaintObject] │  │
│  │  │    ├── PendingOrderPaintObject [+Interactive]      │  │
│  │  │    └── TpSlPaintObject         [+Interactive]      │  │
│  │  ├── Cross Layer      (repaintCross)                 │  │
│  │  └── Draw Layer       (repaintDraw)                  │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                           │
│  手势优先级:                                                │
│  Draw → Interactive Business → Chart (pan/zoom/cross)     │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                    业务层 (example/)                       │
│                                                           │
│  Riverpod Providers:                                      │
│  ├── tradeMarkGroupedProvider  → setBusinessData(...)     │
│  ├── pendingOrdersProvider     → setBusinessData(...)     │
│  └── tpSlProvider              → setBusinessData(...)     │
│                                                           │
│  回调:                                                     │
│  └── controller.onBusinessDragEnd → API 调用               │
└─────────────────────────────────────────────────────────┘
```

## 5. 实施路线

### Phase 1：基础设施 + 历史成交标记（当前）

- [x] `IPaintContext.getBusinessData<T>()` 接口
- [x] `KlineBindingBase.setBusinessData()` / `removeBusinessData()`
- [ ] `TradeMarkIndicator` 重构（移除数据，纯配置）
- [ ] `TradeMarkPaintObject` 重构（从 context 取数据）
- [ ] `example/` 层 Riverpod Provider + 测试数据

### Phase 2：交互接口（未来）

- [ ] 定义 `IInteractiveBusinessPainter` 接口
- [ ] 手势分发扩展（touch + non-touch gesture detector）
- [ ] `BusinessDragEndCallback` 回调机制
- [ ] 拖拽过程中的视觉反馈（虚线 + 价格标签）

### Phase 3：委托订单

- [ ] `PendingOrderIndicator` + `PendingOrderPaintObject`
- [ ] 实现 `IInteractiveBusinessPainter`（拖拽改价）
- [ ] 水平价格线 + 订单信息标签绘制
- [ ] `example/` 层集成

### Phase 4：持仓止盈止损

- [ ] `TpSlIndicator` + `TpSlPaintObject`
- [ ] 实现 `IInteractiveBusinessPainter`（拖拽设价）
- [ ] 止盈/止损区间色块 + 价格线绘制
- [ ] `example/` 层集成

## 6. 性能考量

| 关注点 | 策略 |
|--------|------|
| 数据注入 | `identical` 引用检查，相同数据不触发重绘 |
| 绘制帧内 | 零对象分配，`getBusinessData` → O(1) Map 查找 |
| 分组计算 | 在 `example/` 层完成，不在绘制帧内执行 |
| 大量数据 | 超过 10000 条时可用 `compute()` 放到 isolate |
| hitTest | 只遍历可见范围内的元素 |
| 拖拽重绘 | 只触发 `requestRepaint()`，不重新分组数据 |
