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

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';

import '../../framework/serializers.dart';

part 'avl_param.g.dart';

@CopyWith()
@FlexiParamSerializable
final class AVLParam extends Equatable {
  // AVL 指标不需要额外参数，使用默认计算逻辑
  final int dummy; // 添加一个虚拟参数以满足 copy_with_extension 要求
  
  const AVLParam({this.dummy = 0});

  bool isValid(int len) => len > 0;

  factory AVLParam.fromJson(Map<String, dynamic> json) =>
      _$AVLParamFromJson(json);
  Map<String, dynamic> toJson() => _$AVLParamToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [dummy];
} 