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

/// 业务叠加层交互状态
///
/// 状态流转:
/// Normal  --[tap 命中]--> Editing
/// Editing --[tap 空白 / 关闭]--> Normal
/// Editing --[tap 其他对象]--> Editing(other)
/// Editing --[拖拽手柄开始拖]--> Dragging
/// Dragging --[拖拽结束]--> Editing
/// Editing --[删除按钮]--> callback → Normal
sealed class BusinessOverlayState {
  const BusinessOverlayState();

  bool get isNormal => this is BONormal;
  bool get isEditing => this is BOEditing;
  bool get isDragging => this is BODragging;

  BusinessOverlayObject? get object => null;
}

class BONormal extends BusinessOverlayState {
  const BONormal();
}

class BOEditing extends BusinessOverlayState {
  const BOEditing(this.object);

  @override
  final BusinessOverlayObject object;
}

class BODragging extends BusinessOverlayState {
  const BODragging(this.object);

  @override
  final BusinessOverlayObject object;
}
