# WebSocket 封装使用指南

这个WebSocket封装提供了基于 `web_socket_channel` 的完整解决方案，支持 `@ws` 注解风格的使用方式。

## 特性

- ✅ 自动重连机制
- ✅ Ping/Pong 心跳检测
- ✅ 连接状态管理
- ✅ 错误处理
- ✅ 注解风格API
- ✅ Riverpod集成
- ✅ 类型安全
- ✅ 避免配置重复

## 快速开始

### 1. 基本使用

```dart
import 'package:example/core/network/ws/ws_export.dart';

// 创建WebSocket客户端
final wsClient = WsClient(
  config: const WsConfig(
    url: 'wss://your-websocket-server.com',
    connectTimeout: Duration(seconds: 10),
    pingInterval: Duration(seconds: 30),
  ),
  onMessage: (message) {
    print('收到消息: ${message.data}');
  },
  onStateChanged: (state) {
    print('连接状态: $state');
  },
  onError: (error, stackTrace) {
    print('错误: $error');
  },
);

// 连接
await wsClient.connect();

// 发送消息
wsClient.sendJson({'type': 'subscribe', 'channel': 'kline'});

// 断开连接
await wsClient.disconnect();
```

### 2. 使用注解风格

#### ✅ 推荐方式：直接使用预定义配置

```dart
class MyWsService {
  WsClient? _client;
  WsConfig? _config;

  /// 初始化配置 - 直接使用预定义配置
  void initConfig() {
    _config = WsConfigs.klineConfig;
  }

  /// 连接
  Future<void> connect() async {
    if (_config == null) initConfig();
    _client = WsClient(config: _config!);
    await _client!.connect();
  }

  /// 发送消息
  void subscribe(String channel) {
    _client?.sendJson({'op': 'subscribe', 'args': [channel]});
  }

  /// 处理消息
  void handleMessage(WsMessage message) {
    print('处理消息: ${message.data}');
  }
}
```

#### ✅ 可选方式：注解用于文档说明

```dart
class MyWsService {
  static const WsConfig _wsConfig = WsConfig(
    url: 'wss://your-server.com',
    connectTimeout: Duration(seconds: 10),
    pingInterval: Duration(seconds: 30),
  );
  
  /// 注解仅用于文档说明，代码中直接使用配置
  @Ws(config: _wsConfig)
  void initConfig() {
    _config = _wsConfig; // 使用同一个常量
  }
}
```

#### ✅ 最简洁方式：直接使用预定义配置

```dart
class SimpleKlineWsService {
  WsClient? _client;

  /// 连接WebSocket - 无需注解，直接使用预定义配置
  Future<void> connect() async {
    _client = WsClient(
      config: WsConfigs.klineConfig, // 直接使用预定义配置
      onMessage: _handleMessage,
      onStateChanged: _handleStateChanged,
      onError: _handleError,
    );

    await _client!.connect();
  }
}
```

#### ❌ 不推荐：无意义的重复

```dart
class MyWsService {
  @Ws(config: WsConfigs.klineConfig)
  void initConfig() {
    _config = WsConfigs.klineConfig; // 重复！无意义
  }
}
```

### 3. 与Riverpod集成

```dart
// 创建Provider
final wsServiceProvider = Provider<MyWsService>((ref) {
  return MyWsService();
});

// 在Widget中使用
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wsService = ref.watch(wsServiceProvider);
    
    return ElevatedButton(
      onPressed: () => wsService.connect(),
      child: Text('连接WebSocket'),
    );
  }
}
```

## 预定义配置

我们提供了预定义的WebSocket配置，避免重复定义：

```dart
// K线数据配置
final klineConfig = WsConfigs.klineConfig;

// 交易数据配置  
final tradeConfig = WsConfigs.tradeConfig;

// 深度数据配置
final depthConfig = WsConfigs.depthConfig;
```

## API 参考

### WsConfig

WebSocket配置类：

```dart
const WsConfig({
  required String url,                    // WebSocket URL
  Duration connectTimeout = 10s,         // 连接超时
  Duration pingInterval = 30s,           // Ping间隔
  Duration pongTimeout = 10s,            // Pong超时
  int maxReconnectAttempts = 5,          // 最大重连次数
  Duration reconnectDelay = 3s,          // 重连延迟
  Map<String, String> headers = {},      // 请求头
  List<String> protocols = [],           // 协议列表
});
```

### WsClient

WebSocket客户端类：

```dart
class WsClient {
  // 属性
  WsConnectionState get state;           // 当前状态
  bool get isConnected;                  // 是否已连接
  Stream<WsMessage> get messageStream;   // 消息流
  Stream<WsConnectionState> get stateStream; // 状态流

  // 方法
  Future<void> connect();                // 连接
  Future<void> disconnect();             // 断开
  void send(dynamic data);               // 发送消息
  void sendJson(Map<String, dynamic> data); // 发送JSON
  void sendPing();                       // 发送Ping
  void dispose();                        // 释放资源
}
```

### 注解

- `@Ws()` - WebSocket配置注解（用于文档说明或代码生成）
- `@WsConnect()` - 连接方法注解
- `@WsDisconnect()` - 断开方法注解
- `@WsSend()` - 发送消息方法注解
- `@WsMessageAnnotation()` - 消息处理方法注解

## 连接状态

- `WsConnectionState.disconnected` - 未连接
- `WsConnectionState.connecting` - 连接中
- `WsConnectionState.connected` - 已连接
- `WsConnectionState.reconnecting` - 重连中
- `WsConnectionState.error` - 错误状态

## 消息类型

- `WsMessageType.text` - 文本消息
- `WsMessageType.binary` - 二进制消息
- `WsMessageType.ping` - Ping消息
- `WsMessageType.pong` - Pong消息

## 最佳实践

### 1. 避免无意义的重复

✅ **推荐**：直接使用预定义配置
```dart
// 方式1：直接使用
_config = WsConfigs.klineConfig;

// 方式2：常量
static const WsConfig _wsConfig = WsConfig(url: 'wss://your-server.com');
void initConfig() {
  _config = _wsConfig;
}

// 方式3：最简洁
_client = WsClient(config: WsConfigs.klineConfig);
```

❌ **不推荐**：无意义的重复
```dart
@Ws(config: WsConfigs.klineConfig)
void initConfig() {
  _config = WsConfigs.klineConfig; // 重复！无意义
}
```

### 2. 注解的正确用途

注解应该用于以下场景：

#### ✅ 文档说明
```dart
@Ws(config: WsConfigs.klineConfig)
void initConfig() {
  _config = WsConfigs.klineConfig; // 注解仅用于文档
}
```

#### ✅ 代码生成
```dart
@Ws(config: WsConfigs.klineConfig)
void initConfig() {
  // 代码生成器会自动生成配置赋值
}
```

#### ✅ 运行时验证
```dart
@Ws(config: WsConfigs.klineConfig)
void initConfig() {
  final annotation = _getAnnotation();
  _config = annotation?.config ?? WsConfigs.klineConfig;
}
```

### 3. 错误处理

```dart
wsClient.onError = (error, stackTrace) {
  logger.e('WebSocket错误', error: error, stackTrace: stackTrace);
  // 处理错误逻辑
};
```

## 示例项目

查看 `ws_example_widget.dart`、`ws_usage_example.dart`、`ws_simple_service.dart` 和 `ws_meaningful_example.dart` 文件获取完整的使用示例。

## 注意事项

1. 确保在 `pubspec.yaml` 中添加了 `web_socket_channel` 依赖
2. 记得在不需要时调用 `dispose()` 方法释放资源
3. 处理网络错误和重连逻辑
4. 使用预定义配置或常量避免重复定义
5. 根据实际需求调整配置参数
6. **避免无意义的注解重复，注解应该有实际用途** 