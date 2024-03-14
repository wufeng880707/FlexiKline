import 'package:flutter/widgets.dart';

class KlineWidget extends StatefulWidget {
  const KlineWidget({super.key});

  @override
  State<KlineWidget> createState() => _KlineWidgetState();
}

class _KlineWidgetState extends State<KlineWidget> {
  Size size = Size.zero;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.loose(size),
      child: Stack(
        children: <Widget>[
          RepaintBoundary(
            child: CustomPaint(
              size: size,
              // painter: KlinePainter(klineData: controller.klineData),
              isComplex: true,
            ),
          ),
        ],
      ),
    );
  }
}

class KlinePainter extends CustomPainter {
  const KlinePainter({required this.klineData}) : super(repaint: klineData);

  final ChangeNotifier klineData;

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    throw oldDelegate != this;
  }
}
