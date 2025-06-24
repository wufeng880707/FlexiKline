part of 'trade_mark.dart';

/// 交易标记参数配置
@CopyWith()
@FlexiParamSerializable
final class TradeMarkParam {
  const TradeMarkParam({
    this.show = true,
    this.spacing = 4.0,
    this.markerRadius = 8.0,
    this.buyBgColor = const Color(0xff03a66d),
    this.sellBgColor = const Color(0xfff15057),
    this.buyStyle = const TextStyle(
      color: Colors.white,
      fontSize: 10,
      fontWeight: FontWeight.bold,
    ),
    this.sellStyle = const TextStyle(
      color: Colors.white,
      fontSize: 10,
      fontWeight: FontWeight.bold,
    ),
  });

  final bool show;
  final double spacing;
  final double markerRadius;
  final Color buyBgColor;
  final Color sellBgColor;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final TextStyle buyStyle;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final TextStyle sellStyle;

  factory TradeMarkParam.fromJson(Map<String, dynamic> json) =>
      _$TradeMarkParamFromJson(json);

  Map<String, dynamic> toJson() => _$TradeMarkParamToJson(this);
} 