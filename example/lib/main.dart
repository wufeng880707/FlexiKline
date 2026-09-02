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

// import 'package:device_preview/device_preview.dart';
// import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';
import 'src/config.dart';
import 'src/i18n.dart';
import 'src/repo/okx_api.dart';
import 'src/repo/polygon_api.dart';
import 'src/theme/theme_manager.dart';
import 'src/utils/cache_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await CacheUtil().init();

  final locale = I18nManager().init();
  final themeMode = ThemeManager().init();

  initOkxHttpClient();

  // Polygon API Key 通过 --dart-define 注入，避免硬编码进仓库：
  // flutter run --dart-define=POLYGON_API_KEY=your_key
  const polygonApiKey = String.fromEnvironment('POLYGON_API_KEY');
  if (polygonApiKey.isNotEmpty) {
    initPolygonHttpClient(apiKey: polygonApiKey);
  } else {
    debugPrint('未配置 POLYGON_API_KEY，Polygon 数据源不可用。'
        '运行时请使用 --dart-define=POLYGON_API_KEY=your_key 注入。');
  }

  runApp(ProviderScope(
    overrides: [
      localProvider.overrideWith((ref) => locale),
      themeModeProvider.overrideWith((ref) => themeMode),
    ],
    observers: [AppProviderObserver()],
    child: const MyApp(),
    // child: DevicePreview(
    //   enabled: !kReleaseMode,
    //   builder: (context) => const MyApp(),
    // ),
  ));
}
