# FlexiKline 指标宽度配置指南

## 📏 宽度配置概述

为了提供更细粒度的指标显示控制，我们在 `flexi_kline_indicators_configuration.json` 中为每个指标添加了详细的宽度配置。

## 🎯 配置范围

### 主区指标宽度配置

#### 1. **蜡烛图 (Candle)**
```json
"config": {
  "bodyWidth": 1.0,           // 蜡烛实体宽度倍数
  "shadowWidth": 0.5,         // 蜡烛影线宽度
  "borderWidth": 0.5          // 空心蜡烛边框宽度
}
```

#### 2. **成交量 (Volume)**
```json
"config": {
  "barWidth": 0.8,            // 成交量柱宽度占蜡烛宽度的比例
  "borderWidth": 0.0          // 成交量柱边框宽度
}
```

#### 3. **移动平均线 (MA)**
```json
"config": {
  "lineWidths": [1.0, 1.0, 1.0, 1.0], // 各周期MA线宽度数组
  "pointRadius": 0.0                   // MA线节点半径
}
```

#### 4. **指数移动平均线 (EMA)**
```json
"config": {
  "lineWidths": [1.5, 1.5],   // 各周期EMA线宽度数组
  "pointRadius": 0.0          // EMA线节点半径
}
```

#### 5. **布林带 (BOLL)**
```json
"config": {
  "lineWidths": {
    "upper": 1.0,             // 上轨线宽
    "middle": 1.2,            // 中轨线宽
    "lower": 1.0              // 下轨线宽
  },
  "fillOpacity": 0.1          // 填充区域透明度
}
```

#### 6. **抛物线转向 (SAR)**
```json
"config": {
  "pointRadius": 2.0,         // SAR点的半径大小
  "borderWidth": 0.5,         // SAR点边框宽度
  "minRadius": 1.0,           // SAR点最小半径
  "maxRadius": 4.0            // SAR点最大半径
}
```

#### 7. **均价线 (AVL)**
```json
"config": {
  "lineWidth": 1.2,           // 均价线宽度
  "dashWidth": 0.0,           // 虚线间隔，0表示实线
  "pointRadius": 0.0          // 线上节点半径
}
```

### 副区指标宽度配置

#### 1. **MACD指标**
```json
"config": {
  "lineWidths": {
    "dif": 1.0,               // DIF线宽
    "dea": 1.0                // DEA线宽
  },
  "histogramWidth": 0.6,      // MACD柱状图宽度占蜡烛宽度比例
  "histogramBorderWidth": 0.0 // 柱状图边框宽度
}
```

#### 2. **KDJ指标**
```json
"config": {
  "lineWidths": {
    "k": 1.0,                 // K线宽
    "d": 1.0,                 // D线宽
    "j": 1.2                  // J线宽
  },
  "pointRadius": 0.0,         // 线上节点半径
  "referenceLineWidth": 0.5   // 超买超卖参考线宽度
}
```

#### 3. **RSI指标**
```json
"config": {
  "lineWidths": [1.0, 1.0, 1.0],      // 各周期RSI线宽数组
  "referenceLineWidth": 0.5,          // 超买超卖参考线宽度
  "pointRadius": 0.0                  // 线上节点半径
}
```

#### 4. **成交量移动平均线 (MAVOL)**
```json
"config": {
  "barWidth": 0.8,            // 成交量柱宽度占蜡烛宽度比例
  "lineWidths": [1.0, 1.0],   // 各周期MAVOL线宽数组
  "borderWidth": 0.0          // 成交量柱边框宽度
}
```

#### 5. **OBV指标**
```json
"config": {
  "lineWidth": 1.0,           // OBV线宽度
  "pointRadius": 0.0,         // 线上节点半径
  "fillOpacity": 0.1          // OBV区域填充透明度
}
```

#### 6. **CCI指标**
```json
"config": {
  "lineWidth": 1.0,           // CCI线宽度
  "referenceLineWidth": 0.5,  // CCI参考线宽度(±100)
  "pointRadius": 0.0          // 线上节点半径
}
```

#### 7. **威廉指标 (Williams)**
```json
"config": {
  "lineWidths": [1.0, 1.0],   // 各周期威廉指标线宽数组
  "referenceLineWidth": 0.5,  // 超买超卖参考线宽度
  "pointRadius": 0.0          // 线上节点半径
}
```

## 🎛️ 全局宽度设置

### 全局倍数控制
```json
"widthSettings": {
  "global": {
    "lineWidthMultiplier": 1.0,    // 全局线宽倍数
    "pointSizeMultiplier": 1.0,    // 全局点大小倍数
    "barWidthMultiplier": 1.0      // 全局柱宽倍数
  }
}
```

### 响应式宽度配置
```json
"responsive": {
  "enabled": true,
  "breakpoints": {
    "small": {
      "screenWidth": 360,
      "multiplier": 0.8           // 小屏幕设备宽度调整
    },
    "medium": {
      "screenWidth": 768,
      "multiplier": 1.0           // 中等屏幕设备宽度调整
    },
    "large": {
      "screenWidth": 1024,
      "multiplier": 1.2           // 大屏幕设备宽度调整
    }
  }
}
```

### 无障碍宽度配置
```json
"accessibility": {
  "highContrastMode": {
    "lineWidthIncrease": 0.5,     // 高对比度模式下线宽增加值
    "pointSizeIncrease": 1.0      // 高对比度模式下点大小增加值
  }
}
```

## 🔧 使用场景

### 1. **不同设备适配**
- 小屏手机：较细的线宽，节省空间
- 平板设备：标准线宽，平衡显示效果
- 大屏设备：较粗的线宽，增强可读性

### 2. **用户偏好设置**
- 允许用户调整指标线宽度
- 支持不同的视觉风格偏好
- 提供预设的宽度主题

### 3. **无障碍支持**
- 高对比度模式自动加粗线条
- 视觉障碍用户的友好支持
- 符合无障碍设计标准

### 4. **性能优化**
- 根据设备性能动态调整线宽
- 在性能较低设备上使用更简单的绘制

## 💡 最佳实践

### 1. **宽度配置原则**
- **线性指标**：线宽通常在 0.5-2.0 之间
- **柱状指标**：柱宽比例通常在 0.6-0.9 之间
- **点状指标**：点半径通常在 1.0-4.0 之间

### 2. **视觉层次**
- **主要线条**：使用较粗的线宽突出重要信息
- **辅助线条**：使用较细的线宽，避免干扰主要内容
- **参考线**：使用最细的线宽，仅作参考

### 3. **响应式设计**
- 小屏幕：减少宽度，优先显示内容
- 大屏幕：增加宽度，提升视觉效果
- 高DPI屏幕：适当增加宽度，保持清晰度

## 🎨 配置示例

### 基础配置
```json
{
  "ma": {
    "config": {
      "lineWidths": [1.0, 1.0, 1.0, 1.0]  // 统一线宽
    }
  }
}
```

### 进阶配置
```json
{
  "ma": {
    "config": {
      "lineWidths": [1.2, 1.0, 0.8, 0.6],  // 递减线宽
      "pointRadius": 2.0                    // 显示节点
    }
  }
}
```

### 个性化配置
```json
{
  "boll": {
    "config": {
      "lineWidths": {
        "upper": 1.5,     // 上轨加粗
        "middle": 2.0,    // 中轨最粗
        "lower": 1.5      // 下轨加粗
      },
      "fillOpacity": 0.2  // 增加填充透明度
    }
  }
}
```

## 📊 配置效果

通过精细的宽度配置，可以实现：

- ✅ **更好的视觉层次** - 突出重要指标
- ✅ **设备适配** - 不同设备的最佳显示效果  
- ✅ **用户定制** - 满足个性化需求
- ✅ **无障碍支持** - 包容性设计
- ✅ **性能优化** - 根据设备能力调整

这套完整的宽度配置系统为 FlexiKline 提供了前所未有的显示控制能力！
