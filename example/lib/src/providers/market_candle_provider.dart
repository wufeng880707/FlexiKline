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

import 'dart:async';

import 'package:flexi_kline/flexi_kline.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final marketCandleProvider =
    StreamNotifierProvider.autoDispose<MarketCandleNotifier, FlexiCandleModel>(
  MarketCandleNotifier.new,
);

class MarketCandleNotifier extends AutoDisposeStreamNotifier<FlexiCandleModel> {
  late StreamController<FlexiCandleModel> controller;

  bool isCrossing = false;

  /// 十字线期间暂存的振幅率字符串
  String? crossRangeRate;

  @override
  Stream<FlexiCandleModel> build() {
    controller = StreamController<FlexiCandleModel>();
    return controller.stream;
  }

  void emitOnCross(FlexiCandleModel? model, {String? rangeRate}) {
    if (model != null) {
      isCrossing = true;
      crossRangeRate = rangeRate;
      controller.add(model);
    } else {
      isCrossing = false;
      crossRangeRate = null;
    }
  }

  void emit(FlexiCandleModel model) {
    if (isCrossing) return;
    controller.add(model);
  }
}
