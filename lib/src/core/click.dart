// import 'dart:ui';
//
// import '../../flexi_kline.dart';
// import '../framework/click/click_object.dart';
part of 'core.dart';

mixin ClickBinding on KlineBindingBase {
  /// 处理点击事件
  bool handleClick(Offset position) {
    // 检查主图指标
    for (final paintObject in mainPaintObject.children) {
      if (paintObject is ClickableMixin) {
        if ((paintObject as ClickableMixin).handleClick(position)) {
          return true; // 已处理
        }
      }
    }
    return false; // 未处理
  }
}
