// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sar.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SARIndicatorCWProxy {
  SARIndicator zIndex(int zIndex);

  SARIndicator height(double height);

  SARIndicator padding(EdgeInsets padding);

  SARIndicator calcParam(SARParam calcParam);

  SARIndicator tipsPadding(EdgeInsets tipsPadding);

  SARIndicator tickCount(int tickCount);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SARIndicator(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SARIndicator(...).copyWith(id: 12, name: "My name")
  /// ````
  SARIndicator call({
    int zIndex,
    double height,
    EdgeInsets padding,
    SARParam calcParam,
    EdgeInsets tipsPadding,
    int tickCount,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSARIndicator.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSARIndicator.copyWith.fieldName(...)`
class _$SARIndicatorCWProxyImpl implements _$SARIndicatorCWProxy {
  const _$SARIndicatorCWProxyImpl(this._value);

  final SARIndicator _value;

  @override
  SARIndicator zIndex(int zIndex) => this(zIndex: zIndex);

  @override
  SARIndicator height(double height) => this(height: height);

  @override
  SARIndicator padding(EdgeInsets padding) => this(padding: padding);

  @override
  SARIndicator calcParam(SARParam calcParam) => this(calcParam: calcParam);

  @override
  SARIndicator tipsPadding(EdgeInsets tipsPadding) => this(tipsPadding: tipsPadding);

  @override
  SARIndicator tickCount(int tickCount) => this(tickCount: tickCount);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SARIndicator(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SARIndicator(...).copyWith(id: 12, name: "My name")
  /// ````
  SARIndicator call({
    Object? zIndex = const $CopyWithPlaceholder(),
    Object? height = const $CopyWithPlaceholder(),
    Object? padding = const $CopyWithPlaceholder(),
    Object? calcParam = const $CopyWithPlaceholder(),
    Object? tipsPadding = const $CopyWithPlaceholder(),
    Object? tickCount = const $CopyWithPlaceholder(),
  }) {
    return SARIndicator(
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
          : calcParam as SARParam,
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

extension $SARIndicatorCopyWith on SARIndicator {
  /// Returns a callable class that can be used as follows: `instanceOfSARIndicator.copyWith(...)` or like so:`instanceOfSARIndicator.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SARIndicatorCWProxy get copyWith => _$SARIndicatorCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SARIndicator _$SARIndicatorFromJson(Map<String, dynamic> json) => SARIndicator(
      zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
      height: (json['height'] as num).toDouble(),
      padding: json['padding'] == null
          ? defaultMainIndicatorPadding
          : const EdgeInsetsConverter().fromJson(json['padding'] as Map<String, dynamic>),
      calcParam:
          json['calcParam'] == null ? const SARParam() : SARParam.fromJson(json['calcParam'] as Map<String, dynamic>),
      tipsPadding: const EdgeInsetsConverter().fromJson(json['tipsPadding'] as Map<String, dynamic>),
      tickCount: (json['tickCount'] as num?)?.toInt() ?? defaultSubTickCount,
    );

Map<String, dynamic> _$SARIndicatorToJson(SARIndicator instance) => <String, dynamic>{
      'height': instance.height,
      'padding': const EdgeInsetsConverter().toJson(instance.padding),
      'zIndex': instance.zIndex,
      'calcParam': instance.calcParam.toJson(),
      'tipsPadding': const EdgeInsetsConverter().toJson(instance.tipsPadding),
      'tickCount': instance.tickCount,
    };
