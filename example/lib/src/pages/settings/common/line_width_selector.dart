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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/flexi_theme.dart';

/// 线宽选择器 - 展开式设计，类似 ColorSelector 的交互模式
class LineWidthSelector extends ConsumerStatefulWidget {
  const LineWidthSelector({
    super.key,
    required this.value,
    required this.onChanged,
    required this.color,
    this.width = 120,
    this.height = 32,
    this.availableWidths = const [1.0, 2.0, 4.0, 5.0],
    this.panelOffset = 4.0, // 组件和面板之间的间距
  });

  final double value;
  final ValueChanged<double> onChanged;
  final Color color;
  final double width;
  final double height;
  final List<double> availableWidths;
  final double panelOffset; // 组件和面板之间的间距

  @override
  ConsumerState<LineWidthSelector> createState() => _LineWidthSelectorState();
}

class _LineWidthSelectorState extends ConsumerState<LineWidthSelector> {
  OverlayEntry? _overlayEntry;
  final GlobalKey _buttonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final WidgetRef ref = this.ref;
    final theme = ref.watch(themeProvider);

    return GestureDetector(
      key: _buttonKey,
      onTap: () => _showLineWidthOverlay(context, theme),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: theme.dividerLine, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsetsDirectional.symmetric(horizontal: 10),
              height: 20,
              width: 20,
              child: CustomPaint(
                size: Size(double.infinity, 20.r),
                painter: LineWidthIconPainter(
                  width: widget.value,
                  color: widget.color,
                ),
              ),
            ),

            Spacer(),
            // 下拉箭头
            Icon(
              Icons.keyboard_arrow_down,
              color: theme.t2,
              size: 16.r,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showLineWidthOverlay(BuildContext context, FKTheme theme) {
    final RenderBox? renderBox = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // 直接使用Overlay，避免Dialog坐标系统问题
    final OverlayState overlay = Overlay.of(context);

    // 获取按钮相对于Overlay的位置
    final Offset buttonPosition = renderBox.localToGlobal(Offset.zero);
    final Size buttonSize = renderBox.size;

    // 面板尺寸配置 - 水平排列
    const double itemWidth = 30.0; // 每个选项的宽度
    const double itemHeight = 30.0; // 每个选项的高度
    const double panelPadding = 8.0;
    const double itemSpacing = 10.0;

    // 计算面板尺寸（水平排列）- 精确计算防止溢出
    final int itemCount = widget.availableWidths.length.clamp(1, 7); // 最多显示7个
    final double panelWidth =
        (panelPadding * 2 + itemCount * itemWidth + (itemCount - 1) * itemSpacing + 2.0).ceilToDouble(); // 加2px缓冲
    final double panelHeight = panelPadding * 2 + itemHeight;
    const double margin = 16.0;

    final Size screenSize = MediaQuery.of(context).size;

    // 1. 水平对齐判断：检查右对齐是否超出右边界
    double panelLeft;

    // 计算左对齐和右对齐的位置
    final double leftAlignedLeft = buttonPosition.dx;
    final double leftAlignedRight = leftAlignedLeft + panelWidth;
    final double rightAlignedLeft = buttonPosition.dx + buttonSize.width - panelWidth;

    // 检查左对齐是否超出右边界
    bool leftWouldOverflow = leftAlignedRight > screenSize.width - margin;
    // 检查右对齐是否超出左边界
    bool rightWouldOverflow = rightAlignedLeft < margin;

    // 智能选择对齐方式 - 优先右对齐
    if (rightWouldOverflow && !leftWouldOverflow) {
      // 右对齐超出，左对齐不超出 → 使用左对齐
      panelLeft = leftAlignedLeft;
    } else if (leftWouldOverflow && !rightWouldOverflow) {
      // 左对齐超出，右对齐不超出 → 使用右对齐
      panelLeft = rightAlignedLeft;
    } else if (!leftWouldOverflow && !rightWouldOverflow) {
      // 都不超出 → 优先使用右对齐
      panelLeft = rightAlignedLeft;
    } else {
      // 都超出 → 强制边界对齐
      panelLeft = margin;
    }

    // 2. 垂直对齐判断：检查向下显示是否超出底部边界
    double panelTop;

    final double downwardTop = buttonPosition.dy + buttonSize.height + widget.panelOffset;
    if (downwardTop + panelHeight <= screenSize.height - margin) {
      // 向下显示不会超出底部边界
      panelTop = downwardTop;
    } else {
      // 向下显示会超出底部边界，向上显示
      panelTop = buttonPosition.dy - panelHeight - widget.panelOffset;

      // 检查向上显示是否超出顶部边界
      if (panelTop < margin) {
        // 向上也超出，强制在屏幕中央或可见区域
        panelTop = margin;
      }
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 全屏透明背景，点击关闭
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeOverlay,
              child: Container(color: Colors.transparent),
            ),
          ),
          // 线宽面板
          Positioned(
            left: panelLeft,
            top: panelTop,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(8.r),
              child: _buildLineWidthPanel(
                theme,
                panelWidth: panelWidth,
                itemWidth: itemWidth,
                itemHeight: itemHeight,
                panelPadding: panelPadding,
                itemSpacing: itemSpacing,
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  Widget _buildLineWidthPanel(
    FKTheme theme, {
    required double panelWidth,
    required double itemWidth,
    required double itemHeight,
    required double panelPadding,
    required double itemSpacing,
  }) {
    // 面板配置参数 - 水平排列
    const double panelRadius = 8.0;

    // 计算选项数量（水平排列）
    final int itemCount = widget.availableWidths.length.clamp(1, 7);

    return Container(
      width: panelWidth,
      padding: EdgeInsets.all(panelPadding),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(panelRadius),
        border: Border.all(color: theme.dividerLine, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: widget.availableWidths.take(itemCount).map((lineWidth) {
          final isSelected = widget.value == lineWidth;
          final isFirst = widget.availableWidths.indexOf(lineWidth) == 0;

          return Padding(
            padding: EdgeInsets.only(left: isFirst ? 0 : itemSpacing),
            child: GestureDetector(
              onTap: () {
                widget.onChanged(lineWidth);
                _removeOverlay();
              },
              child: Container(
                width: itemWidth,
                height: itemHeight,
                decoration: BoxDecoration(
                  color: isSelected ? widget.color : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: theme.dividerLine.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                ),
                child: Center(
                  child: CustomPaint(
                    size: Size(itemWidth * 0.6, itemHeight * 0.5),
                    painter: LineWidthIconPainter(
                      width: lineWidth,
                      color: isSelected ? Colors.white : theme.t1,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// 线宽预览绘制器
class LineWidthPreviewPainter extends CustomPainter {
  const LineWidthPreviewPainter({
    required this.width,
    required this.color,
  });

  final double width;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    final startPoint = Offset(8, size.height / 2);
    final endPoint = Offset(size.width - 8, size.height / 2);

    canvas.drawLine(startPoint, endPoint, paint);
  }

  @override
  bool shouldRepaint(covariant LineWidthPreviewPainter oldDelegate) {
    return width != oldDelegate.width || color != oldDelegate.color;
  }
}

/// 线宽图标绘制器 - 用于按钮和面板显示
class LineWidthIconPainter extends CustomPainter {
  const LineWidthIconPainter({
    required this.width,
    required this.color,
  });

  final double width;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width.clamp(1.0, 4.0) // 调整线宽范围，最小1.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 绘制三段线组成的折线图标（匹配您图片中的效果）
    final path = Path();

    // 第一段：左下到左中上
    path.moveTo(size.width * 0.1, size.height * 0.8);
    path.lineTo(size.width * 0.4, size.height * 0.3);

    // 第二段：左中上到中下
    path.lineTo(size.width * 0.6, size.height * 0.7);

    // 第三段：中下到右上
    path.lineTo(size.width * 0.9, size.height * 0.2);

    paint.style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant LineWidthIconPainter oldDelegate) {
    return width != oldDelegate.width || color != oldDelegate.color;
  }
}
