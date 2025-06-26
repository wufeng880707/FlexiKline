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

import 'dart:math' as math;

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flexi_kline/flexi_kline.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../config.dart';
import '../providers/default_kline_config.dart';
import '../providers/instruments_provider.dart';
import '../theme/flexi_theme.dart';
import 'common/kline_page_data_update_mixin.dart';
import 'components/flexi_kline_draw_toolbar.dart';
import 'components/flexi_kline_indicator_bar.dart';
import 'components/flexi_kline_mark_view.dart';
import 'components/flexi_kline_setting_bar.dart';
import 'components/market_ticker_view.dart';
import 'components/trading_pair_select_title.dart';
import 'index_page.dart';

class OkKlinePage extends ConsumerStatefulWidget {
  const OkKlinePage({
    super.key,
    this.instId = 'BTC-USDT',
  });

  final String instId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OkKlinePageState();
}

class _OkKlinePageState extends ConsumerState<OkKlinePage>
    with KlinePageDataUpdateMixin<OkKlinePage> {
  late final FlexiKlineController controller;
  late final DefaultFlexiKlineConfiguration configuration;
  bool isFullScreen = false;

  // 交易信号数据
  final Map<int, Set<TradeSignalType>> _tradeSignals = {};

  @override
  FlexiKlineController get flexiKlineController => controller;

  @override
  void initState() {
    super.initState();
    final p = ref.read(instrumentsMgrProvider.notifier).getPrecision(
          widget.instId,
        );
    req = CandleReq(
      instId: widget.instId,
      bar: TimeBar.m15.bar,
      precision: p ?? 2,
      limit: 300,
    );
    configuration = DefaultFlexiKlineConfiguration(ref: ref);
    controller = FlexiKlineController(
      configuration: configuration,
      logger: LoggerImpl(
        tag: "OkFlexiKline",
        debug: kDebugMode,
      ),
      klineDataCacheCapacity: 3,
    );

    // 打印支持的主图指标列表
    print(
        'TradeMark: Supported main indicators: ${controller.supportMainIndicatorKeys.map((k) => k.id).toList()}');

    // 添加交易标记指标到交易区
    controller.addTradeIndicator(const FlexiIndicatorKey('trade_mark'));

    // 添加所有支持的副图指标
    for (final key in controller.supportSubIndicatorKeys) {
      controller.addIndicatorInSub(key);
    }

    controller.onCrossI18nTooltipLables = tooltipLables;

    controller.onLoadMoreCandles = loadMoreCandles;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initKlineData(req);
    });
  }

  /// 生成模拟交易信号数据
  void _generateMockTradeSignals(List<CandleModel> candles) {
    _tradeSignals.clear();
    final random = math.Random(42); // 固定种子，确保每次生成相同的数据

    // 为部分K线添加交易信号
    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final signals = <TradeSignalType>{};

      // 随机生成买卖信号，概率为10%
      if (random.nextDouble() < 0.1) {
        if (random.nextBool()) {
          signals.add(TradeSignalType.buy);
        } else {
          signals.add(TradeSignalType.sell);
        }
      }

      // 偶尔同时出现买卖信号（比如做T）
      if (random.nextDouble() < 0.02) {
        signals.addAll([TradeSignalType.buy, TradeSignalType.sell]);
      }

      if (signals.isNotEmpty) {
        _tradeSignals[candle.ts] = signals;
      }
    }

    // 添加调试信息
    print('TradeMark: Generated ${_tradeSignals.length} trade signals');
    if (_tradeSignals.isNotEmpty) {
      print(
          'TradeMark: Sample signals: ${_tradeSignals.entries.take(3).map((e) => '${e.key}: ${e.value}').join(', ')}');
    }

    // 更新交易标记指标的数据
    _updateTradeMarkData();
  }

  /// 更新交易标记指标的数据
  void _updateTradeMarkData() {
    // 使用静态方法设置全局交易信号数据
    TradeMarkDataMixin.setGlobalTradeSignals(_tradeSignals);

    // 触发重绘
    controller.markRepaintChart();
  }

  void setFullScreen() {
    setState(() {
      isFullScreen = !isFullScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    ref.listen(defaultKlineThemeProvider, (previous, next) {
      if (previous != next) {
        final config = configuration.getFlexiKlineConfig();
        controller.updateFlexiKlineConfig(config);
      }
    });
    return Scaffold(
      backgroundColor: theme.pageBg,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            mainNavScaffoldKey.currentState?.openDrawer();
          },
          child: const Icon(Icons.menu_outlined),
        ),
        title: TradingPairSelectTitle(
          instId: req.instId,
          onChangeTradingPair: onChangeTradingSymbol,
        ),
        centerTitle: true,
      ),
      body: EasyRefresh(
        onRefresh: () async {
          req = req.copyWith(after: null, before: null);
          await initKlineData(req, reset: true);
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (isFullScreen) {
              controller.setFixedSize(
                Size(constraints.maxWidth, constraints.maxHeight - 30.r),
              );
            } else {
              controller.exitFixedSize();
            }
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                    visible: !isFullScreen,
                    child: MarketTickerView(
                      instId: req.instId,
                      precision: req.precision,
                    ),
                  ),
                  Visibility(
                    visible: !isFullScreen,
                    child: FlexiKlineSettingBar(
                      controller: controller,
                      onTapTimeBar: onTapTimerBar,
                    ),
                  ),
                  FlexiKlineWidget(
                    controller: controller,
                    mainBackgroundView: FlexiKlineMarkView(
                      margin: EdgeInsetsDirectional.only(
                        bottom: 10.r,
                        start: 36.r,
                      ),
                    ),
                    mainForegroundViewBuilder: _buildKlineMainForgroundView,
                    onDoubleTap: setFullScreen,
                    drawToolbar: FlexiKlineDrawToolbar(
                      controller: controller,
                    ),
                  ),
                  FlexiKlineIndicatorBar(
                    height: 30.r,
                    controller: controller,
                  ),
                  Visibility(
                    visible: !isFullScreen,
                    child: Container(
                      height: 200,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            key: const ValueKey('OkConfigStore'),
            heroTag: "Ok",
            backgroundColor: theme.cardBg,
            foregroundColor: theme.t1,
            mini: true,
            onPressed: () {
              controller.storeFlexiKlineConfig();
            },
            child: Text(
              'Store',
              style: theme.t1s14w400,
            ),
          ),
          SizedBox(height: 8.r),
          FloatingActionButton(
            key: const ValueKey('AddTradeSignals'),
            heroTag: "AddSignals",
            backgroundColor: theme.themeColor,
            foregroundColor: Colors.white,
            mini: true,
            onPressed: () {
              // 添加新的交易信号
              final latest = controller.curKlineData.latest;
              if (latest != null) {
                final signals = <TradeSignalType>{};
                final random = math.Random();

                if (random.nextBool()) {
                  signals.add(TradeSignalType.buy);
                } else {
                  signals.add(TradeSignalType.sell);
                }

                _tradeSignals[latest.ts] = signals;
                _updateTradeMarkData();

                // 触发重绘
                controller.markRepaintChart();
              }
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  /// 构建Kline前景View
  Widget _buildKlineMainForgroundView(BuildContext context) {
    final theme = ref.watch(themeProvider);
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        /// 全屏快捷按钮
        Positioned(
          left: 8.r,
          bottom: 8.r,
          width: 28.r,
          height: 28.r,
          child: IconButton(
            // constraints: BoxConstraints.tight(Size(28.r, 28.r)),
            padding: EdgeInsets.zero,
            style: theme.circleBtnStyle(bg: theme.markBg.withOpacity(0.6)),
            iconSize: 16.r,
            icon: Icon(isFullScreen ? Icons.close_fullscreen_outlined : Icons.open_in_full_rounded),
            onPressed: setFullScreen,
          ),
        ),

        /// 回到初始位置
        Positioned(
          left: 80.r,
          right: 0,
          bottom: 8.r,
          child: ValueListenableBuilder(
            valueListenable: controller.isFirstCandleMoveOffScreenListener,
            builder: (context, value, child) => Offstage(
              offstage: !value,
              child: SizedBox(
                width: 28.r,
                height: 28.r,
                child: IconButton(
                  // constraints: BoxConstraints.tight(Size(28.r, 28.r)),
                  padding: EdgeInsets.zero,
                  style: theme.circleBtnStyle(
                    bg: theme.markBg.withOpacity(0.6),
                  ),
                  iconSize: 16.r,
                  icon: const Icon(Icons.keyboard_double_arrow_right_outlined),
                  onPressed: controller.moveToInitialPosition,
                ),
              ),
            ),
          ),
        ),

        /// Loading
        ValueListenableBuilder(
          valueListenable: controller.candleRequestListener,
          builder: (context, request, child) {
            return Offstage(
              offstage: !request.state.showLoading,
              child: Container(
                key: const ValueKey('loadingView'),
                alignment: request.state == RequestState.initLoading
                    ? AlignmentDirectional.center
                    : AlignmentDirectional.centerStart,
                padding: EdgeInsetsDirectional.all(32.r),
                child: SizedBox.square(
                  dimension: 28.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.r,
                    backgroundColor: theme.markBg,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.t1),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Future<void> initKlineData(CandleReq request, {bool reset = false}) async {
    await super.initKlineData(request, reset: reset);

    // 生成模拟交易信号数据
    if (controller.curKlineData.list.isNotEmpty) {
      _generateMockTradeSignals(controller.curKlineData.list);
    }
  }
}
