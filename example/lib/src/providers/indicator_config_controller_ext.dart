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

import 'package:flexi_kline/flexi_kline.dart';

extension IndicatorConfigControllerExt on FlexiKlineController {
  IIndicatorConfig? get indicatorConfigOrNull {
    final config = configuration;
    return config is IIndicatorConfig ? config as IIndicatorConfig : null;
  }

  T? configuredIndicator<T extends Indicator>(IIndicatorKey key) {
    final config = indicatorConfigOrNull;
    if (config == null) return null;

    final indicators = <Indicator>[
      config.candle,
      config.time,
      ...config.mainIndicators,
      ...config.subIndicators,
    ];
    for (final indicator in indicators) {
      if (indicator.key == key && indicator is T) return indicator;
    }
    return null;
  }

  T? configuredMainIndicator<T extends Indicator>(IIndicatorKey key) {
    final config = indicatorConfigOrNull;
    if (config == null) return null;

    for (final indicator in config.mainIndicators) {
      if (indicator.key == key && indicator is T) return indicator;
    }
    return null;
  }

  T? configuredSubIndicator<T extends Indicator>(IIndicatorKey key) {
    final config = indicatorConfigOrNull;
    if (config == null) return null;

    for (final indicator in config.subIndicators) {
      if (indicator.key == key && indicator is T) return indicator;
    }
    return null;
  }

  Future<bool> saveAndUpdateIndicator<T extends Indicator>(T indicator) async {
    final config = indicatorConfigOrNull;
    if (config == null) return false;

    final oldCandle = config.candle;
    final oldTime = config.time;
    final oldMainIndicators = config.mainIndicators;
    final oldSubIndicators = config.subIndicators;

    final json = _indicatorConfigJson(indicator);
    if (json.isEmpty) return false;
    if (!await config.setConfig(indicator.key.id, json)) return false;

    if (!isMounted) return true;
    updateIndicators(
      oldCandle: oldCandle,
      newCandle: config.candle,
      oldTime: oldTime,
      newTime: config.time,
      oldMainIndicators: oldMainIndicators,
      newMainIndicators: config.mainIndicators,
      oldSubIndicators: oldSubIndicators,
      newSubIndicators: config.subIndicators,
    );
    requestRepaint(reset: true);
    markRepaintCross();
    return true;
  }

  Map<String, dynamic> _indicatorConfigJson(Indicator indicator) {
    final json = Map<String, dynamic>.from(indicator.toJson());
    if (json.isNotEmpty) return json;

    final calcParam =
        indicator is ComputedIndicator ? indicator.calcParam : null;
    final calcParamJson = _toJsonMap(calcParam);
    if (calcParamJson == null || calcParamJson.isEmpty) return const {};

    return {
      'height': indicator.height,
      'calcParam': calcParamJson,
    };
  }

  Map<String, dynamic>? _toJsonMap(Object? value) {
    if (value == null) return null;

    try {
      final json = (value as dynamic).toJson();
      if (json is Map<String, dynamic>) return json;
      if (json is Map) return Map<String, dynamic>.from(json);
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<bool> saveAndSetMainIndicator<T extends Indicator>(
    T indicator, {
    required bool enabled,
  }) async {
    if (!await saveAndUpdateIndicator(indicator)) return false;
    if (!isMounted) return true;

    if (enabled) {
      if (!hasAddedMainIndicator(indicator.key)) {
        showMainIndicator(indicator.key);
      }
    } else {
      hideMainIndicator(indicator.key);
    }
    return true;
  }

  Future<bool> saveAndSetSubIndicator<T extends Indicator>(
    T indicator, {
    required bool enabled,
  }) async {
    if (!await saveAndUpdateIndicator(indicator)) return false;
    if (!isMounted) return true;

    if (enabled) {
      if (!hasAddedSubIndicator(indicator.key)) {
        showSubIndicator(indicator.key);
      }
    } else {
      hideSubIndicator(indicator.key);
    }
    return true;
  }
}
