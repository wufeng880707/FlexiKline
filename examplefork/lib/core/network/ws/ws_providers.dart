import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'ws_client.dart';
import 'ws_service.dart';
import 'ws_simple_service.dart';

/// WebSocket服务Provider
final klineWsServiceProvider = Provider<KlineWsService>((ref) {
  final logger = Logger();

  return KlineWsService(
    logger: logger,
    onKlineData: (data) {
      // 处理K线数据
      logger.i('收到K线数据: $data');
    },
    onError: (error) {
      logger.e('WebSocket错误: $error');
    },
  );
});

/// 简化版WebSocket服务Provider
final simpleKlineWsServiceProvider = Provider<SimpleKlineWsService>((ref) {
  final logger = Logger();
  
  return SimpleKlineWsService(
    logger: logger,
    onKlineData: (data) {
      logger.i('收到K线数据: $data');
    },
    onError: (error) {
      logger.e('WebSocket错误: $error');
    },
  );
});

/// WebSocket连接状态Provider
final wsConnectionStateProvider = StreamProvider<WsConnectionState>((ref) {
  final wsService = ref.watch(klineWsServiceProvider);
  return wsService.client?.stateStream ?? Stream.value(WsConnectionState.disconnected);
});

/// WebSocket消息Provider
final wsMessageProvider = StreamProvider<WsMessage>((ref) {
  final wsService = ref.watch(klineWsServiceProvider);
  return wsService.client?.messageStream ?? Stream.empty();
});

/// 简化版WebSocket连接状态Provider
final simpleWsConnectionStateProvider = StreamProvider<WsConnectionState>((ref) {
  final wsService = ref.watch(simpleKlineWsServiceProvider);
  return wsService.client?.stateStream ?? Stream.value(WsConnectionState.disconnected);
});

/// 简化版WebSocket消息Provider
final simpleWsMessageProvider = StreamProvider<WsMessage>((ref) {
  final wsService = ref.watch(simpleKlineWsServiceProvider);
  return wsService.client?.messageStream ?? Stream.empty();
}); 