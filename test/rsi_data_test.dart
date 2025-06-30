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

import 'package:decimal/decimal.dart';
import 'package:flexi_kline/flexi_kline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const tipsConfig = TipsConfig();
// const candleReq = CandleReq(instId: 'BTC-USDT');

/// RSI相对强弱指数：股票、公式、计算和策略
/// https://bigquant.com/wiki/doc/rsi-eUeAulPIqH
void main() {
  final stopwatch = Stopwatch();
  late KlineData klineData;
  late List<RsiParam> rsiParams;
  late RSIIndicator rsiIndicator;

  setUpAll(() {
    List<String> closeList = [
      '283.46',
      '280.69',
      '285.48',
      '294.08',
      '293.90',
      '299.92',
      '301.15',
      '284.45',
      '294.09',
      '302.77',
      '301.97',
      '306.85',
      '305.02',
      '301.06',
      '291.97',
      '284.18',
      '286.48',
      '284.54',
      '276.82',
      '284.49',
      '275.01',
      '279.07',
      '277.85',
      '278.85',
      '283.76',
      '291.72',
      '284.73',
      '291.82',
      '296.74',
      '291.13'
    ];
    List<CandleModel> list = [];
    for (int i = closeList.length - 1; i >= 0; i--) {
      String close = closeList[i];
      Decimal val = close.d;
      list.add(CandleModel(ts: i, o: val, h: val, l: val, c: val, v: val));
    }

    const timeBar = TimeBarConfig(
      key: 'm15',
      bar: '15m',
      milliseconds: Duration.millisecondsPerMinute * 15,
      multiplier: 15,
      timespan: Timespan.minute,
      showName: '15m',
      sortOrder: 4,
    );

    const candleReq = CandleReq(instId: 'BTC-USDT', timeBar: timeBar);

    klineData = KlineData(candleReq, list: list);
    rsiParams = [const RsiParam(count: 14, tips: tipsConfig)];
    rsiIndicator = RSIIndicator(
      height: 100,
      calcParams: rsiParams,
      tipsPadding: const EdgeInsets.all(4),
      lineWidth: 1.0,
    );
  });

  setUp(() {
    stopwatch.reset();
    stopwatch.start();
  });

  tearDown(() {
    stopwatch.stop();
    debugPrint('tearDown spent:${stopwatch.elapsedMicroseconds}');
  });

  test('RSI指标创建测试', () {
    expect(rsiIndicator.calcParams.length, 1);
    expect(rsiIndicator.calcParams.first.count, 14);
    expect(rsiIndicator.key.id, 'rsi');
    expect(rsiIndicator.height, 100);
    expect(rsiIndicator.lineWidth, 1.0);
    expect(rsiIndicator.precision, 2);
  });

  test('RSI参数验证测试', () {
    final param = rsiParams.first;
    expect(param.count, 14);
    expect(param.tips, tipsConfig);

    // 测试参数序列化
    final json = param.toJson();
    final fromJson = RsiParam.fromJson(json);
    expect(fromJson.count, param.count);
    expect(fromJson.tips.label, param.tips.label);
  });

  test('RSI指标序列化测试', () {
    final json = rsiIndicator.toJson();
    final fromJson = RSIIndicator.fromJson(json);

    expect(fromJson.calcParams.length, rsiIndicator.calcParams.length);
    expect(fromJson.calcParams.first.count, rsiIndicator.calcParams.first.count);
    expect(fromJson.key.id, rsiIndicator.key.id);
    expect(fromJson.height, rsiIndicator.height);
    expect(fromJson.lineWidth, rsiIndicator.lineWidth);
  });

  test('RSI参数工具方法测试', () {
    final params = [
      const RsiParam(count: 6, tips: tipsConfig),
      const RsiParam(count: 12, tips: tipsConfig),
      const RsiParam(count: 24, tips: tipsConfig),
    ];

    final minCount = RsiParam.getMinCountByList(params);
    final maxCount = RsiParam.getMaxCountByList(params);

    expect(minCount, 6);
    expect(maxCount, 24);
  });

  test('KlineData基础功能测试', () {
    expect(klineData.list.length, 30);
    expect(klineData.instId, 'BTC-USDT');
    expect(klineData.precision, 2);
    expect(klineData.key, 'BTC-USDT');
  });
}
