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

/// LoadMore接口
///
/// 加载[request]指定范围[after, before]之前的历史数据.
typedef OnLoadMoreCandles = Future<void> Function(CandleReq request);

/// 状态管理: 负责数据的管理, 缓存, 切换, 计算.
mixin StateBinding on KlineBindingBase, SettingBinding {
  @override
  void init() {
    super.init();
    logd("init state");
    _klineDataCache = FIFOHashMap(capacity: klineDataCacheCapacity);
  }

  @override
  void initState() {
    super.initState();
    logd('initState state');
  }

  @override
  void dispose() {
    super.dispose();
    logd('dispose state');
    _candleRequestListener.dispose();
    _isFirstCandleMoveOffScreenListener.dispose();
    _timeBarListener.dispose();
    // _candleDrawIndexListener.dispose();
    _klineDataCache.forEach((key, data) {
      data.dispose();
    });
    _klineDataCache.clear();
  }

  OnLoadMoreCandles? onLoadMoreCandles;

  /// 首根蜡烛是否移出屏幕监听.
  final _isFirstCandleMoveOffScreenListener = ValueNotifier(false);
  ValueListenable<bool> get isFirstCandleMoveOffScreenListener {
    return _isFirstCandleMoveOffScreenListener;
  }

  /// 当KlineData的TimeBar的监听器
  final _timeBarListener = ValueNotifier<TimeBar?>(null);
  ValueListenable<TimeBar?> get timeBarListener => _timeBarListener;

  /// CandleReq变化监听器
  final _candleRequestListener = ValueNotifier(KlineData.empty.req);
  @override
  ValueListenable<CandleReq> get candleRequestListener {
    return _candleRequestListener;
  }

  /// 当前KlineData绘制范围监听器
  // final _candleDrawIndexListener = ValueNotifier<Range?>(null);
  // @override
  // ValueListenable<Range?> get candleDrawIndexListener {
  //   return _candleDrawIndexListener;
  // }

  void _updateCandleRequestListener(CandleReq request) {
    logd('updateCandleRequestListener $curDataKey, request:$request');
    if (request.key == curDataKey) {
      _candleRequestListener.value = request;
      _timeBarListener.value = request.timeBar;
      _drawObjectManager.onChangeCandleRequest(request, drawConfig);
    }
  }

  ComputeMode _computeMode = ComputeMode.fast;
  // ComputeMode get computeMode => _computeMode;
  set computeMode(mode) {
    if (mode != _computeMode) {
      _computeMode = mode;
      _startPrecomputeKlineData(
        curKlineData,
        reset: true,
      );
    }
  }

  late final FIFOHashMap<String, KlineData> _klineDataCache;
  KlineData _curKlineData = KlineData.empty;
  @override
  KlineData get curKlineData => _curKlineData;

  void cleanUnlessKlineData() {
    final curKey = curDataKey;
    _klineDataCache.removeWhere((key, data) {
      if (key != curKey) {
        data.dispose();
        return true;
      }
      return false;
    });
  }

  /// 设置当前KlineData:
  /// 1. 通知timeBar变更
  /// 2. 初始化首根蜡烛绘制位置于屏幕右侧[initPaintDxOffset]指定处.
  /// 3. 重绘图表
  /// 4. 取消Cross绘制(如果有)
  void _setCurKlineData(KlineData data) {
    _curKlineData = data;
    _updateCandleRequestListener(data.req);
    initPaintDxOffset();
    markRepaintChart(reset: true);
    markRepaintDraw();
    cancelCross();
  }

  /// 数据缓存Key
  String get curDataKey => curKlineData.key;

  /// 最大绘制宽度
  double get maxPaintWidth => curKlineData.length * candleActualWidth;

  @override
  CandleModel? dxToCandle(double dx) {
    final index = dxToIndex(dx);
    return curKlineData.getCandle(index);
  }

  /// 将[dx]转换为当前绘制区域对应的蜡烛的下标.
  @override
  int? dxToIndex(double dx) {
    return mainPaintObject.dxToIndex(dx).toInt();
  }

  /// 将[index]转换为当前绘制区域对应的X轴坐标.
  @override
  double? indexToDx(int index, {bool check = false}) {
    return mainPaintObject.indexToDx(index, check: check);
  }

  /// 将[dx]精确转换为蜡烛的时间戳ts, 差异部分补充到ts中.
  @override
  int? dxToTimestamp(double dx) {
    final indexValue = mainPaintObject.dxToIndex(dx);
    // if (indexValue == null) return null;
    final ts = curKlineData.indexToTimestamp(indexValue);
    return ts;
  }

  /// 将时间戳[ts]精确转换为dx坐标, 并将差异部分汇总到dx中.
  @override
  double? timestampToDx(int ts) {
    final indexValue = curKlineData.timestampToIndex(ts);
    if (indexValue == null) return null;
    final dx = mainPaintObject.indexToDx(indexValue, check: false);
    return dx;
  }

  @override
  double? valueToDy(BagNum value, {bool correct = false}) {
    return mainPaintObject.valueToDy(value, correct: correct);
  }

  @override
  BagNum? dyToValue(double dy, {bool check = false}) {
    return mainPaintObject.dyToValue(dy, check: check);
  }

  /// 当前canvas绘制区域起始蜡烛右部dx值.
  @override
  double get startCandleDx {
    if (paintDxOffset == 0) {
      return mainChartRight;
    } else if (paintDxOffset > 0) {
      return mainChartRight + paintDxOffset % candleActualWidth;
    } else {
      return mainChartRight + paintDxOffset;
    }
  }

  /// 画布是否可以从右向左进行平移.
  bool get canPanRTL => paintDxOffset > minPaintDxOffset;

  /// 画布是否可以从左向右进行平移.
  bool get canPanLTR {
    return paintDxOffset < maxPaintDxOffset;
  }

  double _paintDxOffset = 0;

  /// 代表当前绘制区域相对于startIndex右侧的偏移量.
  /// 1. 当为零时(默认) : 说明首根蜡烛在Canvas右边界展示.
  /// 2. 当为负数时     : 代表首根蜡烛到Canvas右边界的距离.
  /// 3. 当为正数时     : 说明首根蜡烛已向右移出Canvas.
  ///     移出右边界的蜡烛数量 = (paintDxOffset / candleActualWidth).floor()
  ///     绘制起始蜡烛的向右边界外的偏移 = paintDxOffset % candleActualWidth;
  @override
  double get paintDxOffset => _paintDxOffset;
  set paintDxOffset(double val) {
    _paintDxOffset = clampPaintDxOffset(val);
    _isFirstCandleMoveOffScreenListener.value = _paintDxOffset > 0;
  }

  /// PaintDxOffset的最小值
  double get minPaintDxOffset {
    return math.min(
      maxPaintWidth - mainChartWidth,
      -minPaintBlankWidth,
    );
  }

  /// PaintDxOffset的最大值
  double get maxPaintDxOffset {
    return maxPaintWidth - (mainChartWidth - minPaintBlankWidth);
  }

  /// 矫正PaintDxOffset的范围
  double clampPaintDxOffset(double dxOffset) {
    return dxOffset.clamp(minPaintDxOffset, maxPaintDxOffset);
  }

  void initPaintDxOffset() {
    paintDxOffset = math.min(
      maxPaintWidth - mainChartWidth, // 不足一屏, 首根蜡烛偏移量等于首根蜡烛右边长度.
      -settingConfig.firstCandleInitOffset, // 满足一屏时, 首根蜡烛相对于主绘制区域最小的偏移量
    );
  }

  /// 移动蜡烛图回到初始位置
  void moveToInitialPosition() {
    initPaintDxOffset();
    markRepaintChart();
    markRepaintDraw();
  }

  /// 计算绘制蜡烛图的起始数组索引下标
  void calculateCandleDrawIndex() {
    if (paintDxOffset > 0) {
      final startIndex = (paintDxOffset / candleActualWidth).floor();
      final diff = paintDxOffset % candleActualWidth;
      final maxCount = ((mainChartWidth + diff) / candleActualWidth).round();
      curKlineData.ensureStartAndEndIndex(
        startIndex,
        maxCount,
      );
    } else {
      int maxCount;
      if (settingConfig.alwaysCalculateScreenOfCandlesIfEnough) {
        // 1: 当前[start, end]不足一屏蜡烛时, 向后取一屏蜡烛数据来计算最大最小
        maxCount = maxCandleCount;
      } else {
        // 2: 取当前可见蜡烛来计算最大最小. 四舍五入
        final offsetIndex = (paintDxOffset.abs() / candleActualWidth).round();
        maxCount = maxCandleCount - offsetIndex;
      }
      curKlineData.ensureStartAndEndIndex(
        0,
        maxCount,
      );
    }

    // _candleDrawIndexListener.value = curKlineData.drawTimeRange;
  }

  /// 开始预计算Kline指标数据
  /// [data] 待计算的Kline蜡烛数据
  /// [newList] 待计算的蜡烛数据范围
  /// [reset] 是否重置[data],
  /// 1. true: 重新计算[data]的指标数据;
  /// 2. false: 仅计算[data]与[newList]合并后的部分.
  /// 数据合并更新结果的处理:
  /// 1. 对于历史数据追加, 像EMA这类依赖于历史数据会适时考虑从头计算.
  /// 2. 对于实时数据更新, 会仅计算[newList]部分.
  Future<KlineData> _startPrecomputeKlineData(
    KlineData data, {
    List<CandleModel> newList = const [],
    bool reset = false,
  }) async {
    if (newList.isEmpty) {
      // 无需计算; 直接返回
      return data;
    }

    // 确认当前数据的计算模式
    final computeMode = _computeMode;

    // 待计算的指标对象集合
    final paintObjects = [mainPaintObject, ...subPaintObjects];

    final watchPrecompute = Stopwatch();

    try {
      logd('PrecomputeKlineData Begin:${DateTime.now()}');
      watchPrecompute.start();

      /// 使用scheduleTask + compute方式运行预计算
      // return await SchedulerBinding.instance.scheduleTask(
      //   () => precomputeKlineDataByCompute(
      //     data,
      //     newList: newList,
      //     computeMode: computeMode,
      //     calcParams: calcParams,
      //     reset: reset,
      //     debugLabel: 'Precompute-Compute',
      //     logger: loggerDelegate,
      //   ),
      //   Priority.animation,
      //   debugLabel: 'Precompute-Task',
      // );

      /// 使用scheduleTask方式运行预计算
      return await SchedulerBinding.instance.scheduleTask(
        () => KlineData.precomputeKlineData(
          data,
          indicatorCount: indicatorCount,
          newList: newList,
          computeMode: computeMode,
          paintObjects: paintObjects,
          reset: reset,
        ),
        Priority.animation,
        debugLabel: 'Precompute-Task',
      );
    } catch (e, stack) {
      loge('PrecomputeKlineData exception!!!', error: e, stackTrace: stack);
      return data;
    } finally {
      watchPrecompute.stop();
      logd('PrecomputeKlineData End:${DateTime.now()}');
      logi('PrecomputeKlineData spent:${watchPrecompute.elapsedMicroseconds}');
    }
  }

  /// 切换[req]请求指定的蜡烛数据
  /// [req] 待切换的[CandleReq]
  /// [useCacheFirst] 优先使用缓存. 注: 如果有缓存数据(说明之前加载过), loading不会展示.
  /// return
  ///   1. true:  代表使用了缓存, [curKlineData]的请求状态为[RequestState.none], 不展示loading
  ///   2. false: 代表未使用缓存; 且[curKlineData]数据会被清空(如果有).
  bool switchKlineData(
    CandleReq req, {
    bool useCacheFirst = true,
  }) {
    KlineData? data = _klineDataCache[req.key];

    if (useCacheFirst && data != null && !data.isEmpty) {
      // 如果优先使用缓存且缓存数据不为空时, 设置缓存为当前KlineData, 同时结束loading状态.
      _setCurKlineData(data);
      return true;
    }

    // 清理历史缓存数据.
    data?.dispose();

    // 重置当前KlineData为[req]请求指定的KlineData, 并更新到缓存中.
    data = KlineData(
      req.copyWith(state: RequestState.initLoading),
      logger: loggerDelegate,
    );
    final old = _klineDataCache.append(req.key, data);
    if (old != null) Future(() => old.dispose());
    _curKlineData = data;
    _updateCandleRequestListener(data.req);
    return false;
  }

  /// 结束加载中状态
  /// [forceStopCurReq] 强制结束当前请求蜡烛数据[curKlineData]的加载中状态
  /// [request]和[reqKey]指定要结束加载状态的请求, 如果[request]请求的状态非[RequestState.none], 即结束加载中状态
  void stopLoading({
    CandleReq? request,
    String? reqKey,
    bool forceStopCurReq = false,
  }) {
    KlineData? data;
    reqKey ??= request?.key;
    if (forceStopCurReq || reqKey == curDataKey) {
      if (curKlineData.req.state != RequestState.none) {
        _updateCandleRequestListener(
          curKlineData.updateRequest(state: RequestState.none),
        );
      }
    } else {
      if (reqKey != null) data = _klineDataCache[reqKey];
      if (data != null) {
        data.updateRequest(state: RequestState.none);
      }
    }
  }

  /// 更新[list]到[req]请求指定的[KlineData]中
  Future<void> updateKlineData(
    CandleReq req,
    List<CandleModel> list,
  ) async {
    // 数据为空, 无需要更新.
    if (list.isEmpty) {
      stopLoading(request: req);
      return;
    }

    KlineData? data = _klineDataCache[req.key];
    bool reset = data == null || data.isEmpty;
    final oldLen = data?.length ?? 0;

    data ??= KlineData(
      req.copyWith(state: RequestState.initLoading),
      logger: loggerDelegate,
    );

    /// 首先结束[stat.req]的请求状态为[RequestState.none]
    stopLoading(request: data.req);

    data = await _startPrecomputeKlineData(
      data,
      newList: list,
      reset: reset,
    );

    final old = _klineDataCache.append(req.key, data);
    if (old != null) Future(() => old.dispose());

    if (req.key == curDataKey) {
      if (reset) {
        _setCurKlineData(data);
      } else {
        _updateCandleRequestListener(data.req);
        final newLen = data.length;
        if (paintDxOffset < 0 && newLen > oldLen) {
          /// 当数据合并后
          /// 1. 如果paintDxOffset > 0 说明满足一屏, 且最新蜡烛被用户移动到绘制区域外面, 无需调整偏移量paintDxOffset, 重绘时, 仍按此偏移量计算后, 当前首根蜡烛向左移动一个蜡烛.
          /// 2. 如果paintDxOffset == 0 说明当前最新蜡烛在屏幕第一位(最右边)展示. 无需调整偏移量paintDxOffset, 重绘时calculateCandleIndexAndOffset, 会计算startIndex = 0;
          /// 2. 如果paintDxOffset < 0 说明未满足一屏, 需要减小偏移量, 以保证新数据能够展示.
          ///    注: 如果调整后 paintDxOffset > 0 则要置为0, 以保证最新蜡烛在最右边展示.
          paintDxOffset = math.min(
            0,
            paintDxOffset + (newLen - oldLen) * candleActualWidth,
          );
        }

        markRepaintChart();
        markRepaintDraw();
      }
    }
  }
}
