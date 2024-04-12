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

import 'package:example/src/pages/setting_page.dart';
import 'package:flexi_kline/flexi_kline.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../repo/api.dart' as api;
import '../widgets/latest_price_view.dart';

class KOKlinePage extends ConsumerStatefulWidget {
  const KOKlinePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _KOKlinePageState();
}

class _KOKlinePageState extends ConsumerState<KOKlinePage> {
  CandleReq req = CandleReq(
    instId: 'BTC-USDT',
    bar: TimeBar.m15.bar,
    precision: 4,
    limit: 300,
  );

  late final FlexiKlineController controller;
  CandleModel? latest;

  @override
  void initState() {
    super.initState();

    controller = FlexiKlineController(debug: kDebugMode);
    controller.setMainSize(
      Size(ScreenUtil().screenWidth, 300.r),
    );

    api.getHistoryCandles(req).then((resp) {
      if (resp.success && resp.data != null) {
        latest = resp.data?.first;
        controller.setKlineData(req, resp.data!);
        setState(() {});
      } else {
        SmartDialog.showToast(resp.msg);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(req.instId),
        centerTitle: true,
      ),
      drawer: const SettingDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            LatestPriceView(
              model: latest,
              precision: req.precision,
            ),
            FlexiKlineWidget(
              controller: controller,
            ),
          ],
        ),
      ),
    );
  }
}
