// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sar_param.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SARParamCWProxy {
  SARParam periods(SARPeriodsConfig periods);

  SARParam appearance(SARAppearanceConfig appearance);

  SARParam display(SARDisplayConfig display);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SARParam(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SARParam(...).copyWith(id: 12, name: "My name")
  /// ````
  SARParam call({
    SARPeriodsConfig periods,
    SARAppearanceConfig appearance,
    SARDisplayConfig display,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSARParam.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSARParam.copyWith.fieldName(...)`
class _$SARParamCWProxyImpl implements _$SARParamCWProxy {
  const _$SARParamCWProxyImpl(this._value);

  final SARParam _value;

  @override
  SARParam periods(SARPeriodsConfig periods) => this(periods: periods);

  @override
  SARParam appearance(SARAppearanceConfig appearance) =>
      this(appearance: appearance);

  @override
  SARParam display(SARDisplayConfig display) => this(display: display);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SARParam(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SARParam(...).copyWith(id: 12, name: "My name")
  /// ````
  SARParam call({
    Object? periods = const $CopyWithPlaceholder(),
    Object? appearance = const $CopyWithPlaceholder(),
    Object? display = const $CopyWithPlaceholder(),
  }) {
    return SARParam(
      periods: periods == const $CopyWithPlaceholder()
          ? _value.periods
          // ignore: cast_nullable_to_non_nullable
          : periods as SARPeriodsConfig,
      appearance: appearance == const $CopyWithPlaceholder()
          ? _value.appearance
          // ignore: cast_nullable_to_non_nullable
          : appearance as SARAppearanceConfig,
      display: display == const $CopyWithPlaceholder()
          ? _value.display
          // ignore: cast_nullable_to_non_nullable
          : display as SARDisplayConfig,
    );
  }
}

extension $SARParamCopyWith on SARParam {
  /// Returns a callable class that can be used as follows: `instanceOfSARParam.copyWith(...)` or like so:`instanceOfSARParam.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SARParamCWProxy get copyWith => _$SARParamCWProxyImpl(this);
}

abstract class _$SARPeriodsConfigCWProxy {
  SARPeriodsConfig start(double start);

  SARPeriodsConfig max(double max);

  SARPeriodsConfig step(double step);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SARPeriodsConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SARPeriodsConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  SARPeriodsConfig call({
    double start,
    double max,
    double step,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSARPeriodsConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSARPeriodsConfig.copyWith.fieldName(...)`
class _$SARPeriodsConfigCWProxyImpl implements _$SARPeriodsConfigCWProxy {
  const _$SARPeriodsConfigCWProxyImpl(this._value);

  final SARPeriodsConfig _value;

  @override
  SARPeriodsConfig start(double start) => this(start: start);

  @override
  SARPeriodsConfig max(double max) => this(max: max);

  @override
  SARPeriodsConfig step(double step) => this(step: step);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SARPeriodsConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SARPeriodsConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  SARPeriodsConfig call({
    Object? start = const $CopyWithPlaceholder(),
    Object? max = const $CopyWithPlaceholder(),
    Object? step = const $CopyWithPlaceholder(),
  }) {
    return SARPeriodsConfig(
      start: start == const $CopyWithPlaceholder()
          ? _value.start
          // ignore: cast_nullable_to_non_nullable
          : start as double,
      max: max == const $CopyWithPlaceholder()
          ? _value.max
          // ignore: cast_nullable_to_non_nullable
          : max as double,
      step: step == const $CopyWithPlaceholder()
          ? _value.step
          // ignore: cast_nullable_to_non_nullable
          : step as double,
    );
  }
}

extension $SARPeriodsConfigCopyWith on SARPeriodsConfig {
  /// Returns a callable class that can be used as follows: `instanceOfSARPeriodsConfig.copyWith(...)` or like so:`instanceOfSARPeriodsConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SARPeriodsConfigCWProxy get copyWith => _$SARPeriodsConfigCWProxyImpl(this);
}

abstract class _$SARAppearanceConfigCWProxy {
  SARAppearanceConfig color(Color color);

  SARAppearanceConfig pointRadius(double pointRadius);

  SARAppearanceConfig borderWidth(double borderWidth);

  SARAppearanceConfig minRadius(double minRadius);

  SARAppearanceConfig maxRadius(double maxRadius);

  SARAppearanceConfig useTrendColor(bool useTrendColor);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SARAppearanceConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SARAppearanceConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  SARAppearanceConfig call({
    Color color,
    double pointRadius,
    double borderWidth,
    double minRadius,
    double maxRadius,
    bool useTrendColor,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSARAppearanceConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSARAppearanceConfig.copyWith.fieldName(...)`
class _$SARAppearanceConfigCWProxyImpl implements _$SARAppearanceConfigCWProxy {
  const _$SARAppearanceConfigCWProxyImpl(this._value);

  final SARAppearanceConfig _value;

  @override
  SARAppearanceConfig color(Color color) => this(color: color);

  @override
  SARAppearanceConfig pointRadius(double pointRadius) =>
      this(pointRadius: pointRadius);

  @override
  SARAppearanceConfig borderWidth(double borderWidth) =>
      this(borderWidth: borderWidth);

  @override
  SARAppearanceConfig minRadius(double minRadius) => this(minRadius: minRadius);

  @override
  SARAppearanceConfig maxRadius(double maxRadius) => this(maxRadius: maxRadius);

  @override
  SARAppearanceConfig useTrendColor(bool useTrendColor) =>
      this(useTrendColor: useTrendColor);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SARAppearanceConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SARAppearanceConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  SARAppearanceConfig call({
    Object? color = const $CopyWithPlaceholder(),
    Object? pointRadius = const $CopyWithPlaceholder(),
    Object? borderWidth = const $CopyWithPlaceholder(),
    Object? minRadius = const $CopyWithPlaceholder(),
    Object? maxRadius = const $CopyWithPlaceholder(),
    Object? useTrendColor = const $CopyWithPlaceholder(),
  }) {
    return SARAppearanceConfig(
      color: color == const $CopyWithPlaceholder()
          ? _value.color
          // ignore: cast_nullable_to_non_nullable
          : color as Color,
      pointRadius: pointRadius == const $CopyWithPlaceholder()
          ? _value.pointRadius
          // ignore: cast_nullable_to_non_nullable
          : pointRadius as double,
      borderWidth: borderWidth == const $CopyWithPlaceholder()
          ? _value.borderWidth
          // ignore: cast_nullable_to_non_nullable
          : borderWidth as double,
      minRadius: minRadius == const $CopyWithPlaceholder()
          ? _value.minRadius
          // ignore: cast_nullable_to_non_nullable
          : minRadius as double,
      maxRadius: maxRadius == const $CopyWithPlaceholder()
          ? _value.maxRadius
          // ignore: cast_nullable_to_non_nullable
          : maxRadius as double,
      useTrendColor: useTrendColor == const $CopyWithPlaceholder()
          ? _value.useTrendColor
          // ignore: cast_nullable_to_non_nullable
          : useTrendColor as bool,
    );
  }
}

extension $SARAppearanceConfigCopyWith on SARAppearanceConfig {
  /// Returns a callable class that can be used as follows: `instanceOfSARAppearanceConfig.copyWith(...)` or like so:`instanceOfSARAppearanceConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SARAppearanceConfigCWProxy get copyWith =>
      _$SARAppearanceConfigCWProxyImpl(this);
}

abstract class _$SARDisplayConfigCWProxy {
  SARDisplayConfig precision(int precision);

  SARDisplayConfig showPeriodInTips(bool showPeriodInTips);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SARDisplayConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SARDisplayConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  SARDisplayConfig call({
    int precision,
    bool showPeriodInTips,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSARDisplayConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSARDisplayConfig.copyWith.fieldName(...)`
class _$SARDisplayConfigCWProxyImpl implements _$SARDisplayConfigCWProxy {
  const _$SARDisplayConfigCWProxyImpl(this._value);

  final SARDisplayConfig _value;

  @override
  SARDisplayConfig precision(int precision) => this(precision: precision);

  @override
  SARDisplayConfig showPeriodInTips(bool showPeriodInTips) =>
      this(showPeriodInTips: showPeriodInTips);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SARDisplayConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SARDisplayConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  SARDisplayConfig call({
    Object? precision = const $CopyWithPlaceholder(),
    Object? showPeriodInTips = const $CopyWithPlaceholder(),
  }) {
    return SARDisplayConfig(
      precision: precision == const $CopyWithPlaceholder()
          ? _value.precision
          // ignore: cast_nullable_to_non_nullable
          : precision as int,
      showPeriodInTips: showPeriodInTips == const $CopyWithPlaceholder()
          ? _value.showPeriodInTips
          // ignore: cast_nullable_to_non_nullable
          : showPeriodInTips as bool,
    );
  }
}

extension $SARDisplayConfigCopyWith on SARDisplayConfig {
  /// Returns a callable class that can be used as follows: `instanceOfSARDisplayConfig.copyWith(...)` or like so:`instanceOfSARDisplayConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SARDisplayConfigCWProxy get copyWith => _$SARDisplayConfigCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SARParam _$SARParamFromJson(Map<String, dynamic> json) => SARParam(
      periods: json['periods'] == null
          ? const SARPeriodsConfig()
          : SARPeriodsConfig.fromJson(json['periods'] as Map<String, dynamic>),
      appearance: json['appearance'] == null
          ? const SARAppearanceConfig()
          : SARAppearanceConfig.fromJson(
              json['appearance'] as Map<String, dynamic>),
      display: json['display'] == null
          ? const SARDisplayConfig()
          : SARDisplayConfig.fromJson(json['display'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SARParamToJson(SARParam instance) => <String, dynamic>{
      'periods': instance.periods.toJson(),
      'appearance': instance.appearance.toJson(),
      'display': instance.display.toJson(),
    };

SARPeriodsConfig _$SARPeriodsConfigFromJson(Map<String, dynamic> json) =>
    SARPeriodsConfig(
      start: (json['start'] as num?)?.toDouble() ?? 0.02,
      max: (json['max'] as num?)?.toDouble() ?? 0.6,
      step: (json['step'] as num?)?.toDouble() ?? 0.02,
    );

Map<String, dynamic> _$SARPeriodsConfigToJson(SARPeriodsConfig instance) =>
    <String, dynamic>{
      'start': instance.start,
      'max': instance.max,
      'step': instance.step,
    };

SARAppearanceConfig _$SARAppearanceConfigFromJson(Map<String, dynamic> json) =>
    SARAppearanceConfig(
      color: json['color'] == null
          ? const Color(0xff9c27b0)
          : const ColorConverter().fromJson(json['color'] as String),
      pointRadius: (json['pointRadius'] as num?)?.toDouble() ?? 2.0,
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 0.5,
      minRadius: (json['minRadius'] as num?)?.toDouble() ?? 1.0,
      maxRadius: (json['maxRadius'] as num?)?.toDouble() ?? 4.0,
      useTrendColor: json['useTrendColor'] as bool? ?? true,
    );

Map<String, dynamic> _$SARAppearanceConfigToJson(
        SARAppearanceConfig instance) =>
    <String, dynamic>{
      'color': const ColorConverter().toJson(instance.color),
      'pointRadius': instance.pointRadius,
      'borderWidth': instance.borderWidth,
      'minRadius': instance.minRadius,
      'maxRadius': instance.maxRadius,
      'useTrendColor': instance.useTrendColor,
    };

SARDisplayConfig _$SARDisplayConfigFromJson(Map<String, dynamic> json) =>
    SARDisplayConfig(
      precision: (json['precision'] as num?)?.toInt() ?? 4,
      showPeriodInTips: json['showPeriodInTips'] as bool? ?? false,
    );

Map<String, dynamic> _$SARDisplayConfigToJson(SARDisplayConfig instance) =>
    <String, dynamic>{
      'precision': instance.precision,
      'showPeriodInTips': instance.showPeriodInTips,
    };
