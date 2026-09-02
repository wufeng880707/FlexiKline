# FlexiKline 优化清单

> 生成于 2026-09-01，基于全项目扫描（lib/ + example/ + test/ + CI + 仓库卫生）。
> 完成一项后将 `- [ ]` 改为 `- [x]`。

## 执行顺序建议

1. **第一批（安全 + 一行级 bug + 泄漏）**：§一、§二
2. **第二批（改动小、收益大的性能项）**：§三 中的 #31 #22 #28 #29
3. **第三批（核心性能）**：§三 中的 #19 #20 #21 #30
4. **长线（结构性）**：#42 #50 #53、§五 测试补齐

---

## 一、安全与正确性 Bug

- [x] 1.【高】Polygon.io API Key 硬编码且已进入 git 历史 — 吊销 key 并改为 `--dart-define` 注入（`example/lib/main.dart:38`）
- [x] 2.【高】`if (object == null) false;` 无效语句，下一行 `object!` 会 NPE 崩溃，应为 `return false;`（`core/draw.dart:436-455`）
- [x] 3.【高】`candleSpacing` 的 `.clamp()` 返回值未接收，间距下限保护失效（`core/setting.dart:419-430`）
- [x] 4.【中】滚轮越界分支缺 `return`，越界滚轮继续走缩放逻辑（`non_touch_gesture_detector.dart:221-225`）
- [x] 5.【中】`canvasRect` 把宽高当 right/bottom 传给 `Rect.fromLTRB`（`core/setting.dart:110-120`；`grid.dart:147,189` 同类）
- [x] 6.【中】SAR 增量计算丢失 ep/af/趋势状态，与全量值不连续（`indicators/sar/data.dart:64-101`）
- [x] 7.【中】RSI 增量时 Wilder 平滑重新播种，边界值不连续（`indicators/rsi/data.dart:62-112`）
- [ ] 8.【中】MA fast 模式滚动和长序列浮点误差累积（`indicators/ma/data.dart:99-103`）
- [x] 9.【低】`Overlay.fromType` 用毫秒时间戳做 id，同毫秒创建撞 id（`framework/draw/model.dart:101`）

## 二、生命周期与内存泄漏

- [x] 10.【高】`WidgetsBindingObserver` 只 mixin 从未 `addObserver`，内存压力缓存驱逐是死代码（`flexi_kline_widget.dart:145,239`）
- [x] 11.【高】非触摸手势检测器 `drawStateListenable` listener 从不移除，`_mouseCursor` 未 dispose（`non_touch_gesture_detector.dart:88-129`）
- [x] 12.【高】`didUpdateWidget` 未处理 controller 更换：新 controller 不 mount、旧的不释放（`flexi_kline_widget.dart:215-230`）
- [x] 13.【中】`_drawToolbarPosition` ValueNotifier 未 dispose（`flexi_kline_widget.dart:244-248`）
- [x] 14.【中】多个公开数据 API 缺 `isMounted` 守卫，dispose 后异步推数据崩溃（`core/state.dart:411-476`、`binding_base.dart:145-157`）
- [x] 15.【中】滚轮缩放用 `Future.delayed(1s)` 闭包，dispose 后仍执行且连续滚动堆叠任务（`non_touch_gesture_detector.dart:238-285`）
- [x] 16.【低】`FlexiStateNotifier.setSilently` 无 try/finally，异常后通知被永久吞掉（`binding_base.dart:298-302`）
- [x] 17.【低】`PaintObjectManager` dispose 后 late final 无法重挂载（`framework/chart/manager.dart:100-103`）
- [x] 18.【低】`FlexiKlinePageMixin` 无条件 dispose 可能共享的 controller（`flexi_kline_page.dart:84-88`）

## 三、性能优化

### 指标计算（最大 CPU 热点）

- [x] 19.【高】EMA 完全忽略增量 range，每次全量重算 + 整表复制反转（`indicators/ema/data.dart:80-135`）
- [x] 20.【高】MACD 全量重算，单次分配约 10 张全长度临时表（`indicators/macd/data.dart:47-52,96-175`）
- [x] 21.【高】OBV 固定全量重算（running sum 本可增量）+ MA 子线 O(N×period)（`indicators/obv/data.dart:136-170`）
- [x] 22.【高】CCI/OBV 热路径 `double.parse(x.toString())` 字符串往返，直接用 `FlexiNum.toDouble()`（`cci/data.dart:38-39`、`obv/data.dart:97-99`）
- [x] 23.【中】BOLL 方差计算 O(N×period) 且每元素 4 次 toDouble，可用滚动和（`indicators/boll/data.dart:75-99`）
- [x] 24.【中】KDJ 窗口 high/low O(N×kPeriod)，可用单调队列（`indicators/kdj/data.dart:79-85`）
- [x] 25.【中】`appendHistory` 无条件 fullRecompute，便宜指标陪跑（`data/candle_list.dart:153`）
- [ ] 26.【中】`FlexiNum` 每次运算 2-4 次运行时类型检查 + 装箱；按 ComputeMode 走 double/Decimal 专用路径（`model/flexi_num.dart:122-281`）
- [ ] 27.【低】循环内重复构造常量（`FlexiNum.fromNum(50)`、`one - multiplier` 等，kdj/ema/macd data.dart 多处）

### 渲染热路径

- [x] 28.【高】8 个 Paint getter 每根蜡烛新建 Paint，每秒上万次分配（`framework/chart/object_helper.dart:40-91`）
- [x] 29.【高】TextPainter 大量新建且不 dispose（`extension/render/draw_text.dart:65-77`、`draw_image_text.dart:106-129`、`business_overlays/position_overlay.dart:391,418,496`、`pending_order_overlay.dart:255`）
- [ ] 30.【高】画图对象每帧全量 `initPoints` 重算坐标（作者自注"待优化"），应加脏标记缓存（`core/draw.dart:485-502`）
- [x] 31.【高】`tsToIndex` 用 `indexWhere` 线性扫描；`timestampToIndex` 算出二分索引却丢弃（`candle_list.dart:30-33`、`paint_draw.dart:59-73`；仓库已有现成二分 `indexAtOrBefore`）
- [ ] 32.【中】5 个 CustomPainter `shouldRepaint` 恒真 + 每次 build 新建实例（`flexi_kline_widget.dart:603-712`）
- [ ] 33.【中】BusinessOverlay 层 merge 了 repaintChart，平移蜡烛时持仓/挂单层陪着重排文本（`flexi_kline_widget.dart:641-646`）
- [ ] 34.【中】虚线 `dashPath` 每帧重算 + `[5,3]` 字面量分配（`extension/render/draw_path.dart:17-113`）
- [ ] 35.【中】拖 grid 分隔线时每帧重建整个 Stack（含手势层/放大镜）+ 可能每帧落盘（`flexi_kline_widget.dart:292-306`）
- [ ] 36.【中】放大镜子树每帧 Widget 级 rebuild（`flexi_kline_widget.dart:489-555`）
- [ ] 37.【中】Cross tooltip 每次移动全量重建 + 重新排版，可按蜡烛 index 缓存（`core/cross.dart:229-322`）
- [ ] 38.【中】最新价倒计时 Timer 每秒强制全 chart 重绘，页面后台不暂停（`core/chart.dart:114-123`）
- [ ] 39.【中】配置 setter 无值相等检测，改任何开关都全量重绘（`core/setting.dart:692-754`）
- [ ] 40.【中】`throttleOnFps` 用 Timer 非帧对齐，改 `scheduleFrameCallback`（`extension/functions_ext.dart:100-122`）
- [ ] 41.【低】`subPaintObjects` getter、`calculatePaneTop` 每帧新建列表 + O(n²) 前缀和（`manager.dart:110-118`、`setting.dart:474-484`）

### 内存占用

- [ ] 42.【高】指标 slot 为 AoS 嵌套（每蜡烛 × 每指标一个小 List），10 万根光 header 几十 MB；SoA 化（Float64List 按蜡烛索引）
- [ ] 43.【中】`computedDataCapacity` 只增不减，反复增删指标后 slot 数组变长（`framework/chart/manager.dart:88-92`）
- [ ] 44.【中】`BagNum`（570 行）是 FlexiNum 的零引用完整副本，TODO 已注明待废弃，直接删除（`model/bag_num.dart`）
- [ ] 45.【低】`replace` 路径双重复制 10 万根数据（`candle_list.dart:82`、`base_data.dart:37`）

## 四、代码重复与架构

- [ ] 46.【中】`_ema` 函数逐字复制两份（`ema/data.dart:39-78` vs `macd/data.dart:55-94`）
- [ ] 47.【中】MA 与 VolMa 的 data mixin 近乎整体复制；`calculateMinmax` 有三份（ma/vol_ma/volume data.dart）
- [ ] 48.【中】9 套同构 slot 存取 extension（getXxxList/isValidXxx/cleanXxx）可泛型化为 `TypedSlotAccessor<T>`
- [ ] 49.【中】MA/EMA PaintObject 仅前缀不同，可抽"多周期线型指标"基类
- [ ] 50.【中】touch（826 行）/ non_touch（829 行）两套手势检测器大段平行重复，抽共享分派层
- [ ] 51.【中】`position_overlay` 与 `pending_order_overlay` 大段复制（虚线、拖拽手柄、关闭按钮）
- [ ] 52.【中】`drawText` 与 `drawImageText` 约 90 行重复（边界矫正 + 背景框）
- [ ] 53.【中】`FlexiKlineController` 上帝类：7 个 mixin、core/ 9 个 part 共 3463 行，逐步拆分
- [ ] 54.【低】内部可变状态直接暴露：`Indicator.height/size`、`Overlay.zIndex/lock`、`KlineData.list` 可外部增删
- [ ] 55.【低】删除单个画图对象触发全量 JSON 序列化落盘，连续删 N 个 = O(N²)（`framework/draw/manager.dart:184-190`）
- [ ] 56.【低】`SortableHashSet.lookup` 放弃 O(1) 哈希改线性扫描；`FixedHashQueue.append` 命中时整队重建

## 五、测试缺口

- [ ] 57.【高】draw_objects 17 个绘制工具（1552 行）零直接测试：命中判定、点编辑、JSON 持久化
- [ ] 58.【高】全库无 golden test，纯 Canvas 库无视觉回归保障
- [ ] 59.【中】config 序列化（36 文件近 5000 行）缺 toJson/fromJson round-trip 测试
- [ ] 60.【中】indicators 缺"输入序列 → 期望输出"数值正确性测试
- [x] 61.【中】`example/test/widget_test.dart` 是必失败的脚手架 counter 测试
- [ ] 62.【低】根目录 7 个草稿测试与 test/README 宣称的结构矛盾；`base_test.dart` 是语言实验

## 六、工程卫生与 CI

- [x] 63.【高】`lib.zip`（370KB）/`test.zip` 提交进 git，含 `__MACOSX` 垃圾 — `git rm` 并加 `*.zip` 到 .gitignore
- [x] 64.【高】`release.yml` 用 Flutter 3.19.4 与 `sdk >=3.6.0` 冲突必失败，且把 gh-pages 推到上游仓库
- [x] 65.【高】`publish.yml` 会以 `flexi_kline` 名义向 pub.dev 发版，fork 打 tag 即冲突，应禁用
- [x] 66.【中】`test.yml` 只在 main 触发（开发在 dev1），且不 analyze example
- [x] 67.【中】删除 `pubspec.yaml.orig`（含未解决 merge conflict）、`pubspec_1.yaml`
- [ ] 68.【中】根目录 8 份个人笔记 md 删除或归入 doc/
- [ ] 69.【中】example 依赖冗余：riverpod 双包、已注释的 device_preview、全局 vm_service override、flutter_lints 过旧
- [ ] 70.【低】example 55 处 debugPrint + 多处 print；删除 `packages/`、`ws/` 空目录、`archiecture.excalidraw.png`、过时的 TODO.md
- [ ] 71.【中】analyze 共 644 条：8 warning（全在 example）+ 636 info（320 条 hex color、104 条 prefer_const、100 条 prefer_final_locals，可批量修复）
- [ ] 72.【低】`copy_with_extension: ">=6.0.0 <18.0.0"` 版本区间跨 12 个大版本，收紧到实际验证范围

## 七、文档一致性

- [ ] 73.【中】README:339 说绘制工具来自外部包 `flexi_kline_draw_tools`，实际 fork 内置 17 个并导出
- [ ] 74.【中】pubspec 元信息全指向上游；README 安装写法会让用户装到上游包而非本 fork
- [ ] 75.【中】CHANGELOG 缺 3 个 fork 侧适配提交的条目（80a0029 / e19f4a5 / 75a39dc）
- [ ] 76.【低】`example/README.md` 是 Flutter 默认模板

---

## 进度统计

- 总计：76 项
- 已完成：33 项（2026-09-01 第一批 19 项 + 2026-09-02 第二批 14 项：#6 #7 #19 #20 #21 #23 #24 #25 #61 #63 #64 #65 #66 #67）
- 第二批要点：EMA/MACD/OBV/SAR/RSI 全部接入增量计算并有全量一致性测试；BOLL/KDJ 窗口计算 O(N×period)→近似 O(N)；CI 三 workflow 修复；zip/残留 pubspec 清理。全部 957 个测试通过，lib 零 error/warning。
- 剩余高优先级：5 项（#8 #30 #42 #57 #58）
- 备注：#1 代码已改为 `--dart-define=POLYGON_API_KEY` 注入，但旧 key 已进入 git 历史，**仍需去 Polygon.io 后台吊销**。
