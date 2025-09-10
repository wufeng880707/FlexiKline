// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rsi.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RSIIndicatorCWProxy {
  RSIIndicator zIndex(int zIndex);

  RSIIndicator height(double height);

  RSIIndicator padding(EdgeInsets padding);

  RSIIndicator calcParam(RsiParam calcParam);

  RSIIndicator tipsPadding(EdgeInsets tipsPadding);

  RSIIndicator tickCount(int tickCount);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RSIIndicator(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RSIIndicator(...).copyWith(id: 12, name: "My name")
  /// ````
  RSIIndicator call({
    int zIndex,
    double height,
    EdgeInsets padding,
    RsiParam calcParam,
    EdgeInsets tipsPadding,
    int tickCount,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRSIIndicator.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRSIIndicator.copyWith.fieldName(...)`
class _$RSIIndicatorCWProxyImpl implements _$RSIIndicatorCWProxy {
  const _$RSIIndicatorCWProxyImpl(this._value);

  final RSIIndicator _value;

  @override
  RSIIndicator zIndex(int zIndex) => this(zIndex: zIndex);

  @override
  RSIIndicator height(double height) => this(height: height);

  @override
  RSIIndicator padding(EdgeInsets padding) => this(padding: padding);

  @override
  RSIIndicator calcParam(RsiParam calcParam) => this(calcParam: calcParam);

  @override
  RSIIndicator tipsPadding(EdgeInsets tipsPadding) =>
      this(tipsPadding: tipsPadding);

  @override
  RSIIndicator tickCount(int tickCount) => this(tickCount: tickCount);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RSIIndicator(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RSIIndicator(...).copyWith(id: 12, name: "My name")
  /// ````
  RSIIndicator call({
    Object? zIndex = const $CopyWithPlaceholder(),
    Object? height = const $CopyWithPlaceholder(),
    Object? padding = const $CopyWithPlaceholder(),
    Object? calcParam = const $CopyWithPlaceholder(),
    Object? tipsPadding = const $CopyWithPlaceholder(),
    Object? tickCount = const $CopyWithPlaceholder(),
  }) {
    return RSIIndicator(
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
          : calcParam as RsiParam,
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

extension $RSIIndicatorCopyWith on RSIIndicator {
  /// Returns a callable class that can be used as follows: `instanceOfRSIIndicator.copyWith(...)` or like so:`instanceOfRSIIndicator.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RSIIndicatorCWProxy get copyWith => _$RSIIndicatorCWProxyImpl(this);
}
