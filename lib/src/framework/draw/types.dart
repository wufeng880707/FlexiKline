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

part of 'overlay.dart';

const drawObjectDefaultZIndex = 0;

<<<<<<< HEAD:lib/src/framework/draw/common.dart
typedef DrawObjectBuilder<T extends Overlay, R extends DrawObject<T>> = R?
    Function(T overlay, DrawConfig config);
=======
typedef DrawObjectBuilder<T extends Overlay, R extends DrawObject<T>> = R? Function(T overlay, DrawConfig config);
>>>>>>> 6c71d9ce122f9b6298b759a5aa16cfb378d1f65d:lib/src/framework/draw/types.dart

/// 绘制类型接口
abstract interface class IDrawType {
  int get steps;
  String get id;
  String get groupId;
}

/// 自定义绘制类型
final class FlexiDrawType implements IDrawType {
  const FlexiDrawType(
    this.id,
    this.steps, {
    String? groupId,
  }) : groupId = groupId ?? drawGroupUnknown;

  @override
  final String groupId;

  @override
  final String id;

  @override
  final int steps;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FlexiDrawType &&
        runtimeType == other.runtimeType &&
        id == other.id &&
        steps == other.steps &&
        groupId == other.groupId;
  }

  @override
  int get hashCode {
<<<<<<< HEAD:lib/src/framework/draw/common.dart
    return runtimeType.hashCode ^
        id.hashCode ^
        steps.hashCode ^
        groupId.hashCode;
=======
    return runtimeType.hashCode ^ id.hashCode ^ steps.hashCode ^ groupId.hashCode;
>>>>>>> 6c71d9ce122f9b6298b759a5aa16cfb378d1f65d:lib/src/framework/draw/types.dart
  }
}

const unknownDrawType = FlexiDrawType('unknown', 0);

const String drawGroupUnknown = 'unknown';

/// 磁吸模式
enum MagnetMode {
  normal,
  weak,
  strong;

  MagnetMode get next {
    switch (this) {
      case MagnetMode.normal:
        return MagnetMode.weak;
      case MagnetMode.weak:
        return MagnetMode.strong;
      case MagnetMode.strong:
        return MagnetMode.normal;
    }
  }

  /// 排除[strong]类型
  MagnetMode get next2 {
    switch (this) {
      case MagnetMode.normal:
        return MagnetMode.weak;
      case MagnetMode.weak:
        return MagnetMode.normal;
      case MagnetMode.strong:
        return MagnetMode.normal;
    }
  }

  bool get isNormal => this == MagnetMode.normal;
  bool get isWeak => this == MagnetMode.weak;
  bool get isStrong => this == MagnetMode.strong;
}
