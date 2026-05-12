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

import 'package:flexi_formatter/date_time.dart' show TimeUnit;
import 'package:flexi_kline/flexi_kline.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show EdgeInsets;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logger/logger.dart';

// 是否启用实时更新Kline数据.
bool realTimeUpdateKlineData = false;

class AppProviderObserver extends ProviderObserver {
  AppProviderObserver();

  @override
  Future<void> didUpdateProvider(
    ProviderBase<dynamic> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) async {
    if (kDebugMode) {
      // 如果未指定名字, 或名字以下划线开头, 不打印日志.
      if (provider.name == null || provider.name!.startsWith('_')) return;
      debugPrint('PROVIDER    : ${provider.name ?? '<NO NAME>'}\n'
          '  Type      : ${provider.runtimeType}\n'
          '  Old value : $previousValue\n'
          '  New value : $newValue');
    }
  }
}

final defLogger = Logger(
  filter: null, // Use the default LogFilter (-> only log in debug mode)
  printer: PrettyPrinter(
    methodCount: 0, // number of method calls to be displayed
    errorMethodCount: 2, // number of method calls if stacktrace is provided
    lineLength: 120, // width of the output
    colors: true, // Colorful log messages
    printEmojis: true, // Print an emoji for each log message
    dateTimeFormat: DateTimeFormat.onlyTime,
    // printTime: true, // Should each log print contain a timestamp
  ),
  output: null, // Use the default LogOutput (-> send everything to console)
);

class LoggerImpl implements IFlexiLogger {
  LoggerImpl({
    this.tag,
    this.debug = false,
    Logger? logger,
  }) : logger = logger ?? defLogger;

  final String? tag;
  final bool debug;
  final Logger logger;

  @override
  bool get debugMode => debug;

  @override
  void log(
    FlexiLogLevel level,
    String tag,
    String msg, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final text = this.tag == null ? '[$tag] $msg' : '[${this.tag}][$tag] $msg';
    switch (level) {
      case FlexiLogLevel.debug:
        logger.d(text, error: error, stackTrace: stackTrace);
      case FlexiLogLevel.info:
        logger.i(text, error: error, stackTrace: stackTrace);
      case FlexiLogLevel.warn:
        logger.w(text, error: error, stackTrace: stackTrace);
      case FlexiLogLevel.error:
        logger.e(text, error: error, stackTrace: stackTrace);
    }
  }
}

class LogPrintImpl implements IFlexiLogger {
  const LogPrintImpl({
    this.tag,
    this.debug = false,
  });

  final String? tag;
  final bool debug;

  @override
  bool get debugMode => debug;

  @override
  void log(
    FlexiLogLevel level,
    String tag,
    String msg, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final levelLabel = switch (level) {
      FlexiLogLevel.debug => 'Debug',
      FlexiLogLevel.info => 'Info',
      FlexiLogLevel.warn => 'Warn',
      FlexiLogLevel.error => 'Error',
    };
    final prefix = this.tag == null ? 'zp:::$levelLabel [$tag]' : 'zp:::$levelLabel ${this.tag}[$tag]';
    debugPrint('$prefix\t$msg');
  }
}

extension KlineThemeUiExt on IFlexiKlineTheme {
  double get scale => math.min(ScreenUtil().scaleWidth, ScreenUtil().scaleHeight);
  double get normalTextSize => ScreenUtil().setSp(defaultTextSize);
  EdgeInsets get mainIndicatorPadding => EdgeInsets.only(top: 20 * scale, bottom: 20 * scale);
  double get mainIndicatorHeight => 300.r;
  double get subIndicatorHeight => 100.r;
  EdgeInsets get tipsPadding => EdgeInsets.only(left: 8 * scale);
  EdgeInsets get textPadding => EdgeInsets.all(2 * scale);
}

extension KlineIntervalExt on ITimeInterval {
  String get bar {
    final suffix = switch (unit) {
      TimeUnit.second => 's',
      TimeUnit.minute => 'm',
      TimeUnit.hour => 'H',
      TimeUnit.day => 'D',
      TimeUnit.week => 'W',
      TimeUnit.month => 'M',
      TimeUnit.year => 'Y',
      TimeUnit.millisecond => 'ms',
      TimeUnit.microsecond => 'us',
    };
    return '$multiplier$suffix';
  }
}
