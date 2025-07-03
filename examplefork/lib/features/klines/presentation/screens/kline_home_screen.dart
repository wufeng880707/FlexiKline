import 'package:decimal/decimal.dart';
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

    req = CandleReq(
      instId: 'e_btcusdt',
      timeBar: const TimeBarConfig(
        key: '4H',
        bar: '4h',
        milliseconds: Duration.millisecondsPerHour * 4,
        multiplier: 4,
        timespan: Timespan.hour,
        showName: '4H',
        sortOrder: 8,
      ),
      precision: 2,
      limit: 100,
    );

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
                    print("样式改变了:${setting.longColor}");
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
      final interval = req.timeBar.bar;

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
      final interval = req.timeBar.bar;

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
        final tickData = data['tick'];

        if (tickData is List<dynamic>) {
          // 如果是数组，取最后一个元素（最新的K线数据）
          if (tickData.isNotEmpty) {
            final candleModel = _convertToCandleModel(tickData.last as Map<String, dynamic>);
            if (candleModel != null) {
              _updateKlineChart(candleModel);
            }
          }
        } else if (tickData is Map<String, dynamic>) {
          // 如果是单个对象
          final candleModel = _convertToCandleModel(tickData);
          if (candleModel != null) {
            _updateKlineChart(candleModel);
          }
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('处理K线数据失败: $error');
      }
    }
  }

  /// 更新K线图表
  void _updateKlineChart(CandleModel candleModel) {
    if (updateController != null) {
      updateController.updateData([candleModel]);
    }
    if (kDebugMode) {
      print('收到实时K线数据: ${candleModel.toJson()}');
    }
  }

  /// 处理WebSocket错误
  void _handleWsError(dynamic error) {
    if (kDebugMode) {
      print('WebSocket错误: $error');
    }
  }

  /// 转换市场数据为CandleModel
  CandleModel? _convertToCandleModel(Map<String, dynamic> data) {
    try {
      // 安全地获取并转换数值
      final t = (_safeGetInt(data, 'id') ?? 0) * 1000;
      // 处理价格数据 - 支持多种字段名，安全转换
      final o = _safeGetNum(data, 'o') ?? _safeGetNum(data, 'open');
      final h = _safeGetNum(data, 'h') ?? _safeGetNum(data, 'high');
      final l = _safeGetNum(data, 'l') ?? _safeGetNum(data, 'low');
      final c = _safeGetNum(data, 'c') ?? _safeGetNum(data, 'close');

      // 处理成交量数据 - 支持多种字段名
      final v = _safeGetNum(data, 'v') ?? _safeGetNum(data, 'volume') ?? _safeGetNum(data, 'vol');

      // 处理成交额数据 - 支持多种字段名
      final amount = _safeGetNum(data, 'amount') ?? _safeGetNum(data, 'vc');

      // 处理成交笔数数据
      final piece = _safeGetNum(data, 'piece') ?? _safeGetNum(data, 'vcq');

      if (t == null || o == null || h == null || l == null || c == null || v == null) {
        debugPrint('转换CandleModel失败: 缺少必要字段 t=$t, o=$o, h=$h, l=$l, c=$c, v=$v');
        debugPrint('原始数据: $data');
        return null;
      }

      return CandleModel(
        ts: t,
        o: Decimal.parse(o.toString()),
        h: Decimal.parse(h.toString()),
        l: Decimal.parse(l.toString()),
        c: Decimal.parse(c.toString()),
        v: Decimal.parse(v.toString()),
        vc: amount != null ? Decimal.parse(amount.toString()) : null,
        vcq: piece != null ? Decimal.parse(piece.toString()) : null,
        confirm: data['confirm']?.toString() ?? '1',
      );
    } catch (e) {
      debugPrint('转换CandleModel失败: $e');
      debugPrint('原始数据: $data');
      return null;
    }
  }

  /// 安全地获取数值，支持字符串和数字类型
  num? _safeGetNum(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return null;

    if (value is num) {
      return value;
    } else if (value is String) {
      try {
        return num.parse(value);
      } catch (e) {
        debugPrint('无法解析数值 $key: $value');
        return null;
      }
    }
    return null;
  }

  /// 安全地获取整数
  int? _safeGetInt(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return null;

    if (value is int) {
      return value;
    } else if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        debugPrint('无法解析整数 $key: $value');
        return null;
      }
    }
    return null;
  }

  Future<List<CandleModel>> loadKlineDataList(CandleReq req) async {
    final result = await ref.read(klineDataSourceProvider).publicMarketKlineRequest({
      'symbol': req.instId,
      'scaleType': req.timeBar.bar,
      'limit': req.limit,
    });

    if (result.data['data'] != null) {
      final List<dynamic> klineDataList = result.data['data'] as List<dynamic>;

      return klineDataList
          .map((item) => _convertToCandleModel(item as Map<String, dynamic>))
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
      'scaleType': req.timeBar.bar,
      'limit': req.limit,
      'endIdx': lastTs / 1000,
    });

    if (result.data['data'] != null) {
      final List<dynamic> klineDataList = result.data['data'] as List<dynamic>;

      return klineDataList
          .map((item) => _convertToCandleModel(item as Map<String, dynamic>))
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
