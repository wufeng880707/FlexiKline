part of 'trade_mark.dart';

@CopyWith()
@FlexiParamSerializable
class TradeMarkParam extends Equatable {
  const TradeMarkParam({
    this.spacing = 2.0,
    this.markerRadius = 5.0,
    this.arrowSize = 6.0,
    this.buyBgColor = const Color(0xff03a66d),
    this.sellBgColor = const Color(0xfff15057),
    this.buyTextStyle = const TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 8.0,
      fontWeight: FontWeight.bold,
    ),
    this.sellTextStyle = const TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 8.0,
      fontWeight: FontWeight.bold,
    ),
    this.borderWidth = 0.0,
    this.borderColor,
    this.showQuantity = false,
    this.show = true,
    this.useArrowStyle = true,
  });

  /// 标记与K线的间距
  final double spacing;

  /// 标记圆形背景半径
  final double markerRadius;

  /// 箭头大小（三角形底边的一半）
  final double arrowSize;

  /// 买入标记背景色
  final Color buyBgColor;

  /// 卖出标记背景色
  final Color sellBgColor;

  /// 买入文字
  final TextStyle buyTextStyle;

  /// 卖出文字
  final TextStyle sellTextStyle;

  /// 边框宽度
  final double borderWidth;

  /// 边框颜色（如果为null则不显示边框）
  final Color? borderColor;

  /// 是否显示交易数量
  final bool showQuantity;

  /// 是否显示交易标记
  final bool show;

  /// 是否使用箭头样式（否则使用圆形）
  final bool useArrowStyle;

  /// 验证参数是否有效
  bool isValid(int len) => 
      len > 0 && 
      markerRadius > 0 && 
      (buyTextStyle.fontSize ?? 12.0) > 0 &&
      (sellTextStyle.fontSize ?? 12.0) > 0;

  factory TradeMarkParam.fromJson(Map<String, dynamic> json) => _$TradeMarkParamFromJson(json);
  Map<String, dynamic> toJson() => _$TradeMarkParamToJson(this);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [
        spacing,
        markerRadius,
        arrowSize,
        buyBgColor,
        sellBgColor,
        buyTextStyle,
        sellTextStyle,
        borderWidth,
        borderColor,
        showQuantity,
        show,
        useArrowStyle,
      ];
}
