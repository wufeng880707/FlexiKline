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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../framework/export.dart';
import '../model/export.dart';
import 'interface.dart';

abstract class KlineBindingBase with KlineLog, KlineStorage, GestureHanderImpl {
  KlineBindingBase({
    ILogger? logger,
    IStore? storage,
  }) {
    loggerDelegate = logger;
    storeDelegate = storage;
    logd("constrouct");
    init();
  }

  @protected
  @mustCallSuper
  void init() {
    logd("init base");
  }

  @protected
  @mustCallSuper
  void initState() {
    logd("initState base");
  }

  @protected
  @mustCallSuper
  void dispose() {
    logd("dispose base");

    /// TODO: 待验证 销毁前保存当前配置
    storeState();
  }

  @protected
  @mustCallSuper
  void storeState() {
    logd("storeState base");
  }

  @protected
  @mustCallSuper
  void loadConfig(Map<String, dynamic> configData) {
    logd("loadConfig base");
  }

  /// 缓存FlexiKline的所有配置到本地
  void storeStateToLocal() {
    storeState();
    saveFlexiKlineConfig(flexiKlineConfig);
  }

  KlineBindingBase get instance => this;

  T getInstance<T extends KlineBindingBase>(T instance) {
    return instance;
  }
}
