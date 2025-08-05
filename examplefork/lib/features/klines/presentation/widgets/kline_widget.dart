import 'package:example/core/extensions/ex_context.dart';
import 'package:example/features/theme/export.dart';
import 'package:flexi_kline/flexi_kline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/config.dart';
import '../../update_controller.dart';
import '../providers/default_kline_config.dart';
import '../providers/kline_controller_state_provider.dart';
import '../providers/market_candle_provider.dart';
import 'flexi_kline_indicator_bar.dart';
import 'flexi_kline_setting_bar.dart';

////异步获取k线图记录
typedef GetCandleListCallBack = Future<List<CandleModel>> Function(CandleReq req);

////异步获取k线图更多记录
typedef GetMoreCandleListCallBack = Future<List<CandleModel>> Function(CandleReq req);

typedef OnInitCallBack = Function(FlexiKlineController controller);
typedef SettingChangeCallBack = Function(SettingConfig setting);
typedef OnTimeBarChange = Function(TimeBarConfig newTimeBar);

class KLineWidget extends StatefulWidget {
  ///支持的时间周期
  // List<TimeBarConfig> supportTimBars;
  OnInitCallBack? onInitCallBack;
  SettingChangeCallBack? settingChangeCallBack;

  ///根据CandleReq，异步返回k线图数据
  GetCandleListCallBack getCandleList;

  ///根据CandleReq，异步返回k线图更多数据
  GetMoreCandleListCallBack? getMoreCandleList;

  ///k线图显示周期改变
  OnTimeBarChange? onTimeBarChange;

  ///更新数据controller，当收到单条数据时，可用这个及时更新k线图
  UpdateController? updateController;

  ///初始化k线图请求
  CandleReq initReq;

  ///是否展示当前价格，开盘，最高，最低等信息
  bool? isShowMarketTooltipCustomView;

  // ///24小时交易量等等信息
  // final MarketTicker marketTicker;

  ///是否展示底部的指标切换指示器
  bool showBottomIndicator;

  // ////显示的文本配置项
  // StringLabelConfig labelConfig;

  ///容器初始化的大小
  Size? initSize;

  ///是否允许全屏
  bool isCanFullScreen;

  ///是否自动缓存配置
  bool autoCacheConfig;

  final EdgeInsetsGeometry? bottomIndicatorMargin;

  KLineWidget({
    super.key,
    required this.getCandleList,
    this.getMoreCandleList,
    this.isShowMarketTooltipCustomView,
    this.updateController,
    this.settingChangeCallBack,
    this.bottomIndicatorMargin,
    this.onTimeBarChange,
    this.onInitCallBack,
    this.initSize,
    this.isCanFullScreen = false,
    this.autoCacheConfig = false,
    this.showBottomIndicator = true,
    required this.initReq,
  });

  @override
  State<StatefulWidget> createState() {
    return _KLineWidgetState();
  }
}

class _KLineWidgetState extends State<KLineWidget> {
  bool isInitCache = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  void _init() async {
    try {} catch (e) {}
    setState(() {
      isInitCache = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isInitCache
        ? ProviderScope(
          child: KlineWidgetPrivate(
            onInitCallBack: widget.onInitCallBack,
            showBottomIndicator: widget.showBottomIndicator,
            getCandleModelHistory: widget.getCandleList,
            getMoreCandleModelHistory: widget.getMoreCandleList,
            bottomIndicatorMargin: widget.bottomIndicatorMargin,
            initSize: widget.initSize,
            onTimeBarChange: widget.onTimeBarChange,
            updateController: widget.updateController,
            isCanFullScreen: widget.isCanFullScreen,
            autoCacheConfig: widget.autoCacheConfig,
            initReq: widget.initReq,
            settingChangeCallBack: widget.settingChangeCallBack,
            isShowMarketTooltipCustomView: widget.isShowMarketTooltipCustomView ?? true,
          ),
        )
        : SizedBox();
  }
}

class KlineWidgetPrivate extends ConsumerStatefulWidget {
  KlineWidgetPrivate({
    super.key,
    required this.initReq,
    this.updateController,
    this.initSize,
    this.onTimeBarChange,
    this.onInitCallBack,
    this.settingChangeCallBack,
    this.autoCacheConfig = false,
    this.bottomIndicatorMargin,
    this.getMoreCandleModelHistory,
    required this.isCanFullScreen,
    required this.getCandleModelHistory,
    required this.showBottomIndicator,
    this.isShowMarketTooltipCustomView = false,
  });

  final EdgeInsetsGeometry? bottomIndicatorMargin;
  OnInitCallBack? onInitCallBack;
  SettingChangeCallBack? settingChangeCallBack;

  ///是否允许全屏
  bool isCanFullScreen;
  Size? initSize;

  OnTimeBarChange? onTimeBarChange;
  UpdateController? updateController;
  bool showBottomIndicator;
  bool autoCacheConfig = false;
  bool isShowMarketTooltipCustomView = false;
  GetCandleListCallBack getCandleModelHistory;

  GetMoreCandleListCallBack? getMoreCandleModelHistory;

  CandleReq initReq;
  // final MarketTicker marketTicker;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _KlineWidgetPrivateState();
  }
}

class _KlineWidgetPrivateState extends ConsumerState<KlineWidgetPrivate> {
  late final FlexiKlineController controller;
  late final DefaultFlexiKlineConfiguration configuration;

  late CandleReq req;

  @override
  void dispose() {
    widget.updateController?.removeListener(_dataChanges);
    super.dispose();
  }

  final logger = LogPrintImpl(debug: false, tag: 'Demo');

  @override
  void initState() {
    req = widget.initReq;
    configuration = DefaultFlexiKlineConfiguration(ref: ref);

    controller = FlexiKlineController(
      configuration: configuration,
      logger: logger,
      autoSave: widget.autoCacheConfig,
    );

    controller.onCrossCustomTooltip = onCrossCustomTooltip;
    controller.onLoadMoreCandles = loadMoreCandles;

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
      ref.read(klineStateProvider(controller)).addListener(() {
        if (widget.settingChangeCallBack != null) {
          widget.settingChangeCallBack!(controller.settingConfig);
        }
      });
    });
    widget.updateController?.addListener(_dataChanges);
  }

  bool hasListener = false;

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //
  //   // 确保只添加一次监听器
  //   if (!hasListener&&controller!=null) {
  //     ref.listen<KlineStateNotifier>(
  //       klineStateProvider(controller),
  //           (previous, next) {
  //         // 当 klineStateProvider 的状态发生变化时执行此回调
  //         print("klineStateProvider has changed!");
  //       },
  //     );
  //     hasListener = true;
  //   }
  // }

  void _dataChanges() {
    _update(widget.updateController?.data ?? []);
  }

  // /// 当crossing时, 自定义Tooltip
  // List<TooltipInfo>? onCrossCustomTooltip(CandleModel? current, {CandleModel? prev}) {
  //   if (current == null) {
  //     ref.read(marketCandleProvider.notifier).emitOnCross(null);
  //     // Cross事件取消了, 更新行情为最新一根蜡烛数据.
  //     emitLatestMarketCandle();
  //     return [];
  //   }
  //
  //   final candle = current.clone()..confirm = '';
  //   // 暂存振幅到candle的confirm中.
  //   if (prev != null) candle.confirm = candle.rangeRate(prev).toString();
  //   ref.read(marketCandleProvider.notifier).emitOnCross(candle);
  //   // 返回空数组, 自行定制.
  //   return [];
  // }

  /// 更新最新的蜡烛数据到行情上.
  void emitLatestMarketCandle() {
    if (controller.curKlineData.latest != null && mounted) {
      ref.read(marketCandleProvider.notifier).emit(controller.curKlineData.latest!);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ///当前状态信息
        // if (widget.isShowMarketTooltipCustomView)
        // MarketTooltipCustomView(
        //   candleReq: req,
        //   controller: controller,
        //   data: controller.curKlineData.latest,
        //   tooltipOpen: widget.labelConfig.tooltipOpen ?? "",
        //   tooltipHigh: widget.labelConfig.tooltipHigh ?? "",
        //   tooltipLow: widget.labelConfig.tooltipLow ?? "",
        //   tooltipAmount: widget.labelConfig.tooltipAmount ?? "",
        // ),
        ///k线周期，设置等等
        FlexiKlineSettingBar(controller: controller, onTapTimeBar: onTapTimeBar),

        ///具体k线图容器
        FlexiKlineWidget(
          // key: const ValueKey('MyKlineDemo'),
          controller: controller,
          onDoubleTap: openLandscapePage,
          mainForegroundViewBuilder: (cx) {
            return Stack(
              children: [
                if (widget.isCanFullScreen)
                  Positioned(
                    left: 8.r,
                    bottom: 8.r,
                    width: 28.r,
                    height: 28.r,
                    child: IconButton(
                      // constraints: BoxConstraints.tight(Size(28.r, 28.r)),
                      padding: EdgeInsets.zero,
                      style: ref
                          .watch(themeFKProvider)
                          .circleBtnStyle(bg: ref.watch(themeFKProvider).markBg.withOpacity(0.6)),
                      iconSize: 20.r,
                      icon: const Icon(Icons.fullscreen_rounded),
                      onPressed: openLandscapePage,
                    ),
                  ),
              ],
            );
          },
        ),

        if (widget.showBottomIndicator)
          ///底部主副图切换
          FlexiKlineIndicatorBar(controller: controller, margin: widget.bottomIndicatorMargin),
      ],
    );

    return content;
  }

  void onTapTimeBar(TimeBarConfig bar) {
    if (bar.key != req.timeBar.key) {
      req = req.copyWith(timeBar: bar);
      if (widget.onTimeBarChange != null) {
        widget.onTimeBarChange!(bar);
      }
      setState(() {});
      initKlineData();
    }
  }

  /// 初始化加载K线蜡烛数据.
  Future<void> initKlineData() async {
    controller.switchKlineData(req);

    ///请求数据
    final list = await widget.getCandleModelHistory(req);
    await _update(list);
  }

  Future<void> _update(List<CandleModel> list) async {
    await controller.updateKlineData(req, list);
    emitLatestMarketCandle();
  }

  void _init() async {
    initKlineData().then((value) {});
    if (widget.onInitCallBack != null) {
      widget.onInitCallBack!.call(controller);
    }
  }

  void openLandscapePage() async {
    if (!widget.isCanFullScreen) {
      return;
    }
    controller.storeFlexiKlineConfig();
    // 跳转到横屏页面
    // final isUpdate = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder:
    //         (context) => ProviderScope(
    //           child: LandscapeKlinePage(
    //             labelConfig: widget.labelConfig,
    //             updateController: widget.controller,
    //             marketTicker: widget.marketTicker,
    //             getCandleList: widget.getCandleModelHistory,
    //             supportTimeBarList: widget.supportTimBars,
    //             candleReq: controller.curKlineData.req.toInitReq(),
    //             configuration: controller.configuration,
    //           ),
    //         ),
    //   ),
    // );
    // if (mounted && isUpdate == true) {
    //   final landConfig = controller.configuration.getFlexiKlineConfig();
    //   controller.updateFlexiKlineConfig(landConfig);
    // }
  }
}

extension _Action on _KlineWidgetPrivateState {
  Future<void> loadMoreCandles(CandleReq request) async {
    if (widget.getMoreCandleModelHistory != null) {
      final list = await widget.getMoreCandleModelHistory!(req);
      if (list.isNotEmpty) {
        await controller.updateKlineData(request, list);
      }
    }
  }

  // Future<void> loadCountDownFinished(CandleReq request) async {
  //   if (widget.getCandleModelHistory != null) {
  //     ///请求数据
  //     final list = await widget.getCandleModelHistory(req);
  //     await _update(list);
  //   }
  // }

  List<TooltipInfo>? onCrossCustomTooltip(CandleModel? current, {CandleModel? prev}) {
    if (current == null) return [];
    final s = context.trans;
    final klineTheme = ref.read(defaultKlineThemeProvider);
    final lableStyle = TextStyle(color: klineTheme.textColor, fontSize: 10.sp);
    final valueStyle = TextStyle(color: klineTheme.textColor, fontSize: 10.sp);
    final valStyle =
        current.isLong
            ? TextStyle(color: klineTheme.long, fontSize: 10.sp)
            : TextStyle(color: klineTheme.short, fontSize: 10.sp);
    final p = req.precision;
    return <TooltipInfo>[
      TooltipInfo(
        label: s.tooltipTime,
        labelStyle: lableStyle,
        value: current.formatDateTime(req.timeBar),
        valueStyle: valueStyle,
      ),
      TooltipInfo(
        label: s.tooltipOpen,
        labelStyle: lableStyle,
        value: formatPrice(current.o, precision: p, showThousands: true),
        valueStyle: valueStyle,
      ),
      TooltipInfo(
        label: s.tooltipHigh,
        labelStyle: lableStyle,
        value: formatPrice(current.h, precision: p, showThousands: true),
        valueStyle: valueStyle,
      ),
      TooltipInfo(
        label: s.tooltipLow,
        labelStyle: lableStyle,
        value: formatPrice(current.l, precision: p, showThousands: true),
        valueStyle: valueStyle,
      ),
      TooltipInfo(
        label: s.tooltipClose,
        labelStyle: lableStyle,
        value: formatPrice(current.c, precision: p, showThousands: true),
        valueStyle: valueStyle,
      ),
      TooltipInfo(
        label: s.tooltipAmount,
        labelStyle: lableStyle,
        value: formatPrice(current.v, precision: p, showThousands: true),
        valueStyle: valueStyle,
      ),
      TooltipInfo(
        label: s.tooltipChg,
        labelStyle: lableStyle,
        value: formatPrice(current.change, precision: p, showThousands: true),
        valueStyle: valStyle,
      ),
      TooltipInfo(
        label: s.tooltipChgRate,
        labelStyle: lableStyle,
        value: formatPercentage(current.changeRate),
        valueStyle: valStyle,
      ),
      TooltipInfo(
        label: s.tooltipRange,
        labelStyle: lableStyle,
        value:
            prev != null
                ? formatPercentage(current.rangeRate(prev))
                : formatPrice(current.range, precision: p),
        valueStyle: valStyle,
      ),
    ];
  }
}
