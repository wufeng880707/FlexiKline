import 'package:flexi_kline/flexi_kline.dart';
import 'package:flutter/material.dart';

class KLineWidget extends StatefulWidget {
  const KLineWidget({super.key});

  @override
  State<StatefulWidget> createState() => _KLineWidgetState();
}

class _KLineWidgetState extends State<KLineWidget> {
  // 声明 controller
  late final FlexiKlineController controller;

  @override
  void initState() {
    super.initState();

    // // 初始化 controller
    // controller = FlexiKlineController(
    //   configuration: FlexiKlineConfiguration(),
    //   autoSave: true,
    // );

    // // 添加一些示例数据
    // final List<KLineEntity> demoData = [
    //   // 这里添加K线数据，格式为：时间戳、开盘价、最高价、最低价、收盘价、成交量
    //   KLineEntity(
    //     timestamp: DateTime.now().subtract(const Duration(days: 3)).millisecondsSinceEpoch,
    //     open: 100,
    //     high: 105,
    //     low: 95,
    //     close: 102,
    //     volume: 1000,
    //   ),
    //   KLineEntity(
    //     timestamp: DateTime.now().subtract(const Duration(days: 2)).millisecondsSinceEpoch,
    //     open: 102,
    //     high: 108,
    //     low: 100,
    //     close: 106,
    //     volume: 1200,
    //   ),
    //   KLineEntity(
    //     timestamp: DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
    //     open: 106,
    //     high: 110,
    //     low: 104,
    //     close: 108,
    //     volume: 1500,
    //   ),
    // ];
    //
    // // 设置K线数据
    // controller.setKLineDataList(demoData);
  }

  @override
  void dispose() {
    // 释放 controller
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlexiKlineWidget(
      controller: controller,
      // 可以添加其他配置，如：
      // backgroundColor: Colors.black,
      // gridLineColor: Colors.grey,
    );
  }
}
