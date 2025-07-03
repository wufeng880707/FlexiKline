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

import 'dart:math' as math;
import 'dart:ui';

import 'package:flexi_kline/flexi_kline.dart';
import 'package:flexi_kline/src/framework/draw/overlay.dart' as flexi_overlay;
import 'package:flutter/material.dart';

class TestFlexiKlineTheme implements IFlexiKlineTheme {
  @override
  String key = 'flexi_kline_config_key_test';

  double? _scale;
  @override
  double get scale {
    if (_scale != null) return _scale!;
    final mediaQuery = MediaQueryData.fromWindow(window);
    _scale = math.min(mediaQuery.size.width, mediaQuery.size.height) / 393;
    return _scale!;
  }

  double? _pixel;
  @override
  double get pixel {
    if (_pixel != null) return _pixel!;
    final mediaQuery = MediaQueryData.fromWindow(window);
    _pixel = 1.0 / mediaQuery.devicePixelRatio;
    return _pixel!;
  }

  @override
  double setDp(num size) => size * scale;

  @override
  double setSp(num fontSize) => fontSize * scale;

  @override
  Color long = const Color(0xFF33BD65);

  @override
  Color short = const Color(0xFFE84E74);

  @override
  Color chartBg = const Color(0xFFFFFFFF);

  @override
  Color tooltipBg = const Color(0xFFF2F2F2);

  @override
  Color countDownTextBg = const Color(0xFFBDBDBD);

  @override
  Color crossTextBg = const Color(0xFF111111);

  @override
  Color drawTextBg = Colors.blue;

  @override
  Color transparent = Colors.transparent;

  @override
  Color lastPriceTextBg = Colors.black54;

  @override
  Color gridLine = const Color(0xffE9EDF0);

  @override
  Color crossColor = const Color(0xFF000000);

  @override
  Color get drawColor => Colors.blueAccent;

  @override
  Color markLine = const Color(0xFF000000);

  @override
  Color get themeColor => Colors.white;

  @override
  Color textColor = const Color(0xFF000000);

  @override
  Color ticksTextColor = const Color(0xFF949494);

  @override
  Color lastPriceTextColor = const Color(0xFF5F5F5F);

  @override
  Color crossTextColor = const Color(0xFFFFFFFF);

  @override
  Color tooltipTextColor = const Color(0xFF949494);

  @override
  int barType = 1;

  @override
  Color indraTodayAvgColor = const Color(0xFF949494);

  @override
  Color indraTodayCloseColor = const Color(0xFF949494);

  @override
  // TODO: implement longRed
  bool longRed = false;
}

class TestFlexiKlineConfiguration with FlexiKlineThemeConfigurationMixin {
  @override
  Size get initialMainSize {
    final mediaQuery = MediaQueryData.fromWindow(window);
    return Size(mediaQuery.size.width, 300);
  }

  @override
  IFlexiKlineTheme get theme => TestFlexiKlineTheme();

  @override
  FlexiKlineConfig getFlexiKlineConfig() {
    return genFlexiKlineConfig();
  }

  @override
  void saveFlexiKlineConfig(FlexiKlineConfig config) {
    // TODO: implement saveFlexiKlineConfig
  }

  @override
  Iterable<flexi_overlay.Overlay> getOverlayListConfig(String instId) {
    return [];
  }

  @override
  void saveOverlayListConfig(String instId, Iterable<flexi_overlay.Overlay> list) {
    // TODO: implement saveOverlayListConfig
  }

  @override
  FlexiKlineConfig genFlexiKlineConfig() {
    return super.genFlexiKlineConfig()
      ..main.add(const FlexiIndicatorKey('ma'))
      ..main.add(const FlexiIndicatorKey('ema'))
      ..main.add(const FlexiIndicatorKey('boll'))
      ..main.add(const FlexiIndicatorKey('volume'));
  }

  @override
  Map<IIndicatorKey, IndicatorBuilder> mainIndicatorBuilders() {
    return {
      const FlexiIndicatorKey('ma'): (setting) => MAIndicator(
            height: 100,
            padding: EdgeInsets.zero,
            calcParams: [
              MaParam(count: 5, tips: TipsConfig(label: 'MA5:', style: TextStyle(color: Color(0xFF2196F3), fontSize: 12))),
              MaParam(count: 10, tips: TipsConfig(label: 'MA10:', style: TextStyle(color: Color(0xFFE91E63), fontSize: 12))),
              MaParam(count: 20, tips: TipsConfig(label: 'MA20:', style: TextStyle(color: Color(0xFF4CAF50), fontSize: 12))),
            ],
            tipsPadding: EdgeInsets.zero,
            lineWidth: 1.0,
          ),
      const FlexiIndicatorKey('ema'): (setting) => EMAIndicator(
            height: 100,
            padding: EdgeInsets.zero,
            calcParams: [
              MaParam(count: 12, tips: TipsConfig(label: 'EMA12:', style: TextStyle(color: Color(0xFFFF9800), fontSize: 12))),
              MaParam(count: 26, tips: TipsConfig(label: 'EMA26:', style: TextStyle(color: Color(0xFF9C27B0), fontSize: 12))),
            ],
            tipsPadding: EdgeInsets.zero,
            lineWidth: 1.0,
          ),
      const FlexiIndicatorKey('boll'): (setting) => BOLLIndicator(
            height: 100,
            padding: EdgeInsets.zero,
            calcParam: BOLLParam(n: 20, std: 2),
            mbTips: TipsConfig(label: 'BOLL:', style: TextStyle(color: Color(0xFF2196F3), fontSize: 12)),
            upTips: TipsConfig(label: 'UB:', style: TextStyle(color: Color(0xFFE91E63), fontSize: 12)),
            dnTips: TipsConfig(label: 'LB:', style: TextStyle(color: Color(0xFF4CAF50), fontSize: 12)),
            tipsPadding: EdgeInsets.zero,
            lineWidth: 1.0,
          ),
      const FlexiIndicatorKey('volume'): (setting) => VolumeIndicator(
            height: 100,
            padding: EdgeInsets.zero,
            volTips: TipsConfig(label: 'VOL:', style: TextStyle(color: Color(0xFF000000), fontSize: 12)),
            tipsPadding: EdgeInsets.zero,
            tickCount: 3,
            precision: 2,
          ),
      candleIndicatorKey: (setting) => CandleIndicator(
            height: 100,
            high: MarkConfig(),
            low: MarkConfig(),
            last: MarkConfig(),
            latest: MarkConfig(),
            countDown: TextAreaConfig(),
            padding: EdgeInsets.zero,
          ),
    };
  }
}
