import 'dart:convert';

import 'package:logger/logger.dart';

import 'ws_annotation_helper.dart';
import 'ws_client.dart';

/// 简化版K线WebSocket服务
/// 展示最简洁的使用方式，完全避免重复
class SimpleKlineWsService {
  SimpleKlineWsService({
    required this.logger,
    this.onKlineData,
    this.onError,
  });

  final Logger logger;
  final Function(Map<String, dynamic>)? onKlineData;
  final Function(dynamic error)? onError;

  WsClient? _client;

  /// 获取WebSocket客户端
  WsClient? get client => _client;

  /// 连接WebSocket
  Future<void> connect() async {
    // 直接使用预定义配置，无需注解
    _client = WsClient(
      config: WsConfigs.klineConfig,
      onMessage: _handleMessage,
      onStateChanged: _handleStateChanged,
      onError: _handleError,
    );

    await _client!.connect();
  }

  /// 断开连接
  Future<void> disconnect() async {
    await _client?.disconnect();
  }

  /// 订阅K线数据
  void subscribeKline(String symbol, String interval) {
    final message = {
      'event': 'sub',
      'params': {
        'channel': 'market_${symbol}_kline_$interval',
      }
    };

    _client?.sendJson(message);
  }

  /// 取消订阅K线数据
  void unsubscribeKline(String symbol, String interval) {
    final message = {
      'event': 'unsub',
      'params': {
        'channel': 'market_${symbol}_kline_$interval',
      }
    };

    _client?.sendJson(message);
  }

  /// 处理接收到的消息
  void _handleMessage(WsMessage message) {
    try {
      if (message.type == WsMessageType.text) {
        final data = jsonDecode(message.data as String);
        
        if (data['event'] == 'sub') {
          logger.i('订阅成功: ${data['params']}');
        } else if (data['event'] == 'unsub') {
          logger.i('取消订阅成功: ${data['params']}');
        } else if (data['data'] != null) {
          // 处理K线数据
          onKlineData?.call(data);
        }
      }
    } catch (error, stackTrace) {
      logger.e('处理消息失败', error: error, stackTrace: stackTrace);
      onError?.call(error);
    }
  }

  /// 处理连接状态变化
  void _handleStateChanged(WsConnectionState state) {
    logger.i('WebSocket状态变化: $state');
  }

  /// 处理错误
  void _handleError(dynamic error, StackTrace? stackTrace) {
    logger.e('WebSocket错误', error: error, stackTrace: stackTrace);
    onError?.call(error);
  }

  void dispose() {
    _client?.dispose();
    _client = null;
  }
} 