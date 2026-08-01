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

library;

import 'package:flexi_formatter/date_time.dart' show TimeUnit;
import 'package:flexi_kline/flexi_kline.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BusinessOverlayBinding', () {
    test('drag end keeps editing state bound to updated manager object', () async {
      final scenario = ControllerScenario(
        config: FakeFlexiKlineConfiguration(
          mainIndicatorDefaultSize: const Size(400, 300),
        ),
      );
      addTearDown(scenario.dispose);

      const spec = KlineSpec(
        symbol: 'BTC-USDT',
        interval: FlexiTimeInterval(1, TimeUnit.minute),
        precision: 2,
      );
      await scenario.initWithData(
        spec,
        await genRandomCandleList(count: 20, interval: spec.interval),
      );

      final controller = scenario.controller;
      controller.addBusinessOverlay(
        _TestBusinessOverlay(id: 'overlay-1', hitDy: 40),
      );
      controller.onBusinessOverlayAction = (event) {
        controller.updateBusinessOverlay(
          _TestBusinessOverlay(id: event.object.id, hitDy: 80),
        );
      };

      expect(controller.onBusinessOverlayTap(const Offset(10, 40)), isTrue);
      expect(controller.businessOverlayState.isEditing, isTrue);

      final firstDrag = GestureData.pan(const Offset(10, 40));
      expect(controller.onBusinessOverlayDragStart(firstDrag), isTrue);
      controller.onBusinessOverlayDragUpdate(
        firstDrag..update(const Offset(10, 80)),
      );
      controller.onBusinessOverlayDragEndAction();

      expect(controller.businessOverlayState.isEditing, isTrue);
      expect(
        (controller.businessOverlayState.object! as _TestBusinessOverlay).hitDy,
        80,
      );

      final secondDrag = GestureData.pan(const Offset(10, 80));
      expect(controller.onBusinessOverlayDragStart(secondDrag), isTrue);
    });
  });
}

class _TestBusinessOverlay extends BusinessOverlayObject {
  _TestBusinessOverlay({
    required this.id,
    required this.hitDy,
  });

  @override
  final String id;

  final double hitDy;

  @override
  BusinessOverlayType get type => BusinessOverlayType.pendingOrder;

  @override
  BusinessOverlayHitResult? hitTest(
    Offset position,
    BusinessOverlayPaintContext ctx,
  ) {
    if ((position.dy - hitDy).abs() > 1) return null;
    return BusinessOverlayHitResult(
      objectId: id,
      area: BusinessOverlayHitArea.line,
    );
  }

  @override
  void onDragStart(Offset position, BusinessOverlayPaintContext ctx) {}

  @override
  void onDragUpdate(Offset position, Offset delta, Rect chartRect) {}

  @override
  BusinessOverlayDragResult? onDragEnd(BusinessOverlayPaintContext ctx) {
    return BusinessOverlayDragResult(value: FlexiNum.fromNum(80));
  }

  @override
  void onDragCancel() {}

  @override
  void paintDragging(Canvas canvas, BusinessOverlayPaintContext ctx) {}

  @override
  void paintEditing(Canvas canvas, BusinessOverlayPaintContext ctx) {}

  @override
  void paintNormal(Canvas canvas, BusinessOverlayPaintContext ctx) {}
}
