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

import 'package:example/src/pages/settings/common/color_selector.dart';
import 'package:example/src/pages/settings/common/line_width_selector.dart';
import 'package:flexi_kline/flexi_kline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../providers/default_kline_config.dart';
import '../../../providers/kline_controller_state_provider.dart';
import '../../../theme/flexi_theme.dart';
import '../common/base_indicator_setting_page.dart';

class AVLSettingPage extends BaseIndicatorSettingPage {
  const AVLSettingPage({
    super.key,
    required this.controller,
  });

  final FlexiKlineController controller;

  @override
  ConsumerState<AVLSettingPage> createState() => _AVLSettingPageState();
}

class _AVLSettingPageState extends BaseIndicatorSettingPageState<AVLSettingPage> {
  // AVL参数
  late AVLParam _originalParam;
  late AVLParam _currentParam;
  
  // UI状态
  late bool enabled;
  late Color lineColor;
  late double lineWidth;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  /// 从当前K线控制器加载AVL指标设置
  void _loadCurrentSettings() {
    final klineState = ref.read(klineStateProvider(widget.controller));
    final controller = klineState.controller;
    
    try {
      // 检查AVL指标是否存在
      const avlKey = FlexiIndicatorKey('avl');
      enabled = controller.mainIndicatorKeys.contains(avlKey);
      
      if (enabled) {
        // 获取当前AVL指标配置
        final avlIndicator = controller.getIndicator<AVLIndicator>(avlKey);
        if (avlIndicator != null) {
          _originalParam = avlIndicator.calcParam;
          _currentParam = _originalParam;
          
          // 从参数中提取UI状态
          lineColor = _currentParam.appearance.color;
          lineWidth = _currentParam.appearance.lineWidth;
        } else {
          throw StateError('AVL indicator not found');
        }
      } else {
        // 使用默认参数
        _originalParam = const AVLParam();
        _currentParam = _originalParam;
        lineColor = _currentParam.appearance.color;
        lineWidth = _currentParam.appearance.lineWidth;
      }
    } catch (e) {
      debugPrint('获取AVL配置失败: $e');
      // 使用默认配置
      _originalParam = const AVLParam();
      _currentParam = _originalParam;
      lineColor = _currentParam.appearance.color;
      lineWidth = _currentParam.appearance.lineWidth;
      enabled = false;
    }
  }

  @override
  String get indicatorName => 'AVL';

  @override
  String get indicatorTitle => 'AVL均价线';

  @override
  List<Widget> buildSettingItems(FKTheme theme) {
    return [

      // 均价线设置
        buildSectionTitle('均价线样式', theme),

        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: theme.cardBg,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: theme.dividerLine),
          ),
          child: // 控制器行
              Row(
            children: [
              Text(
                'AVL',
                style: TextStyle(
                  color: theme.t1,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              // 线宽选择器
              LineWidthSelector(
                value: lineWidth,
                onChanged: (width) {
                  setState(() {
                    lineWidth = width;
                    // 更新当前参数
                    _currentParam = _currentParam.copyWith(
                      appearance: _currentParam.appearance.copyWith(
                        lineWidth: width,
                      ),
                    );
                  });
                },
                color: lineColor,
                width: 80,
                height: 32,
              ),

              SizedBox(width: 26.r),

              // 颜色选择器 - 透明覆盖层实现
              ColorSelector(
                value: lineColor,
                onChanged: (color) {
                  setState(() {
                    lineColor = color;
                    // 更新当前参数
                    _currentParam = _currentParam.copyWith(
                      appearance: _currentParam.appearance.copyWith(
                        color: color,
                      ),
                    );
                  });
                },
                width: 80,
                height: 32,
              ),
            ],
          ),
        ),

        SizedBox(height: 16.r),

        // 说明文字
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: theme.long.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: theme.long.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.long,
                size: 16.r,
              ),
              SizedBox(width: 8.r),
              Expanded(
                child: Text(
                  'AVL均价线：显示当前价格的平均值线，帮助判断价格趋势',
                  style: TextStyle(
                    color: theme.long,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
        ),

    ];
  }

  @override
  Future<void> saveSettings() async {
    debugPrint('保存AVL设置:');
    debugPrint('  线条颜色: ${lineColor.toString()}');
    debugPrint('  线条宽度: $lineWidth');
    debugPrint('  当前参数: $_currentParam');
    
    try {
      final klineState = ref.read(klineStateProvider(widget.controller));
      final controller = klineState.controller;
      const avlKey = FlexiIndicatorKey('avl');
      
      if (enabled && controller.mainIndicatorKeys.contains(avlKey)) {
        // 更新现有的AVL指标
        final oldIndicator = controller.getIndicator<AVLIndicator>(avlKey);
        if (oldIndicator != null) {
          final newIndicator = AVLIndicator(
            height: oldIndicator.height,
            padding: oldIndicator.padding,
            calcParam: _currentParam,
            tipsPadding: oldIndicator.tipsPadding,
            tickCount: oldIndicator.tickCount,
          );
          
          // 使用controller的updateIndicator方法更新
          controller.updateIndicator(newIndicator);
          
          debugPrint('AVL指标参数已更新');
        } else {
          debugPrint('AVL指标未找到，无法更新');
        }
      } else if (enabled) {
        // 添加AVL指标（如果还没有的话）
        controller.addMainIndicator(avlKey);
        debugPrint('AVL指标已启用');
      }
      
      // 保存原始参数为新的参考值
      _originalParam = _currentParam;
      
    } catch (e) {
      debugPrint('保存AVL设置失败: $e');
    }
  }

  @override
  Future<void> resetToDefault() async {
    debugPrint('重置AVL设置为默认值');
    
    try {
      
       
      // 从默认主指标配置中获取AVL指标
      const avlKey = FlexiIndicatorKey('avl');
      final defaultMainIndicators = widget.controller.configuration.getDefaultMainIndicatorBuilders();
      final avlBuilder = defaultMainIndicators[avlKey];
      
      if (avlBuilder != null) {
        // 创建默认的AVL指标实例
        final defaultIndicator = avlBuilder(null) as AVLIndicator;
        final defaultParam = defaultIndicator.calcParam;
        
        setState(() {
          _currentParam = defaultParam;
          lineColor = _currentParam.appearance.color;
          lineWidth = _currentParam.appearance.lineWidth;
        });
        
        debugPrint('AVL指标已重置为默认配置: $_currentParam');
      } else {
        // 如果没有找到默认配置，使用硬编码的默认值
        setState(() {
          _currentParam = const AVLParam();
          lineColor = _currentParam.appearance.color;
          lineWidth = _currentParam.appearance.lineWidth;
        });
        
        debugPrint('使用硬编码默认值重置AVL指标');
      }
    } catch (e) {
      debugPrint('重置AVL设置失败: $e');
      // 出错时使用硬编码的默认值
      setState(() {
        _currentParam = const AVLParam();
        lineColor = _currentParam.appearance.color;
        lineWidth = _currentParam.appearance.lineWidth;
      });
    }
  }
}
