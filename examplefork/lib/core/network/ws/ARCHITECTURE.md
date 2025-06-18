# WebSocket 封装架构设计

## 📁 文件组织结构

```
examplefork/lib/core/network/ws/
├── ws_client.dart              # 核心客户端 - 基础功能
├── ws_service.dart             # 业务服务 - K线数据处理
├── ws_simple_service.dart      # 简化服务 - 最简洁使用方式
├── ws_providers.dart           # 依赖注入 - Provider定义
├── ws_annotation_helper.dart   # 配置管理 - 预定义配置
├── ws_usage_example.dart       # 使用示例 - 各种使用方式
├── ws_meaningful_example.dart  # 注解示例 - 注解的真正用途
├── ws_example_widget.dart      # UI示例 - Widget使用示例
├── ws_export.dart              # 统一导出 - 方便导入
└── README.md                   # 使用文档 - 详细说明
```

## 🏗️ 架构原则

### 1. **单一职责原则 (SRP)**
每个文件只负责一个特定的功能：

- **`ws_client.dart`** - 只负责WebSocket连接、消息处理、重连等基础功能
- **`ws_service.dart`** - 只负责K线数据的业务逻辑处理
- **`ws_providers.dart`** - 只负责依赖注入和Provider定义
- **`ws_annotation_helper.dart`** - 只负责配置管理和预定义配置

### 2. **依赖倒置原则 (DIP)**
- 高层模块（服务）不依赖低层模块（客户端）的具体实现
- 通过抽象接口进行依赖

### 3. **开闭原则 (OCP)**
- 对扩展开放，对修改封闭
- 可以通过继承或组合扩展功能，而不修改现有代码

## 🔄 依赖关系

```
UI层 (Widgets)
    ↓
Provider层 (ws_providers.dart)
    ↓
服务层 (ws_service.dart / ws_simple_service.dart)
    ↓
客户端层 (ws_client.dart)
    ↓
网络层 (web_socket_channel)
```

## 📋 各层职责

### 1. **UI层**
- 显示WebSocket状态
- 处理用户交互
- 展示数据

### 2. **Provider层** (`ws_providers.dart`)
- 定义依赖注入
- 管理服务实例
- 提供状态流

### 3. **服务层**
- **`ws_service.dart`** - 完整功能服务
- **`ws_simple_service.dart`** - 简化服务

### 4. **客户端层** (`ws_client.dart`)
- WebSocket连接管理
- 消息处理
- 重连机制
- 心跳检测

### 5. **配置层** (`ws_annotation_helper.dart`)
- 预定义配置
- 配置验证
- 注解辅助

## 🎯 设计优势

### 1. **清晰的职责分离**
- 每个文件都有明确的职责
- 便于维护和测试
- 降低耦合度

### 2. **灵活的扩展性**
- 可以轻松添加新的服务类型
- 支持不同的配置需求
- 便于功能扩展

### 3. **良好的可测试性**
- 各层可以独立测试
- 依赖注入便于Mock
- 清晰的接口定义

### 4. **易于使用**
- 提供多种使用方式
- 预定义配置减少重复
- 详细的文档和示例

## 🔧 使用建议

### 1. **简单场景**
```dart
// 直接使用简化服务
final service = SimpleKlineWsService(logger: logger);
await service.connect();
```

### 2. **复杂场景**
```dart
// 使用完整服务
final service = KlineWsService(
  logger: logger,
  onKlineData: handleKlineData,
  onError: handleError,
);
await service.connect();
```

### 3. **UI集成**
```dart
// 使用Provider
final wsService = ref.watch(klineWsServiceProvider);
final connectionState = ref.watch(wsConnectionStateProvider);
```

## 📝 最佳实践

1. **选择合适的服务类型**
   - 简单需求 → `SimpleKlineWsService`
   - 复杂需求 → `KlineWsService`

2. **使用预定义配置**
   - 避免重复定义
   - 保持配置一致性

3. **正确处理生命周期**
   - 及时调用 `dispose()`
   - 处理连接状态变化

4. **错误处理**
   - 监听错误事件
   - 提供用户友好的错误信息

5. **性能优化**
   - 合理使用Stream
   - 避免内存泄漏 