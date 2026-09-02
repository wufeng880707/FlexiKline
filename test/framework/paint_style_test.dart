import 'package:flexi_kline/flexi_kline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/doubles/fake_paint_context.dart';
import '../support/doubles/test_indicators.dart';

void main() {
  test('cached candle paints refresh independently when candle width changes', () {
    final context = _MutableCandleWidthPaintContext(8);
    final indicator = TestComputedIndicator(
      key: const ComputedIndicatorKey('paint-style'),
    );
    final object = _PaintStyleProbe();

    object.mount(indicator, context);

    expect(object.defLongBarPaint.strokeWidth, 8);
    expect(object.defShortBarPaint.strokeWidth, 8);

    context.width = 12;

    expect(object.defLongBarPaint.strokeWidth, 12);
    expect(object.defShortBarPaint.strokeWidth, 12);
    expect(object.defLongTintBarPaint.strokeWidth, 12);
    expect(object.defShortTintBarPaint.strokeWidth, 12);
  });
}

class _MutableCandleWidthPaintContext extends FakePaintContext {
  _MutableCandleWidthPaintContext(this.width);

  double width;

  @override
  double get candleWidth => width;
}

class _PaintStyleProbe extends ComputedPaintObject<TestComputedIndicator> {
  @override
  MinMax? computeVisibleMinMax(int start, int end) => null;

  @override
  void paint(Canvas canvas, Size size) {}
}
