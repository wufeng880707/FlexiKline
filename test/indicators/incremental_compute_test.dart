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

import 'package:decimal/decimal.dart';
import 'package:flexi_formatter/date_time.dart' show TimeUnit;
import 'package:flexi_kline/flexi_kline.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/support.dart';

const _spec = KlineSpec(symbol: 'TEST', interval: FlexiTimeInterval(1, TimeUnit.day));

/// 生成一段随机但确定性的蜡烛序列（从新到旧：ts 递减）。
List<CandleModel> _candles(int count, {int firstTs = 1000, int seed = 7}) {
  var state = seed;
  double next() => ((state = state * 1103515245 + 12345) % 1000) / 100.0 + 1.0;
  return List.generate(count, (i) {
    final open = next();
    final close = next();
    final high = (open > close ? open : close) + next() / 10.0;
    final low = (open < close ? open : close) - next() / 10.0;
    return CandleModel(
      timestamp: firstTs - i,
      open: Decimal.parse(open.toStringAsFixed(4)),
      high: Decimal.parse(high.toStringAsFixed(4)),
      low: Decimal.parse(low.toStringAsFixed(4)),
      close: Decimal.parse(close.toStringAsFixed(4)),
      volume: Decimal.parse(next().toStringAsFixed(4)),
    );
  });
}

({KlineData data, IndicatorPaintObjectManager manager}) _scene(
  List<Indicator> mainIndicators,
) {
  final manager = IndicatorPaintObjectManager(
    configuration: FakeFlexiKlineConfiguration(mainChildren: {
      for (final i in mainIndicators) i.key,
    }),
  );
  manager.mountIndicators(
    candle: TestCandleIndicator(),
    time: TestTimeIndicator(),
    mainIndicators: mainIndicators,
    subIndicators: const [],
    context: FakePaintContext(),
  );
  return (data: KlineData(_spec), manager: manager);
}

/// 对比两条 KlineData 上 [key] 指标在 [dataIndex] 槽位的值是否一致。
/// 旧端（下标 > [lastComparable]，默认为全部）为 seed 区，跳过不比。
void _expectSlotsEqual(
  KlineData full,
  KlineData incremental,
  int dataIndex,
  int slotLen, {
  int firstComparable = 0,
  int? lastComparable,
}) {
  final len = full.list.length;
  final last = lastComparable ?? len;
  expect(incremental.list.length, len);
  for (int i = firstComparable; i < last; i++) {
    final a = full.list[i].getList<FlexiNum>(dataIndex);
    final b = incremental.list[i].getList<FlexiNum>(dataIndex);
    expect(a != null, isTrue, reason: 'full[$i] should have value');
    expect(b != null, isTrue, reason: 'incremental[$i] should have value');
    for (int j = 0; j < slotLen; j++) {
      final va = a![j]?.toDouble();
      final vb = b![j]?.toDouble();
      expect(
        (va == null) == (vb == null),
        isTrue,
        reason: 'slot[$i][$j] nullness mismatch: $va vs $vb',
      );
      if (va != null && vb != null) {
        expect(
          (va - vb).abs() < 1e-9,
          isTrue,
          reason: 'slot[$i][$j] mismatch: $va vs $vb',
        );
      }
    }
  }
}

void main() {
  group('EMA incremental equals full recompute', () {
    test('updateLatest 后增量结果与全量一致', () {
      const key = ComputedIndicatorKey('ema');
      EMAIndicator buildIndicator() => EMAIndicator(
            height: defaultSubIndicatorHeight,
            tipsPadding: EdgeInsets.zero,
            calcParam: const EmaParam(
              lines: [
                EMALineConfig(id: 'ema7', period: 7),
                EMALineConfig(id: 'ema30', period: 30),
                EMALineConfig(id: 'ema99', period: 99),
              ],
            ),
          );
      final indicator = buildIndicator();
      final fullScene = _scene([indicator]);
      final incScene = _scene([buildIndicator()]);
      addTearDown(fullScene.data.dispose);
      addTearDown(fullScene.manager.dispose);
      addTearDown(incScene.data.dispose);
      addTearDown(incScene.manager.dispose);

      final candles = _candles(200);
      final dataIndex = (incScene.manager.getCalculator(key)! as dynamic).dataIndex as int;

      void seed(KlineData data, IndicatorPaintObjectManager manager) {
        data.replace(candles, slotCount: manager.computedDataCapacity);
      }

      seed(fullScene.data, fullScene.manager);
      seed(incScene.data, incScene.manager);

      final fullCalc = fullScene.manager.getCalculator(key)!;
      final incCalc = incScene.manager.getCalculator(key)!;

      // 全量：直接整段计算。
      fullCalc.compute(fullScene.data, fullScene.data.computableRange, reset: true);
      // 增量：先整段计算一次建立锚点。
      incCalc.compute(incScene.data, incScene.data.computableRange, reset: true);

      final updated = [
        CandleModel(
          timestamp: candles[0].timestamp,
          open: candles[0].open,
          high: candles[0].high,
          low: candles[0].low,
          close: Decimal.parse('9.99'),
          volume: candles[0].volume,
        ),
        CandleModel(
          timestamp: candles[1].timestamp,
          open: candles[1].open,
          high: candles[1].high,
          low: candles[1].low,
          close: Decimal.parse('3.33'),
          volume: candles[1].volume,
        ),
      ];
      fullScene.data.updateLatest(updated, slotCount: fullScene.manager.computedDataCapacity);
      incScene.data.updateLatest(updated, slotCount: incScene.manager.computedDataCapacity);

      fullCalc.compute(fullScene.data, fullScene.data.computableRange, reset: true);
      incCalc.compute(incScene.data, const Range(0, 2));

      // EMA 最大周期 99：旧端（下标 > len-99）是 seed 区为 null；新端全部可比
      // （增量锚点即 index=2 的已存值，不涉及播种）。
      _expectSlotsEqual(
        fullScene.data,
        incScene.data,
        dataIndex,
        3,
        lastComparable: 200 - 99,
      );
    });
  });

  group('MACD incremental equals full recompute', () {
    test('updateLatest 后增量结果与全量一致', () {
      const key = ComputedIndicatorKey('macd');
      MACDIndicator buildIndicator() => MACDIndicator(
            height: defaultSubIndicatorHeight,
            difTips: const TipsConfig(),
            deaTips: const TipsConfig(),
            macdTips: const TipsConfig(),
            tipsPadding: EdgeInsets.zero,
          );
      final fullScene = _scene([buildIndicator()]);
      final incScene = _scene([buildIndicator()]);
      addTearDown(fullScene.data.dispose);
      addTearDown(fullScene.manager.dispose);
      addTearDown(incScene.data.dispose);
      addTearDown(incScene.manager.dispose);

      final candles = _candles(200);
      final dataIndex = (incScene.manager.getCalculator(key)! as dynamic).dataIndex as int;

      fullScene.data.replace(candles, slotCount: fullScene.manager.computedDataCapacity);
      incScene.data.replace(candles, slotCount: incScene.manager.computedDataCapacity);

      final fullCalc = fullScene.manager.getCalculator(key)!;
      final incCalc = incScene.manager.getCalculator(key)!;

      fullCalc.compute(fullScene.data, fullScene.data.computableRange, reset: true);
      incCalc.compute(incScene.data, incScene.data.computableRange, reset: true);

      final updated = [
        CandleModel(
          timestamp: candles[0].timestamp,
          open: candles[0].open,
          high: candles[0].high,
          low: candles[0].low,
          close: Decimal.parse('8.88'),
          volume: candles[0].volume,
        ),
      ];
      fullScene.data.updateLatest(updated, slotCount: fullScene.manager.computedDataCapacity);
      incScene.data.updateLatest(updated, slotCount: incScene.manager.computedDataCapacity);

      fullCalc.compute(fullScene.data, fullScene.data.computableRange, reset: true);
      incCalc.compute(incScene.data, const Range(0, 1));

      // MACD 播种链路 ~35 根：下标 > len-40 为 seed 区。比较到 len-40（不含）。
      _expectSlotsEqual(
        fullScene.data,
        incScene.data,
        dataIndex,
        6,
        firstComparable: 0,
        lastComparable: 200 - 40,
      );
    });
  });

  group('OBV incremental equals full recompute', () {
    test('updateLatest 后增量结果与全量一致（含 MA 线）', () {
      const key = ComputedIndicatorKey('obv');
      OBVIndicator buildIndicator() => OBVIndicator(
            height: defaultSubIndicatorHeight,
            tipsPadding: EdgeInsets.zero,
            calcParam: const OBVParam(
              maLines: [
                OBVMALineConfig(id: 'ma7', period: 7, color: Color(0xFFFF9800)),
                OBVMALineConfig(id: 'ma30', period: 30, color: Color(0xFFFF9800)),
              ],
            ),
          );
      final fullScene = _scene([buildIndicator()]);
      final incScene = _scene([buildIndicator()]);
      addTearDown(fullScene.data.dispose);
      addTearDown(fullScene.manager.dispose);
      addTearDown(incScene.data.dispose);
      addTearDown(incScene.manager.dispose);

      final candles = _candles(200);
      final dataIndex = (incScene.manager.getCalculator(key)! as dynamic).dataIndex as int;

      fullScene.data.replace(candles, slotCount: fullScene.manager.computedDataCapacity);
      incScene.data.replace(candles, slotCount: incScene.manager.computedDataCapacity);

      final fullCalc = fullScene.manager.getCalculator(key)!;
      final incCalc = incScene.manager.getCalculator(key)!;

      fullCalc.compute(fullScene.data, fullScene.data.computableRange, reset: true);
      incCalc.compute(incScene.data, incScene.data.computableRange, reset: true);

      final updated = [
        CandleModel(
          timestamp: candles[0].timestamp,
          open: candles[0].open,
          high: candles[0].high,
          low: candles[0].low,
          close: Decimal.parse('7.77'),
          volume: Decimal.parse('5.55'),
        ),
        CandleModel(
          timestamp: candles[1].timestamp,
          open: candles[1].open,
          high: candles[1].high,
          low: candles[1].low,
          close: Decimal.parse('2.22'),
          volume: Decimal.parse('1.11'),
        ),
      ];
      fullScene.data.updateLatest(updated, slotCount: fullScene.manager.computedDataCapacity);
      incScene.data.updateLatest(updated, slotCount: incScene.manager.computedDataCapacity);

      fullCalc.compute(fullScene.data, fullScene.data.computableRange, reset: true);
      incCalc.compute(incScene.data, const Range(0, 2));

      // OBV slot 是 double 类型：obv 主线 + 2 条 MA，全部位置可比。
      final len = fullScene.data.list.length;
      for (int i = 0; i < len; i++) {
        final a = fullScene.data.list[i].getList<double>(dataIndex);
        final b = incScene.data.list[i].getList<double>(dataIndex);
        expect(a != null, isTrue, reason: 'full[$i] obv should have value');
        expect(b != null, isTrue, reason: 'incremental[$i] obv should have value');
        for (int j = 0; j < 3; j++) {
          final va = a![j];
          final vb = b![j];
          expect(
            (va == null) == (vb == null),
            isTrue,
            reason: 'obv slot[$i][$j] nullness mismatch: $va vs $vb',
          );
          if (va != null && vb != null) {
            expect(
              (va - vb).abs() < 1e-9,
              isTrue,
              reason: 'obv slot[$i][$j] mismatch: $va vs $vb',
            );
          }
        }
      }
    });
  });

  group('SAR incremental equals full recompute', () {
    test('updateLatest 后增量结果与全量一致（sar/flag/ep/af/dir）', () {
      const key = ComputedIndicatorKey('sar');
      SARIndicator buildIndicator() => SARIndicator(
            height: defaultSubIndicatorHeight,
            tipsPadding: EdgeInsets.zero,
          );
      final fullScene = _scene([buildIndicator()]);
      final incScene = _scene([buildIndicator()]);
      addTearDown(fullScene.data.dispose);
      addTearDown(fullScene.manager.dispose);
      addTearDown(incScene.data.dispose);
      addTearDown(incScene.manager.dispose);

      final candles = _candles(200);
      final dataIndex = (incScene.manager.getCalculator(key)! as dynamic).dataIndex as int;

      fullScene.data.replace(candles, slotCount: fullScene.manager.computedDataCapacity);
      incScene.data.replace(candles, slotCount: incScene.manager.computedDataCapacity);

      final fullCalc = fullScene.manager.getCalculator(key)!;
      final incCalc = incScene.manager.getCalculator(key)!;

      fullCalc.compute(fullScene.data, fullScene.data.computableRange, reset: true);
      incCalc.compute(incScene.data, incScene.data.computableRange, reset: true);

      // 更新最新一根（触发 SAR 趋势/AF/EP 递推），含一次显著跳变以覆盖反转帧路径。
      final updated = [
        CandleModel(
          timestamp: candles[0].timestamp,
          open: candles[0].open,
          high: Decimal.parse('0.01'),
          low: Decimal.parse('0.01'),
          close: Decimal.parse('0.01'),
          volume: candles[0].volume,
        ),
      ];
      fullScene.data.updateLatest(updated, slotCount: fullScene.manager.computedDataCapacity);
      incScene.data.updateLatest(updated, slotCount: incScene.manager.computedDataCapacity);

      fullCalc.compute(fullScene.data, fullScene.data.computableRange, reset: true);
      incCalc.compute(incScene.data, const Range(0, 1));

      // SAR slot: [sar, flag, ep, af, dir]，全段可比（SAR 从最旧端就有值）。
      final len = fullScene.data.list.length;
      for (int i = 0; i < len; i++) {
        final a = fullScene.data.list[i].getList<FlexiNum>(dataIndex);
        final b = incScene.data.list[i].getList<FlexiNum>(dataIndex);
        expect(a != null, isTrue, reason: 'full[$i] sar should have value');
        expect(b != null, isTrue, reason: 'incremental[$i] sar should have value');
        for (int j = 0; j < 5; j++) {
          final va = a![j]?.toDouble();
          final vb = b![j]?.toDouble();
          expect(
            (va == null) == (vb == null),
            isTrue,
            reason: 'sar slot[$i][$j] nullness mismatch: $va vs $vb',
          );
          if (va != null && vb != null) {
            expect(
              (va - vb).abs() < 1e-9,
              isTrue,
              reason: 'sar slot[$i][$j] mismatch: $va vs $vb',
            );
          }
        }
      }
    });
  });

  group('BOLL rolling sum equals per-window sum', () {
    test('滚动和与逐窗口求和数值一致（1e-9）', () {
      const key = ComputedIndicatorKey('boll');
      BOLLIndicator buildIndicator() => BOLLIndicator(
            height: defaultSubIndicatorHeight,
            tipsPadding: EdgeInsets.zero,
          );
      final scene = _scene([buildIndicator()]);
      addTearDown(scene.data.dispose);
      addTearDown(scene.manager.dispose);

      final candles = _candles(300);
      scene.data.replace(candles, slotCount: scene.manager.computedDataCapacity);
      final calc = scene.manager.getCalculator(key)!;
      final dataIndex = (calc as dynamic).dataIndex as int;
      calc.compute(scene.data, scene.data.computableRange, reset: true);

      // 与独立的逐窗口求和参考实现对比。
      final len = scene.data.list.length;
      const period = 20; // BOLLParam 默认周期
      for (int i = 0; i + period <= len; i++) {
        double sum = 0;
        for (int j = i; j < i + period; j++) {
          sum += scene.data.list[j].close.toDouble();
        }
        final maRef = sum / period;
        final slot = scene.data.list[i].getList<FlexiNum>(dataIndex);
        expect(slot, isNotNull, reason: 'boll[$i] should have value');
        expect(
          (slot![0]!.toDouble() - maRef).abs() < 1e-9,
          isTrue,
          reason: 'boll ma[$i] mismatch: ${slot[0]!.toDouble()} vs $maRef',
        );

        // 标准差参考实现。
        double variance = 0;
        for (int j = i; j < i + period; j++) {
          final d = scene.data.list[j].close.toDouble() - maRef;
          variance += d * d;
        }
        final stdRef = math.sqrt(variance < 0 ? 0 : variance / period);
        final mid = slot[0]!.toDouble();
        // 上轨 = ma + 2*std
        expect(
          (slot[1]!.toDouble() - (mid + 2 * stdRef)).abs() < 1e-8,
          isTrue,
          reason: 'boll upper[$i] mismatch: ${slot[1]!.toDouble()} vs ${mid + 2 * stdRef}',
        );
        expect(
          (slot[2]!.toDouble() - (mid - 2 * stdRef)).abs() < 1e-8,
          isTrue,
          reason: 'boll lower[$i] mismatch: ${slot[2]!.toDouble()} vs ${mid - 2 * stdRef}',
        );
      }
    });
  });

  group('KDJ monotonic queue equals brute-force window scan', () {
    test('单调队列结果与暴力扫描一致', () {
      const key = ComputedIndicatorKey('kdj');
      KDJIndicator buildIndicator() => KDJIndicator(
            height: defaultSubIndicatorHeight,
            tipsPadding: EdgeInsets.zero,
          );
      final scene = _scene([buildIndicator()]);
      addTearDown(scene.data.dispose);
      addTearDown(scene.manager.dispose);

      final candles = _candles(300);
      scene.data.replace(candles, slotCount: scene.manager.computedDataCapacity);
      final calc = scene.manager.getCalculator(key)!;
      final dataIndex = (calc as dynamic).dataIndex as int;
      calc.compute(scene.data, scene.data.computableRange, reset: true);

      // 暴力参考实现：每个位置重新扫窗口求 high/low，再做 K/D 递推。
      final list = scene.data.list;
      final len = list.length;
      const kPeriod = 9; // KDJParam 默认
      const dPeriod = 3;
      const jPeriod = 3;
      FlexiNum? prevK;
      FlexiNum? prevD;
      // 从最旧端向新端（下标递减）逐根计算。
      for (int i = len - kPeriod; i >= 0; i--) {
        var high = list[i].high;
        var low = list[i].low;
        for (int j = i + 1; j < i + kPeriod; j++) {
          if (list[j].high > high) high = list[j].high;
          if (list[j].low < low) low = list[j].low;
        }
        final rsv = high == low
            ? FlexiNum.fromNum(50)
            : ((list[i].close - low) / (high - low)) * FlexiNum.fromNum(100);
        // 与生产代码一致的语义：所有帧统一 prevK/prevD 为 null 时取 50 起播。
        final kVal = ((prevK ?? FlexiNum.fromNum(50)) * FlexiNum.fromNum(dPeriod - 1) + rsv) /
            FlexiNum.fromNum(dPeriod);
        final dVal = ((prevD ?? FlexiNum.fromNum(50)) * FlexiNum.fromNum(jPeriod - 1) + kVal) /
            FlexiNum.fromNum(jPeriod);
        final j = kVal * FlexiNum.fromNum(3) - dVal * FlexiNum.fromNum(2);
        prevK = kVal;
        prevD = dVal;

        final slot = list[i].getList<FlexiNum>(dataIndex);
        expect(slot, isNotNull, reason: 'kdj[$i] should have value');
        expect(
          (slot![0]!.toDouble() - kVal.toDouble()).abs() < 1e-9,
          isTrue,
          reason: 'kdj K[$i] mismatch: ${slot[0]!.toDouble()} vs ${kVal.toDouble()}',
        );
        expect(
          (slot[1]!.toDouble() - dVal.toDouble()).abs() < 1e-9,
          isTrue,
          reason: 'kdj D[$i] mismatch: ${slot[1]!.toDouble()} vs ${dVal.toDouble()}',
        );
        expect(
          (slot[2]!.toDouble() - j.toDouble()).abs() < 1e-9,
          isTrue,
          reason: 'kdj J[$i] mismatch: ${slot[2]!.toDouble()} vs ${j.toDouble()}',
        );
      }
    });
  });

  group('RSI incremental equals full recompute', () {
    test('updateLatest 后增量结果与全量一致（Wilder 状态恢复）', () {
      const key = ComputedIndicatorKey('rsi');
      RSIIndicator buildIndicator() => RSIIndicator(
            height: defaultSubIndicatorHeight,
            tipsPadding: EdgeInsets.zero,
            calcParam: const RsiParam(
              lines: [
                RSILineConfig(id: 'rsi6', period: 6, color: Color(0xFFFF9800)),
                RSILineConfig(id: 'rsi14', period: 14, color: Color(0xFFFF9800)),
              ],
            ),
          );
      final fullScene = _scene([buildIndicator()]);
      final incScene = _scene([buildIndicator()]);
      addTearDown(fullScene.data.dispose);
      addTearDown(fullScene.manager.dispose);
      addTearDown(incScene.data.dispose);
      addTearDown(incScene.manager.dispose);

      final candles = _candles(200);
      final dataIndex = (incScene.manager.getCalculator(key)! as dynamic).dataIndex as int;

      fullScene.data.replace(candles, slotCount: fullScene.manager.computedDataCapacity);
      incScene.data.replace(candles, slotCount: incScene.manager.computedDataCapacity);

      final fullCalc = fullScene.manager.getCalculator(key)!;
      final incCalc = incScene.manager.getCalculator(key)!;

      fullCalc.compute(fullScene.data, fullScene.data.computableRange, reset: true);
      incCalc.compute(incScene.data, incScene.data.computableRange, reset: true);

      final updated = [
        CandleModel(
          timestamp: candles[0].timestamp,
          open: candles[0].open,
          high: candles[0].high,
          low: candles[0].low,
          close: Decimal.parse('6.66'),
          volume: candles[0].volume,
        ),
      ];
      fullScene.data.updateLatest(updated, slotCount: fullScene.manager.computedDataCapacity);
      incScene.data.updateLatest(updated, slotCount: incScene.manager.computedDataCapacity);

      fullCalc.compute(fullScene.data, fullScene.data.computableRange, reset: true);
      incCalc.compute(incScene.data, const Range(0, 1));

      // RSI slot: [rsi0, rsi1, avgGain0, avgLoss0, prevClose0, avgGain1, ...]，
      // 双线共 8 位；seed 区（下标 > len-16）跳过。
      final len = fullScene.data.list.length;
      final seedZone = 16;
      for (int i = 0; i < len - seedZone; i++) {
        final a = fullScene.data.list[i].getList<double>(dataIndex);
        final b = incScene.data.list[i].getList<double>(dataIndex);
        expect(a != null, isTrue, reason: 'full[$i] rsi should have value');
        expect(b != null, isTrue, reason: 'incremental[$i] rsi should have value');
        for (int j = 0; j < 8; j++) {
          final va = a![j];
          final vb = b![j];
          expect(
            (va == null) == (vb == null),
            isTrue,
            reason: 'rsi slot[$i][$j] nullness mismatch: $va vs $vb',
          );
          if (va != null && vb != null) {
            expect(
              (va - vb).abs() < 1e-9,
              isTrue,
              reason: 'rsi slot[$i][$j] mismatch: $va vs $vb',
            );
          }
        }
      }
    });
  });
}
