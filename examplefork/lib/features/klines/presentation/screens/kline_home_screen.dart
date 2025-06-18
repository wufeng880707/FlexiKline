import 'package:example/core/network/ws/ws_export.dart';
import 'package:example/features/klines/data/data_sources/kline_data_source_impl.dart';
import 'package:flexi_kline/flexi_kline.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../theme/flexi_theme.dart';
import '../../update_controller.dart';
import '../widgets/kline_widget.dart';

class KlineHomeScreen extends ConsumerStatefulWidget {
  const KlineHomeScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _KlineHomeScreenState();
}

class _KlineHomeScreenState extends ConsumerState<KlineHomeScreen> {
  late final Size prevSize;
  UpdateController updateController = UpdateController();
  // TimeBar timeBar = TimeBar.s1;
  int lastTs = 0;
  late CandleReq req;

  // WebSocket相关
  KlineWsService? _wsService;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();

    req = CandleReq(instId: 'e_btcusdt', bar: TimeBar.H4.bar, precision: 2, limit: 300);

    // 初始化WebSocket服务
    _initWebSocket();
  }

  @override
  void dispose() {
    _unsubscribeKline();
    _wsService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }
}

extension _UI on _KlineHomeScreenState {
  /// 构建WebSocket状态图标
  Widget _buildWsStatusIcon(WsConnectionState state) {
    IconData iconData;
    Color iconColor;

    switch (state) {
      case WsConnectionState.connected:
        iconData = Icons.wifi;
        iconColor = Colors.green;
        break;
      case WsConnectionState.connecting:
      case WsConnectionState.reconnecting:
        iconData = Icons.wifi_find;
        iconColor = Colors.orange;
        break;
      case WsConnectionState.disconnected:
        iconData = Icons.wifi_off;
        iconColor = Colors.grey;
        break;
      case WsConnectionState.error:
        iconData = Icons.wifi_off;
        iconColor = Colors.red;
        break;
    }

    return Icon(iconData, color: iconColor, size: 20);
  }

  Widget _buildBody() {
    final theme = ref.watch(themeFKProvider);
    return Scaffold(
      backgroundColor: theme.pageBg,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            // mainNavScaffoldKey.currentState?.openDrawer();
          },
          child: const Icon(Icons.menu_outlined),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Offstage(
              offstage: req.displayName == null,
              child: Text(req.displayName ?? '', style: theme.t1s18w700),
            ),
            Text(req.instId, style: theme.t1s12w400),
          ],
        ),
        centerTitle: true,
        actions: [
          // WebSocket连接状态指示器
          Consumer(
            builder: (context, ref, child) {
              final connectionState = ref.watch(wsConnectionStateProvider);
              return connectionState.when(
                data: (state) => _buildWsStatusIcon(state),
                loading:
                    () => const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                error: (error, stack) => Icon(Icons.wifi_off, color: Colors.red, size: 20),
              );
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // mainNavScaffoldKey.currentState?.openDrawer();
            },
          ),
        ],
      ),
      body: SizedBox(
        height: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            children: [
              KLineWidget(
                ///是否允许全屏，允许的话，会显示一个按钮和双击图表变成全屏
                isCanFullScreen: true,
                supportTimBars: [
                  ///配置分时，
                  TimeBar.IntraDay,
                  TimeBar.m1,
                  TimeBar.s1,
                  TimeBar.m3,
                  TimeBar.m5,
                  TimeBar.m15,
                  TimeBar.m30,
                  TimeBar.H1,
                  TimeBar.H4,
                  TimeBar.D1,
                  TimeBar.M1,
                ],
                updateController: updateController,
                // onTimeBarChange: (TimeBar newT) {
                //   // req.bar = newT.bar;
                //   // timeBar = newT;
                //   // 时间周期改变时，重新订阅
                //   _resubscribeKline();
                // },
                isShowMarketTooltipCustomView: true,
                getCandleList: (CandleReq req1) async {
                  ///根据周期返回k线图数据（初始化使用）
                  req = req1;
                  final list = await loadKlineDataList(req);
                  lastTs = list.last.ts;
                  // 数据加载完成后，自动订阅实时数据
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _resubscribeKline();
                  });

                  return list;
                },
                getMoreCandleList: (CandleReq req) async {
                  ///根据周期返回k线图数据（初始化使用）
                  final list = await loadMoreKlineDataList(req);
                  lastTs = list.last.ts;
                  return list;
                },

                // marketTicker: MarketTicker(),
                initReq: req,
                autoCacheConfig: true,
                settingChangeCallBack: (SettingConfig setting) {
                  ///这里可以读到红涨绿跌，绿涨红跌配置，方便在自己的app中统一其他颜色
                  if (kDebugMode) {
                    print("样式改变了:${setting.longRed}");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension _Action on _KlineHomeScreenState {
  /// 初始化WebSocket服务
  Future<void> _initWebSocket() async {
    try {
      // 使用自定义Provider，传入回调函数
      _wsService = ref.read(klineWsServiceWithCallbackProvider(_handleKlineData));

      // 连接WebSocket
      await _wsService!.connect();

      if (kDebugMode) {
        print('WebSocket连接成功');
      }
    } catch (error) {
      if (kDebugMode) {
        print('WebSocket连接失败: $error');
      }
    }
  }

  /// 订阅K线数据
  Future<void> _subscribeKline() async {
    if (_wsService == null || _isSubscribed) return;

    try {
      final symbol = req.instId;
      final interval = req.bar;

      _wsService!.subscribeKline(symbol, interval);
      _isSubscribed = true;

      if (kDebugMode) {
        print('订阅K线数据: $symbol, $interval');
      }
    } catch (error) {
      if (kDebugMode) {
        print('订阅K线数据失败: $error');
      }
    }
  }

  /// 取消订阅K线数据
  Future<void> _unsubscribeKline() async {
    if (_wsService == null || !_isSubscribed) return;

    try {
      final symbol = req.instId;
      final interval = req.bar;

      _wsService!.unsubscribeKline(symbol, interval);
      _isSubscribed = false;

      if (kDebugMode) {
        print('取消订阅K线数据: $symbol, $interval');
      }
    } catch (error) {
      if (kDebugMode) {
        print('取消订阅K线数据失败: $error');
      }
    }
  }

  /// 处理WebSocket接收到的K线数据
  void _handleKlineData(Map<String, dynamic> data) {
    debugPrint('收到K线数据222: $data');
    try {
      if (data['tick'] != null) {
        final klineData = data['tick'] as Map<String, dynamic>;
        final candleModel = CandleModel.fromMarketData(klineData);

        if (candleModel != null) {
          // 更新K线图表 - 使用controller的updateKlineData方法
          if (updateController != null) {
            updateController.updateData([candleModel]);
          }
          if (kDebugMode) {
            print('收到实时K线数据: ${candleModel.toJson()}');
          }
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('处理K线数据失败: $error');
      }
    }
  }

  /// 处理WebSocket错误
  void _handleWsError(dynamic error) {
    if (kDebugMode) {
      print('WebSocket错误: $error');
    }
  }

  Future<List<CandleModel>> loadKlineDataList(CandleReq req) async {
    final result = await ref.read(klineDataSourceProvider).publicMarketKlineRequest({
      'symbol': req.instId,
      'scaleType': req.bar,
    });

    if (result.data['data'] != null) {
      final List<dynamic> klineDataList = result.data['data'] as List<dynamic>;

      return klineDataList
          .map((item) => CandleModel.fromMarketData(item as Map<String, dynamic>))
          .where((model) => model != null)
          .cast<CandleModel>()
          .toList()
          .reversed
          .toList();
    }
    return [];
  }

  Future<List<CandleModel>> loadMoreKlineDataList(CandleReq req) async {
    final result = await ref.read(klineDataSourceProvider).publicMarketKlineRequest({
      'symbol': req.instId,
      'scaleType': req.bar,
      'endIdx': lastTs / 1000,
    });

    if (result.data['data'] != null) {
      final List<dynamic> klineDataList = result.data['data'] as List<dynamic>;

      return klineDataList
          .map((item) => CandleModel.fromMarketData(item as Map<String, dynamic>))
          .where((model) => model != null)
          .cast<CandleModel>()
          .toList()
          .reversed
          .toList();
    }
    return [];
  }

  /// 重新订阅K线数据
  Future<void> _resubscribeKline() async {
    await _unsubscribeKline();
    await _subscribeKline();
  }
}

/// 自定义K线WebSocket服务Provider
final klineWsServiceWithCallbackProvider =
    Provider.family<KlineWsService, Function(Map<String, dynamic>)?>((ref, onKlineData) {
      final logger = Logger();

      return KlineWsService(
        logger: logger,
        onKlineData: onKlineData,
        onError: (error) {
          logger.e('WebSocket错误: $error');
        },
      );
    });
