import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// WebSocket 连接状态
enum WsConnectionState {
  disconnected, // 未连接
  connecting,   // 连接中
  connected,    // 已连接
  reconnecting, // 重连中
  error,        // 错误状态
}

/// WebSocket 消息类型
enum WsMessageType {
  text,   // 文本消息
  binary, // 二进制消息
  ping,   // Ping消息
  pong,   // Pong消息
}

/// WebSocket 消息
class WsMessage {
  final dynamic data;
  final WsMessageType type;
  final DateTime timestamp;

  WsMessage({
    required this.data,
    required this.type,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    return 'WsMessage{data: $data, type: $type, timestamp: $timestamp}';
  }
}

/// WebSocket 配置
class WsConfig {
  final String url;
  final Duration connectTimeout;
  final Duration pingInterval;
  final Duration pongTimeout;
  final int maxReconnectAttempts;
  final Duration reconnectDelay;
  final Map<String, String> headers;
  final List<String> protocols;

  const WsConfig({
    required this.url,
    this.connectTimeout = const Duration(seconds: 10),
    this.pingInterval = const Duration(seconds: 30),
    this.pongTimeout = const Duration(seconds: 10),
    this.maxReconnectAttempts = 5,
    this.reconnectDelay = const Duration(seconds: 3),
    this.headers = const {},
    this.protocols = const [],
  });

  WsConfig copyWith({
    String? url,
    Duration? connectTimeout,
    Duration? pingInterval,
    Duration? pongTimeout,
    int? maxReconnectAttempts,
    Duration? reconnectDelay,
    Map<String, String>? headers,
    List<String>? protocols,
  }) {
    return WsConfig(
      url: url ?? this.url,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      pingInterval: pingInterval ?? this.pingInterval,
      pongTimeout: pongTimeout ?? this.pongTimeout,
      maxReconnectAttempts: maxReconnectAttempts ?? this.maxReconnectAttempts,
      reconnectDelay: reconnectDelay ?? this.reconnectDelay,
      headers: headers ?? this.headers,
      protocols: protocols ?? this.protocols,
    );
  }
}

/// WebSocket 事件回调
typedef WsMessageCallback = void Function(WsMessage message);
typedef WsStateCallback = void Function(WsConnectionState state);
typedef WsErrorCallback = void Function(dynamic error, StackTrace? stackTrace);

/// WebSocket 客户端
class WsClient {
  WsClient({
    required this.config,
    this.onMessage,
    this.onStateChanged,
    this.onError,
  });

  final WsConfig config;
  final WsMessageCallback? onMessage;
  final WsStateCallback? onStateChanged;
  final WsErrorCallback? onError;

  WebSocketChannel? _channel;
  WsConnectionState _state = WsConnectionState.disconnected;
  Timer? _pingTimer;
  Timer? _pongTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _isManualClose = false;
  final StreamController<WsMessage> _messageController = StreamController<WsMessage>.broadcast();
  final StreamController<WsConnectionState> _stateController = StreamController<WsConnectionState>.broadcast();

  /// 当前连接状态
  WsConnectionState get state => _state;

  /// 是否已连接
  bool get isConnected => _state == WsConnectionState.connected;

  /// 消息流
  Stream<WsMessage> get messageStream => _messageController.stream;

  /// 状态流
  Stream<WsConnectionState> get stateStream => _stateController.stream;

  /// 连接WebSocket
  Future<void> connect() async {
    if (_state == WsConnectionState.connected || _state == WsConnectionState.connecting) {
      return;
    }

    _isManualClose = false;
    _updateState(WsConnectionState.connecting);

    try {
      _channel = WebSocketChannel.connect(
        Uri.parse(config.url),
        protocols: config.protocols.isNotEmpty ? config.protocols : null,
      );

      // 设置连接超时
      final connectTimer = Timer(config.connectTimeout, () {
        if (_state == WsConnectionState.connecting) {
          _handleError('连接超时', null);
        }
      });

      // 监听连接状态
      _channel!.stream.listen(
        (data) {
          connectTimer.cancel();
          _handleMessage(data);
        },
        onError: (error, stackTrace) {
          connectTimer.cancel();
          _handleError(error, stackTrace);
        },
        onDone: () {
          connectTimer.cancel();
          _handleDisconnect();
        },
      );

      _reconnectAttempts = 0;
      _startPingTimer();
      _updateState(WsConnectionState.connected);

    } catch (error, stackTrace) {
      _handleError(error, stackTrace);
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    _isManualClose = true;
    _stopPingTimer();
    _stopPongTimer();
    _stopReconnectTimer();
    
    await _channel?.sink.close();
    _channel = null;
    
    _updateState(WsConnectionState.disconnected);
  }

  /// 发送消息
  void send(dynamic data) {
    if (!isConnected) {
      throw StateError('WebSocket未连接');
    }

    try {
      if (data is String) {
        _channel!.sink.add(data);
      } else if (data is Map || data is List) {
        _channel!.sink.add(jsonEncode(data));
      } else {
        _channel!.sink.add(data.toString());
      }
    } catch (error, stackTrace) {
      _handleError(error, stackTrace);
    }
  }

  /// 发送JSON消息
  void sendJson(Map<String, dynamic> data) {
    send(jsonEncode(data));
  }

  /// 发送Ping消息
  void sendPing() {
    if (isConnected) {
      try {
        _channel!.sink.add('ping');
        _startPongTimer();
      } catch (error, stackTrace) {
        _handleError(error, stackTrace);
      }
    }
  }

  /// 更新连接状态
  void _updateState(WsConnectionState newState) {
    if (_state != newState) {
      _state = newState;
      _stateController.add(newState);
      onStateChanged?.call(newState);
      
      if (kDebugMode) {
        debugPrint('WsClient: 状态更新 -> $newState');
      }
    }
  }

  /// 处理接收到的消息
  void _handleMessage(dynamic data) {
    WsMessageType type = WsMessageType.text;
    dynamic processedData = data;
    
    try {
      if (data is List<int>) {
        // 尝试GZIP解压
        final decompressed = GZipCodec().decode(data as List<int>);
        final jsonStr = utf8.decode(decompressed);
        // 解析JSON
        processedData = jsonDecode(jsonStr);
        type = WsMessageType.text;
        
        if (kDebugMode) {
          debugPrint('WsClient: GZIP解压成功');
          debugPrint('WsClient: 解析后数据 -> $processedData');
        }
      } else if (data is String) {
        if (data == 'ping') {
          type = WsMessageType.ping;
          _sendPong();
          return;
        } else if (data == 'pong') {
          type = WsMessageType.pong;
          _stopPongTimer();
          return;
        } else {
          // 尝试解析JSON字符串
          try {
            processedData = jsonDecode(data);
            if (kDebugMode) {
              debugPrint('WsClient: 解析JSON成功 -> $processedData');
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('WsClient: JSON解析失败，使用原始数据');
            }
          }
        }
      }

      final message = WsMessage(data: processedData, type: type);
      _messageController.add(message);
      onMessage?.call(message);

      if (kDebugMode) {
        debugPrint('WsClient: 发送消息到业务层 -> ${message.type}');
      }
    } catch (e, stack) {
      debugPrint('WsClient: 消息处理错误 -> $e\n$stack');
      // 如果解压或解析失败，仍然发送原始数据
      final message = WsMessage(data: data, type: type);
      _messageController.add(message);
      onMessage?.call(message);
    }
  }

  /// 发送Pong响应
  void _sendPong() {
    if (isConnected) {
      try {
        _channel!.sink.add('pong');
      } catch (error, stackTrace) {
        _handleError(error, stackTrace);
      }
    }
  }

  /// 处理连接断开
  void _handleDisconnect() {
    _stopPingTimer();
    _stopPongTimer();
    
    if (!_isManualClose) {
      _updateState(WsConnectionState.disconnected);
      _scheduleReconnect();
    } else {
      _updateState(WsConnectionState.disconnected);
    }
  }

  /// 处理错误
  void _handleError(dynamic error, StackTrace? stackTrace) {
    _stopPingTimer();
    _stopPongTimer();
    
    _updateState(WsConnectionState.error);
    _stateController.addError(error, stackTrace);
    onError?.call(error, stackTrace);

    if (kDebugMode) {
      debugPrint('WsClient: 错误 -> $error');
      if (stackTrace != null) {
        debugPrint('WsClient: 堆栈 -> $stackTrace');
      }
    }

    if (!_isManualClose) {
      _scheduleReconnect();
    }
  }

  /// 启动Ping定时器
  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(config.pingInterval, (timer) {
      sendPing();
    });
  }

  /// 停止Ping定时器
  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  /// 启动Pong超时定时器
  void _startPongTimer() {
    _pongTimer?.cancel();
    _pongTimer = Timer(config.pongTimeout, () {
      _handleError('Pong超时', null);
    });
  }

  /// 停止Pong定时器
  void _stopPongTimer() {
    _pongTimer?.cancel();
    _pongTimer = null;
  }

  /// 安排重连
  void _scheduleReconnect() {
    if (_isManualClose || _reconnectAttempts >= config.maxReconnectAttempts) {
      return;
    }

    _reconnectAttempts++;
    _updateState(WsConnectionState.reconnecting);

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(config.reconnectDelay, () {
      if (kDebugMode) {
        debugPrint('WsClient: 尝试重连 (${_reconnectAttempts}/${config.maxReconnectAttempts})');
      }
      connect();
    });
  }

  /// 停止重连定时器
  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// 释放资源
  void dispose() {
    disconnect();
    _messageController.close();
    _stateController.close();
  }
}

/// WebSocket 注解类
/// 用于标记WebSocket配置，避免重复定义
class Ws {
  const Ws({
    this.config,
  });

  final WsConfig? config;
}

/// WebSocket 消息注解
class WsMessageAnnotation {
  const WsMessageAnnotation({
    this.type,
    this.topic,
  });

  final WsMessageType? type;
  final String? topic;
}

/// WebSocket 连接注解
class WsConnect {
  const WsConnect();
}

/// WebSocket 断开注解
class WsDisconnect {
  const WsDisconnect();
}

/// WebSocket 发送注解
class WsSend {
  const WsSend({
    this.topic,
    this.type = WsMessageType.text,
  });

  final String? topic;
  final WsMessageType type;
} 