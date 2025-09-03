# 时间周期配置管理示例

## 问题解决

由于 `timeBarBuilders()` 方法已被删除，现在使用 `getConfig` 和 `setConfig` 系统来管理时间周期配置。

## 新的解决方案

### 1. 配置结构

时间周期配置现在存储为JSON格式：

```dart
Map<String, dynamic> timeBarConfigData = {
  'timeBarConfigs': [
    {
      'key': '1m',
      'bar': '1m',
      'milliseconds': 60000,
      'multiplier': 1,
      'timespan': 'minute',
      'showName': '1分钟',
      'isUtc': false,
      'locale': 'zh',
      'sortOrder': 1,
      'intraDay': false,
    },
    {
      'key': '5m',
      'bar': '5m',
      'milliseconds': 300000,
      'multiplier': 5,
      'timespan': 'minute',
      'showName': '5分钟',
      'isUtc': false,
      'locale': 'zh',
      'sortOrder': 2,
      'intraDay': false,
    },
    // ... 更多配置
  ],
};
```

### 2. 在 BitFlexiKlineConfiguration 中的实现

已经在 `BitFlexiKlineConfiguration` 中添加了以下方法：

```dart
class BitFlexiKlineConfiguration {
  // 时间周期配置缓存
  List<TimeBarConfig>? _cachedTimeBarConfigs;
  
  /// 获取时间周期配置列表
  List<TimeBarConfig> getTimeBarConfigs() {
    if (_cachedTimeBarConfigs != null) {
      return _cachedTimeBarConfigs!;
    }
    
    // 从配置中读取时间周期配置
    final config = getConfig('timeBarConfigs');
    if (config != null) {
      try {
        _cachedTimeBarConfigs = _buildTimeBarConfigsFromConfig(config);
        return _cachedTimeBarConfigs!;
      } catch (e) {
        defLogger.e('Failed to build time bar configs from config: $e');
      }
    }
    
    // 默认配置
    _cachedTimeBarConfigs = _getDefaultTimeBarConfigs();
    return _cachedTimeBarConfigs!;
  }
  
  /// 设置时间周期配置
  Future<bool> setTimeBarConfigs(List<TimeBarConfig> configs) async {
    try {
      final configData = {
        'timeBarConfigs': configs.map((config) => config.toJson()).toList(),
      };
      
      final success = await setConfig('timeBarConfigs', configData);
      if (success) {
        _cachedTimeBarConfigs = null; // 清除缓存
      }
      return success;
    } catch (e) {
      defLogger.e('Failed to set time bar configs: $e');
      return false;
    }
  }
}
```

### 3. 在对话框中的使用

更新 `TimerBarSelectDialog` 中的使用方式：

```dart
// 旧的方式（已删除）
// children: controller.configuration.timeBarBuilders().map((timeBar) {

// 新的方式
children: (controller.configuration as BitFlexiKlineConfiguration).getTimeBarConfigs().map((timeBar) {
  final selected = value == timeBar;
  return SizedBox(
    width: barWidth,
    child: TextButton(
      key: ValueKey(timeBar),
      style: theme.outlinedBtnStyle(showOutlined: selected),
      onPressed: () => onTapTimeBar(timeBar),
      child: FittedBox(
        child: Text(
          timeBar.showName,
          style: theme.t2s12w400.copyWith(
            color: theme.t1,
            fontWeight: selected ? FontWeight.bold : null,
          ),
        ),
      ),
    ),
  );
}).toList(),
```

### 4. 使用示例

#### 读取时间周期配置

```dart
void loadTimeBarConfigs() {
  final config = BitFlexiKlineConfiguration(ref: ref);
  
  // 获取当前配置
  final timeBarConfigs = config.getTimeBarConfigs();
  
  print('当前时间周期配置数量: ${timeBarConfigs.length}');
  for (final timeBar in timeBarConfigs) {
    print('${timeBar.showName}: ${timeBar.bar}');
  }
}
```

#### 设置自定义时间周期配置

```dart
Future<void> setupCustomTimeBarConfigs() async {
  final config = BitFlexiKlineConfiguration(ref: ref);
  
  final customConfigs = [
    const TimeBarConfig(
      key: '1m',
      bar: '1m',
      milliseconds: Duration.millisecondsPerMinute,
      multiplier: 1,
      timespan: Timespan.minute,
      showName: '1分钟',
      sortOrder: 1,
    ),
    const TimeBarConfig(
      key: '3m',
      bar: '3m',
      milliseconds: Duration.millisecondsPerMinute * 3,
      multiplier: 3,
      timespan: Timespan.minute,
      showName: '3分钟',
      sortOrder: 2,
    ),
    const TimeBarConfig(
      key: '5m',
      bar: '5m',
      milliseconds: Duration.millisecondsPerMinute * 5,
      multiplier: 5,
      timespan: Timespan.minute,
      showName: '5分钟',
      sortOrder: 3,
    ),
    const TimeBarConfig(
      key: '15m',
      bar: '15m',
      milliseconds: Duration.millisecondsPerMinute * 15,
      multiplier: 15,
      timespan: Timespan.minute,
      showName: '15分钟',
      sortOrder: 4,
    ),
    const TimeBarConfig(
      key: '30m',
      bar: '30m',
      milliseconds: Duration.millisecondsPerMinute * 30,
      multiplier: 30,
      timespan: Timespan.minute,
      showName: '30分钟',
      sortOrder: 5,
    ),
    const TimeBarConfig(
      key: '1H',
      bar: '1H',
      milliseconds: Duration.millisecondsPerHour,
      multiplier: 1,
      timespan: Timespan.hour,
      showName: '1小时',
      sortOrder: 6,
    ),
    const TimeBarConfig(
      key: '4H',
      bar: '4H',
      milliseconds: Duration.millisecondsPerHour * 4,
      multiplier: 4,
      timespan: Timespan.hour,
      showName: '4小时',
      sortOrder: 7,
    ),
    const TimeBarConfig(
      key: '1D',
      bar: '1D',
      milliseconds: Duration.millisecondsPerDay,
      multiplier: 1,
      timespan: Timespan.day,
      showName: '1天',
      sortOrder: 8,
    ),
    const TimeBarConfig(
      key: '1W',
      bar: '1W',
      milliseconds: Duration.millisecondsPerDay * 7,
      multiplier: 7,
      timespan: Timespan.week,
      showName: '1周',
      sortOrder: 9,
    ),
    const TimeBarConfig(
      key: '1M',
      bar: '1M',
      milliseconds: Duration.millisecondsPerDay * 30,
      multiplier: 1,
      timespan: Timespan.month,
      showName: '1月',
      sortOrder: 10,
    ),
  ];
  
  final success = await config.setTimeBarConfigs(customConfigs);
  if (success) {
    print('时间周期配置设置成功');
  } else {
    print('时间周期配置设置失败');
  }
}
```

#### 动态添加时间周期

```dart
Future<void> addCustomTimeBar() async {
  final config = BitFlexiKlineConfiguration(ref: ref);
  
  // 获取现有配置
  final existingConfigs = config.getTimeBarConfigs().toList();
  
  // 添加新的时间周期
  final newTimeBar = const TimeBarConfig(
    key: '2H',
    bar: '2H',
    milliseconds: Duration.millisecondsPerHour * 2,
    multiplier: 2,
    timespan: Timespan.hour,
    showName: '2小时',
    sortOrder: 100,
  );
  
  existingConfigs.add(newTimeBar);
  
  // 保存更新后的配置
  await config.setTimeBarConfigs(existingConfigs);
  print('新增时间周期: ${newTimeBar.showName}');
}
```

#### 移除时间周期

```dart
Future<void> removeTimeBar(String key) async {
  final config = BitFlexiKlineConfiguration(ref: ref);
  
  // 获取现有配置
  final existingConfigs = config.getTimeBarConfigs().toList();
  
  // 移除指定的时间周期
  existingConfigs.removeWhere((timeBar) => timeBar.key == key);
  
  // 保存更新后的配置
  await config.setTimeBarConfigs(existingConfigs);
  print('移除时间周期: $key');
}
```

### 5. 完整示例应用

```dart
class TimeBarConfigExample extends ConsumerStatefulWidget {
  @override
  _TimeBarConfigExampleState createState() => _TimeBarConfigExampleState();
}

class _TimeBarConfigExampleState extends ConsumerState<TimeBarConfigExample> {
  late BitFlexiKlineConfiguration config;
  List<TimeBarConfig> timeBarConfigs = [];
  
  @override
  void initState() {
    super.initState();
    config = BitFlexiKlineConfiguration(ref: ref);
    _loadTimeBarConfigs();
  }
  
  void _loadTimeBarConfigs() {
    setState(() {
      timeBarConfigs = config.getTimeBarConfigs();
    });
  }
  
  Future<void> _addCustomTimeBar() async {
    final newTimeBar = TimeBarConfig(
      key: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      bar: '6H',
      milliseconds: Duration.millisecondsPerHour * 6,
      multiplier: 6,
      timespan: Timespan.hour,
      showName: '6小时',
      sortOrder: timeBarConfigs.length + 1,
    );
    
    final updatedConfigs = [...timeBarConfigs, newTimeBar];
    final success = await config.setTimeBarConfigs(updatedConfigs);
    
    if (success) {
      _loadTimeBarConfigs();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('添加时间周期成功')),
      );
    }
  }
  
  Future<void> _removeTimeBar(TimeBarConfig timeBar) async {
    final updatedConfigs = timeBarConfigs
        .where((config) => config.key != timeBar.key)
        .toList();
    
    final success = await config.setTimeBarConfigs(updatedConfigs);
    
    if (success) {
      _loadTimeBarConfigs();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除时间周期 ${timeBar.showName} 成功')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('时间周期配置管理'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addCustomTimeBar,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: timeBarConfigs.length,
        itemBuilder: (context, index) {
          final timeBar = timeBarConfigs[index];
          return ListTile(
            title: Text(timeBar.showName),
            subtitle: Text('${timeBar.bar} (${timeBar.timespan.name})'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _removeTimeBar(timeBar),
            ),
          );
        },
      ),
    );
  }
}
```

## 总结

通过这种新的配置系统，你可以：

1. **动态配置时间周期**：无需重新编译代码
2. **持久化存储**：配置会自动保存到本地
3. **灵活管理**：可以添加、删除、修改时间周期配置
4. **缓存优化**：配置会被缓存，提高性能
5. **错误处理**：包含完善的错误处理机制

这种方式比原来的硬编码 `timeBarBuilders()` 方法更加灵活和强大。
