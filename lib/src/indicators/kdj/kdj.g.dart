// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kdj.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$KDJIndicatorCWProxy {
  KDJIndicator zIndex(int zIndex);

  KDJIndicator height(double height);

  KDJIndicator padding(EdgeInsets padding);

  KDJIndicator calcParam(KDJParam calcParam);

  KDJIndicator tipsPadding(EdgeInsets tipsPadding);

  KDJIndicator tickCount(int tickCount);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `KDJIndicator(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// KDJIndicator(...).copyWith(id: 12, name: "My name")
  /// ````
  KDJIndicator call({
    int zIndex,
    double height,
    EdgeInsets padding,
    KDJParam calcParam,
    EdgeInsets tipsPadding,
    int tickCount,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfKDJIndicator.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfKDJIndicator.copyWith.fieldName(...)`
class _$KDJIndicatorCWProxyImpl implements _$KDJIndicatorCWProxy {
  const _$KDJIndicatorCWProxyImpl(this._value);

  final KDJIndicator _value;

  @override
  KDJIndicator zIndex(int zIndex) => this(zIndex: zIndex);

  @override
  KDJIndicator height(double height) => this(height: height);

  @override
  KDJIndicator padding(EdgeInsets padding) => this(padding: padding);

  @override
  KDJIndicator calcParam(KDJParam calcParam) => this(calcParam: calcParam);

  @override
  KDJIndicator tipsPadding(EdgeInsets tipsPadding) => this(tipsPadding: tipsPadding);

  @override
  KDJIndicator tickCount(int tickCount) => this(tickCount: tickCount);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `KDJIndicator(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// KDJIndicator(...).copyWith(id: 12, name: "My name")
  /// ````
  KDJIndicator call({
    Object? zIndex = const $CopyWithPlaceholder(),
    Object? height = const $CopyWithPlaceholder(),
    Object? padding = const $CopyWithPlaceholder(),
    Object? calcParam = const $CopyWithPlaceholder(),
    Object? tipsPadding = const $CopyWithPlaceholder(),
    Object? tickCount = const $CopyWithPlaceholder(),
  }) {
    return KDJIndicator(
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
          : calcParam as KDJParam,
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

extension $KDJIndicatorCopyWith on KDJIndicator {
  /// Returns a callable class that can be used as follows: `instanceOfKDJIndicator.copyWith(...)` or like so:`instanceOfKDJIndicator.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$KDJIndicatorCWProxy get copyWith => _$KDJIndicatorCWProxyImpl(this);
}
