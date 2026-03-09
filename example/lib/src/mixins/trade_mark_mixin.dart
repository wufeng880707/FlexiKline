// Copyright 2024 Andy.Zhao
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flexi_kline/flexi_kline.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 交易标记数据接口
abstract interface class ITradeMarkPage {
  FlexiKlineController get flexiKlineController;
}

/// 交易标记功能Mixin
/// 提供交易标记的管理和显示功能
mixin TradeMarkMixin<T extends ConsumerStatefulWidget> on ConsumerState<T>
    implements ITradeMarkPage {
  
  static const String _tradeMarksConfigKey = 'trade_marks_data';
  
  List<TradeMarkData> _tradeMarks = [];
  bool _isTradeMarkEnabled = false;
  
  /// 获取当前交易标记数据
  List<TradeMarkData> get tradeMarks => _tradeMarks;
  
  /// 是否启用交易标记显示
  bool get isTradeMarkEnabled => _isTradeMarkEnabled;

  @override
  void initState() {
    super.initState();
    _loadTradeMarksFromConfig();
  }

  /// 从配置加载交易标记
  void _loadTradeMarksFromConfig() {
    try {
      final config = flexiKlineController.configuration.getConfig(_tradeMarksConfigKey);
      if (config != null) {
        final marks = config['marks'] as List?;
        if (marks != null) {
          _tradeMarks = marks
              .map((m) => TradeMarkData.fromJson(m as Map<String, dynamic>))
              .toList();
          debugPrint('Loaded ${_tradeMarks.length} trade marks from config');
        }
        
        _isTradeMarkEnabled = config['enabled'] as bool? ?? false;
      }
    } catch (e) {
      debugPrint('Failed to load trade marks: $e');
    }
  }
  
  /// 保存交易标记到配置
  Future<void> _saveTradeMarksToConfig() async {
    try {
      final json = {
        'marks': _tradeMarks.map((m) => m.toJson()).toList(),
        'enabled': _isTradeMarkEnabled,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      };
      
      await flexiKlineController.configuration.setConfig(_tradeMarksConfigKey, json);
      debugPrint('Saved ${_tradeMarks.length} trade marks to config');
    } catch (e) {
      debugPrint('Failed to save trade marks: $e');
    }
  }
  
  /// 设置交易标记数据
  Future<void> setTradeMarks(List<TradeMarkData> marks) async {
    _tradeMarks = marks;
    await _saveTradeMarksToConfig();
    
    if (_isTradeMarkEnabled) {
      _updateTradeMarkIndicator();
    }
  }
  
  /// 添加单个交易标记
  Future<void> addTradeMark(TradeMarkData mark) async {
    _tradeMarks.add(mark);
    await _saveTradeMarksToConfig();
    
    if (_isTradeMarkEnabled) {
      _updateTradeMarkIndicator();
    }
  }
  
  /// 清空交易标记
  Future<void> clearTradeMarks() async {
    await setTradeMarks([]);
  }
  
  /// 启用交易标记显示
  void enableTradeMarkDisplay() {
    if (!flexiKlineController.hasAddedMainIndicator(tradeMarkIndicatorKey)) {
      flexiKlineController.addMainIndicator(tradeMarkIndicatorKey);
    }
    
    _isTradeMarkEnabled = true;
    _updateTradeMarkIndicator();
    _saveTradeMarksToConfig();
  }
  
  /// 禁用交易标记显示
  void disableTradeMarkDisplay() {
    if (flexiKlineController.hasAddedMainIndicator(tradeMarkIndicatorKey)) {
      flexiKlineController.removeMainIndicator(tradeMarkIndicatorKey);
    }
    
    _isTradeMarkEnabled = false;
    _saveTradeMarksToConfig();
  }
  
  /// 切换交易标记显示状态
  void toggleTradeMarkDisplay() {
    if (_isTradeMarkEnabled) {
      disableTradeMarkDisplay();
    } else {
      enableTradeMarkDisplay();
    }
  }
  
  /// 更新交易标记指示器
  void _updateTradeMarkIndicator() {
    final currentIndicator = flexiKlineController.getIndicator<TradeMarkIndicator>(
      tradeMarkIndicatorKey,
    );
    
    if (currentIndicator != null) {
      final updatedIndicator = currentIndicator.updateTradeMarks(_tradeMarks);
      flexiKlineController.updateIndicator(updatedIndicator);
    } else {
      final newIndicator = TradeMarkIndicator(tradeMarks: _tradeMarks);
      flexiKlineController.updateIndicator(newIndicator);
    }
  }
  
  /// 从API加载交易标记数据（需要子类实现）
  Future<List<TradeMarkData>> loadTradeMarksFromAPI() async {
    // 子类应该重写此方法以从实际的API加载数据
    throw UnimplementedError('子类必须实现 loadTradeMarksFromAPI 方法');
  }
  
  /// 创建测试交易标记数据 - 覆盖多个时间周期
  List<TradeMarkData> createTestTradeMarks() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return [
      // === 1分钟级别数据 (1m) ===
      TradeMarkData(
        timestamp: now - 5 * 60 * 1000, // 5分钟前
        type: TradeType.buy,
        price: 50000.0,
        maxPrice: 50050.0,
        volume: 0.1,
        orderId: 'buy_1m_1',
      ),
      TradeMarkData(
        timestamp: now - 3 * 60 * 1000, // 3分钟前
        type: TradeType.sell,
        price: 50200.0,
        maxPrice: 50250.0,
        volume: 0.08,
        orderId: 'sell_1m_1',
      ),
      
      // === 15分钟级别数据 (15m) ===
      TradeMarkData(
        timestamp: now - 30 * 60 * 1000, // 30分钟前
        type: TradeType.buy,
        price: 49800.0,
        maxPrice: 49850.0,
        volume: 0.2,
        orderId: 'buy_15m_1',
      ),
      TradeMarkData(
        timestamp: now - 45 * 60 * 1000, // 45分钟前
        type: TradeType.sell,
        price: 49600.0,
        maxPrice: 49650.0,
        volume: 0.15,
        orderId: 'sell_15m_1',
      ),
      TradeMarkData(
        timestamp: now - 75 * 60 * 1000, // 75分钟前
        type: TradeType.buy,
        price: 49400.0,
        maxPrice: 49450.0,
        volume: 0.3,
        orderId: 'buy_15m_2',
      ),
      
      // === 1小时级别数据 (1H) ===
      TradeMarkData(
        timestamp: now - 2 * 60 * 60 * 1000, // 2小时前
        type: TradeType.sell,
        price: 49200.0,
        maxPrice: 49280.0,
        volume: 0.5,
        orderId: 'sell_1h_1',
      ),
      TradeMarkData(
        timestamp: now - 4 * 60 * 60 * 1000, // 4小时前
        type: TradeType.buy,
        price: 49000.0,
        maxPrice: 49100.0,
        volume: 0.25,
        orderId: 'buy_1h_1',
      ),
      TradeMarkData(
        timestamp: now - 8 * 60 * 60 * 1000, // 8小时前
        type: TradeType.sell,
        price: 48800.0,
        maxPrice: 48900.0,
        volume: 0.4,
        orderId: 'sell_1h_2',
      ),
      
      // === 4小时级别数据 (4H) ===
      TradeMarkData(
        timestamp: now - 1 * 24 * 60 * 60 * 1000, // 1天前
        type: TradeType.buy,
        price: 48500.0,
        maxPrice: 48600.0,
        volume: 0.8,
        orderId: 'buy_4h_1',
      ),
      TradeMarkData(
        timestamp: now - 2 * 24 * 60 * 60 * 1000, // 2天前
        type: TradeType.sell,
        price: 48200.0,
        maxPrice: 48350.0,
        volume: 0.6,
        orderId: 'sell_4h_1',
      ),
      TradeMarkData(
        timestamp: now - 4 * 24 * 60 * 60 * 1000, // 4天前
        type: TradeType.buy,
        price: 48000.0,
        maxPrice: 48150.0,
        volume: 1.0,
        orderId: 'buy_4h_2',
      ),
      
      // === 1天级别数据 (1D) ===
      TradeMarkData(
        timestamp: now - 7 * 24 * 60 * 60 * 1000, // 1周前
        type: TradeType.sell,
        price: 47500.0,
        maxPrice: 47700.0,
        volume: 1.2,
        orderId: 'sell_1d_1',
      ),
      TradeMarkData(
        timestamp: now - 14 * 24 * 60 * 60 * 1000, // 2周前
        type: TradeType.buy,
        price: 47000.0,
        maxPrice: 47200.0,
        volume: 0.9,
        orderId: 'buy_1d_1',
      ),
      TradeMarkData(
        timestamp: now - 21 * 24 * 60 * 60 * 1000, // 3周前
        type: TradeType.sell,
        price: 46500.0,
        maxPrice: 46800.0,
        volume: 1.5,
        orderId: 'sell_1d_2',
      ),
      
      // === 1周级别数据 (1W) ===
      TradeMarkData(
        timestamp: now - 30 * 24 * 60 * 60 * 1000, // 1个月前
        type: TradeType.buy,
        price: 45000.0,
        maxPrice: 45300.0,
        volume: 2.0,
        orderId: 'buy_1w_1',
      ),
      TradeMarkData(
        timestamp: now - 60 * 24 * 60 * 60 * 1000, // 2个月前
        type: TradeType.sell,
        price: 44000.0,
        maxPrice: 44500.0,
        volume: 1.8,
        orderId: 'sell_1w_1',
      ),
      TradeMarkData(
        timestamp: now - 90 * 24 * 60 * 60 * 1000, // 3个月前
        type: TradeType.buy,
        price: 43000.0,
        maxPrice: 43400.0,
        volume: 2.5,
        orderId: 'buy_1w_2',
      ),
      
      // === 1月级别数据 (1M) ===
      TradeMarkData(
        timestamp: now - 180 * 24 * 60 * 60 * 1000, // 6个月前
        type: TradeType.sell,
        price: 40000.0,
        maxPrice: 40800.0,
        volume: 3.0,
        orderId: 'sell_1m_1',
      ),
      TradeMarkData(
        timestamp: now - 365 * 24 * 60 * 60 * 1000, // 1年前
        type: TradeType.buy,
        price: 35000.0,
        maxPrice: 35500.0,
        volume: 4.0,
        orderId: 'buy_1m_1',
      ),
    ];
  }
}