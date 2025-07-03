import 'ws_client.dart';

/// WebSocket注解辅助类
/// 用于处理@Ws注解的配置，避免重复定义
class WsAnnotationHelper {
  /// 从注解中获取配置
  /// 在实际项目中，这可以通过代码生成或反射来实现
  static WsConfig? getConfigFromAnnotation(Ws annotation) {
    return annotation.config;
  }

  /// 创建默认配置
  static WsConfig createDefaultConfig(String url) {
    return WsConfig(
      url: url,
      connectTimeout: const Duration(seconds: 10),
      pingInterval: const Duration(seconds: 30),
      pongTimeout: const Duration(seconds: 10),
      maxReconnectAttempts: 5,
      reconnectDelay: const Duration(seconds: 3),
    );
  }
}

/// 预定义WebSocket配置
class WsConfigs {
  // K线数据WebSocket配置
  static const klineConfig = WsConfig(
    url: 'wss://ws.aivora.com/futures/ws?compress=0',
    connectTimeout: Duration(seconds: 10),
    pingInterval: Duration(seconds: 30),
    pongTimeout: Duration(seconds: 10),
    maxReconnectAttempts: 5,
    reconnectDelay: Duration(seconds: 3),
  );

  // 交易数据WebSocket配置
  static const tradeConfig = WsConfig(
    url: 'wss://ws.aivora.com/futures/ws?compress=0',
    connectTimeout: Duration(seconds: 10),
    pingInterval: Duration(seconds: 30),
    pongTimeout: Duration(seconds: 10),
    maxReconnectAttempts: 5,
    reconnectDelay: Duration(seconds: 3),
  );

  // 深度数据WebSocket配置
  static const depthConfig = WsConfig(
    url: 'wss://futuresws.aivora.com/depth-api/ws',
    connectTimeout: Duration(seconds: 10),
    pingInterval: Duration(seconds: 30),
    pongTimeout: Duration(seconds: 10),
    maxReconnectAttempts: 5,
    reconnectDelay: Duration(seconds: 3),
  );
}
