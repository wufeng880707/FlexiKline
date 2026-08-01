// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cci.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CCIIndicatorCWProxy {
  CCIIndicator zIndex(int zIndex);

  CCIIndicator height(double height);

  CCIIndicator padding(EdgeInsets padding);

  CCIIndicator calcParam(CCIParam calcParam);

  CCIIndicator tipsPadding(EdgeInsets tipsPadding);

  CCIIndicator tickCount(int tickCount);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CCIIndicator(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CCIIndicator(...).copyWith(id: 12, name: "My name")
  /// ````
  CCIIndicator call({
    int zIndex,
    double height,
    EdgeInsets padding,
    CCIParam calcParam,
    EdgeInsets tipsPadding,
    int tickCount,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCCIIndicator.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCCIIndicator.copyWith.fieldName(...)`
class _$CCIIndicatorCWProxyImpl implements _$CCIIndicatorCWProxy {
  const _$CCIIndicatorCWProxyImpl(this._value);

  final CCIIndicator _value;

  @override
  CCIIndicator zIndex(int zIndex) => this(zIndex: zIndex);

  @override
  CCIIndicator height(double height) => this(height: height);

  @override
  CCIIndicator padding(EdgeInsets padding) => this(padding: padding);

  @override
  CCIIndicator calcParam(CCIParam calcParam) => this(calcParam: calcParam);

  @override
  CCIIndicator tipsPadding(EdgeInsets tipsPadding) => this(tipsPadding: tipsPadding);

  @override
  CCIIndicator tickCount(int tickCount) => this(tickCount: tickCount);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CCIIndicator(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CCIIndicator(...).copyWith(id: 12, name: "My name")
  /// ````
  CCIIndicator call({
    Object? zIndex = const $CopyWithPlaceholder(),
    Object? height = const $CopyWithPlaceholder(),
    Object? padding = const $CopyWithPlaceholder(),
    Object? calcParam = const $CopyWithPlaceholder(),
    Object? tipsPadding = const $CopyWithPlaceholder(),
    Object? tickCount = const $CopyWithPlaceholder(),
  }) {
    return CCIIndicator(
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
          : calcParam as CCIParam,
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

extension $CCIIndicatorCopyWith on CCIIndicator {
  /// Returns a callable class that can be used as follows: `instanceOfCCIIndicator.copyWith(...)` or like so:`instanceOfCCIIndicator.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CCIIndicatorCWProxy get copyWith => _$CCIIndicatorCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CCIIndicator _$CCIIndicatorFromJson(Map<String, dynamic> json) => CCIIndicator(
      zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
      height: (json['height'] as num).toDouble(),
      padding: json['padding'] == null
          ? defaultSubIndicatorPadding
          : const EdgeInsetsConverter().fromJson(json['padding'] as Map<String, dynamic>),
      calcParam: CCIParam.fromJson(json['calcParam'] as Map<String, dynamic>),
      tipsPadding: const EdgeInsetsConverter().fromJson(json['tipsPadding'] as Map<String, dynamic>),
      tickCount: (json['tickCount'] as num?)?.toInt() ?? defaultSubTickCount,
    );

Map<String, dynamic> _$CCIIndicatorToJson(CCIIndicator instance) => <String, dynamic>{
      'height': instance.height,
      'padding': const EdgeInsetsConverter().toJson(instance.padding),
      'zIndex': instance.zIndex,
      'calcParam': instance.calcParam.toJson(),
      'tipsPadding': const EdgeInsetsConverter().toJson(instance.tipsPadding),
      'tickCount': instance.tickCount,
    };
