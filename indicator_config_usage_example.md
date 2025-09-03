# 使用 getConfig 和 setConfig 配置指标的完整示例

## 概述

`BitFlexiKlineConfiguration` 现在支持通过 `getConfig()` 和 `setConfig()` 方法来动态配置指标，而不是使用硬编码的 `mainIndicatorBuilders()` 和 `subIndicatorBuilders()` 方法。

## 配置数据结构

### 主指标配置示例

```dart
Map<String, Map<String, dynamic>> mainIndicatorConfig = {
  'ma': {
    'type': 'ma',
    'height': 200.0,
    'calcParams': [
      {
        'count': 5,
        'tips': {
          'label': 'MA5: ',
          'style': {
            'color': 0xFF2196F3, // 蓝色
            'fontSize': 12.0,
            'height': 1.2,
          },
        },
      },
      {
        'count': 10,
        'tips': {
          'label': 'MA10: ',
          'style': {
            'color': 0xFFFF5722, // 红色
            'fontSize': 12.0,
            'height': 1.2,
          },
        },
      },
      {
        'count': 20,
        'tips': {
          'label': 'MA20: ',
          'style': {
            'color': 0xFF4CAF50, // 绿色
            'fontSize': 12.0,
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
      'style': {
        'color': 0xFF2196F3,
        'fontSize': 12.0,
        'height': 1.2,
      },
    },
    'upTips': {
      'label': 'UB: ',
      'style': {
        'color': 0xFFFF5722,
        'fontSize': 12.0,
        'height': 1.2,
      },
    },
    'dnTips': {
      'label': 'LB: ',
      'style': {
        'color': 0xFF4CAF50,
        'fontSize': 12.0,
        'height': 1.2,
      },
    },
  },
  'ema': {
    'type': 'ema',
    'height': 200.0,
    'calcParams': [
      {
        'count': 12,
        'tips': {
          'label': 'EMA12: ',
          'style': {
            'color': 0xFFFF9800, // 橙色
            'fontSize': 12.0,
            'height': 1.2,
          },
        },
      },
      {
        'count': 26,
        'tips': {
          'label': 'EMA26: ',
          'style': {
            'color': 0xFF9C27B0, // 紫色
            'fontSize': 12.0,
            'height': 1.2,
          },
        },
      },
    ],
  },
};
```

### 副指标配置示例

```dart
Map<String, Map<String, dynamic>> subIndicatorConfig = {
  'rsi': {
    'type': 'rsi',
    'height': 100.0,
    'precision': 2,
    'calcParams': [
      {
        'count': 6,
        'tips': {
          'label': 'RSI6: ',
          'style': {
            'color': 0xFFFF9800,
            'fontSize': 12.0,
            'height': 1.2,
          },
        },
      },
      {
        'count': 12,
        'tips': {
          'label': 'RSI12: ',
          'style': {
            'color': 0xFF2196F3,
            'fontSize': 12.0,
            'height': 1.2,
          },
        },
      },
      {
        'count': 24,
        'tips': {
          'label': 'RSI24: ',
          'style': {
            'color': 0xFF9C27B0,
            'fontSize': 12.0,
            'height': 1.2,
          },
        },
      },
    ],
  },
  'kdj': {
    'type': 'kdj',
    'height': 100.0,
    'precision': 2,
    'calcParam': {
      'n': 9,
      'm1': 3,
      'm2': 3,
    },
    'ktips': {
      'label': 'K: ',
      'style': {
        'color': 0xFF2196F3,
        'fontSize': 12.0,
        'height': 1.2,
      },
    },
    'dtips': {
      'label': 'D: ',
      'style': {
        'color': 0xFFFF5722,
        'fontSize': 12.0,
        'height': 1.2,
      },
    },
    'jtips': {
      'label': 'J: ',
      'style': {
        'color': 0xFF4CAF50,
        'fontSize': 12.0,
        'height': 1.2,
      },
    },
  },
  'macd': {
    'type': 'macd',
    'height': 120.0,
    'precision': 2,
    'calcParam': {
      's': 12,
      'l': 26,
      'm': 9,
    },
    'difTips': {
      'label': 'DIF: ',
      'style': {
        'color': 0xFF2196F3,
        'fontSize': 12.0,
        'height': 1.2,
      },
    },
    'deaTips': {
      'label': 'DEA: ',
      'style': {
        'color': 0xFFFF5722,
        'fontSize': 12.0,
        'height': 1.2,
      },
    },
    'macdTips': {
      'label': 'MACD: ',
      'style': {
        'color': 0xFF4CAF50,
        'fontSize': 12.0,
        'height': 1.2,
      },
    },
  },
  'volume': {
    'type': 'volume',
    'height': 80.0,
    'precision': 2,
    'volTips': {
      'label': 'VOL: ',
      'style': {
        'color': 0xFF2196F3,
        'fontSize': 12.0,
        'height': 1.2,
      },
    },
  },
};
```

## 使用方法

### 1. 设置指标配置

```dart
void setupIndicatorConfigurations() async {
  final config = BitFlexiKlineConfiguration(ref: ref);
  
  // 设置主指标配置
  await config.setMainIndicatorConfig(mainIndicatorConfig);
  
  // 设置副指标配置
  await config.setSubIndicatorConfig(subIndicatorConfig);
  
  print('指标配置已保存');
}
```

### 2. 读取指标配置

```dart
void readIndicatorConfigurations() {
  final config = BitFlexiKlineConfiguration(ref: ref);
  
  // 读取主指标配置
  final mainConfig = config.getConfig('mainIndicatorBuilders');
  if (mainConfig != null) {
    print('主指标配置: $mainConfig');
  }
  
  // 读取副指标配置
  final subConfig = config.getConfig('subIndicatorBuilders');
  if (subConfig != null) {
    print('副指标配置: $subConfig');
  }
}
```

### 3. 动态修改指标配置

```dart
void updateMAIndicator() async {
  final config = BitFlexiKlineConfiguration(ref: ref);
  
  // 修改 MA 指标的参数
  Map<String, Map<String, dynamic>> updatedConfig = {
    'ma': {
      'type': 'ma',
      'height': 250.0, // 增加高度
      'calcParams': [
        {
          'count': 7,  // 修改为 MA7
          'tips': {
            'label': 'MA7: ',
            'style': {
              'color': 0xFF2196F3,
              'fontSize': 14.0, // 增加字体大小
              'height': 1.2,
            },
          },
        },
        {
          'count': 21, // 修改为 MA21
          'tips': {
            'label': 'MA21: ',
            'style': {
              'color': 0xFFFF5722,
              'fontSize': 14.0,
              'height': 1.2,
            },
          },
        },
      ],
    },
  };
  
  // 保存新的配置
  await config.setMainIndicatorConfig(updatedConfig);
  
  print('MA 指标配置已更新');
}
```

### 4. 添加自定义指标

```dart
void addCustomIndicator() async {
  final config = BitFlexiKlineConfiguration(ref: ref);
  
  // 获取当前主指标配置
  final currentConfig = config.getConfig('mainIndicatorBuilders') ?? {};
  
  // 添加新的自定义指标
  currentConfig['custom_ma'] = {
    'type': 'ma',
    'height': 180.0,
    'calcParams': [
      {
        'count': 30,
        'tips': {
          'label': '月线: ',
          'style': {
            'color': 0xFFE91E63, // 粉色
            'fontSize': 12.0,
            'height': 1.2,
          },
        },
      },
      {
        'count': 60,
        'tips': {
          'label': '双月线: ',
          'style': {
            'color': 0xFF673AB7, // 深紫色
            'fontSize': 12.0,
            'height': 1.2,
          },
        },
      },
    ],
  };
  
  // 保存更新的配置
  await config.setConfig('mainIndicatorBuilders', currentConfig);
  
  print('自定义指标已添加');
}
```

### 5. 删除指标

```dart
void removeIndicator(String indicatorKey, bool isMainIndicator) async {
  final config = BitFlexiKlineConfiguration(ref: ref);
  
  final configKey = isMainIndicator ? 'mainIndicatorBuilders' : 'subIndicatorBuilders';
  final currentConfig = config.getConfig(configKey) ?? {};
  
  // 删除指定指标
  currentConfig.remove(indicatorKey);
  
  // 保存更新的配置
  await config.setConfig(configKey, currentConfig);
  
  print('指标 $indicatorKey 已删除');
}
```

## 支持的指标类型

### 主指标类型
- `ma` - 移动平均线
- `boll` - 布林带
- `ema` - 指数移动平均线

### 副指标类型
- `rsi` - 相对强弱指标
- `kdj` - 随机指标
- `macd` - 指数平滑异同移动平均线
- `volume` - 成交量

## 颜色配置

颜色可以用以下格式指定：
- 十六进制整数：`0xFFFF0000` (红色)
- 十六进制字符串：`"#FF0000"` (红色)
- 十六进制字符串带前缀：`"0xFFFF0000"` (红色)

## 注意事项

1. **配置缓存**：指标配置会被缓存，只有在调用 `setConfig` 时才会重新加载
2. **错误处理**：如果配置格式错误，系统会回退到默认配置
3. **持久化存储**：配置会自动保存到本地存储，应用重启后仍然有效
4. **实时更新**：配置更新后，需要重新初始化 K 线图才能生效

## 完整示例应用

```dart
class IndicatorConfigExample extends ConsumerStatefulWidget {
  @override
  _IndicatorConfigExampleState createState() => _IndicatorConfigExampleState();
}

class _IndicatorConfigExampleState extends ConsumerState<IndicatorConfigExample> {
  late BitFlexiKlineConfiguration config;
  
  @override
  void initState() {
    super.initState();
    config = BitFlexiKlineConfiguration(ref: ref);
    _loadInitialConfig();
  }
  
  Future<void> _loadInitialConfig() async {
    // 设置默认的指标配置
    await config.setMainIndicatorConfig(mainIndicatorConfig);
    await config.setSubIndicatorConfig(subIndicatorConfig);
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('指标配置示例')),
      body: Column(
        children: [
          // K线图组件
          Expanded(
            child: FlexiKlineWidget(
              configuration: config,
              // ... 其他参数
            ),
          ),
          
          // 配置控制按钮
          Row(
            children: [
              ElevatedButton(
                onPressed: () => updateMAIndicator(),
                child: Text('更新 MA'),
              ),
              ElevatedButton(
                onPressed: () => addCustomIndicator(),
                child: Text('添加自定义指标'),
              ),
              ElevatedButton(
                onPressed: () => removeIndicator('boll', true),
                child: Text('删除 BOLL'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

这种配置方式提供了更大的灵活性，允许用户根据需要动态调整指标配置，而无需重新编译代码。
