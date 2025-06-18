import 'ws_annotation_helper.dart';
import 'ws_client.dart';

/// WebSocket注解使用示例
/// 展示如何避免URL和配置的重复定义
class WsUsageExample {
  
  /// 方式1: 使用预定义配置（推荐）
  /// 优点：完全避免重复，配置集中管理
  @Ws(config: WsConfigs.klineConfig)
  void initKlineConfig() {
    // 直接使用预定义配置，注解中的配置仅用于文档说明
    final config = WsConfigs.klineConfig;
    print('使用预定义配置: ${config.url}');
  }

  /// 方式2: 使用注解辅助类
  /// 优点：注解真正发挥作用，配置从注解中获取
  void initTradeConfig() {
    // 通过辅助类从注解中获取配置
    final annotation = Ws(
      config: WsConfig(
        url: 'wss://futuresws.aivora.com/trade-api/ws',
        connectTimeout: Duration(seconds: 5),
        pingInterval: Duration(seconds: 15),
      ),
    );
    
    final config = WsAnnotationHelper.getConfigFromAnnotation(annotation);
    print('从注解获取配置: ${config?.url}');
  }

  /// 方式3: 使用常量避免重复（当前实现）
  /// 优点：简单直接，易于理解
  static const WsConfig _depthConfig = WsConfig(
    url: 'wss://futuresws.aivora.com/depth-api/ws',
    connectTimeout: Duration(seconds: 10),
    pingInterval: Duration(seconds: 30),
  );
  
  @Ws(config: _depthConfig)
  void initDepthConfig() {
    // 使用常量，注解和代码保持一致
    final config = _depthConfig;
    print('使用常量配置: ${config.url}');
  }
}

/// 最佳实践示例
class WsBestPractices {
  
  /// ✅ 推荐：使用预定义配置
  void recommendedApproach() {
    // 1. 在 WsConfigs 中定义所有配置
    // 2. 注解仅用于文档说明
    // 3. 代码中使用预定义配置
    final config = WsConfigs.klineConfig;
  }
  
  /// ❌ 不推荐：重复定义
  void notRecommended() {
    // 注解和代码中都定义了配置，容易出错
    const WsConfig wsConfig = WsConfig(
      url: 'wss://example.com/ws',
      connectTimeout: Duration(seconds: 10),
    );
    
    @Ws(config: wsConfig)
    void initConfig() {
      final config = WsConfig(
        url: 'wss://example.com/ws', // 重复定义！
        connectTimeout: Duration(seconds: 10),
      );
    }
  }
  
  /// ✅ 推荐：使用常量
  void recommendedWithConstants() {
    const WsConfig wsConfig = WsConfig(
      url: 'wss://example.com/ws',
      connectTimeout: Duration(seconds: 10),
    );
    
    @Ws(config: wsConfig)
    void initConfig() {
      final config = wsConfig; // 使用同一个常量
    }
  }
} 