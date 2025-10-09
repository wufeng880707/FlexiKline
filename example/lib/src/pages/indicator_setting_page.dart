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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/flexi_theme.dart';
import '../widgets/right_arrow.dart';
import 'settings/main_indicators/avl_setting_page.dart';
import 'settings/main_indicators/ma_setting_page.dart';
import 'settings/sub_indicators/macd_setting_page.dart';
import 'settings/sub_indicators/vol_ma_setting_page.dart';

class IndicatorSettingPage extends ConsumerStatefulWidget {
  const IndicatorSettingPage({
    super.key,
    required this.controller,
  });

  final FlexiKlineController controller;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _IndicatorSettingPageState();
}

class _IndicatorSettingPageState extends ConsumerState<IndicatorSettingPage> {
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    return Scaffold(
      backgroundColor: theme.pageBg,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(
          '指标设置',
          style: theme.t1s18w600,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: 16.r,
                vertical: 12.r,
              ),
              child: Text(
                '主图指标',
                style: theme.t2s14w400,
              ),
            ),
            ListTile(
              onTap: () {},
              title: Text(
                'VOL(成交量)',
                style: theme.t1s16w400,
              ),
              trailing: const RightArrow(),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MASettingPage(),
                  ),
                );
              },
              title: Text(
                'MA(移动平均线)',
                style: theme.t1s16w400,
              ),
              trailing: const RightArrow(),
            ),
            ListTile(
              onTap: () {},
              title: Text(
                'EMA(指数移动平均线)',
                style: theme.t1s16w400,
              ),
              trailing: const RightArrow(),
            ),
            ListTile(
              onTap: () {},
              title: Text(
                'BOLL(布林线)',
                style: theme.t1s16w400,
              ),
              trailing: const RightArrow(),
            ),
            ListTile(
              onTap: () {},
              title: Text(
                'SAR(抛物线转向指标)',
                style: theme.t1s16w400,
              ),
              trailing: const RightArrow(),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AVLSettingPage(controller: widget.controller),
                  ),
                );
              },
              title: Text(
                'AVL(均价线指标)',
                style: theme.t1s16w400,
              ),
              trailing: const RightArrow(),
            ),
            Container(height: 0.5.r, color: theme.dividerLine),
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: 16.r,
                vertical: 12.r,
              ),
              child: Text(
                '副图指标',
                style: theme.t2s14w400,
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const VolMASettingPage(),
                  ),
                );
              },
              title: Text(
                'VOLMA(成交量移动平均线)',
                style: theme.t1s16w400,
              ),
              trailing: const RightArrow(),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MACDSettingPage(),
                  ),
                );
              },
              title: Text(
                'MACD(指数平滑异同移动平均线)',
                style: theme.t1s16w400,
              ),
              trailing: const RightArrow(),
            ),
            ListTile(
              onTap: () {},
              title: Text(
                'KDJ(随机指标)',
                style: theme.t1s16w400,
              ),
              trailing: const RightArrow(),
            ),
            ListTile(
              onTap: () {},
              title: Text(
                'BOLL(布林线)',
                style: theme.t1s16w400,
              ),
              trailing: const RightArrow(),
            ),
            ListTile(
              onTap: () {},
              title: Text(
                'SAR(抛物线转向指标)',
                style: theme.t1s16w400,
              ),
              trailing: const RightArrow(),
            ),
            ListTile(
              onTap: () {},
              title: Text(
                'RSI(相对强弱指标)',
                style: theme.t1s16w400,
              ),
              trailing: const RightArrow(),
            ),
            SizedBox(height: 20.r)
          ],
        ),
      ),
    );
  }
}
