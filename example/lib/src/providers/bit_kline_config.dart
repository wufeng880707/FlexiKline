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

import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';

import 'package:example/src/config.dart';
import 'package:example/src/theme/export.dart';
import 'package:example/src/theme/flexi_theme.dart';
import 'package:example/src/utils/cache_util.dart';
import 'package:flexi_kline/flexi_kline.dart' hide Overlay;
import 'package:flexi_kline/src/framework/draw/overlay.dart' as flexi_overlay;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class BaseBitFlexiKlineTheme with FlexiKlineThemeTextStyle implements IFlexiKlineTheme {
  double? _scale;
  @override
  double get scale => _scale ??= math.min(
        ScreenUtil().scaleWidth,
        ScreenUtil().scaleHeight,
      );

  double? _pixel;
  @override
  double get pixel {
    if (_pixel != null) return _pixel!;
    double? ratio = ScreenUtil().pixelRatio;
    ratio ??= PlatformDispatcher.instance.displays.first.devicePixelRatio;
    _pixel = 1 / ratio;
    return _pixel!;
  }

  @override
  double setDp(num size) => ScreenUtil().radius(size);

  @override
  double setSp(num fontSize) => ScreenUtil().setSp(fontSize);

  @override
  Color long = const Color(0xFF21B26D);

  @override
  Color short = const Color(0xFFEE4549);

  @override
  Color transparent = Colors.transparent;

  @override
  Color crossColor = const Color(0xFFF6A701);

  @override
  Color get drawColor => Colors.blueAccent;

  @override
  Color get drawTextBg => Colors.blue;
}

class BitFlexiKlineLightTheme extends BaseBitFlexiKlineTheme {
  @override
  String get key => 'flexi_kline_config_key_bit-light';

  @override
  Color get chartBg => const Color(0xFFFBFDFF);

  @override
  Color get tooltipBg => const Color(0xFFFFFFFF);

  @override
  Color get countDownTextBg => const Color(0xFFF5F5F5);

  @override
  Color get crossTextBg => const Color(0xFF444444);

  @override
  Color get lastPriceTextBg => Colors.black54;

  @override
  Color get gridLine => textColor;

  @override
  Color get markLine => textColor;

  @override
  Color get themeColor => Colors.white;

  @override
  Color get textColor => const Color(0xFF111111);

  @override
  Color get ticksTextColor => const Color(0xFF949494);

  @override
  Color get lastPriceTextColor => crossTextColor;

  @override
  Color get crossTextColor => const Color(0xFFF9F8F8);

  @override
  Color get tooltipTextColor => textColor;

  @override
  Color get drawColor => Colors.blue;
}

class BitFlexiKlineDarkTheme extends BaseBitFlexiKlineTheme {
  @override
  String key = 'flexi_kline_config_key_bit-dark';

  @override
  Color chartBg = const Color(0xFF111111);

  @override
  Color tooltipBg = const Color(0xFF16181A);

  @override
  Color countDownTextBg = const Color(0xFF333333);

  @override
  Color crossTextBg = const Color(0xFF404040);

  @override
  Color lastPriceTextBg = Colors.black54;

  @override
  Color gridLine = const Color(0xFF222222);

  @override
  Color markLine = const Color(0xFFA0A0A0);

  @override
  Color get themeColor => Colors.black;

  @override
  Color textColor = const Color(0xFFA0A0A0);

  @override
  Color ticksTextColor = const Color(0xFF949494);

  @override
  Color lastPriceTextColor = const Color(0xFF5F5F5F);

  @override
  Color crossTextColor = const Color(0xFFFFFFFF);

  @override
  Color tooltipTextColor = const Color(0xFF9D9DA1);

  @override
  Color get drawColor => Colors.lightBlue;
}

final lightBitFlexiKlineTheme = BitFlexiKlineLightTheme();
final darkBitFlexiKlineTheme = BitFlexiKlineDarkTheme();

final bitFlexiKlineThemeProvider = StateProvider<BaseBitFlexiKlineTheme>((ref) {
  final brightness = ref.watch(
    themeProvider.select((theme) => theme.brightness),
  );
  if (brightness == Brightness.dark) {
    return darkBitFlexiKlineTheme;
  } else {
    return lightBitFlexiKlineTheme;
  }
});

class BitFlexiKlineConfiguration with FlexiKlineThemeConfigurationMixin {
  final WidgetRef ref;

  BitFlexiKlineConfiguration({required this.ref});
  
  @override
  Size get initialMainSize {
    return Size(ScreenUtil().screenWidth, 300.r);
  }

  @override
  FlexiKlineConfig getFlexiKlineConfig() {
    final theme = ref.read(bitFlexiKlineThemeProvider);
    try {
      final String? jsonStr = CacheUtil().get(theme.key);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final json = jsonDecode(jsonStr);
        if (json is Map<String, dynamic>) {
          return FlexiKlineConfig.fromJson(json);
        }
      }
    } catch (err, stack) {
      defLogger.e('getFlexiKlineConfig error:$err', stackTrace: stack);
    }

    return genFlexiKlineConfig();
  }

  @override
  void saveFlexiKlineConfig(FlexiKlineConfig config) {
    final jsonSrc = jsonEncode(config);
    CacheUtil().setString(config.key, jsonSrc);
  }

  @override
  LoadingConfig genInnerLoadingConfig() {
    final theme = ref.read(bitFlexiKlineThemeProvider);
    return super.genInnerLoadingConfig().copyWith(
          background: theme.countDownTextBg,
          valueColor: theme.crossColor,
        );
  }

  @override
  CrossConfig genCrossConfig() {
    return super.genCrossConfig().copyWith(
          moveByCandleInBlank: true,
        );
  }

  @override
  GestureConfig genGestureConfig() {
    return super.genGestureConfig().copyWith(
          tolerance: ToleranceConfig(distanceFactor: 0.5),
        );
  }

  @override
  SettingConfig genSettingConfig() {
    return super.genSettingConfig().copyWith(
          candleFixedSpacing: null,
          candleSpacingParts: 7,
        );
  }

  @override
  TimeIndicator genTimeIndicator(SettingConfig setting) {
    return super.genTimeIndicator(setting).copyWith(
          position: DrawPosition.bottom,
        );
  }

  @override
  Iterable<flexi_overlay.Overlay> getOverlayListConfig(String instId) {
    try {
      final String? jsonStr = CacheUtil().get('overlay_$instId');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final json = jsonDecode(jsonStr);
        if (json is List) {
          return json.map((e) => flexi_overlay.Overlay.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
    } catch (err, stack) {
      defLogger.e('getOverlayListConfig error:$err', stackTrace: stack);
    }
    return [];
  }

  @override
  void saveOverlayListConfig(String instId, Iterable<flexi_overlay.Overlay> list) {
    try {
      final jsonList = list.map((overlay) => overlay.toJson()).toList();
      final jsonSrc = jsonEncode(jsonList);
      CacheUtil().setString('overlay_$instId', jsonSrc);
    } catch (err, stack) {
      defLogger.e('saveOverlayListConfig error:$err', stackTrace: stack);
    }
  }

  @override
  IFlexiKlineTheme get theme => ref.read(bitFlexiKlineThemeProvider);
}
