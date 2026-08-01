// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'macd.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MACDIndicatorCWProxy {
  MACDIndicator zIndex(int zIndex);

  MACDIndicator height(double height);

  MACDIndicator padding(EdgeInsets padding);

  MACDIndicator calcParam(MACDParam calcParam);

  MACDIndicator difTips(TipsConfig difTips);

  MACDIndicator deaTips(TipsConfig deaTips);

  MACDIndicator macdTips(TipsConfig macdTips);

  MACDIndicator tipsPadding(EdgeInsets tipsPadding);

  MACDIndicator tickCount(int tickCount);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MACDIndicator(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MACDIndicator(...).copyWith(id: 12, name: "My name")
  /// ````
  MACDIndicator call({
    int zIndex,
    double height,
    EdgeInsets padding,
    MACDParam calcParam,
    TipsConfig difTips,
    TipsConfig deaTips,
    TipsConfig macdTips,
    EdgeInsets tipsPadding,
    int tickCount,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMACDIndicator.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMACDIndicator.copyWith.fieldName(...)`
class _$MACDIndicatorCWProxyImpl implements _$MACDIndicatorCWProxy {
  const _$MACDIndicatorCWProxyImpl(this._value);

  final MACDIndicator _value;

  @override
  MACDIndicator zIndex(int zIndex) => this(zIndex: zIndex);

  @override
  MACDIndicator height(double height) => this(height: height);

  @override
  MACDIndicator padding(EdgeInsets padding) => this(padding: padding);

  @override
  MACDIndicator calcParam(MACDParam calcParam) => this(calcParam: calcParam);

  @override
  MACDIndicator difTips(TipsConfig difTips) => this(difTips: difTips);

  @override
  MACDIndicator deaTips(TipsConfig deaTips) => this(deaTips: deaTips);

  @override
  MACDIndicator macdTips(TipsConfig macdTips) => this(macdTips: macdTips);

  @override
  MACDIndicator tipsPadding(EdgeInsets tipsPadding) => this(tipsPadding: tipsPadding);

  @override
  MACDIndicator tickCount(int tickCount) => this(tickCount: tickCount);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MACDIndicator(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MACDIndicator(...).copyWith(id: 12, name: "My name")
  /// ````
  MACDIndicator call({
    Object? zIndex = const $CopyWithPlaceholder(),
    Object? height = const $CopyWithPlaceholder(),
    Object? padding = const $CopyWithPlaceholder(),
    Object? calcParam = const $CopyWithPlaceholder(),
    Object? difTips = const $CopyWithPlaceholder(),
    Object? deaTips = const $CopyWithPlaceholder(),
    Object? macdTips = const $CopyWithPlaceholder(),
    Object? tipsPadding = const $CopyWithPlaceholder(),
    Object? tickCount = const $CopyWithPlaceholder(),
  }) {
    return MACDIndicator(
      zIndex: zIndex == const $CopyWithPlaceholder()
          ? _value.zIndex
          // ignore: cast_nullable_to_non_nullable
          : zIndex as int,
      height: height == const $CopyWithPlaceholder()
          ? _value.height
          // ignore: cast_nullable_to_non_nullable
          : height as double,
      padding: padding == const $CopyWithPlaceholder()
          ? _value.padding
          // ignore: cast_nullable_to_non_nullable
          : padding as EdgeInsets,
      calcParam: calcParam == const $CopyWithPlaceholder()
          ? _value.calcParam
          // ignore: cast_nullable_to_non_nullable
          : calcParam as MACDParam,
      difTips: difTips == const $CopyWithPlaceholder()
          ? _value.difTips
          // ignore: cast_nullable_to_non_nullable
          : difTips as TipsConfig,
      deaTips: deaTips == const $CopyWithPlaceholder()
          ? _value.deaTips
          // ignore: cast_nullable_to_non_nullable
          : deaTips as TipsConfig,
      macdTips: macdTips == const $CopyWithPlaceholder()
          ? _value.macdTips
          // ignore: cast_nullable_to_non_nullable
          : macdTips as TipsConfig,
      tipsPadding: tipsPadding == const $CopyWithPlaceholder()
          ? _value.tipsPadding
          // ignore: cast_nullable_to_non_nullable
          : tipsPadding as EdgeInsets,
      tickCount: tickCount == const $CopyWithPlaceholder()
          ? _value.tickCount
          // ignore: cast_nullable_to_non_nullable
          : tickCount as int,
    );
  }
}

extension $MACDIndicatorCopyWith on MACDIndicator {
  /// Returns a callable class that can be used as follows: `instanceOfMACDIndicator.copyWith(...)` or like so:`instanceOfMACDIndicator.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MACDIndicatorCWProxy get copyWith => _$MACDIndicatorCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MACDIndicator _$MACDIndicatorFromJson(Map<String, dynamic> json) => MACDIndicator(
      zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
      height: (json['height'] as num).toDouble(),
      padding: json['padding'] == null
          ? defaultSubIndicatorPadding
          : const EdgeInsetsConverter().fromJson(json['padding'] as Map<String, dynamic>),
      calcParam: json['calcParam'] == null
          ? const MACDParam(s: 12, l: 26, m: 9)
          : MACDParam.fromJson(json['calcParam'] as Map<String, dynamic>),
      difTips: TipsConfig.fromJson(json['difTips'] as Map<String, dynamic>),
      deaTips: TipsConfig.fromJson(json['deaTips'] as Map<String, dynamic>),
      macdTips: TipsConfig.fromJson(json['macdTips'] as Map<String, dynamic>),
      tipsPadding: const EdgeInsetsConverter().fromJson(json['tipsPadding'] as Map<String, dynamic>),
      tickCount: (json['tickCount'] as num?)?.toInt() ?? defaultSubTickCount,
    );

Map<String, dynamic> _$MACDIndicatorToJson(MACDIndicator instance) => <String, dynamic>{
      'height': instance.height,
      'padding': const EdgeInsetsConverter().toJson(instance.padding),
      'zIndex': instance.zIndex,
      'calcParam': instance.calcParam.toJson(),
      'difTips': instance.difTips.toJson(),
      'deaTips': instance.deaTips.toJson(),
      'macdTips': instance.macdTips.toJson(),
      'tipsPadding': const EdgeInsetsConverter().toJson(instance.tipsPadding),
      'tickCount': instance.tickCount,
    };
