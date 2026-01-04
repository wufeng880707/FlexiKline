// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gradient_config.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GradientConfigCWProxy {
  GradientConfig begin(Alignment begin);

  GradientConfig end(Alignment end);

  GradientConfig stops(List<double>? stops);

  GradientConfig tileMode(TileMode tileMode);

  GradientConfig startAlpha(double startAlpha);

  GradientConfig endAlpha(double endAlpha);

  GradientConfig colors(List<Color>? colors);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GradientConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GradientConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  GradientConfig call({
    Alignment begin,
    Alignment end,
    List<double>? stops,
    TileMode tileMode,
    double startAlpha,
    double endAlpha,
    List<Color>? colors,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGradientConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGradientConfig.copyWith.fieldName(...)`
class _$GradientConfigCWProxyImpl implements _$GradientConfigCWProxy {
  const _$GradientConfigCWProxyImpl(this._value);

  final GradientConfig _value;

  @override
  GradientConfig begin(Alignment begin) => this(begin: begin);

  @override
  GradientConfig end(Alignment end) => this(end: end);

  @override
  GradientConfig stops(List<double>? stops) => this(stops: stops);

  @override
  GradientConfig tileMode(TileMode tileMode) => this(tileMode: tileMode);

  @override
  GradientConfig startAlpha(double startAlpha) => this(startAlpha: startAlpha);

  @override
  GradientConfig endAlpha(double endAlpha) => this(endAlpha: endAlpha);

  @override
  GradientConfig colors(List<Color>? colors) => this(colors: colors);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GradientConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GradientConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  GradientConfig call({
    Object? begin = const $CopyWithPlaceholder(),
    Object? end = const $CopyWithPlaceholder(),
    Object? stops = const $CopyWithPlaceholder(),
    Object? tileMode = const $CopyWithPlaceholder(),
    Object? startAlpha = const $CopyWithPlaceholder(),
    Object? endAlpha = const $CopyWithPlaceholder(),
    Object? colors = const $CopyWithPlaceholder(),
  }) {
    return GradientConfig(
      begin: begin == const $CopyWithPlaceholder()
          ? _value.begin
          // ignore: cast_nullable_to_non_nullable
          : begin as Alignment,
      end: end == const $CopyWithPlaceholder()
          ? _value.end
          // ignore: cast_nullable_to_non_nullable
          : end as Alignment,
      stops: stops == const $CopyWithPlaceholder()
          ? _value.stops
          // ignore: cast_nullable_to_non_nullable
          : stops as List<double>?,
      tileMode: tileMode == const $CopyWithPlaceholder()
          ? _value.tileMode
          // ignore: cast_nullable_to_non_nullable
          : tileMode as TileMode,
      startAlpha: startAlpha == const $CopyWithPlaceholder()
          ? _value.startAlpha
          // ignore: cast_nullable_to_non_nullable
          : startAlpha as double,
      endAlpha: endAlpha == const $CopyWithPlaceholder()
          ? _value.endAlpha
          // ignore: cast_nullable_to_non_nullable
          : endAlpha as double,
      colors: colors == const $CopyWithPlaceholder()
          ? _value.colors
          // ignore: cast_nullable_to_non_nullable
          : colors as List<Color>?,
    );
  }
}

extension $GradientConfigCopyWith on GradientConfig {
  /// Returns a callable class that can be used as follows: `instanceOfGradientConfig.copyWith(...)` or like so:`instanceOfGradientConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GradientConfigCWProxy get copyWith => _$GradientConfigCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GradientConfig _$GradientConfigFromJson(Map<String, dynamic> json) =>
    GradientConfig(
      begin: json['begin'] == null
          ? Alignment.topCenter
          : const AlignmentConverter()
              .fromJson(json['begin'] as Map<String, dynamic>),
      end: json['end'] == null
          ? Alignment.bottomCenter
          : const AlignmentConverter()
              .fromJson(json['end'] as Map<String, dynamic>),
      stops: (json['stops'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      tileMode: json['tileMode'] == null
          ? TileMode.decal
          : const TileModeConverter().fromJson(json['tileMode'] as String),
      startAlpha: (json['startAlpha'] as num?)?.toDouble() ?? 0.5,
      endAlpha: (json['endAlpha'] as num?)?.toDouble() ?? 0.0,
      colors: (json['colors'] as List<dynamic>?)
          ?.map((e) => const ColorConverter().fromJson(e as String))
          .toList(),
    );

Map<String, dynamic> _$GradientConfigToJson(GradientConfig instance) =>
    <String, dynamic>{
      'begin': const AlignmentConverter().toJson(instance.begin),
      'end': const AlignmentConverter().toJson(instance.end),
      if (instance.stops case final value?) 'stops': value,
      'tileMode': const TileModeConverter().toJson(instance.tileMode),
      'startAlpha': instance.startAlpha,
      'endAlpha': instance.endAlpha,
      if (instance.colors?.map(const ColorConverter().toJson).toList()
          case final value?)
        'colors': value,
    };
