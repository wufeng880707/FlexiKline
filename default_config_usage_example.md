# DefaultFlexiKlineConfiguration 配置使用示例

## 修复完成

`DefaultFlexiKlineConfiguration` 已经成功修复并实现了基于 `getConfig/setConfig` 的配置系统，就像 `BitFlexiKlineConfiguration` 一样。

## 修复内容

1. **修复语法错误**：添加了缺失的分号
2. **解决方法冲突**：将 `mainIndicatorBuilders()` 和 `subIndicatorBuilders()` 方法转换为 getter
3. **实现配置系统**：完整实现了 `getConfig` 和 `setConfig` 方法
4. **移除错误注解**：移除了不正确的 `@override` 注解
5. **添加配置解析**：支持从 JSON 配置动态创建指标

## 现在支持的指标类型

### 主指标
- `ma` - 移动平均线
- `boll` - 布林带 
- `ema` - 指数移动平均线
- `sar` - 抛物线转向指标
- `avl` - 均价线

### 副指标
- `rsi` - 相对强弱指标
- `kdj` - 随机指标
- `macd` - 指数平滑异同移动平均线
- `volMa` - 成交量移动平均线
- `volume` - 成交量

## 使用示例

### 1. 基本使用

```dart
void setupDefaultConfiguration() {
  final config = DefaultFlexiKlineConfiguration(ref: ref);
  
  // 获取当前主指标配置
  final mainIndicators = config.mainIndicatorBuilders;
  print('当前主指标数量: ${mainIndicators.length}');
  
  // 获取当前副指标配置  
  final subIndicators = config.subIndicatorBuilders;
  print('当前副指标数量: ${subIndicators.length}');
}
```

### 2. 设置自定义指标配置

```dart
Future<void> customizeIndicators() async {
  final config = DefaultFlexiKlineConfiguration(ref: ref);
  
  // 设置自定义MA配置
  final customMainConfig = {
    'ma': {
      'type': 'ma',
      'height': 250.0,
      'calcParams': [
        {
          'count': 7,
          'tips': {
            'label': 'MA7: ',
            'style': {
              'color': 0xFF2196F3, // 蓝色
              'fontSize': 14.0,
              'height': 1.2,
            },
          },
        },
        {
          'count': 14,
          'tips': {
            'label': 'MA14: ',
            'style': {
              'color': 0xFFFF5722, // 红色
              'fontSize': 14.0,
              'height': 1.2,
            },
          },
        },
      ],
    },
    'boll': {
      'type': 'boll',
      'height': 200.0,
      'calcParam': {
        'n': 20,
        'std': 2,
      },
      'mbTips': {
        'label': 'BOLL: ',
        'style': {'color': 0xFF2196F3, 'fontSize': 12.0, 'height': 1.2},
      },
      'upTips': {
        'label': 'UB: ',
        'style': {'color': 0xFFFF5722, 'fontSize': 12.0, 'height': 1.2},
      },
      'dnTips': {
        'label': 'LB: ',
        'style': {'color': 0xFF4CAF50, 'fontSize': 12.0, 'height': 1.2},
      },
    },
  };
  
  // 保存主指标配置
  await config.setMainIndicatorConfig(customMainConfig);
  print('主指标配置已保存');
}
```

### 3. 设置副指标配置

```dart
Future<void> customizeSubIndicators() async {
  final config = DefaultFlexiKlineConfiguration(ref: ref);
  
  final customSubConfig = {
    'rsi': {
      'type': 'rsi',
      'height': 120.0,
      'precision': 2,
      'calcParams': [
        {
          'count': 14,
          'tips': {
            'label': 'RSI14: ',
            'style': {'color': 0xFFFF9800, 'fontSize': 12.0, 'height': 1.2},
          },
        },
      ],
    },
    'macd': {
      'type': 'macd', 
      'height': 150.0,
      'precision': 4,
      'calcParam': {
        's': 12,
        'l': 26,
        'm': 9,
      },
      'difTips': {
        'label': 'DIF: ',
        'style': {'color': 0xFF2196F3, 'fontSize': 12.0, 'height': 1.2},
      },
      'deaTips': {
        'label': 'DEA: ',
        'style': {'color': 0xFFFF5722, 'fontSize': 12.0, 'height': 1.2},
      },
      'macdTips': {
        'label': 'MACD: ',
        'style': {'color': 0xFF4CAF50, 'fontSize': 12.0, 'height': 1.2},
      },
    },
  };
  
  // 保存副指标配置
  await config.setSubIndicatorConfig(customSubConfig);
  print('副指标配置已保存');
}
```

### 4. 读取和修改现有配置

```dart
Future<void> modifyExistingConfig() async {
  final config = DefaultFlexiKlineConfiguration(ref: ref);
  
  // 读取现有的主指标配置
  final existingConfig = config.getConfig('mainIndicatorBuilders');
  if (existingConfig != null) {
    print('现有配置: $existingConfig');
    
    // 修改现有配置
    existingConfig['ema'] = {
      'type': 'ema',
      'height': 180.0,
      'calcParams': [
        {
          'count': 9,
          'tips': {
            'label': 'EMA9: ',
            'style': {'color': 0xFF9C27B0, 'fontSize': 12.0, 'height': 1.2},
          },
        },
        {
          'count': 21,
          'tips': {
            'label': 'EMA21: ',
            'style': {'color': 0xFFE91E63, 'fontSize': 12.0, 'height': 1.2},
          },
        },
      ],
    };
    
    // 保存修改后的配置
    await config.setConfig('mainIndicatorBuilders', existingConfig);
    print('配置已更新');
  }
}
```

### 5. 清除配置（恢复默认）

```dart
Future<void> resetToDefault() async {
  final config = DefaultFlexiKlineConfiguration(ref: ref);
  
  // 清除主指标配置（将使用默认配置）
  await config.setConfig('mainIndicatorBuilders', {});
  
  // 清除副指标配置
  await config.setConfig('subIndicatorBuilders', {});
  
  print('配置已重置为默认值');
}
```

## 与 BitFlexiKlineConfiguration 的区别

1. **缓存键前缀不同**：
   - DefaultFlexiKlineConfiguration 使用 `'default_config_'` 前缀
   - BitFlexiKlineConfiguration 使用 `'bit_indicator_config_'` 前缀

2. **支持的指标类型更多**：
   - DefaultFlexiKlineConfiguration 额外支持 SAR、AVL、VolMa 指标
   - 包含交易指标支持（TradeMarkIndicator）

3. **主题系统不同**：
   - DefaultFlexiKlineConfiguration 使用 `DefaultFlexiKlineTheme`
   - BitFlexiKlineConfiguration 使用 `BaseBitFlexiKlineTheme`

## 配置持久化

所有配置都会自动保存到本地存储，应用重启后配置仍然有效。配置存储使用 `CacheUtil` 实现，支持 JSON 格式的配置数据。

## 错误处理

配置系统包含完善的错误处理：
- 配置解析失败时自动回退到默认配置
- 错误信息会记录到日志中
- 不会因为配置错误导致应用崩溃

## 性能优化

- 配置会被缓存，避免重复解析
- 只有在配置变更时才会重新加载
- 支持增量更新，不需要重新设置所有配置
