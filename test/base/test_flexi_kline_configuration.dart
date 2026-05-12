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

import 'dart:ui';

import 'package:flexi_kline/flexi_kline.dart';
import 'package:flutter/material.dart' hide Overlay;

class TestFlexiKlineTheme implements IFlexiKlineTheme {
  double? _scale;
  double get scale {
    if (_scale != null) return _scale!;
    final view = PlatformDispatcher.instance.implicitView;
    final size = view != null
        ? view.physicalSize / view.devicePixelRatio
        : const Size(393, 852);
    _scale = size.shortestSide / 393;
    return _scale!;
  }

  double? _pixel;
  double get pixel {
    if (_pixel != null) return _pixel!;
    final view = PlatformDispatcher.instance.implicitView;
    _pixel = view != null ? 1.0 / view.devicePixelRatio : 1.0;
    return _pixel!;
  }

  double setDp(num size) => size * scale;

  double setSp(num fontSize) => fontSize * scale;

  Color long = const Color(0xFF33BD65);

  Color short = const Color(0xFFE84E74);

  @override
  Color get longColor => long;

  @override
  Color get shortColor => short;

  @override
  Color chartBg = const Color(0xFFFFFFFF);

  @override
  Color tooltipBg = const Color(0xFFF2F2F2);

  Color countDownTextBg = const Color(0xFFBDBDBD);

  @override
  Color get countDownBg => countDownTextBg;

  @override
  Color crossTextBg = const Color(0xFF111111);

  // @override
  // Color drawTextBg = Colors.blue;

  Color transparent = Colors.transparent;

  Color lastPriceTextBg = Colors.black54;

  @override
  Color get lastPriceBg => lastPriceTextBg;

  Color gridLine = const Color(0xffE9EDF0);

  Color crossColor = const Color(0xFF000000);

  Color get drawColor => Colors.blue;

  Color get drawTextColor => const Color(0xFFFFFFFF);

  @override
  Color markLineColor = Colors.blue;

  Color get themeColor => Colors.white;

  @override
  Color textColor = const Color(0xFF000000);

  @override
  Color ticksTextColor = const Color(0xFF949494);

  Color lastPriceTextColor = const Color(0xFF5F5F5F);

  @override
  Color get lastPriceColor => lastPriceTextColor;

  @override
  Color crossTextColor = const Color(0xFFFFFFFF);

  @override
  Color tooltipTextColor = const Color(0xFF949494);

  Color get latestPriceTextBg => const Color(0xFF000000);

  @override
  Color get latestPriceBg => latestPriceTextBg;

  @override
  Color get dragBg => const Color(0x33000000);

  @override
  Color get lineChartColor => const Color(0xFF2196F3);

  @override
  Color get gridLineColor => gridLine;

  @override
  Color get crosshairColor => crossColor;

  @override
  Color get drawToolColor => drawColor;
}

class TestFlexiKlineConfiguration with FlexiKlineThemeConfigurationMixin {
  @override
  IFlexiKlineTheme get theme => TestFlexiKlineTheme();

  @override
  Map<IDrawType, DrawObjectBuilder> get drawObjectBuilders {
    return {};
  }

  @override
  MainPaintObjectIndicator genMainIndicator(
    MainPaintObjectIndicator<Indicator>? mainIndicator,
  ) {
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic>? getConfig(String key) {
    throw UnimplementedError();
  }

  @override
  Future<bool> setConfig(String key, Map<String, dynamic> value) {
    throw UnimplementedError();
  }

  @override
  String get configKey => 'test';
}
