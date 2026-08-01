// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'obv.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OBVIndicatorCWProxy {
  OBVIndicator zIndex(int zIndex);

  OBVIndicator height(double height);

  OBVIndicator padding(EdgeInsets padding);

  OBVIndicator calcParam(OBVParam calcParam);

  OBVIndicator tipsPadding(EdgeInsets tipsPadding);

  OBVIndicator tickCount(int tickCount);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OBVIndicator(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OBVIndicator(...).copyWith(id: 12, name: "My name")
  /// ````
  OBVIndicator call({
    int zIndex,
    double height,
    EdgeInsets padding,
    OBVParam calcParam,
    EdgeInsets tipsPadding,
    int tickCount,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOBVIndicator.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOBVIndicator.copyWith.fieldName(...)`
class _$OBVIndicatorCWProxyImpl implements _$OBVIndicatorCWProxy {
  const _$OBVIndicatorCWProxyImpl(this._value);

  final OBVIndicator _value;

  @override
  OBVIndicator zIndex(int zIndex) => this(zIndex: zIndex);

  @override
  OBVIndicator height(double height) => this(height: height);

  @override
  OBVIndicator padding(EdgeInsets padding) => this(padding: padding);

  @override
  OBVIndicator calcParam(OBVParam calcParam) => this(calcParam: calcParam);

  @override
  OBVIndicator tipsPadding(EdgeInsets tipsPadding) => this(tipsPadding: tipsPadding);

  @override
  OBVIndicator tickCount(int tickCount) => this(tickCount: tickCount);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OBVIndicator(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OBVIndicator(...).copyWith(id: 12, name: "My name")
  /// ````
  OBVIndicator call({
    Object? zIndex = const $CopyWithPlaceholder(),
    Object? height = const $CopyWithPlaceholder(),
    Object? padding = const $CopyWithPlaceholder(),
    Object? calcParam = const $CopyWithPlaceholder(),
    Object? tipsPadding = const $CopyWithPlaceholder(),
    Object? tickCount = const $CopyWithPlaceholder(),
  }) {
    return OBVIndicator(
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
          : calcParam as OBVParam,
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

extension $OBVIndicatorCopyWith on OBVIndicator {
  /// Returns a callable class that can be used as follows: `instanceOfOBVIndicator.copyWith(...)` or like so:`instanceOfOBVIndicator.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OBVIndicatorCWProxy get copyWith => _$OBVIndicatorCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OBVIndicator _$OBVIndicatorFromJson(Map<String, dynamic> json) => OBVIndicator(
      zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
      height: (json['height'] as num).toDouble(),
      padding: json['padding'] == null
          ? defaultSubIndicatorPadding
          : const EdgeInsetsConverter().fromJson(json['padding'] as Map<String, dynamic>),
      calcParam: OBVParam.fromJson(json['calcParam'] as Map<String, dynamic>),
      tipsPadding: const EdgeInsetsConverter().fromJson(json['tipsPadding'] as Map<String, dynamic>),
      tickCount: (json['tickCount'] as num?)?.toInt() ?? defaultSubTickCount,
    );

Map<String, dynamic> _$OBVIndicatorToJson(OBVIndicator instance) => <String, dynamic>{
      'height': instance.height,
      'padding': const EdgeInsetsConverter().toJson(instance.padding),
      'zIndex': instance.zIndex,
      'calcParam': instance.calcParam.toJson(),
      'tipsPadding': const EdgeInsetsConverter().toJson(instance.tipsPadding),
      'tickCount': instance.tickCount,
    };
