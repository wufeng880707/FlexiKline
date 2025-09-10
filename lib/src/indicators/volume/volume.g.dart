// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'volume.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$VolumeIndicatorCWProxy {
  VolumeIndicator zIndex(int zIndex);

  VolumeIndicator height(double height);

  VolumeIndicator padding(EdgeInsets padding);

  VolumeIndicator calcParam(VolumeParam calcParam);

  VolumeIndicator tipsPadding(EdgeInsets tipsPadding);

  VolumeIndicator tickCount(int tickCount);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VolumeIndicator(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VolumeIndicator(...).copyWith(id: 12, name: "My name")
  /// ````
  VolumeIndicator call({
    int zIndex,
    double height,
    EdgeInsets padding,
    VolumeParam calcParam,
    EdgeInsets tipsPadding,
    int tickCount,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVolumeIndicator.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVolumeIndicator.copyWith.fieldName(...)`
class _$VolumeIndicatorCWProxyImpl implements _$VolumeIndicatorCWProxy {
  const _$VolumeIndicatorCWProxyImpl(this._value);

  final VolumeIndicator _value;

  @override
  VolumeIndicator zIndex(int zIndex) => this(zIndex: zIndex);

  @override
  VolumeIndicator height(double height) => this(height: height);

  @override
  VolumeIndicator padding(EdgeInsets padding) => this(padding: padding);

  @override
  VolumeIndicator calcParam(VolumeParam calcParam) =>
      this(calcParam: calcParam);

  @override
  VolumeIndicator tipsPadding(EdgeInsets tipsPadding) =>
      this(tipsPadding: tipsPadding);

  @override
  VolumeIndicator tickCount(int tickCount) => this(tickCount: tickCount);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VolumeIndicator(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VolumeIndicator(...).copyWith(id: 12, name: "My name")
  /// ````
  VolumeIndicator call({
    Object? zIndex = const $CopyWithPlaceholder(),
    Object? height = const $CopyWithPlaceholder(),
    Object? padding = const $CopyWithPlaceholder(),
    Object? calcParam = const $CopyWithPlaceholder(),
    Object? tipsPadding = const $CopyWithPlaceholder(),
    Object? tickCount = const $CopyWithPlaceholder(),
  }) {
    return VolumeIndicator(
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
          : calcParam as VolumeParam,
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

extension $VolumeIndicatorCopyWith on VolumeIndicator {
  /// Returns a callable class that can be used as follows: `instanceOfVolumeIndicator.copyWith(...)` or like so:`instanceOfVolumeIndicator.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VolumeIndicatorCWProxy get copyWith => _$VolumeIndicatorCWProxyImpl(this);
}
