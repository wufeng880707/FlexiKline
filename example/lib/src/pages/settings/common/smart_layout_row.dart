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
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 智能布局行组件 - 自动处理溢出问题
class SmartLayoutRow extends StatelessWidget {
  const SmartLayoutRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.spacing = 8.0,
  });

  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
            ),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: mainAxisAlignment,
                crossAxisAlignment: crossAxisAlignment,
                mainAxisSize: mainAxisSize,
                children: _buildSpacedChildren(),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildSpacedChildren() {
    if (children.isEmpty) return [];
    
    final List<Widget> spacedChildren = [];
    
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      
      // 在非最后一个元素后添加间距
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(width: spacing.r));
      }
    }
    
    return spacedChildren;
  }
}

/// 智能弹出定位组件 - 自动处理弹出位置
class SmartPopupPositioner extends StatelessWidget {
  const SmartPopupPositioner({
    super.key,
    required this.child,
    required this.popup,
    required this.isVisible,
    this.offset = const Offset(0, 8),
    this.popupWidth = 280,
    this.popupHeight = 160,
  });

  final Widget child;
  final Widget popup;
  final bool isVisible;
  final Offset offset;
  final double popupWidth;
  final double popupHeight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (isVisible)
          Positioned(
            top: offset.dy,
            child: _buildSmartPositionedPopup(context),
          ),
      ],
    );
  }

  Widget _buildSmartPositionedPopup(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = MediaQuery.of(context).size;
        
        // 计算最佳位置
        double? left;
        double? right;
        
        // 判断是否有足够空间显示在右侧
        final hasRightSpace = popupWidth <= screenSize.width - 32.r;
        
        if (hasRightSpace) {
          // 优先左对齐
          left = offset.dx;
        } else {
          // 空间不够时居中
          left = (screenSize.width - popupWidth.r) / 2 - 16.r;
        }
        
        return Transform.translate(
          offset: Offset(left ?? 0, 0),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: screenSize.width - 32.r,
              maxHeight: popupHeight.r,
            ),
            child: popup,
          ),
        );
      },
    );
  }
}
