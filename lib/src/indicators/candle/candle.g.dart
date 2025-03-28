// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candle.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CandleIndicatorCWProxy {
  CandleIndicator zIndex(int zIndex);

  CandleIndicator height(double height);

  CandleIndicator padding(EdgeInsets padding);

  CandleIndicator high(MarkConfig high);

  CandleIndicator low(MarkConfig low);

  CandleIndicator last(MarkConfig last);

  CandleIndicator latest(MarkConfig latest);

  CandleIndicator useCandleColorAsLatestBg(bool useCandleColorAsLatestBg);

  CandleIndicator showCountDown(bool showCountDown);

  CandleIndicator countDown(TextAreaConfig countDown);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CandleIndicator(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CandleIndicator(...).copyWith(id: 12, name: "My name")
  /// ````
  CandleIndicator call({
    int zIndex,
    double height,
    EdgeInsets padding,
    MarkConfig high,
    MarkConfig low,
    MarkConfig last,
    MarkConfig latest,
    bool useCandleColorAsLatestBg,
    bool showCountDown,
    TextAreaConfig countDown,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCandleIndicator.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCandleIndicator.copyWith.fieldName(...)`
class _$CandleIndicatorCWProxyImpl implements _$CandleIndicatorCWProxy {
  const _$CandleIndicatorCWProxyImpl(this._value);

  final CandleIndicator _value;

  @override
  CandleIndicator zIndex(int zIndex) => this(zIndex: zIndex);

  @override
  CandleIndicator height(double height) => this(height: height);

  @override
  CandleIndicator padding(EdgeInsets padding) => this(padding: padding);

  @override
  CandleIndicator high(MarkConfig high) => this(high: high);

  @override
  CandleIndicator low(MarkConfig low) => this(low: low);

  @override
  CandleIndicator last(MarkConfig last) => this(last: last);

  @override
  CandleIndicator latest(MarkConfig latest) => this(latest: latest);

  @override
  CandleIndicator useCandleColorAsLatestBg(bool useCandleColorAsLatestBg) =>
      this(useCandleColorAsLatestBg: useCandleColorAsLatestBg);

  @override
  CandleIndicator showCountDown(bool showCountDown) =>
      this(showCountDown: showCountDown);

  @override
  CandleIndicator countDown(TextAreaConfig countDown) =>
      this(countDown: countDown);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CandleIndicator(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CandleIndicator(...).copyWith(id: 12, name: "My name")
  /// ````
  CandleIndicator call({
    Object? zIndex = const $CopyWithPlaceholder(),
    Object? height = const $CopyWithPlaceholder(),
    Object? padding = const $CopyWithPlaceholder(),
    Object? high = const $CopyWithPlaceholder(),
    Object? low = const $CopyWithPlaceholder(),
    Object? last = const $CopyWithPlaceholder(),
    Object? latest = const $CopyWithPlaceholder(),
    Object? useCandleColorAsLatestBg = const $CopyWithPlaceholder(),
    Object? showCountDown = const $CopyWithPlaceholder(),
    Object? countDown = const $CopyWithPlaceholder(),
  }) {
    return CandleIndicator(
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
      high: high == const $CopyWithPlaceholder()
          ? _value.high
          // ignore: cast_nullable_to_non_nullable
          : high as MarkConfig,
      low: low == const $CopyWithPlaceholder()
          ? _value.low
          // ignore: cast_nullable_to_non_nullable
          : low as MarkConfig,
      last: last == const $CopyWithPlaceholder()
          ? _value.last
          // ignore: cast_nullable_to_non_nullable
          : last as MarkConfig,
      latest: latest == const $CopyWithPlaceholder()
          ? _value.latest
          // ignore: cast_nullable_to_non_nullable
          : latest as MarkConfig,
      useCandleColorAsLatestBg:
          useCandleColorAsLatestBg == const $CopyWithPlaceholder()
              ? _value.useCandleColorAsLatestBg
              // ignore: cast_nullable_to_non_nullable
              : useCandleColorAsLatestBg as bool,
      showCountDown: showCountDown == const $CopyWithPlaceholder()
          ? _value.showCountDown
          // ignore: cast_nullable_to_non_nullable
          : showCountDown as bool,
      countDown: countDown == const $CopyWithPlaceholder()
          ? _value.countDown
          // ignore: cast_nullable_to_non_nullable
          : countDown as TextAreaConfig,
    );
  }
}

extension $CandleIndicatorCopyWith on CandleIndicator {
  /// Returns a callable class that can be used as follows: `instanceOfCandleIndicator.copyWith(...)` or like so:`instanceOfCandleIndicator.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CandleIndicatorCWProxy get copyWith => _$CandleIndicatorCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CandleIndicator _$CandleIndicatorFromJson(Map<String, dynamic> json) =>
    CandleIndicator(
      zIndex: (json['zIndex'] as num?)?.toInt() ?? -1,
      height: (json['height'] as num).toDouble(),
      padding: json['padding'] == null
          ? defaultMainIndicatorPadding
          : const EdgeInsetsConverter()
              .fromJson(json['padding'] as Map<String, dynamic>),
      high: MarkConfig.fromJson(json['high'] as Map<String, dynamic>),
      low: MarkConfig.fromJson(json['low'] as Map<String, dynamic>),
      last: MarkConfig.fromJson(json['last'] as Map<String, dynamic>),
      latest: MarkConfig.fromJson(json['latest'] as Map<String, dynamic>),
      useCandleColorAsLatestBg:
          json['useCandleColorAsLatestBg'] as bool? ?? true,
      showCountDown: json['showCountDown'] as bool? ?? true,
      countDown:
          TextAreaConfig.fromJson(json['countDown'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CandleIndicatorToJson(CandleIndicator instance) =>
    <String, dynamic>{
      'height': instance.height,
      'padding': const EdgeInsetsConverter().toJson(instance.padding),
      'zIndex': instance.zIndex,
      'high': instance.high.toJson(),
      'low': instance.low.toJson(),
      'last': instance.last.toJson(),
      'latest': instance.latest.toJson(),
      'useCandleColorAsLatestBg': instance.useCandleColorAsLatestBg,
      'showCountDown': instance.showCountDown,
      'countDown': instance.countDown.toJson(),
    };
