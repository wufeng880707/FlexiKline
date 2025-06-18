import 'package:flutter_ume_kit_dio_plus/flutter_ume_kit_dio_plus.dart';

class AppDioInspector extends DioInspector {
  AppDioInspector({super.key, required super.dio, required this.showName});

  final String showName;

  @override
  String get name => showName;

  @override
  String get displayName => showName;
}
