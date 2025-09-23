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

import 'package:example/src/theme/flexi_theme.dart';
import 'package:flexi_kline/flexi_kline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../widgets/no_thumb_scroll_behavior.dart';
import '../../widgets/shrink_icon_button.dart';

/// 绘制工具菜单栏组件
/// 
/// 提供绘制工具选择、连续绘制开关、磁吸模式切换、
/// 显示/隐藏绘制对象、清空所有绘制对象等功能
class FlexiKlineDrawMenubar extends ConsumerStatefulWidget {
  const FlexiKlineDrawMenubar({
    super.key,
    required this.controller,
  });

  final FlexiKlineController controller;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FlexiKlineDrawMenubarState();
}

class _FlexiKlineDrawMenubarState extends ConsumerState<FlexiKlineDrawMenubar> {
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    return Container(
      alignment: AlignmentDirectional.centerStart,
      padding: EdgeInsetsDirectional.symmetric(horizontal: 8.r),
      child: Row(
        children: [
          Expanded(
            child: _DrawToolsScrollableSection(controller: widget.controller),
          ),
          _Divider(theme: theme),
          _ContinuousDrawToggle(controller: widget.controller, theme: theme),
          _MagnetModeToggle(controller: widget.controller, theme: theme),
          _VisibilityToggle(controller: widget.controller),
          _ClearAllButton(controller: widget.controller),
          const _SaveButton(),
        ],
      ),
    );
  }
}

/// 绘制工具滚动区域
class _DrawToolsScrollableSection extends ConsumerWidget {
  const _DrawToolsScrollableSection({required this.controller});

  final FlexiKlineController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    
    return ScrollConfiguration(
      behavior: NoThumbScrollBehavior().copyWith(scrollbars: false),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: ValueListenableBuilder(
          valueListenable: controller.drawStateListener,
          builder: (context, state, child) {
            final drawType = state.object?.type;
            return Row(
              children: controller.supportDrawTypes.map((type) {
                return ShrinkIconButton(
                  key: ValueKey(type),
                  onPressed: () => controller.startDraw(type),
                  content: 'assets/svgs/${type.id}.svg',
                  color: drawType == type ? theme.t1 : theme.t2,
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

/// 分隔线组件
class _Divider extends StatelessWidget {
  const _Divider({required this.theme});

  final FKTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.dividerLine,
      width: 1.r,
      height: 18.r,
      margin: EdgeInsets.symmetric(horizontal: 4.r),
    );
  }
}

/// 连续绘制开关
class _ContinuousDrawToggle extends StatelessWidget {
  const _ContinuousDrawToggle({
    required this.controller,
    required this.theme,
  });

  final FlexiKlineController controller;
  final FKTheme theme;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.drawContinuousListener,
      builder: (context, isOn, child) => ShrinkIconButton(
        onPressed: () => controller.setDrawContinuous(!isOn),
        content: Icons.auto_awesome_motion_rounded,
        color: isOn ? theme.t1 : theme.t2,
      ),
    );
  }
}

/// 磁吸模式切换
class _MagnetModeToggle extends StatelessWidget {
  const _MagnetModeToggle({
    required this.controller,
    required this.theme,
  });

  final FlexiKlineController controller;
  final FKTheme theme;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.drawMagnetModeListener,
      builder: (context, mode, child) => ShrinkIconButton(
        onPressed: () => controller.setDrawMagnetMode(mode.next),
        color: mode.isNormal ? theme.t2 : Colors.blueAccent,
        content: 'assets/svgs/magnet_mode_${mode.name}.svg',
      ),
    );
  }
}

/// 显示/隐藏切换
class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle({required this.controller});

  final FlexiKlineController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.drawVisibilityListener,
      builder: (context, isShow, child) => ShrinkIconButton(
        onPressed: () => controller.setDrawVisibility(!isShow),
        content: isShow
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined,
      ),
    );
  }
}

/// 清空所有绘制对象按钮
class _ClearAllButton extends StatelessWidget {
  const _ClearAllButton({required this.controller});

  final FlexiKlineController controller;

  @override
  Widget build(BuildContext context) {
    return ShrinkIconButton(
      onPressed: () => controller.removeAllDrawObject(),
      content: Icons.cleaning_services_rounded,
    );
  }
}

/// 保存按钮（暂时未实现功能）
class _SaveButton extends StatelessWidget {
  const _SaveButton();

  @override
  Widget build(BuildContext context) {
    return ShrinkIconButton(
      onPressed: () {
        // TODO: 实现保存绘制对象到文件的功能
      },
      content: Icons.login_rounded,
    );
  }
}
