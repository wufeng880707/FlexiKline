// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ma.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MAIndicatorCWProxy {
  MAIndicator zIndex(int zIndex);

  MAIndicator height(double height);

  MAIndicator padding(EdgeInsets padding);

  MAIndicator calcParam(MaParam calcParam);

  MAIndicator tipsPadding(EdgeInsets tipsPadding);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MAIndicator(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MAIndicator(...).copyWith(id: 12, name: "My name")
  /// ````
  MAIndicator call({
    int zIndex,
    double height,
    EdgeInsets padding,
    MaParam calcParam,
    EdgeInsets tipsPadding,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMAIndicator.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMAIndicator.copyWith.fieldName(...)`
class _$MAIndicatorCWProxyImpl implements _$MAIndicatorCWProxy {
  const _$MAIndicatorCWProxyImpl(this._value);

  final MAIndicator _value;

  @override
  MAIndicator zIndex(int zIndex) => this(zIndex: zIndex);

  @override
  MAIndicator height(double height) => this(height: height);

  @override
  MAIndicator padding(EdgeInsets padding) => this(padding: padding);

  @override
  MAIndicator calcParam(MaParam calcParam) => this(calcParam: calcParam);

  @override
  MAIndicator tipsPadding(EdgeInsets tipsPadding) =>
      this(tipsPadding: tipsPadding);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MAIndicator(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MAIndicator(...).copyWith(id: 12, name: "My name")
  /// ````
  MAIndicator call({
    Object? zIndex = const $CopyWithPlaceholder(),
    Object? height = const $CopyWithPlaceholder(),
    Object? padding = const $CopyWithPlaceholder(),
    Object? calcParam = const $CopyWithPlaceholder(),
    Object? tipsPadding = const $CopyWithPlaceholder(),
  }) {
    return MAIndicator(
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
          : calcParam as MaParam,
      tipsPadding: tipsPadding == const $CopyWithPlaceholder()
          ? _value.tipsPadding
          // ignore: cast_nullable_to_non_nullable
          : tipsPadding as EdgeInsets,
    );
  }
}

extension $MAIndicatorCopyWith on MAIndicator {
  /// Returns a callable class that can be used as follows: `instanceOfMAIndicator.copyWith(...)` or like so:`instanceOfMAIndicator.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MAIndicatorCWProxy get copyWith => _$MAIndicatorCWProxyImpl(this);
}
