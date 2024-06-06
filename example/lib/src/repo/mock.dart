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
import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flexi_kline/flexi_kline.dart';
import 'package:flutter/foundation.dart';

Future<List<CandleModel>> genCustomCandleList({
  int count = 7,
  TimeBar bar = TimeBar.D1,
}) async {
  DateTime dateTime = DateTime.now();
  return <CandleModel>[
    CandleModel(
      timestamp: dateTime.add(const Duration(days: 0)).millisecondsSinceEpoch,
      h: 320.d,
      o: 100.d,
      c: 300.d,
      l: 10.d,
      v: 80.d,
    ),
    CandleModel(
      timestamp: dateTime.add(const Duration(days: -1)).millisecondsSinceEpoch,
      h: 220.d,
      o: 60.d,
      c: 200.d,
      l: 50.d,
      v: 50.d,
    ),
    CandleModel(
      timestamp: dateTime.add(const Duration(days: -2)).millisecondsSinceEpoch,
      h: 320.d,
      o: 200.d,
      c: 100.d,
      l: 50.d,
      v: 90.d,
    ),
    CandleModel(
      timestamp: dateTime.add(const Duration(days: -3)).millisecondsSinceEpoch,
      h: 140.d,
      o: 90.d,
      c: 120.d,
      l: 80.d,
      v: 30.d,
    ),
    CandleModel(
      timestamp: dateTime.add(const Duration(days: -4)).millisecondsSinceEpoch,
      h: 200.d,
      o: 120.d,
      c: 20.d,
      l: 20.d,
      v: 20.d,
    ),
    CandleModel(
      timestamp: dateTime.add(const Duration(days: -5)).millisecondsSinceEpoch,
      h: 130.d,
      o: 20.d,
      c: 110.d,
      l: 10.d,
      v: 10.d,
    ),
    CandleModel(
      timestamp: dateTime.add(const Duration(days: -6)).millisecondsSinceEpoch,
      h: 160.d,
      o: 110.d,
      c: 150.d,
      l: 100.d,
      v: 90.d,
    ),
    CandleModel(
      timestamp: dateTime.add(const Duration(days: -7)).millisecondsSinceEpoch,
      h: 160.d,
      o: 150.d,
      c: 120.d,
      l: 100.d,
      v: 20.d,
    ),
  ];
}

/// 随机生成CandleModel列表
/// [count] : 返回列表数量
/// [inital] : 初始收盘价
/// [range] : 开/收/高/低价的随机波动范围
/// [initalVol] : 初始交易量
/// [rangeVol] : 交易量的随机波动范围
/// [bar] : 时间间隔
/// [dateTime] : 初始时间
/// [isHistory] : 是否生成历史数据
Future<List<CandleModel>> genRandomCandleList({
  int count = 5,
  double inital = 1000,
  double range = 100,
  double initalVol = 100,
  double rangeVol = 50,
  TimeBar bar = TimeBar.D1,
  DateTime? dateTime,
  bool isHistory = true,
}) async {
  if (count > 10000) {
    return await compute((List<dynamic> list) async {
      debugPrint('zp::: genRandomCandleList Begin ${DateTime.now()}');
      final result = await _genRandomCandleList(
        count: list[0],
        inital: list[1],
        range: list[2],
        initalVol: list[3],
        rangeVol: list[4],
        bar: list[5],
        dateTime: list[6],
        isHistory: list[7],
      );
      debugPrint('zp::: genRandomCandleList End ${DateTime.now()}');
      return result;
    }, [
      count,
      inital,
      range,
      initalVol,
      rangeVol,
      bar,
      dateTime,
      isHistory,
    ]);
  }
  return _genRandomCandleList(
    count: count,
    inital: inital,
    range: range,
    initalVol: initalVol,
    rangeVol: rangeVol,
    bar: bar,
    dateTime: dateTime,
    isHistory: isHistory,
  );
}

Future<List<CandleModel>> _genRandomCandleList({
  int count = 5,
  double inital = 1000,
  double range = 100,
  double initalVol = 100,
  double rangeVol = 50,
  TimeBar bar = TimeBar.D1,
  DateTime? dateTime,
  bool isHistory = true,
}) async {
  List<CandleModel> list = [];
  dateTime ??= DateTime.now();
  final random = math.Random();
  CandleModel? m;
  double h, l, o, c = inital, v = initalVol;

  double genVal(double m, double k, {bool? isUp}) {
    double val;
    double r = random.nextDouble();
    if (isUp != null) {
      r = r * r;
    }
    isUp ??= random.nextBool();
    if (isUp) {
      val = m + r * k;
    } else {
      val = m - r * k;
    }
    return val;
  }

  int flag = isHistory ? -1 : 1;

  for (int i = 0; i < count; i++) {
    o = c;
    c = genVal(o, range);
    h = genVal(math.max(o, c), range, isUp: true);
    l = genVal(math.min(o, c), range, isUp: false);
    if (h < l) [h, l] = [l, h];
    v = genVal(v, rangeVol);
    m = CandleModel(
      timestamp: dateTime
          .add(Duration(milliseconds: flag * i * bar.milliseconds))
          .millisecondsSinceEpoch,
      h: h.d,
      o: o.d,
      c: c.d,
      l: l.d,
      v: v.d,
    );
    if (isHistory) {
      list.add(m);
    } else {
      list.insert(0, m);
    }
  }

  return list;
}

Future<List<CandleModel>> genLocalCandleList({String json = jsonString}) async {
  final data = jsonDecode(json);
  if (data is List) {
    List<CandleModel> list = List.empty(growable: true);
    for (var i = data.length - 1; i >= 0; i--) {
      final item = data[i];
      if (item is List) {
        list.add(CandleModel(
          timestamp: item[0] * 1000,
          o: Decimal.parse(item[1].toString()),
          h: Decimal.parse(item[2].toString()),
          l: Decimal.parse(item[3].toString()),
          c: Decimal.parse(item[4].toString()),
          v: Decimal.parse(item[5].toString()),
          vc: Decimal.parse(item[6].toString()),
        ));
      }
    }
    return list;
  }
  return [];
}

const jsonString = '''
[
	[1677380400, 23237.84, 23241.32, 23186.79, 23220.74, 13.3079, 308857.6952927],
	[1677381300, 23220.72, 23236.66, 23194.86, 23216.63, 14.64115, 339897.2510879],
	[1677382200, 23216.64, 23248.9, 23211.94, 23247.92, 13.18691, 306319.183075],
	[1677383100, 23247.9, 23247.9, 23213.07, 23214.37, 13.09034, 304099.3704977],
	[1677384000, 23214.35, 23222.86, 23197.19, 23198.24, 12.87428, 298822.6376701],
	[1677384900, 23198.29, 23226.31, 23197.43, 23211.61, 11.69171, 271366.7633878],
	[1677385800, 23211.59, 23212.58, 23170.94, 23171.63, 14.25677, 330746.969454],
	[1677386700, 23171.64, 23202.67, 23153.24, 23189.5, 17.20027, 398707.3508568],
	[1677387600, 23189.48, 23201.31, 23167.43, 23175.21, 14.5613, 337642.5395126],
	[1677388500, 23175.2, 23191.98, 23163.9, 23164.54, 14.79229, 342918.9899285],
	[1677389400, 23164.55, 23177.43, 23154.53, 23169.33, 20.2114, 468278.0697394],
	[1677390300, 23169.35, 23171.96, 23127.34, 23127.39, 12.80231, 296486.3875812],
	[1677391200, 23127.37, 23150.47, 23093.85, 23094.03, 15.81007, 365691.2364176],
	[1677392100, 23094.02, 23145.92, 23093.75, 23135.81, 12.13726, 280702.6097338],
	[1677393000, 23135.79, 23158.25, 23131.83, 23156.36, 13.21481, 305855.204312],
	[1677393900, 23156.26, 23170.53, 23145.47, 23167.32, 13.99314, 324047.8049432],
	[1677394800, 23167.34, 23183.48, 23152.42, 23155.48, 14.49893, 335931.0766147],
	[1677395700, 23155.46, 23173.98, 23152.58, 23158.5, 12.28025, 284451.4952105],
	[1677396600, 23158.65, 23188.1, 23158.65, 23179.73, 15.12905, 350613.6859391],
	[1677397500, 23179.19, 23202.67, 23140.37, 23155.08, 15.54948, 360219.7754545],
	[1677398400, 23155.06, 23161.3, 23131.26, 23140.78, 18.18857, 420972.3476868],
	[1677399300, 23140.79, 23140.83, 23113.67, 23134.44, 14.8108, 342551.8263577],
	[1677400200, 23134.93, 23162.45, 23120.46, 23161.69, 15.42763, 357072.478667],
	[1677401100, 23161.7, 23174.24, 23152.21, 23152.3, 18.90238, 437809.7646015],
	[1677402000, 23152.65, 23195.67, 23152.32, 23189.11, 15.97097, 370181.7497648],
	[1677402900, 23189.12, 23228.68, 23163.42, 23228.65, 14.32978, 332220.8759319],
	[1677403800, 23227.47, 23249.13, 23194.02, 23241.08, 15.91509, 369489.0557809],
	[1677404700, 23241.1, 23287.33, 23227.54, 23277.36, 18.08556, 420706.8190828],
	[1677405600, 23277.35, 23279.11, 23227.66, 23243.55, 14.28101, 332030.2198364],
	[1677406500, 23242.74, 23251.76, 23227.56, 23236.99, 15.86621, 368727.5958624],
	[1677407400, 23238.51, 23257.34, 23212.74, 23230.36, 16.14322, 375001.9261535],
	[1677408300, 23230.35, 23242.35, 23216.35, 23236.97, 12.94607, 300746.1385611],
	[1677409200, 23236.98, 23244.19, 23215.76, 23215.82, 16.01594, 372090.9872287],
	[1677410100, 23215.84, 23228.71, 23201.98, 23220.53, 16.59977, 385410.2603485],
	[1677411000, 23219.31, 23243.41, 23215.46, 23217.42, 14.63286, 339895.9486417],
	[1677411900, 23217.08, 23256.01, 23216.71, 23254.43, 13.24945, 307942.1082172],
	[1677412800, 23253.82, 23280.18, 23185.33, 23196.46, 18.38435, 427091.0473433],
	[1677413700, 23196.48, 23253.32, 23193.12, 23237.5, 17.5423, 407429.559249],
	[1677414600, 23237.51, 23238.04, 23179.48, 23183.53, 17.04385, 395488.7169376],
	[1677415500, 23183.52, 23192.15, 23129.89, 23162.89, 16.95079, 392709.2840314],
	[1677416400, 23162.73, 23183.76, 23139.03, 23156.33, 13.43983, 311334.7312513],
	[1677417300, 23156.32, 23189.98, 23153.66, 23179.52, 13.1932, 305732.6021634],
	[1677418200, 23183.51, 23195.93, 23169.22, 23181.87, 14.12151, 327391.9063356],
	[1677419100, 23182.03, 23217.17, 23173.74, 23212.66, 15.76397, 365517.6137714],
	[1677420000, 23212.67, 23272.38, 23204.2, 23272.38, 16.24008, 377353.5475444],
	[1677420900, 23272.39, 23316.19, 23223.74, 23226.38, 15.9314, 370487.531161],
	[1677421800, 23226.4, 23235.9, 23182.05, 23226.57, 15.52354, 360315.3256759],
	[1677422700, 23226.55, 23286.7, 23192.55, 23197.82, 16.02305, 372297.2027107],
	[1677423600, 23196.6, 23241.58, 23180.51, 23215.72, 14.22447, 330188.3514404],
	[1677424500, 23215.72, 23222.85, 23184.43, 23199.92, 12.29389, 285255.072789],
	[1677425400, 23199.9, 23234.15, 23185.73, 23218.76, 13.65367, 316818.5456115],
	[1677426300, 23218.74, 23249.15, 23206.96, 23247.12, 13.68295, 317783.2940308],
	[1677427200, 23247.14, 23253.79, 23219.23, 23253.68, 15.29087, 355363.7246006],
	[1677428100, 23253.7, 23255.98, 23199.86, 23201.64, 10.59038, 246058.6149144],
	[1677429000, 23201.66, 23208.57, 23168.63, 23186.06, 12.07971, 280131.0039818],
	[1677429900, 23186.07, 23208.76, 23167.25, 23184.83, 11.03918, 255985.5246777],
	[1677430800, 23184.77, 23189.31, 23139.75, 23179.46, 11.49464, 266348.4456914],
	[1677431700, 23179.47, 23192.85, 23148.15, 23167.43, 13.29375, 308050.1333941],
	[1677432600, 23167.44, 23185.06, 23157.32, 23181.72, 9.88691, 229063.0280231],
	[1677433500, 23181.73, 23241.48, 23178.07, 23240.21, 10.58559, 245641.50214],
	[1677434400, 23240.2, 23283.54, 23228.65, 23257.68, 13.00687, 302522.2793561],
	[1677435300, 23257.66, 23274.59, 23225.83, 23227.68, 11.18825, 260130.7947812],
	[1677436200, 23227.7, 23457.59, 23223.32, 23428.49, 14.19364, 330973.3113287],
	[1677437100, 23428.51, 23535.15, 23419.68, 23485.07, 19.90454, 467380.4090377],
	[1677438000, 23485.09, 23493.2, 23369.82, 23447.77, 22.87768, 536203.5215969],
	[1677438900, 23447.76, 23513.89, 23417.81, 23463.38, 17.13678, 402162.7390767],
	[1677439800, 23463.36, 23507.88, 23458.19, 23477.67, 13.97406, 328055.563312],
	[1677440700, 23477.43, 23542.24, 23476.28, 23504.97, 14.56856, 342656.2142013],
	[1677441600, 23501.85, 23544.77, 23485.73, 23492.71, 12.04631, 283247.0724583],
	[1677442500, 23492.7, 23586.49, 23463.52, 23586.47, 13.34299, 313601.9520703],
	[1677443400, 23586.45, 23681.58, 23549.28, 23655.99, 25.09718, 592880.4266415],
	[1677444300, 23656.01, 23658.78, 23617.1, 23640.97, 12.14485, 287124.4051718],
	[1677445200, 23640.96, 23646.38, 23583.56, 23644.16, 14.59998, 344747.7124005],
	[1677446100, 23644.44, 23650.29, 23591.36, 23600.14, 15.33014, 362038.5699428],
	[1677447000, 23600.46, 23610.99, 23570.58, 23587.59, 14.43662, 340594.3443229],
	[1677447900, 23587.6, 23609.43, 23553.17, 23560.51, 13.64539, 321776.4237048],
	[1677448800, 23560.52, 23593.46, 23542.96, 23567.56, 13.59577, 320412.6505276],
	[1677449700, 23567.58, 23568.01, 23353.78, 23372.2, 19.23387, 451153.2792933],
	[1677450600, 23372.18, 23430.82, 23326.32, 23430.82, 17.94196, 419342.7650494],
	[1677451500, 23431.37, 23478.04, 23378.54, 23477.58, 16.46914, 385947.0787015],
	[1677452400, 23477.49, 23626.34, 23455.94, 23544.86, 18.19524, 428092.7821114],
	[1677453300, 23544.84, 23578.13, 23492.58, 23522.07, 16.70499, 393100.586784],
	[1677454200, 23522.06, 23583.41, 23510.32, 23529.82, 20.08384, 472821.3773015],
	[1677455100, 23529.83, 23563.32, 23519.26, 23555.41, 12.73884, 299855.9528609],
	[1677456000, 23555.91, 23563.41, 23473.77, 23498.44, 13.43063, 315887.0372978],
	[1677456900, 23498.43, 23528.53, 23471.5, 23471.5, 12.97554, 304929.8549588],
	[1677457800, 23471.52, 23510.71, 23454.08, 23475.81, 10.21234, 239796.135034],
	[1677458700, 23475.8, 23504.07, 23473.64, 23492.54, 11.94682, 280619.3720539],
	[1677459600, 23492.56, 23498.21, 23435.56, 23452.36, 16.44574, 385894.1678818],
	[1677460500, 23452.35, 23481.37, 23437.73, 23466.62, 13.16845, 308989.2004913],
	[1677461400, 23466.63, 23519.23, 23466.63, 23519.23, 12.86449, 302309.8468539],
	[1677462300, 23519.24, 23562.25, 23519.24, 23552.2, 14.30856, 336879.1896453],
	[1677463200, 23552.18, 23642.8, 23552.18, 23566.58, 12.47666, 294239.2588552],
	[1677464100, 23566.59, 23585.79, 23534.28, 23538.14, 11.6275, 273933.3377725],
	[1677465000, 23538.15, 23557.47, 23523.79, 23542.6, 12.32801, 290221.4014894],
	[1677465900, 23542.58, 23566.09, 23541.35, 23559.27, 10.92622, 257382.8055569],
	[1677466800, 23559.42, 23590.24, 23545.06, 23589.03, 13.09922, 308680.1748892],
	[1677467700, 23589.05, 23640.64, 23589.05, 23594.88, 11.68313, 275860.1521536],
	[1677468600, 23594.9, 23616.59, 23562.72, 23567.41, 13.22796, 311954.8217063],
	[1677469500, 23567.43, 23587.82, 23541.52, 23554.15, 15.04014, 354350.3619831],
	[1677470400, 23553.15, 23558.27, 23514.87, 23518.59, 14.75305, 347344.5072843],
	[1677471300, 23518.58, 23531.97, 23487.04, 23496.07, 15.69479, 368985.6964111],
	[1677472200, 23496.45, 23512.82, 23464.78, 23484.45, 12.01311, 282228.3746932],
	[1677473100, 23484.43, 23506.88, 23468.53, 23491.73, 13.25548, 311374.0212313],
	[1677474000, 23491.71, 23507.18, 23457.09, 23465.99, 14.24452, 334644.0890232],
	[1677474900, 23465.97, 23486.64, 23448.48, 23478.59, 12.48033, 292907.1764304],
	[1677475800, 23479.42, 23483.62, 23451.43, 23456.21, 13.8886, 325937.4749885],
	[1677476700, 23456.04, 23456.04, 23350.56, 23390.24, 16.29381, 381220.0727026],
	[1677477600, 23390.23, 23421.86, 23373.5, 23421.54, 15.09548, 353201.0557021],
	[1677478500, 23421.56, 23434.86, 23389.07, 23389.07, 12.30733, 288195.9958506],
	[1677479400, 23389.53, 23408.25, 23374.64, 23396.03, 12.28967, 287494.136262],
	[1677480300, 23396.91, 23428.04, 23394.1, 23405.76, 15.55536, 364195.2857147],
	[1677481200, 23405.75, 23449.02, 23402.23, 23431.28, 14.04922, 329095.7493988],
	[1677482100, 23431.27, 23455.16, 23413.25, 23452.76, 13.18736, 308972.8550382],
	[1677483000, 23454.74, 23455.99, 23418.82, 23433.78, 16.08355, 377013.2084584],
	[1677483900, 23433.79, 23446.24, 23416.02, 23423.88, 12.54606, 294026.2395635],
	[1677484800, 23423.89, 23453.12, 23376.37, 23390.14, 19.67739, 460806.7559265],
	[1677485700, 23388.76, 23406.87, 23347.2, 23347.2, 14.33297, 335095.0304614],
	[1677486600, 23347.21, 23421.21, 23346.9, 23408.78, 14.81596, 346489.0578455],
	[1677487500, 23408.8, 23419.26, 23357.03, 23359.45, 12.62398, 295323.8245653],
	[1677488400, 23359.44, 23388.82, 23337.09, 23375.81, 13.6386, 318610.8017809],
	[1677489300, 23375.8, 23411.98, 23366.17, 23411.55, 12.85967, 300832.2044171],
	[1677490200, 23411.84, 23437.66, 23402.77, 23414.17, 16.98126, 397715.2317683],
	[1677491100, 23414.16, 23416.26, 23383.84, 23392.14, 12.55984, 293841.1456845],
	[1677492000, 23392.12, 23404.81, 23373.32, 23396.07, 14.11257, 330013.7665065],
	[1677492900, 23396.09, 23397.32, 23369.3, 23393.33, 12.40066, 289950.9608273],
	[1677493800, 23393.31, 23393.34, 23351.05, 23373.39, 12.45374, 290995.9834383],
	[1677494700, 23373.41, 23419.2, 23365.54, 23379.56, 13.52773, 316445.4935302],
	[1677495600, 23379.03, 23409.34, 23371.27, 23406.4, 12.1814, 284999.7399489],
	[1677496500, 23406.41, 23419.68, 23402.19, 23418.05, 13.16851, 308276.7530832],
	[1677497400, 23418.06, 23443.3, 23417.2, 23422.1, 14.81782, 347137.2573331],
	[1677498300, 23422.73, 23444.92, 23411.11, 23430.19, 12.77552, 299339.8735826],
	[1677499200, 23430.18, 23440.36, 23399.21, 23399.47, 15.62367, 365833.3503126],
	[1677500100, 23399.3, 23418.91, 23383.77, 23389.59, 12.42938, 290834.0369764],
	[1677501000, 23389.61, 23414.36, 23381.81, 23407.19, 15.52351, 363244.0759843],
	[1677501900, 23407.09, 23435.5, 23381.34, 23403.48, 14.63756, 342618.8811161],
	[1677502800, 23403.36, 23445.46, 23398.45, 23434.25, 15.15072, 354838.580056],
	[1677503700, 23434.24, 23553.12, 23433.76, 23552.21, 16.74647, 393541.2539558],
	[1677504600, 23552.19, 23798.29, 23540.82, 23739.12, 23.81643, 564176.2778872],
	[1677505500, 23739.88, 23770.31, 23689.01, 23705.33, 22.90727, 543544.1984464],
	[1677506400, 23704.05, 23752.68, 23678.54, 23691.21, 22.55791, 534946.1734529],
	[1677507300, 23691.2, 23851.05, 23684.72, 23790.42, 18.92707, 449765.4487853],
	[1677508200, 23790.41, 23802.37, 23725.13, 23743.34, 22.00673, 523030.3107329],
	[1677509100, 23743.25, 23819.23, 23725.46, 23803.23, 20.19327, 479879.8991453],
	[1677510000, 23803.34, 23895.09, 23772.22, 23840.65, 22.60799, 538797.5545524],
	[1677510900, 23841.19, 23853.6, 23809.79, 23815.59, 24.14579, 575394.1917025],
	[1677511800, 23815.66, 23817.06, 23482.66, 23573.81, 21.45011, 507598.7563157],
	[1677512700, 23573.83, 23622.42, 23512.05, 23558, 22.73108, 535628.7996669],
	[1677513600, 23558.21, 23615.53, 23204.01, 23299.25, 26.78524, 629636.1231853],
	[1677514500, 23300.27, 23352.86, 23255.2, 23321.14, 23.63962, 551153.5427291],
	[1677515400, 23321.13, 23419.07, 23188.1, 23401.1, 26.40815, 615505.88608],
	[1677516300, 23401.09, 23451.21, 23354.2, 23392.22, 18.12987, 424230.9009408],
	[1677517200, 23395.45, 23408.02, 23314.63, 23367.04, 17.43769, 407303.4246716],
	[1677518100, 23367.02, 23377.18, 23268.89, 23338.03, 15.2201, 355120.6517522],
	[1677519000, 23338.04, 23420.86, 23335.09, 23365.34, 14.69157, 343489.7760271],
	[1677519900, 23364.22, 23406.83, 23333.13, 23333.9, 14.13536, 330268.1865376],
	[1677520800, 23333.91, 23366.73, 23273.03, 23328.24, 15.99625, 372907.1791619],
	[1677521700, 23328.25, 23328.29, 23169.53, 23205.18, 17.28322, 401512.8938183],
	[1677522600, 23205.17, 23249.78, 23164.89, 23230.52, 21.30451, 494638.93452],
	[1677523500, 23226.78, 23287.95, 23203.68, 23287.95, 13.98125, 325012.8582345],
	[1677524400, 23287.97, 23358.23, 23253.72, 23294.8, 15.38516, 358375.9669108],
	[1677525300, 23294.78, 23320.17, 23221.98, 23311.76, 17.37127, 404117.8412475],
	[1677526200, 23311.77, 23333.67, 23260.36, 23286.91, 17.12461, 399104.0399545],
	[1677527100, 23286.92, 23304.15, 23256.45, 23275.92, 14.00576, 326086.8370355],
	[1677528000, 23275.94, 23275.96, 23149.09, 23224.19, 18.44074, 428001.9072996],
	[1677528900, 23224.17, 23266.27, 23188.97, 23262.12, 18.2591, 424052.2838724],
	[1677529800, 23262.14, 23262.23, 23195.25, 23247.11, 19.09536, 443559.4257764],
	[1677530700, 23245.69, 23327.84, 23241.4, 23320.66, 14.68262, 341864.9719013],
	[1677531600, 23320.67, 23366.17, 23298.61, 23336.61, 16.09174, 375470.7340578],
	[1677532500, 23336.96, 23366.96, 23313.35, 23350.09, 15.23477, 355620.9368315],
	[1677533400, 23350.1, 23394.1, 23347.62, 23379.92, 14.84142, 346850.4129901],
	[1677534300, 23379.93, 23391.61, 23361.58, 23380.78, 13.87044, 324248.9412708],
	[1677535200, 23380.77, 23435.08, 23362.01, 23388.87, 15.63334, 365801.4743782],
	[1677536100, 23388.89, 23421.72, 23362.57, 23380.56, 15.21757, 355970.9852724],
	[1677537000, 23380.05, 23415.1, 23378.85, 23398.13, 15.62655, 365626.4987416],
	[1677537900, 23398.64, 23536.62, 23392.35, 23476.4, 16.49294, 386952.0138404],
	[1677538800, 23479.78, 23505.52, 23449.76, 23468.13, 12.78774, 300300.7781122],
	[1677539700, 23468.11, 23523.35, 23467.42, 23491.54, 12.90511, 303238.2010418],
	[1677540600, 23491.53, 23551.27, 23481.66, 23531.29, 14.21297, 334176.8786775],
	[1677541500, 23533.85, 23574.35, 23487.89, 23488.23, 15.27467, 359158.3689874],
	[1677542400, 23488.25, 23512.97, 23471.68, 23484.39, 11.98213, 281460.7332099],
	[1677543300, 23484.37, 23547.87, 23473.21, 23480.3, 17.09605, 401791.5440555],
	[1677544200, 23480.31, 23524.36, 23445.72, 23471.93, 17.40771, 408616.3714398],
	[1677545100, 23472.83, 23483.13, 23413.85, 23420.46, 13.54925, 317750.6363936],
	[1677546000, 23420.48, 23456.61, 23395.32, 23453.91, 16.33998, 382722.2196757],
	[1677546900, 23453.93, 23458.73, 23411.25, 23421.2, 13.96539, 327260.5070042],
	[1677547800, 23421.26, 23441.09, 23352.99, 23365.96, 13.06558, 305682.2799736],
	[1677548700, 23365.97, 23452.87, 23361.29, 23432.68, 14.96715, 350454.4535218],
	[1677549600, 23432.7, 23439.75, 23388.6, 23439.75, 12.74124, 298336.1772686],
	[1677550500, 23439.81, 23474.28, 23429.09, 23470.37, 12.55802, 294512.7538156],
	[1677551400, 23470.38, 23470.39, 23424.72, 23426.15, 11.62382, 272491.3107268],
	[1677552300, 23426.37, 23456.31, 23412.81, 23441.83, 13.70726, 321203.1688458],
	[1677553200, 23441.82, 23522.78, 23437.06, 23494.28, 11.96652, 280731.2382647],
	[1677554100, 23494.3, 23507.82, 23467.55, 23479.74, 14.89656, 349850.2785831],
	[1677555000, 23477.79, 23488.95, 23459.62, 23487.74, 14.84599, 348532.470936],
	[1677555900, 23487.72, 23488.94, 23452.1, 23465.86, 12.18841, 285970.6049347],
	[1677556800, 23465.88, 23467.53, 23423.21, 23426.15, 17.01143, 398843.2826516],
	[1677557700, 23426.13, 23439.98, 23397.13, 23426.64, 14.569, 341170.9610089],
	[1677558600, 23426.63, 23428.77, 23392.95, 23412.7, 14.9587, 350191.6791967],
	[1677559500, 23412.68, 23437.45, 23390.07, 23413.95, 12.51854, 293144.1466691],
	[1677560400, 23413.97, 23432.04, 23406.62, 23431.84, 13.36878, 313059.8240465],
	[1677561300, 23431.83, 23446.67, 23407.78, 23428.37, 13.72069, 321497.0903177],
	[1677562200, 23429.03, 23429.03, 23365.74, 23396.42, 15.52581, 363237.5052557],
	[1677563100, 23396.46, 23405.05, 23374.97, 23375.33, 16.12181, 377104.3925737],
	[1677564000, 23375.34, 23401.6, 23367.93, 23401.59, 14.68005, 343330.1850773],
	[1677564900, 23401.59, 23407.51, 23371.36, 23371.36, 12.51771, 292839.3242895],
	[1677565800, 23372.54, 23404.92, 23365.26, 23397.29, 13.86041, 324234.3247478],
	[1677566700, 23397.3, 23413.28, 23387.08, 23391.88, 13.15795, 307870.5996891],
	[1677567600, 23391.9, 23392.89, 23367.45, 23388.97, 16.58299, 387753.7759676],
	[1677568500, 23388.62, 23395.79, 23354.47, 23356.17, 16.64866, 389222.9397326],
	[1677569400, 23356.16, 23377.74, 23285.38, 23305.85, 22.50877, 525156.2137364],
	[1677570300, 23307.96, 23310.87, 23225.06, 23234.99, 17.90746, 416605.3320897],
	[1677571200, 23235, 23280.14, 23205.15, 23268.41, 18.17074, 422375.2198324],
	[1677572100, 23268.39, 23295.31, 23236.36, 23289.7, 16.70004, 388595.707694],
	[1677573000, 23289.71, 23300.5, 23264.25, 23280.14, 12.12753, 282318.3159134],
	[1677573900, 23280.16, 23299.62, 23243.8, 23265.03, 15.80633, 367842.9286341],
	[1677574800, 23265.04, 23319.76, 23259.99, 23303.97, 14.83465, 345556.7612154],
	[1677575700, 23303.95, 23310.43, 23276.85, 23288.15, 20.60433, 479919.8300143],
	[1677576600, 23288.16, 23289.85, 23244.88, 23276.23, 16.03908, 373199.720254],
	[1677577500, 23276.22, 23296.34, 23257.13, 23268.64, 14.6948, 342077.8136145],
	[1677578400, 23268.63, 23298.03, 23254.79, 23288.12, 15.78201, 367319.7306174],
	[1677579300, 23288.14, 23310.38, 23270.92, 23294.2, 13.30515, 309849.5108473],
	[1677580200, 23294.18, 23355.41, 23287.46, 23354.38, 16.03564, 373875.8990018],
	[1677581100, 23354.37, 23385.13, 23345.15, 23362.87, 18.98587, 443579.490416],
	[1677582000, 23364.55, 23375.9, 23337.85, 23341.98, 13.74366, 321039.431335],
	[1677582900, 23341.48, 23367.23, 23338.65, 23347.36, 16.77999, 391906.2200837],
	[1677583800, 23347.35, 23419.58, 23347.21, 23405.93, 19.13408, 447335.9125145],
	[1677584700, 23405.92, 23414.35, 23381.89, 23392.61, 19.0116, 444845.1108401],
	[1677585600, 23392.63, 23450.92, 23388.37, 23433.31, 18.47476, 432621.8950358],
	[1677586500, 23433.3, 23501.95, 23429.71, 23494.08, 19.90463, 467129.5856932],
	[1677587400, 23494.68, 23500.61, 23451.2, 23457.62, 16.70119, 391930.1391302],
	[1677588300, 23457.61, 23470.25, 23439.23, 23455.34, 17.42687, 408774.478505],
	[1677589200, 23454.76, 23485.82, 23394.99, 23428.5, 19.37669, 454010.0854226],
	[1677590100, 23428.48, 23438.75, 23372.6, 23408.52, 17.87233, 418354.9724269],
	[1677591000, 23408.53, 23415.93, 23376.63, 23391.04, 18.15303, 424592.7971448],
	[1677591900, 23391.05, 23445.42, 23391.05, 23402.86, 15.65093, 366462.7851714],
	[1677592800, 23402.85, 23431.04, 23381.63, 23392.61, 16.27003, 380820.5874573],
	[1677593700, 23392.62, 23427.16, 23385.75, 23395.25, 14.74987, 345237.7384042],
	[1677594600, 23395.14, 23550.54, 23323.97, 23502.81, 23.28004, 545683.0913632],
	[1677595500, 23502.79, 23571.65, 23410.04, 23423.07, 28.40914, 667073.3981334],
	[1677596400, 23423.06, 23528.82, 23407.83, 23439.29, 24.11402, 566029.1373975],
	[1677597300, 23439.18, 23540.79, 23408.74, 23466.07, 21.46281, 503729.7528248],
	[1677598200, 23468.34, 23542.97, 23458.24, 23522.2, 24.09819, 566333.5745671],
	[1677599100, 23522.73, 23531.35, 23475.21, 23519.75, 21.1405, 496876.7024268],
	[1677600000, 23519.73, 23597.81, 23501.25, 23505.88, 24.90078, 586467.8170092],
	[1677600900, 23505.86, 23531.86, 23462.23, 23490.24, 20.51308, 481956.9163846],
	[1677601800, 23490.25, 23498.54, 23450.66, 23451.21, 18.55161, 435406.2878327],
	[1677602700, 23451.1, 23476.75, 23427.19, 23455.37, 20.31673, 476428.2322717],
	[1677603600, 23455.57, 23509.42, 23449.4, 23502.96, 17.61643, 413512.3313484],
	[1677604500, 23502.98, 23540.47, 23483.21, 23503.61, 17.64111, 414709.3606068],
	[1677605400, 23503.62, 23508.15, 23475.99, 23502.28, 17.13566, 402550.4959911],
	[1677606300, 23502.73, 23556.1, 23497.2, 23526.05, 16.72575, 393605.5571404],
	[1677607200, 23526.07, 23547.39, 23512.31, 23512.38, 16.74654, 394038.2043341],
	[1677608100, 23512.4, 23512.44, 23437.98, 23482.99, 17.51067, 411132.0827921],
	[1677609000, 23482.98, 23497, 23443.79, 23485.49, 17.95467, 421327.1819571],
	[1677609900, 23485.12, 23498.15, 23459.82, 23480.64, 14.44257, 339085.3673313],
	[1677610800, 23481.11, 23491.07, 23435.34, 23461.98, 14.93682, 350442.4966786],
	[1677611700, 23461.57, 23464.13, 23221.45, 23227.82, 22.33262, 521736.4826078],
	[1677612600, 23227.81, 23318.94, 23213.27, 23277.69, 22.43982, 522385.9009282],
	[1677613500, 23277.71, 23312.6, 23252.05, 23264.74, 18.00615, 419195.631525],
	[1677614400, 23264.73, 23311.15, 23171.53, 23304.83, 25.88424, 601658.6452749],
	[1677615300, 23304.81, 23304.81, 23246.09, 23259.87, 21.73182, 505786.0526406],
	[1677616200, 23259.22, 23306.72, 23229.68, 23303.5, 20.79499, 483798.1183304],
	[1677617100, 23303.52, 23340.45, 23275.86, 23275.86, 19.81832, 461882.7693768],
	[1677618000, 23275.84, 23275.84, 23116.22, 23164.68, 19.12564, 443548.418523],
	[1677618900, 23166.12, 23207.6, 23153.69, 23193.72, 17.15914, 397836.9512479],
	[1677619800, 23194.23, 23196.27, 23028.58, 23090.8, 20.12758, 464945.1023382],
	[1677620700, 23089.19, 23151.91, 23042.64, 23139.91, 20.40061, 471328.7325543],
	[1677621600, 23139.9, 23224.67, 23097.38, 23221.3, 19.2508, 446071.0814639],
	[1677622500, 23221.76, 23238.23, 23182.66, 23194.06, 24.68166, 572756.5331743],
	[1677623400, 23194.05, 23222.44, 23173.01, 23222.44, 17.50017, 406033.4264857],
	[1677624300, 23222.46, 23227.33, 23123.87, 23159.3, 18.02575, 417651.3991424],
	[1677625200, 23159.84, 23167.9, 23124.53, 23153.77, 19.60989, 453985.6203635],
	[1677626100, 23153.76, 23196.73, 23125.18, 23127.61, 16.35519, 379018.9083542],
	[1677627000, 23127.22, 23173.9, 23102.81, 23137.16, 16.06103, 371545.7813026],
	[1677627900, 23137.15, 23159.75, 23113.74, 23132.39, 16.85952, 390065.08279],
	[1677628800, 23133.91, 23179.55, 23119.21, 23160.43, 15.80283, 365828.808397],
	[1677629700, 23160.45, 23218.22, 23159.68, 23170.95, 16.15786, 374625.8601256],
	[1677630600, 23170.93, 23216.03, 23142.52, 23143.32, 15.44294, 358117.7195363],
	[1677631500, 23146.03, 23147.76, 23022.12, 23098.1, 19.75152, 455913.9755774],
	[1677632400, 23098.08, 23164.9, 23077.15, 23164.75, 17.81147, 411811.1591821],
	[1677633300, 23164.24, 23166.13, 23125.93, 23149.15, 14.8146, 342873.7536175],
	[1677634200, 23149.17, 23274.72, 23149.17, 23236.72, 15.41754, 358003.7245882],
	[1677635100, 23237.31, 23294.15, 23225.72, 23248.53, 14.92876, 347089.803393],
	[1677636000, 23247.99, 23263.83, 23237.36, 23258.48, 15.55253, 361596.2307062],
	[1677636900, 23258.5, 23287.19, 23242.07, 23245.76, 12.69914, 295445.8632974],
	[1677637800, 23245.46, 23315.68, 23235.43, 23292.43, 17.23934, 401241.3886137],
	[1677638700, 23293.25, 23333.02, 23289.45, 23328.76, 16.93749, 394724.5524994],
	[1677639600, 23331.8, 23439.85, 23307.3, 23439.22, 20.18062, 470872.0648021],
	[1677640500, 23438.59, 23491.84, 23390.27, 23419.26, 23.39367, 548507.4992652],
	[1677641400, 23422.09, 23487.68, 23422.09, 23475, 19.41475, 455554.9048149],
	[1677642300, 23474.99, 23484.28, 23405.12, 23441.91, 16.07861, 376867.9065637],
	[1677643200, 23441.89, 23455.43, 23429.17, 23430.5, 16.12003, 377822.9103909],
	[1677644100, 23430.57, 23482.31, 23430.57, 23467.07, 18.54112, 434985.0911647],
	[1677645000, 23467.08, 23525.45, 23467.08, 23492.12, 13.85937, 325661.2321329],
	[1677645900, 23492.13, 23837.49, 23492.13, 23792.6, 20.43446, 484352.693998],
	[1677646800, 23792.55, 23820.41, 23729.85, 23730.88, 21.89969, 520782.6676474],
	[1677647700, 23730.86, 23760.79, 23650.29, 23681.65, 20.44646, 484441.1032018],
	[1677648600, 23682.91, 23719.28, 23637.77, 23682.39, 18.75004, 444081.1829765],
	[1677649500, 23682.4, 23799.52, 23657.73, 23677.8, 12.21567, 289288.480896]
]

''';
