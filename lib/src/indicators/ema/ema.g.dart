// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ema.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EMAIndicatorCWProxy {
  EMAIndicator zIndex(int zIndex);

  EMAIndicator height(double height);

  EMAIndicator padding(EdgeInsets padding);

  EMAIndicator calcParam(EmaParam calcParam);

  EMAIndicator tipsPadding(EdgeInsets tipsPadding);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EMAIndicator(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EMAIndicator(...).copyWith(id: 12, name: "My name")
  /// ````
  EMAIndicator call({
    int zIndex,
    double height,
    EdgeInsets padding,
    EmaParam calcParam,
    EdgeInsets tipsPadding,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEMAIndicator.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEMAIndicator.copyWith.fieldName(...)`
class _$EMAIndicatorCWProxyImpl implements _$EMAIndicatorCWProxy {
  const _$EMAIndicatorCWProxyImpl(this._value);

  final EMAIndicator _value;

  @override
  EMAIndicator zIndex(int zIndex) => this(zIndex: zIndex);

  @override
  EMAIndicator height(double height) => this(height: height);

  @override
  EMAIndicator padding(EdgeInsets padding) => this(padding: padding);

  @override
  EMAIndicator calcParam(EmaParam calcParam) => this(calcParam: calcParam);

  @override
  EMAIndicator tipsPadding(EdgeInsets tipsPadding) =>
      this(tipsPadding: tipsPadding);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EMAIndicator(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EMAIndicator(...).copyWith(id: 12, name: "My name")
  /// ````
  EMAIndicator call({
    Object? zIndex = const $CopyWithPlaceholder(),
    Object? height = const $CopyWithPlaceholder(),
    Object? padding = const $CopyWithPlaceholder(),
    Object? calcParam = const $CopyWithPlaceholder(),
    Object? tipsPadding = const $CopyWithPlaceholder(),
  }) {
    return EMAIndicator(
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
          : calcParam as EmaParam,
      tipsPadding: tipsPadding == const $CopyWithPlaceholder()
          ? _value.tipsPadding
          // ignore: cast_nullable_to_non_nullable
          : tipsPadding as EdgeInsets,
    );
  }
}

extension $EMAIndicatorCopyWith on EMAIndicator {
  /// Returns a callable class that can be used as follows: `instanceOfEMAIndicator.copyWith(...)` or like so:`instanceOfEMAIndicator.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EMAIndicatorCWProxy get copyWith => _$EMAIndicatorCWProxyImpl(this);
}
