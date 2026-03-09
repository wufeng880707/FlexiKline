# 交易标记功能使用示例

## 功能概述

交易标记功能允许在K线图上显示历史买卖订单，每根K线最多显示一个买入标记(B)和一个卖出标记(S)：
- 买入标记显示在K线下方，绿色背景
- 卖出标记显示在K线上方，红色背景
- 如果同一根K线有多个相同类型的交易，会自动合并并显示交易次数

## 快速开始

### 1. 在页面中使用TradeMarkMixin

```dart
// 在你的K线页面中混入TradeMarkMixin
class _BitKlinePageState extends ConsumerState<BitKlinePage>
    with KlinePageDataUpdateMixin<BitKlinePage>, TradeMarkMixin<BitKlinePage> {

  @override
  void initState() {
    super.initState();
    
    // 现有的初始化代码...
    
    // 启用交易标记功能
    WidgetsBinding.instance.addPostFrameCallback((_) {
      enableTradeMarkDisplay();
      _loadTradeData();
    });
  }

  /// 从API加载交易数据
  @override
  Future<List<TradeMarkData>> loadTradeMarksFromAPI() async {
    try {
      // 这里调用你的实际API
      // final response = await api.getTradeMarks(widget.instId);
      
      // 示例：返回模拟数据
      return createTestTradeMarks();
    } catch (e) {
      debugPrint('Failed to load trade marks: $e');
      return [];
    }
  }

  /// 加载交易数据
  Future<void> _loadTradeData() async {
    try {
      final marks = await loadTradeMarksFromAPI();
      await setTradeMarks(marks);
    } catch (e) {
      debugPrint('Error loading trade data: $e');
    }
  }

  // 在build方法中添加控制按钮（可选）
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 现有的build代码...
      
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            mini: true,
            onPressed: toggleTradeMarkDisplay,
            child: Icon(isTradeMarkEnabled ? Icons.visibility : Icons.visibility_off),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            mini: true,
            onPressed: () async {
              final testMark = TradeMarkData(
                timestamp: DateTime.now().millisecondsSinceEpoch,
                type: TradeType.buy,
                price: 50200.0,
                maxPrice: 50220.0,
                volume: 0.05,
              );
              await addTradeMark(testMark);
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            mini: true,
            onPressed: clearTradeMarks,
            child: const Icon(Icons.clear),
          ),
        ],
      ),
    );
  }
}
```

### 2. 数据格式

交易标记数据使用`TradeMarkData`模型：

```dart
final tradeMark = TradeMarkData(
  timestamp: DateTime.now().millisecondsSinceEpoch, // 交易时间戳
  type: TradeType.buy, // 交易类型：buy 或 sell
  price: 50000.0, // 交易价格
  maxPrice: 50050.0, // 最高价格
  volume: 0.1, // 交易数量
  orderId: 'order_123', // 订单ID（可选）
  count: 1, // 交易次数（默认为1）
);
```

### 3. API集成示例

如果你有实际的交易API，可以这样集成：

```dart
@override
Future<List<TradeMarkData>> loadTradeMarksFromAPI() async {
  try {
    // 调用你的交易API
    final response = await http.get(
      Uri.parse('https://api.yourexchange.com/trades/${widget.instId}'),
      headers: {'Authorization': 'Bearer $yourToken'},
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final trades = data['trades'] as List;
      
      return trades.map((trade) => TradeMarkData(
        timestamp: trade['timestamp'],
        type: trade['side'] == 'buy' ? TradeType.buy : TradeType.sell,
        price: double.parse(trade['price']),
        maxPrice: double.parse(trade['maxPrice'] ?? trade['price']),
        volume: double.parse(trade['quantity']),
        orderId: trade['orderId'],
      )).toList();
    } else {
      throw Exception('Failed to load trades: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('API Error: $e');
    return [];
  }
}
```

## 功能说明

### 自动数据处理
- 同一根K线的多个相同类型交易会自动合并
- 合并时会累加交易量，显示交易次数
- 使用最新的交易价格和时间戳

### 配置选项
交易标记的显示样式可以通过`TradeMarkParam`配置：

```dart
final customParam = TradeMarkParam(
  show: true, // 是否显示
  spacing: 4.0, // 与K线的间距
  markerRadius: 10.0, // 标记圆圈半径
  buyBgColor: Color(0xFF00C853), // 买入背景色
  sellBgColor: Color(0xFFFF5252), // 卖出背景色
  fontSize: 12.0, // 字体大小
  showQuantity: true, // 是否显示交易数量
);
```

### 数据持久化
- 交易标记数据会自动保存到本地配置中
- 下次打开应用时会自动加载之前的数据
- 支持启用/禁用状态的持久化

### Tips显示
当鼠标悬停在有交易标记的K线上时，会显示详细信息：
- 买入信息：价格、数量、交易次数
- 卖出信息：价格、数量、交易次数

## 注意事项

1. **时间匹配**：交易时间戳会自动匹配到对应的K线时间段
2. **性能优化**：大量交易数据会自动分组和合并，避免性能问题
3. **数据验证**：无效的交易数据会被过滤掉
4. **内存管理**：不再使用的交易数据会被及时清理

## 故障排除

### 交易标记不显示
1. 确认已调用`enableTradeMarkDisplay()`
2. 检查交易数据格式是否正确
3. 确认时间戳与K线数据匹配

### 性能问题
1. 限制交易数据的数量（建议不超过1000条）
2. 定期清理旧的交易数据
3. 使用分页加载大量数据

### 数据不准确
1. 确认API返回的时间戳格式正确
2. 检查价格和数量的数据类型
3. 验证交易类型映射是否正确