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

/// 柱状图样式枚举（K线样式）
enum BarStyle {
  hollow, // 空心
  filled, // 实心
}

/// K线样式选择器（空心/实心）- 展开式下拉选择器
class KLineStyleSelector extends ConsumerStatefulWidget {
  const KLineStyleSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 120,
    this.height = 32,
    this.panelOffset = 4.0, // 组件和面板之间的间距
  });

  final BarStyle value;
  final ValueChanged<BarStyle> onChanged;
  final double width;
  final double height;
  final double panelOffset; // 组件和面板之间的间距

  @override
  ConsumerState<KLineStyleSelector> createState() => _KLineStyleSelectorState();
}

class _KLineStyleSelectorState extends ConsumerState<KLineStyleSelector> {
  OverlayEntry? _overlayEntry;
  final GlobalKey _buttonKey = GlobalKey();

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final WidgetRef ref = this.ref;
    final theme = ref.watch(themeProvider);

    return GestureDetector(
      key: _buttonKey,
      onTap: () => _showStyleOverlay(context, theme),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: theme.cardBg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: theme.dividerLine, width: 0.5),
        ),
        child: Row(
          children: [
            SizedBox(width: 8),
            // 显示当前选中的样式文本
            Text(
              _getBarStyleName(widget.value),
              style: TextStyle(
                color: theme.t1,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            // 下拉箭头
            Icon(
              Icons.keyboard_arrow_down,
              color: theme.t2,
              size: 16,
            ),
            SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  void _showStyleOverlay(BuildContext context, FKTheme theme) {
    final RenderBox? renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // 直接使用Overlay，避免Dialog坐标系统问题
    final OverlayState overlay = Overlay.of(context);

    // 获取按钮相对于Overlay的位置
    final Offset buttonPosition = renderBox.localToGlobal(Offset.zero);
    final Size buttonSize = renderBox.size;

    // 面板尺寸配置 - 垂直列表
    const double panelWidth = 80.0;
    const double itemHeight = 32.0;
    const double panelPadding = 4.0;

    // 计算面板尺寸（垂直排列）
    final int itemCount = BarStyle.values.length;
    final double panelHeight = panelPadding * 2 + itemCount * itemHeight;
    const double margin = 16.0;

    final Size screenSize = MediaQuery.of(context).size;

    // 1. 水平对齐判断：检查右对齐是否超出右边界
    double panelLeft;

    // 计算左对齐和右对齐的位置
    final double leftAlignedLeft = buttonPosition.dx;
    final double leftAlignedRight = leftAlignedLeft + panelWidth;
    final double rightAlignedLeft =
        buttonPosition.dx + buttonSize.width - panelWidth;

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

    // 最终边界检查 - 确保面板绝不会超出屏幕
    panelLeft = panelLeft.clamp(margin, screenSize.width - panelWidth - margin);

    // 2. 垂直对齐判断：检查向下显示是否超出底部边界
    double panelTop;

    final double downwardTop =
        buttonPosition.dy + buttonSize.height + widget.panelOffset;
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
          // 样式面板
          Positioned(
            left: panelLeft,
            top: panelTop,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(8),
              child: _buildStylePanel(
                theme,
                panelWidth: panelWidth,
                itemHeight: itemHeight,
                panelPadding: panelPadding,
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  Widget _buildStylePanel(
    FKTheme theme, {
    required double panelWidth,
    required double itemHeight,
    required double panelPadding,
  }) {
    // 面板配置参数 - 垂直排列
    const double panelRadius = 8.0;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: BarStyle.values.map((style) {
          final isSelected = widget.value == style;
          final isLast =
              BarStyle.values.indexOf(style) == BarStyle.values.length - 1;

          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  widget.onChanged(style);
                  _removeOverlay();
                },
                child: Container(
                  height: itemHeight,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.long.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 8),
                      Text(
                        _getBarStyleName(style),
                        style: TextStyle(
                          color: isSelected ? theme.long : theme.t1,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Icon(
                          Icons.check,
                          color: theme.long,
                          size: 16,
                        ),
                      SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: theme.dividerLine.withValues(alpha: 0.3),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _getBarStyleName(BarStyle style) {
    switch (style) {
      case BarStyle.hollow:
        return '空心';
      case BarStyle.filled:
        return '实心';
    }
  }
}

/// 柱状图样式选择器（传统版本）- 用于下拉选择
class BarStyleSelector extends ConsumerWidget {
  const BarStyleSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 80,
    this.height = 32,
  });

  final BarStyle value;
  final ValueChanged<BarStyle> onChanged;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return GestureDetector(
      onTap: () => _showBarStylePicker(context, theme),
      child: Container(
        width: width.r,
        height: height.r,
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerLine),
          borderRadius: BorderRadius.circular(4.r),
          color: theme.cardBg,
        ),
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: CustomPaint(
                  size: Size(20.r, 16.r),
                  painter: BarStylePainter(
                    style: value,
                    color: theme.t1,
                    strokeWidth: 1.5,
                  ),
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: theme.t2,
              size: 16.r,
            ),
            SizedBox(width: 4.r),
          ],
        ),
      ),
    );
  }

  void _showBarStylePicker(BuildContext context, FKTheme theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardBg,
        title: Text(
          '选择样式',
          style: TextStyle(
            color: theme.t1,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: BarStyle.values.map((style) {
            return ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 8.r),
              leading: CustomPaint(
                size: Size(24.r, 20.r),
                painter: BarStylePainter(
                  style: style,
                  color: theme.t1,
                  strokeWidth: 1.5,
                ),
              ),
              title: Text(
                _getBarStyleName(style),
                style: TextStyle(color: theme.t1, fontSize: 14.sp),
              ),
              trailing: value == style
                  ? Icon(Icons.check, color: theme.long, size: 16.r)
                  : null,
              onTap: () {
                onChanged(style);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getBarStyleName(BarStyle style) {
    switch (style) {
      case BarStyle.hollow:
        return '空心';
      case BarStyle.filled:
        return '实心';
    }
  }
}

/// 柱状图样式绘制器
class BarStylePainter extends CustomPainter {
  const BarStylePainter({
    required this.style,
    required this.color,
    required this.strokeWidth,
  });

  final BarStyle style;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;

    final rect = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.2,
      size.width * 0.6,
      size.height * 0.6,
    );

    switch (style) {
      case BarStyle.hollow:
        paint.style = PaintingStyle.stroke;
        canvas.drawRect(rect, paint);
        break;

      case BarStyle.filled:
        paint.style = PaintingStyle.fill;
        canvas.drawRect(rect, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant BarStylePainter oldDelegate) {
    return style != oldDelegate.style ||
        color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}
