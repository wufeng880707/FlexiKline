import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/flexi_theme.dart';

/// 颜色选择器 - 透明覆盖层实现
class ColorSelector extends ConsumerStatefulWidget {
  const ColorSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 140,
    this.height = 32,
    this.colors = defaultColors,
    this.panelOffset = 4.0, // 组件和面板之间的间距，默认2px
  });

  static const List<Color> defaultColors = [
    // 第一行 - 亮色系
    Color(0xFFFFEB3B), // 黄色
    Color(0xFF9C27B0), // 紫色
    Color(0xFF2196F3), // 蓝色
    Color(0xFFE91E63), // 粉红
    Color(0xFF4CAF50), // 绿色

    // 第二行 - 深色系
    Color(0xFFFF9800), // 橙色
    Color(0xFF673AB7), // 深紫
    Color(0xFF00BCD4), // 青色
    Color(0xFFFF6B9D), // 浅粉
    Color(0xFF8BC34A), // 浅绿
  ];

  final Color value;
  final ValueChanged<Color> onChanged;
  final double width;
  final double height;
  final List<Color> colors;
  final double panelOffset; // 组件和面板之间的间距

  @override
  ConsumerState<ColorSelector> createState() => _ColorSelectorState();
}

class _ColorSelectorState extends ConsumerState<ColorSelector> {
  OverlayEntry? _overlayEntry;
  final GlobalKey _buttonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return GestureDetector(
      key: _buttonKey,
      onTap: () => _showColorPickerOverlay(context, theme),
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(border: Border.all(color: theme.dividerLine), borderRadius: BorderRadius.circular(4), color: theme.cardBg),
        child: Row(
          // mainAxisSize: MainAxisSize.min,
          children: [
            // 颜色块
            Container(
              margin: const EdgeInsetsDirectional.symmetric(horizontal: 10),
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                color: widget.value,
                borderRadius: BorderRadius.all(Radius.circular(4.r)),
              ),
            ),
            const Spacer(),
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

  void _showColorPickerOverlay(BuildContext context, FKTheme theme) {
    final RenderBox? renderBox = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // 直接使用Overlay，避免Dialog坐标系统问题
    final OverlayState overlay = Overlay.of(context);

    // 获取按钮相对于Overlay的位置
    final Offset buttonPosition = renderBox.localToGlobal(Offset.zero);
    final Size buttonSize = renderBox.size;

    print('按钮位置(Overlay坐标): x=${buttonPosition.dx}, y=${buttonPosition.dy}');
    print('按钮尺寸: w=${buttonSize.width}, h=${buttonSize.height}');

    // 面板尺寸配置 - 与_buildColorPanel中的设置保持一致
    const double panelWidthBase = 140.0; // 从160进一步减小到140
    final double panelWidth = panelWidthBase; // 使用ScreenUtil缩放，与_buildColorPanel一致

    // 根据配置计算面板高度 - 与_buildColorPanel保持一致
    const double panelPadding = 10.0; // 与面板配置一致
    const double itemSpacing = 6.0; // 与面板配置一致
    const int itemsPerRow = 5;

    // 计算颜色块大小（与_buildColorPanel中的计算保持一致）
    final double availableWidth = panelWidthBase - panelPadding * 2 - (itemsPerRow - 1) * itemSpacing;
    final double colorSize = (availableWidth / itemsPerRow) - 0.5; // 减少0.5px确保不会溢出

    // 计算总行数
    final int totalColors = 10; // 假设总共10个颜色
    final int rowCount = (totalColors / itemsPerRow).ceil(); // 计算需要的行数

    // 面板高度 = 上下内边距 + 行数*颜色块高度 + (行数-1)*行间距
    final double panelHeight = (panelPadding * 4 + rowCount * colorSize + (rowCount - 1) * itemSpacing);
    const double margin = 16.0;

    final Size screenSize = MediaQuery.of(context).size;

    // 1. 水平对齐判断：检查右对齐是否超出右边界
    double panelLeft;
    bool isLeftAligned;

    // 计算左对齐和右对齐的位置
    final double leftAlignedLeft = buttonPosition.dx;
    final double leftAlignedRight = leftAlignedLeft + panelWidth;
    final double rightAlignedLeft = buttonPosition.dx + buttonSize.width - panelWidth;
    final double rightAlignedRight = rightAlignedLeft + panelWidth;

    // 检查左对齐是否超出右边界
    bool leftWouldOverflow = leftAlignedRight > screenSize.width - margin;
    // 检查右对齐是否超出左边界
    bool rightWouldOverflow = rightAlignedLeft < margin;

    // 智能选择对齐方式
    if (leftWouldOverflow && !rightWouldOverflow) {
      // 左对齐超出，右对齐不超出 → 使用右对齐
      panelLeft = rightAlignedLeft;
      isLeftAligned = false;
    } else if (rightWouldOverflow && !leftWouldOverflow) {
      // 右对齐超出，左对齐不超出 → 使用左对齐
      panelLeft = leftAlignedLeft;
      isLeftAligned = true;
    } else if (!leftWouldOverflow && !rightWouldOverflow) {
      // 都不超出 → 默认使用左对齐
      panelLeft = leftAlignedLeft;
      isLeftAligned = true;
    } else {
      // 都超出 → 强制边界对齐
      panelLeft = margin;
      isLeftAligned = true;
    }

    // 2. 垂直对齐判断：检查向下显示是否超出底部边界
    double panelTop;
    bool isDownwardAligned;

    final double downwardTop = buttonPosition.dy + buttonSize.height + widget.panelOffset;
    if (downwardTop + panelHeight <= screenSize.height - margin) {
      // 向下显示不会超出底部边界
      panelTop = downwardTop;
      isDownwardAligned = true;
    } else {
      // 向下显示会超出底部边界，向上显示
      panelTop = buttonPosition.dy - panelHeight - widget.panelOffset;
      isDownwardAligned = false;

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
          // 颜色面板
          Positioned(
            left: panelLeft,
            top: panelTop,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(8.r),
              child: _buildColorPanel(theme),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildColorPanel(FKTheme theme) {
    // 面板配置参数
    const double panelWidth = 140.0; // 面板宽度
    const double panelPadding = 10.0; // 面板内边距
    const double panelRadius = 3.0; // 面板圆角
    const double itemSpacing = 6.0; // Container之间的间距
    const double colorRadius = 3.0; // 颜色块圆角
    const double borderWidth = 0.5; // 边框宽度
    const double iconSize = 8.0; // 图标大小
    const int itemsPerRow = 5; // 每行数量，默认5个

    // 根据配置计算颜色块大小 - 简单有效的方案
    // 可用宽度 = 面板宽度 - 左右内边距 - (颜色块之间的间距数量 × 间距大小)
    final double availableWidth = panelWidth - panelPadding * 2 - (itemsPerRow - 1) * itemSpacing;
    final double colorSize = (availableWidth / itemsPerRow) - 0.5; // 减少0.5px确保不会溢出

    return Container(
      width: panelWidth,
      padding: EdgeInsets.symmetric(vertical: panelPadding, horizontal: panelPadding),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(panelRadius),
        border: Border.all(color: theme.dividerLine),
      ),
      child: Wrap(
        spacing: itemSpacing, // 水平间距 - 已精确计算
        runSpacing: itemSpacing, // 垂直间距 - 已精确计算
        children: widget.colors.map((color) {
          final isSelected = color == widget.value;
          return GestureDetector(
            onTap: () {
              widget.onChanged(color);
              _removeOverlay();
            },
            child: Container(
              width: colorSize, // 已精确计算的宽度
              height: colorSize, // 已精确计算的高度
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(colorRadius),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: borderWidth,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: _getContrastColor(color),
                      size: iconSize,
                    )
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getContrastColor(Color backgroundColor) {
    final brightness = backgroundColor.computeLuminance();
    return brightness > 0.5 ? Colors.black : Colors.white;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }
}
