// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boll_param.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BOLLParamCWProxy {
  BOLLParam periods(BOLLPeriodsConfig periods);

  BOLLParam lines(BOLLLinesConfig lines);

  BOLLParam fill(BOLLFillConfig fill);

  BOLLParam display(BOLLDisplayConfig display);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BOLLParam(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BOLLParam(...).copyWith(id: 12, name: "My name")
  /// ````
  BOLLParam call({
    BOLLPeriodsConfig periods,
    BOLLLinesConfig lines,
    BOLLFillConfig fill,
    BOLLDisplayConfig display,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBOLLParam.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBOLLParam.copyWith.fieldName(...)`
class _$BOLLParamCWProxyImpl implements _$BOLLParamCWProxy {
  const _$BOLLParamCWProxyImpl(this._value);

  final BOLLParam _value;

  @override
  BOLLParam periods(BOLLPeriodsConfig periods) => this(periods: periods);

  @override
  BOLLParam lines(BOLLLinesConfig lines) => this(lines: lines);

  @override
  BOLLParam fill(BOLLFillConfig fill) => this(fill: fill);

  @override
  BOLLParam display(BOLLDisplayConfig display) => this(display: display);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BOLLParam(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BOLLParam(...).copyWith(id: 12, name: "My name")
  /// ````
  BOLLParam call({
    Object? periods = const $CopyWithPlaceholder(),
    Object? lines = const $CopyWithPlaceholder(),
    Object? fill = const $CopyWithPlaceholder(),
    Object? display = const $CopyWithPlaceholder(),
  }) {
    return BOLLParam(
      periods: periods == const $CopyWithPlaceholder()
          ? _value.periods
          // ignore: cast_nullable_to_non_nullable
          : periods as BOLLPeriodsConfig,
      lines: lines == const $CopyWithPlaceholder()
          ? _value.lines
          // ignore: cast_nullable_to_non_nullable
          : lines as BOLLLinesConfig,
      fill: fill == const $CopyWithPlaceholder()
          ? _value.fill
          // ignore: cast_nullable_to_non_nullable
          : fill as BOLLFillConfig,
      display: display == const $CopyWithPlaceholder()
          ? _value.display
          // ignore: cast_nullable_to_non_nullable
          : display as BOLLDisplayConfig,
    );
  }
}

extension $BOLLParamCopyWith on BOLLParam {
  /// Returns a callable class that can be used as follows: `instanceOfBOLLParam.copyWith(...)` or like so:`instanceOfBOLLParam.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BOLLParamCWProxy get copyWith => _$BOLLParamCWProxyImpl(this);
}

abstract class _$BOLLPeriodsConfigCWProxy {
  BOLLPeriodsConfig period(int period);

  BOLLPeriodsConfig stdDev(double stdDev);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BOLLPeriodsConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BOLLPeriodsConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  BOLLPeriodsConfig call({
    int period,
    double stdDev,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBOLLPeriodsConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBOLLPeriodsConfig.copyWith.fieldName(...)`
class _$BOLLPeriodsConfigCWProxyImpl implements _$BOLLPeriodsConfigCWProxy {
  const _$BOLLPeriodsConfigCWProxyImpl(this._value);

  final BOLLPeriodsConfig _value;

  @override
  BOLLPeriodsConfig period(int period) => this(period: period);

  @override
  BOLLPeriodsConfig stdDev(double stdDev) => this(stdDev: stdDev);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BOLLPeriodsConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BOLLPeriodsConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  BOLLPeriodsConfig call({
    Object? period = const $CopyWithPlaceholder(),
    Object? stdDev = const $CopyWithPlaceholder(),
  }) {
    return BOLLPeriodsConfig(
      period: period == const $CopyWithPlaceholder()
          ? _value.period
          // ignore: cast_nullable_to_non_nullable
          : period as int,
      stdDev: stdDev == const $CopyWithPlaceholder()
          ? _value.stdDev
          // ignore: cast_nullable_to_non_nullable
          : stdDev as double,
    );
  }
}

extension $BOLLPeriodsConfigCopyWith on BOLLPeriodsConfig {
  /// Returns a callable class that can be used as follows: `instanceOfBOLLPeriodsConfig.copyWith(...)` or like so:`instanceOfBOLLPeriodsConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BOLLPeriodsConfigCWProxy get copyWith => _$BOLLPeriodsConfigCWProxyImpl(this);
}

abstract class _$BOLLLineConfigCWProxy {
  BOLLLineConfig enabled(bool enabled);

  BOLLLineConfig color(Color color);

  BOLLLineConfig width(double width);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BOLLLineConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BOLLLineConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  BOLLLineConfig call({
    bool enabled,
    Color color,
    double width,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBOLLLineConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBOLLLineConfig.copyWith.fieldName(...)`
class _$BOLLLineConfigCWProxyImpl implements _$BOLLLineConfigCWProxy {
  const _$BOLLLineConfigCWProxyImpl(this._value);

  final BOLLLineConfig _value;

  @override
  BOLLLineConfig enabled(bool enabled) => this(enabled: enabled);

  @override
  BOLLLineConfig color(Color color) => this(color: color);

  @override
  BOLLLineConfig width(double width) => this(width: width);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BOLLLineConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BOLLLineConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  BOLLLineConfig call({
    Object? enabled = const $CopyWithPlaceholder(),
    Object? color = const $CopyWithPlaceholder(),
    Object? width = const $CopyWithPlaceholder(),
  }) {
    return BOLLLineConfig(
      enabled: enabled == const $CopyWithPlaceholder()
          ? _value.enabled
          // ignore: cast_nullable_to_non_nullable
          : enabled as bool,
      color: color == const $CopyWithPlaceholder()
          ? _value.color
          // ignore: cast_nullable_to_non_nullable
          : color as Color,
      width: width == const $CopyWithPlaceholder()
          ? _value.width
          // ignore: cast_nullable_to_non_nullable
          : width as double,
    );
  }
}

extension $BOLLLineConfigCopyWith on BOLLLineConfig {
  /// Returns a callable class that can be used as follows: `instanceOfBOLLLineConfig.copyWith(...)` or like so:`instanceOfBOLLLineConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BOLLLineConfigCWProxy get copyWith => _$BOLLLineConfigCWProxyImpl(this);
}

abstract class _$BOLLLinesConfigCWProxy {
  BOLLLinesConfig ub(BOLLLineConfig ub);

  BOLLLinesConfig boll(BOLLLineConfig boll);

  BOLLLinesConfig lb(BOLLLineConfig lb);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BOLLLinesConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BOLLLinesConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  BOLLLinesConfig call({
    BOLLLineConfig ub,
    BOLLLineConfig boll,
    BOLLLineConfig lb,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBOLLLinesConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBOLLLinesConfig.copyWith.fieldName(...)`
class _$BOLLLinesConfigCWProxyImpl implements _$BOLLLinesConfigCWProxy {
  const _$BOLLLinesConfigCWProxyImpl(this._value);

  final BOLLLinesConfig _value;

  @override
  BOLLLinesConfig ub(BOLLLineConfig ub) => this(ub: ub);

  @override
  BOLLLinesConfig boll(BOLLLineConfig boll) => this(boll: boll);

  @override
  BOLLLinesConfig lb(BOLLLineConfig lb) => this(lb: lb);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BOLLLinesConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BOLLLinesConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  BOLLLinesConfig call({
    Object? ub = const $CopyWithPlaceholder(),
    Object? boll = const $CopyWithPlaceholder(),
    Object? lb = const $CopyWithPlaceholder(),
  }) {
    return BOLLLinesConfig(
      ub: ub == const $CopyWithPlaceholder()
          ? _value.ub
          // ignore: cast_nullable_to_non_nullable
          : ub as BOLLLineConfig,
      boll: boll == const $CopyWithPlaceholder()
          ? _value.boll
          // ignore: cast_nullable_to_non_nullable
          : boll as BOLLLineConfig,
      lb: lb == const $CopyWithPlaceholder()
          ? _value.lb
          // ignore: cast_nullable_to_non_nullable
          : lb as BOLLLineConfig,
    );
  }
}

extension $BOLLLinesConfigCopyWith on BOLLLinesConfig {
  /// Returns a callable class that can be used as follows: `instanceOfBOLLLinesConfig.copyWith(...)` or like so:`instanceOfBOLLLinesConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BOLLLinesConfigCWProxy get copyWith => _$BOLLLinesConfigCWProxyImpl(this);
}

abstract class _$BOLLFillConfigCWProxy {
  BOLLFillConfig enabled(bool enabled);

  BOLLFillConfig color(Color color);

  BOLLFillConfig opacity(double opacity);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BOLLFillConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BOLLFillConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  BOLLFillConfig call({
    bool enabled,
    Color color,
    double opacity,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBOLLFillConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBOLLFillConfig.copyWith.fieldName(...)`
class _$BOLLFillConfigCWProxyImpl implements _$BOLLFillConfigCWProxy {
  const _$BOLLFillConfigCWProxyImpl(this._value);

  final BOLLFillConfig _value;

  @override
  BOLLFillConfig enabled(bool enabled) => this(enabled: enabled);

  @override
  BOLLFillConfig color(Color color) => this(color: color);

  @override
  BOLLFillConfig opacity(double opacity) => this(opacity: opacity);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BOLLFillConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BOLLFillConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  BOLLFillConfig call({
    Object? enabled = const $CopyWithPlaceholder(),
    Object? color = const $CopyWithPlaceholder(),
    Object? opacity = const $CopyWithPlaceholder(),
  }) {
    return BOLLFillConfig(
      enabled: enabled == const $CopyWithPlaceholder()
          ? _value.enabled
          // ignore: cast_nullable_to_non_nullable
          : enabled as bool,
      color: color == const $CopyWithPlaceholder()
          ? _value.color
          // ignore: cast_nullable_to_non_nullable
          : color as Color,
      opacity: opacity == const $CopyWithPlaceholder()
          ? _value.opacity
          // ignore: cast_nullable_to_non_nullable
          : opacity as double,
    );
  }
}

extension $BOLLFillConfigCopyWith on BOLLFillConfig {
  /// Returns a callable class that can be used as follows: `instanceOfBOLLFillConfig.copyWith(...)` or like so:`instanceOfBOLLFillConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BOLLFillConfigCWProxy get copyWith => _$BOLLFillConfigCWProxyImpl(this);
}

abstract class _$BOLLDisplayConfigCWProxy {
  BOLLDisplayConfig pointRadius(double pointRadius);

  BOLLDisplayConfig showCrossPoint(bool showCrossPoint);

  BOLLDisplayConfig precision(int precision);

  BOLLDisplayConfig showPeriodInTips(bool showPeriodInTips);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BOLLDisplayConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BOLLDisplayConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  BOLLDisplayConfig call({
    double pointRadius,
    bool showCrossPoint,
    int precision,
    bool showPeriodInTips,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBOLLDisplayConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBOLLDisplayConfig.copyWith.fieldName(...)`
class _$BOLLDisplayConfigCWProxyImpl implements _$BOLLDisplayConfigCWProxy {
  const _$BOLLDisplayConfigCWProxyImpl(this._value);

  final BOLLDisplayConfig _value;

  @override
  BOLLDisplayConfig pointRadius(double pointRadius) => this(pointRadius: pointRadius);

  @override
  BOLLDisplayConfig showCrossPoint(bool showCrossPoint) => this(showCrossPoint: showCrossPoint);

  @override
  BOLLDisplayConfig precision(int precision) => this(precision: precision);

  @override
  BOLLDisplayConfig showPeriodInTips(bool showPeriodInTips) => this(showPeriodInTips: showPeriodInTips);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BOLLDisplayConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BOLLDisplayConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  BOLLDisplayConfig call({
    Object? pointRadius = const $CopyWithPlaceholder(),
    Object? showCrossPoint = const $CopyWithPlaceholder(),
    Object? precision = const $CopyWithPlaceholder(),
    Object? showPeriodInTips = const $CopyWithPlaceholder(),
  }) {
    return BOLLDisplayConfig(
      pointRadius: pointRadius == const $CopyWithPlaceholder()
          ? _value.pointRadius
          // ignore: cast_nullable_to_non_nullable
          : pointRadius as double,
      showCrossPoint: showCrossPoint == const $CopyWithPlaceholder()
          ? _value.showCrossPoint
          // ignore: cast_nullable_to_non_nullable
          : showCrossPoint as bool,
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

extension $BOLLDisplayConfigCopyWith on BOLLDisplayConfig {
  /// Returns a callable class that can be used as follows: `instanceOfBOLLDisplayConfig.copyWith(...)` or like so:`instanceOfBOLLDisplayConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BOLLDisplayConfigCWProxy get copyWith => _$BOLLDisplayConfigCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BOLLParam _$BOLLParamFromJson(Map<String, dynamic> json) => BOLLParam(
      periods: json['periods'] == null
          ? const BOLLPeriodsConfig()
          : BOLLPeriodsConfig.fromJson(json['periods'] as Map<String, dynamic>),
      lines: json['lines'] == null
          ? const BOLLLinesConfig()
          : BOLLLinesConfig.fromJson(json['lines'] as Map<String, dynamic>),
      fill:
          json['fill'] == null ? const BOLLFillConfig() : BOLLFillConfig.fromJson(json['fill'] as Map<String, dynamic>),
      display: json['display'] == null
          ? const BOLLDisplayConfig()
          : BOLLDisplayConfig.fromJson(json['display'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BOLLParamToJson(BOLLParam instance) => <String, dynamic>{
      'periods': instance.periods.toJson(),
      'lines': instance.lines.toJson(),
      'fill': instance.fill.toJson(),
      'display': instance.display.toJson(),
    };

BOLLPeriodsConfig _$BOLLPeriodsConfigFromJson(Map<String, dynamic> json) => BOLLPeriodsConfig(
      period: (json['period'] as num?)?.toInt() ?? 20,
      stdDev: (json['stdDev'] as num?)?.toDouble() ?? 2.0,
    );

Map<String, dynamic> _$BOLLPeriodsConfigToJson(BOLLPeriodsConfig instance) => <String, dynamic>{
      'period': instance.period,
      'stdDev': instance.stdDev,
    };

BOLLLineConfig _$BOLLLineConfigFromJson(Map<String, dynamic> json) => BOLLLineConfig(
      enabled: json['enabled'] as bool? ?? true,
      color: json['color'] == null ? const Color(0xff2196f3) : const ColorConverter().fromJson(json['color'] as String),
      width: (json['width'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$BOLLLineConfigToJson(BOLLLineConfig instance) => <String, dynamic>{
      'enabled': instance.enabled,
      'color': const ColorConverter().toJson(instance.color),
      'width': instance.width,
    };

BOLLLinesConfig _$BOLLLinesConfigFromJson(Map<String, dynamic> json) => BOLLLinesConfig(
      ub: json['ub'] == null
          ? const BOLLLineConfig(color: Color(0xffffff00))
          : BOLLLineConfig.fromJson(json['ub'] as Map<String, dynamic>),
      boll: json['boll'] == null
          ? const BOLLLineConfig(color: Color(0xffff69b4))
          : BOLLLineConfig.fromJson(json['boll'] as Map<String, dynamic>),
      lb: json['lb'] == null
          ? const BOLLLineConfig(color: Color(0xff9c27b0))
          : BOLLLineConfig.fromJson(json['lb'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BOLLLinesConfigToJson(BOLLLinesConfig instance) => <String, dynamic>{
      'ub': instance.ub.toJson(),
      'boll': instance.boll.toJson(),
      'lb': instance.lb.toJson(),
    };

BOLLFillConfig _$BOLLFillConfigFromJson(Map<String, dynamic> json) => BOLLFillConfig(
      enabled: json['enabled'] as bool? ?? true,
      color: json['color'] == null ? const Color(0x1a4caf50) : const ColorConverter().fromJson(json['color'] as String),
      opacity: (json['opacity'] as num?)?.toDouble() ?? 0.1,
    );

Map<String, dynamic> _$BOLLFillConfigToJson(BOLLFillConfig instance) => <String, dynamic>{
      'enabled': instance.enabled,
      'color': const ColorConverter().toJson(instance.color),
      'opacity': instance.opacity,
    };

BOLLDisplayConfig _$BOLLDisplayConfigFromJson(Map<String, dynamic> json) => BOLLDisplayConfig(
      pointRadius: (json['pointRadius'] as num?)?.toDouble() ?? 0.0,
      showCrossPoint: json['showCrossPoint'] as bool? ?? false,
      precision: (json['precision'] as num?)?.toInt() ?? 2,
      showPeriodInTips: json['showPeriodInTips'] as bool? ?? true,
    );

Map<String, dynamic> _$BOLLDisplayConfigToJson(BOLLDisplayConfig instance) => <String, dynamic>{
      'pointRadius': instance.pointRadius,
      'showCrossPoint': instance.showCrossPoint,
      'precision': instance.precision,
      'showPeriodInTips': instance.showPeriodInTips,
    };
