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

import 'package:dio/dio.dart';
import 'package:flexi_kline/flexi_kline.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../config.dart';
import '../providers/default_kline_config.dart';
import '../providers/market_candle_provider.dart';
import '../repo/mock.dart';
import '../repo/polygon_api.dart' as api;
// import '../test/canvas_demo.dart';
import '../theme/flexi_theme.dart';
import 'components/flexi_kline_draw_toolbar.dart';
import 'components/flexi_kline_indicator_bar.dart';
import 'components/flexi_kline_mark_view.dart';
import 'components/flexi_kline_setting_bar.dart';
import 'components/market_tooltip_custom_view.dart';
import 'index_page.dart';

class MyKlineDemoPage extends ConsumerStatefulWidget {
  const MyKlineDemoPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyDemoPageState();
}

class _MyDemoPageState extends ConsumerState<MyKlineDemoPage> {
  late final FlexiKlineController controller;
  late final DefaultFlexiKlineConfiguration configuration;

  late KlineSpec req;
  CancelToken? cancelToken;
  bool isFullScreen = false;

  final logger = LogPrintImpl(
    debug: kDebugMode,
    tag: 'Demo',
  );

  @override
  void initState() {
    super.initState();
    const count = 500;

    configuration = DefaultFlexiKlineConfiguration(ref: ref);
    controller = FlexiKlineController(
      configuration: configuration,
      logger: logger,
    );

    final interval = configuration.getTimeBarConfigs().firstWhere((e) => e.debugLabel == '15m');
    final now = DateTime.now().millisecondsSinceEpoch;
    final before = now - (now % interval.milliseconds);
    final after = before - count * interval.milliseconds;
    req = KlineSpec(
      symbol: 'AAPL',
      interval: interval,
      precision: 2,
      from: after,
      to: before,
    );

    controller.onCrossCustomTooltip = onCrossCustomTooltip;

    controller.onLoadMoreCandles = loadMoreCandles;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initKlineData(req);
    });
  }

  /// 初始化加载K线蜡烛数据.
  Future<void> initKlineData(KlineSpec request) async {
    controller.switchKlineData(request);
    List<CandleModel>? list;

    // list = await genRandomCandleList(
    //   count: 500,
    //   bar: request.interval!,
    // );

    // list = genETHUSDT1DLimit100List();

    final resp = await api.getHistoryKlineData(
      request,
      cancelToken: cancelToken = CancelToken(),
    );
    if (resp.success) {
      list = resp.data;
    } else {
      SmartDialog.showToast(resp.msg);
    }

    await controller.updateKlineData(request, list ?? const []);
    emitLatestMarketCandle();
  }

  Future<void> loadMoreCandles(KlineSpec request) async {
    // // await Future.delayed(const Duration(milliseconds: 2000)); // 模拟延时, 展示loading
    // final resp = await api.getHistoryKlineData(
    //   request,
    //   cancelToken: cancelToken = CancelToken(),
    // );
    // cancelToken = null;
    // if (resp.success && resp.data != null && resp.data!.isNotEmpty) {
    //   await controller.updateKlineData(request, resp.data!);
    // } else if (resp.msg.isNotEmpty) {
    //   SmartDialog.showToast(resp.msg);
    // }
  }

  /// 当crossing时, 自定义Tooltip
  List<TooltipInfo>? onCrossCustomTooltip(
    FlexiCandleModel? current, {
    FlexiCandleModel? prev,
  }) {
    if (current == null) {
      ref.read(marketCandleProvider.notifier).emitOnCross(null);
      // Cross事件取消了, 更新行情为最新一根蜡烛数据.
      emitLatestMarketCandle();
      return [];
    }

    String? rangeRate;
    if (prev != null) rangeRate = current.rangeRate(prev).toString();
    ref.read(marketCandleProvider.notifier).emitOnCross(current, rangeRate: rangeRate);
    // 返回空数组, 自行定制.
    return [];
  }

  /// 更新最新的蜡烛数据到行情上.
  void emitLatestMarketCandle() {
    if (controller.curKlineData.latest != null) {
      ref.read(marketCandleProvider.notifier).emit(
            controller.curKlineData.latest!,
          );
    }
  }

  void onTapTimeBar(ITimeInterval bar) {
    if (bar != req.interval) {
      req = req.copyWith(interval: bar);
      setState(() {});
      initKlineData(req);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    ref.listen(defaultKlineThemeProvider, (previous, next) {
      if (previous != next) {
        controller.updateFlexiKlineConfig();
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
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Apple Inc.',
              style: theme.t1s18w700,
            ),
            Text(
              req.symbol,
              style: theme.t1s12w400,
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarketTooltipCustomView(
              candleReq: req,
              data: controller.curKlineData.latest,
            ),
            FlexiKlineSettingBar(
              controller: controller,
              onTapTimeBar: onTapTimeBar,
            ),
            FlexiKlineWidget(
              key: const ValueKey('MyKlineDemo'),
              controller: controller,
              mainBackgroundView: FlexiKlineMarkView(
                margin: EdgeInsetsDirectional.only(bottom: 10.r, start: 10.r),
              ),
              drawToolbar: FlexiKlineDrawToolbar(
                controller: controller,
              ),
            ),
            FlexiKlineIndicatorBar(
              controller: controller,
            ),
            Container(
              height: 0.5.r,
              color: theme.dividerLine,
            ),
            // Container(
            //   height: 200.r,
            //   child: const CanvasDemo(),
            // ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final latest = controller.curKlineData.latest;
          DateTime? dateTime;
          if (latest != null) {
            dateTime = DateTime.fromMillisecondsSinceEpoch(latest.ts);
          }
          dateTime ??= DateTime.now();

          /// 随机生成[count] 个以 [dateTime]为基准的新数据
          final newList = await genRandomCandleList(
            count: 3,
            dateTime: dateTime,
            interval: controller.curKlineData.spec.interval,
            isHistory: false,
          );

          controller.logd('Add $dateTime, ${req.key}, ${newList.length}');
          controller.updateKlineData(req, newList);

          emitLatestMarketCandle();
        },
        child: const Text('Add'),
      ),
    );
  }
}
