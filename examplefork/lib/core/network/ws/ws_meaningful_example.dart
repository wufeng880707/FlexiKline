import 'ws_annotation_helper.dart';
import 'ws_client.dart';

/// 展示注解真正意义的示例
/// 注解应该用于代码生成、文档说明或运行时检查
class WsMeaningfulExample {
  
  /// 方式1: 注解用于代码生成（理想情况）
  /// 在实际项目中，可以通过代码生成器自动生成配置
  @Ws(config: WsConfigs.klineConfig)
  void initConfig() {
    // 代码生成器会自动生成这行代码
    // _config = WsConfigs.klineConfig;
    
    // 或者通过反射获取注解中的配置
    final annotation = _getAnnotation();
    _config = annotation?.config ?? WsConfigs.klineConfig;
  }
  
  /// 方式2: 注解用于文档说明
  /// 注解作为配置的文档，代码中直接使用
  @Ws(config: WsConfigs.klineConfig)
  void initConfigWithDoc() {
    // 直接使用配置，注解仅用于文档说明
    _config = WsConfigs.klineConfig;
  }
  
  /// 方式3: 注解用于运行时验证
  /// 注解用于验证配置的正确性
  @Ws(config: WsConfigs.klineConfig)
  void initConfigWithValidation() {
    final annotation = _getAnnotation();
    if (annotation?.config != null) {
      // 验证配置
      _validateConfig(annotation!.config!);
      _config = annotation.config!;
    } else {
      _config = WsConfigs.klineConfig;
    }
  }
  
  /// 方式4: 最简洁方式（推荐）
  /// 不使用注解，直接使用预定义配置
  void initConfigSimple() {
    _config = WsConfigs.klineConfig;
  }
  
  // 模拟获取注解的方法
  Ws? _getAnnotation() {
    // 在实际项目中，这可以通过反射实现
    return null;
  }
  
  // 验证配置
  void _validateConfig(WsConfig config) {
    if (config.url.isEmpty) {
      throw ArgumentError('WebSocket URL不能为空');
    }
    // 其他验证逻辑...
  }
  
  WsConfig? _config;
}

/// 实际使用建议
class WsUsageRecommendation {
  
  /// ✅ 推荐：直接使用预定义配置
  /// 优点：简洁、清晰、无重复
  void recommended() {
    final config = WsConfigs.klineConfig;
    // 直接使用，无需注解
  }
  
  /// ✅ 可选：注解用于文档
  /// 优点：提供配置的文档说明
  @Ws(config: WsConfigs.klineConfig)
  void withDocumentation() {
    final config = WsConfigs.klineConfig;
    // 注解仅用于文档说明
  }
  
  /// ❌ 不推荐：注解和代码重复
  /// 缺点：无意义、容易出错
  @Ws(config: WsConfigs.klineConfig)
  void notRecommended() {
    final config = WsConfigs.klineConfig; // 重复！
  }
} 