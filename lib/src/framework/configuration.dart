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

// import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../config/export.dart';
import '../core/export.dart';
import '../extension/export.dart';
import '../indicators/export.dart';
import 'indicator.dart';
import 'logger.dart';

typedef IndicatorFromJson<T extends Indicator> = T Function(
  Map<String, dynamic>,
);

const defaultFlexKlineConfigKey = 'flexi_kline_config_key';

abstract class IConfiguration {
  Size get initialMainSize;

  FlexiKlineConfig getFlexiKlineConfig();

  void saveFlexiKlineConfig(FlexiKlineConfig config);
}

mixin KlineConfiguration implements IConfiguration, ILogger, ISetting {
  late IConfiguration configuration;

  /// 一个像素的值.
  // double get pixel {
  //   final mediaQuery = MediaQueryData.fromView(ui.window);
  //   return 1.0 / mediaQuery.devicePixelRatio;
  // }

  @override
  Size get initialMainSize {
    return configuration.initialMainSize;
    // final mediaQuery = MediaQueryData.fromWindow(ui.window);
    // return Size(mediaQuery.size.width, 300);
  }

  FlexiKlineConfig? _flexiKlineConfig;
  FlexiKlineConfig get flexiKlineConfig {
    if (_flexiKlineConfig == null) {
      final config = getFlexiKlineConfig();
      try {
        _flexiKlineConfig = FlexiKlineConfig.fromJson(config.toJson());
      } catch (e) {
        loge('flexiKlineConfig init failed!!!');
        _flexiKlineConfig = config;
      }
    }
    return _flexiKlineConfig!;
  }

  /// 保存当前FlexiKline配置到本地
  void storeFlexiKlineConfig() {
    saveFlexiKlineConfig(flexiKlineConfig);
  }

  @override
  FlexiKlineConfig getFlexiKlineConfig() {
    return configuration.getFlexiKlineConfig();
  }

  @override
  void saveFlexiKlineConfig(FlexiKlineConfig config) {
    storeMainConfig(mainIndicator);
    storeSubConfig(subRectIndicators);
    configuration.saveFlexiKlineConfig(config);
  }

  Set<SinglePaintObjectIndicator> genMainChildIndicators() {
    final list = <SinglePaintObjectIndicator>{};
    for (var key in mainConfig) {
      final indicator = indicatorsConfig.mainIndicators.getItem(key);
      if (indicator != null) {
        list.add(indicator);
      }
    }
    return list;
  }

  Set<Indicator> genSubIndicators() {
    final list = <Indicator>{};
    for (var key in subConfig) {
      final indicator = indicatorsConfig.subIndicators.getItem(key);
      if (indicator != null) {
        list.add(indicator);
      }
    }
    return list;
  }

  CandleIndicator getCandleIndicator() {
    return indicatorsConfig.candle;
  }

  /// mainConfig
  Set<ValueKey> get mainConfig => flexiKlineConfig.main;
  void storeMainConfig(MultiPaintObjectIndicator mainIndicator) {
    flexiKlineConfig.main = mainIndicator.children.map((e) => e.key).toSet();
  }

  /// subConfig
  Set<ValueKey> get subConfig => flexiKlineConfig.sub;
  void storeSubConfig(List<Indicator> list) {
    flexiKlineConfig.sub = list.map((e) => e.key).toSet();
  }

  /// IndicatorsConfig
  IndicatorsConfig get indicatorsConfig => flexiKlineConfig.indicators;
  void storeIndicatorsConfig(IndicatorsConfig config) {
    flexiKlineConfig.indicators = config;
  }

  /// SettingConfig
  SettingConfig get settingConfig => flexiKlineConfig.setting;
  void storeSettingConfig(SettingConfig config) {
    flexiKlineConfig.setting = config;
  }

  /// GridConfig
  GridConfig get gridConfig => flexiKlineConfig.grid;
  void storeGridConfig(GridConfig config) {
    flexiKlineConfig.grid = config;
  }

  /// CrossConfig
  CrossConfig get crossConfig => flexiKlineConfig.cross;
  void storeCrossConfig(CrossConfig config) {
    flexiKlineConfig.cross = config;
  }

  /// TooltipConfig
  TooltipConfig get tooltipConfig => flexiKlineConfig.tooltip;
  void storeTooltipConfig(TooltipConfig config) {
    flexiKlineConfig.tooltip = config;
  }
}
