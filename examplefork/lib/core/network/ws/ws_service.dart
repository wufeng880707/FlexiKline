import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import 'ws_annotation_helper.dart';
import 'ws_client.dart';

/// WebSocket 服务基类
abstract class WsService {
  WsClient? get client;
  void dispose();
}

/// K线数据WebSocket服务
class KlineWsService implements WsService {
  KlineWsService({required this.logger, this.onKlineData, this.onError}) {
    logger.i('KlineWsService创建，onKlineData: $onKlineData');
  }

  final Logger logger;
  final Function(Map<String, dynamic>)? onKlineData;
  final Function(dynamic error)? onError;

  WsClient? _client;
  WsConfig? _config;

  @override
  WsClient? get client => _client;

  /// 初始化WebSocket配置
  /// 直接使用预定义配置，简洁明了
  void initConfig() {
    _config = WsConfigs.klineConfig;
  }

  /// 连接WebSocket
  @WsConnect()
  Future<void> connect() async {
    if (_config == null) {
      initConfig();
    }

    _client = WsClient(
      config: _config!,
      onMessage: _handleMessage,
      onStateChanged: _handleStateChanged,
      onError: _handleError,
    );

    await _client!.connect();
  }

  /// 断开连接
  @WsDisconnect()
  Future<void> disconnect() async {
    await _client?.disconnect();
  }

  /// 订阅K线数据
  @WsSend(topic: 'subscribe', type: WsMessageType.text)
  void subscribeKline(String symbol, String interval) {
    final message = {
      'event': 'sub',
      'params': {'channel': 'market_${symbol}_kline_$interval'},
    };
    debugPrint('WsClient: 订阅 -> $message');
    _client?.sendJson(message);
  }

  /// 取消订阅K线数据
  @WsSend(topic: 'unsubscribe', type: WsMessageType.text)
  void unsubscribeKline(String symbol, String interval) {
    final message = {
      'event': 'unsub',
      'params': {'channel': 'market_${symbol}_kline_$interval'},
    };

    _client?.sendJson(message);
  }

  /// 处理接收到的消息
  @WsMessageAnnotation(type: WsMessageType.text)
  void _handleMessage(WsMessage message) {
    try {
      if (message.type == WsMessageType.text) {
        if (kDebugMode) {
          debugPrint('WsService: 收到消息数据 -> ${message.data}');
        }

        final data = message.data;
        if (data is Map<String, dynamic>) {
          logger.i('准备回调onKlineData: $onKlineData');
          if (onKlineData != null) {
            _handleKlineData(data);
          }

          logger.i('onKlineData回调完成');
        } else if (data is String) {
          // 尝试解析JSON字符串
          try {
            final jsonData = jsonDecode(data);
            if (jsonData is Map<String, dynamic>) {
              logger.i('准备回调onKlineData: $onKlineData');
              _handleKlineData(jsonData);
              logger.i('onKlineData回调完成');
            }
          } catch (e) {
            logger.e('JSON解析失败', error: e);
          }
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

    switch (state) {
      case WsConnectionState.connected:
        logger.i('WebSocket连接成功');
        break;
      case WsConnectionState.disconnected:
        logger.w('WebSocket连接断开');
        break;
      case WsConnectionState.connecting:
        logger.i('WebSocket连接中...');
        break;
      case WsConnectionState.reconnecting:
        logger.w('WebSocket重连中...');
        break;
      case WsConnectionState.error:
        logger.e('WebSocket连接错误');
        break;
    }
  }

  /// 处理错误
  void _handleError(dynamic error, StackTrace? stackTrace) {
    logger.e('WebSocket错误', error: error, stackTrace: stackTrace);
    onError?.call(error);
  }

  void _handleKlineData(Map<String, dynamic> data) {
    try {
      print('收到K线数据11: $data');
      if (onKlineData != null) {
        onKlineData?.call(data);
      }
    } catch (e, s) {
      print('K线回调异常: $e\n$s');
      onError?.call(e);
    }
  }

  @override
  void dispose() {
    _client?.dispose();
    _client = null;
  }
}
