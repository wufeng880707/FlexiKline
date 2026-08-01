// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vol_ma.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$VolMaIndicatorCWProxy {
  VolMaIndicator zIndex(int zIndex);

  VolMaIndicator height(double height);

  VolMaIndicator padding(EdgeInsets padding);

  VolMaIndicator calcParam(VolMaParam calcParam);

  VolMaIndicator tipsPadding(EdgeInsets tipsPadding);

  VolMaIndicator ticksCount(int ticksCount);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VolMaIndicator(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VolMaIndicator(...).copyWith(id: 12, name: "My name")
  /// ````
  VolMaIndicator call({
    int zIndex,
    double height,
    EdgeInsets padding,
    VolMaParam calcParam,
    EdgeInsets tipsPadding,
    int ticksCount,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVolMaIndicator.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVolMaIndicator.copyWith.fieldName(...)`
class _$VolMaIndicatorCWProxyImpl implements _$VolMaIndicatorCWProxy {
  const _$VolMaIndicatorCWProxyImpl(this._value);

  final VolMaIndicator _value;

  @override
  VolMaIndicator zIndex(int zIndex) => this(zIndex: zIndex);

  @override
  VolMaIndicator height(double height) => this(height: height);

  @override
  VolMaIndicator padding(EdgeInsets padding) => this(padding: padding);

  @override
  VolMaIndicator calcParam(VolMaParam calcParam) => this(calcParam: calcParam);

  @override
  VolMaIndicator tipsPadding(EdgeInsets tipsPadding) => this(tipsPadding: tipsPadding);

  @override
  VolMaIndicator ticksCount(int ticksCount) => this(ticksCount: ticksCount);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VolMaIndicator(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VolMaIndicator(...).copyWith(id: 12, name: "My name")
  /// ````
  VolMaIndicator call({
    Object? zIndex = const $CopyWithPlaceholder(),
    Object? height = const $CopyWithPlaceholder(),
    Object? padding = const $CopyWithPlaceholder(),
    Object? calcParam = const $CopyWithPlaceholder(),
    Object? tipsPadding = const $CopyWithPlaceholder(),
    Object? ticksCount = const $CopyWithPlaceholder(),
  }) {
    return VolMaIndicator(
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
          : calcParam as VolMaParam,
      tipsPadding: tipsPadding == const $CopyWithPlaceholder()
          ? _value.tipsPadding
          // ignore: cast_nullable_to_non_nullable
          : tipsPadding as EdgeInsets,
      ticksCount: ticksCount == const $CopyWithPlaceholder()
          ? _value.ticksCount
          // ignore: cast_nullable_to_non_nullable
          : ticksCount as int,
    );
  }
}

extension $VolMaIndicatorCopyWith on VolMaIndicator {
  /// Returns a callable class that can be used as follows: `instanceOfVolMaIndicator.copyWith(...)` or like so:`instanceOfVolMaIndicator.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VolMaIndicatorCWProxy get copyWith => _$VolMaIndicatorCWProxyImpl(this);
}
