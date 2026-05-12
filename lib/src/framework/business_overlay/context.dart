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

part of 'business_overlay.dart';

/// 业务叠加层绘制上下文
///
/// 提供坐标转换能力，使 [BusinessOverlayObject] 不直接依赖内部图表类型。
/// 由 [BusinessOverlayBinding] 在每次绑定/绘制时构造。
class BusinessOverlayPaintContext {
  const BusinessOverlayPaintContext({
    required this.chartRect,
    required this.precision,
    required this.valueToDy,
    required this.dyToValue,
  });

  /// 主图绘制区域
  final Rect chartRect;

  /// 价格精度（小数位数）
  final int precision;

  /// 价格值 → 像素 Y 坐标
  final double Function(FlexiNum value) valueToDy;

  /// 像素 Y 坐标 → 价格值
  final FlexiNum? Function(double dy) dyToValue;
}
