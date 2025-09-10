// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ema_param.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EmaParamCWProxy {
  EmaParam maxLines(int maxLines);

  EmaParam lines(List<EMALineConfig> lines);

  EmaParam validation(EMAValidationConfig validation);

  EmaParam display(EMADisplayConfig display);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EmaParam(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EmaParam(...).copyWith(id: 12, name: "My name")
  /// ````
  EmaParam call({
    int maxLines,
    List<EMALineConfig> lines,
    EMAValidationConfig validation,
    EMADisplayConfig display,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEmaParam.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEmaParam.copyWith.fieldName(...)`
class _$EmaParamCWProxyImpl implements _$EmaParamCWProxy {
  const _$EmaParamCWProxyImpl(this._value);

  final EmaParam _value;

  @override
  EmaParam maxLines(int maxLines) => this(maxLines: maxLines);

  @override
  EmaParam lines(List<EMALineConfig> lines) => this(lines: lines);

  @override
  EmaParam validation(EMAValidationConfig validation) =>
      this(validation: validation);

  @override
  EmaParam display(EMADisplayConfig display) => this(display: display);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EmaParam(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EmaParam(...).copyWith(id: 12, name: "My name")
  /// ````
  EmaParam call({
    Object? maxLines = const $CopyWithPlaceholder(),
    Object? lines = const $CopyWithPlaceholder(),
    Object? validation = const $CopyWithPlaceholder(),
    Object? display = const $CopyWithPlaceholder(),
  }) {
    return EmaParam(
      maxLines: maxLines == const $CopyWithPlaceholder()
          ? _value.maxLines
          // ignore: cast_nullable_to_non_nullable
          : maxLines as int,
      lines: lines == const $CopyWithPlaceholder()
          ? _value.lines
          // ignore: cast_nullable_to_non_nullable
          : lines as List<EMALineConfig>,
      validation: validation == const $CopyWithPlaceholder()
          ? _value.validation
          // ignore: cast_nullable_to_non_nullable
          : validation as EMAValidationConfig,
      display: display == const $CopyWithPlaceholder()
          ? _value.display
          // ignore: cast_nullable_to_non_nullable
          : display as EMADisplayConfig,
    );
  }
}

extension $EmaParamCopyWith on EmaParam {
  /// Returns a callable class that can be used as follows: `instanceOfEmaParam.copyWith(...)` or like so:`instanceOfEmaParam.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EmaParamCWProxy get copyWith => _$EmaParamCWProxyImpl(this);
}

abstract class _$EMALineConfigCWProxy {
  EMALineConfig id(String id);

  EMALineConfig enabled(bool enabled);

  EMALineConfig period(int period);

  EMALineConfig color(Color color);

  EMALineConfig width(double width);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EMALineConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EMALineConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  EMALineConfig call({
    String id,
    bool enabled,
    int period,
    Color color,
    double width,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEMALineConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEMALineConfig.copyWith.fieldName(...)`
class _$EMALineConfigCWProxyImpl implements _$EMALineConfigCWProxy {
  const _$EMALineConfigCWProxyImpl(this._value);

  final EMALineConfig _value;

  @override
  EMALineConfig id(String id) => this(id: id);

  @override
  EMALineConfig enabled(bool enabled) => this(enabled: enabled);

  @override
  EMALineConfig period(int period) => this(period: period);

  @override
  EMALineConfig color(Color color) => this(color: color);

  @override
  EMALineConfig width(double width) => this(width: width);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EMALineConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EMALineConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  EMALineConfig call({
    Object? id = const $CopyWithPlaceholder(),
    Object? enabled = const $CopyWithPlaceholder(),
    Object? period = const $CopyWithPlaceholder(),
    Object? color = const $CopyWithPlaceholder(),
    Object? width = const $CopyWithPlaceholder(),
  }) {
    return EMALineConfig(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      enabled: enabled == const $CopyWithPlaceholder()
          ? _value.enabled
          // ignore: cast_nullable_to_non_nullable
          : enabled as bool,
      period: period == const $CopyWithPlaceholder()
          ? _value.period
          // ignore: cast_nullable_to_non_nullable
          : period as int,
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

extension $EMALineConfigCopyWith on EMALineConfig {
  /// Returns a callable class that can be used as follows: `instanceOfEMALineConfig.copyWith(...)` or like so:`instanceOfEMALineConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EMALineConfigCWProxy get copyWith => _$EMALineConfigCWProxyImpl(this);
}

abstract class _$EMAValidationConfigCWProxy {
  EMAValidationConfig minPeriod(int minPeriod);

  EMAValidationConfig maxPeriod(int maxPeriod);

  EMAValidationConfig allowDuplicate(bool allowDuplicate);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EMAValidationConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EMAValidationConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  EMAValidationConfig call({
    int minPeriod,
    int maxPeriod,
    bool allowDuplicate,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEMAValidationConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEMAValidationConfig.copyWith.fieldName(...)`
class _$EMAValidationConfigCWProxyImpl implements _$EMAValidationConfigCWProxy {
  const _$EMAValidationConfigCWProxyImpl(this._value);

  final EMAValidationConfig _value;

  @override
  EMAValidationConfig minPeriod(int minPeriod) => this(minPeriod: minPeriod);

  @override
  EMAValidationConfig maxPeriod(int maxPeriod) => this(maxPeriod: maxPeriod);

  @override
  EMAValidationConfig allowDuplicate(bool allowDuplicate) =>
      this(allowDuplicate: allowDuplicate);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EMAValidationConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EMAValidationConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  EMAValidationConfig call({
    Object? minPeriod = const $CopyWithPlaceholder(),
    Object? maxPeriod = const $CopyWithPlaceholder(),
    Object? allowDuplicate = const $CopyWithPlaceholder(),
  }) {
    return EMAValidationConfig(
      minPeriod: minPeriod == const $CopyWithPlaceholder()
          ? _value.minPeriod
          // ignore: cast_nullable_to_non_nullable
          : minPeriod as int,
      maxPeriod: maxPeriod == const $CopyWithPlaceholder()
          ? _value.maxPeriod
          // ignore: cast_nullable_to_non_nullable
          : maxPeriod as int,
      allowDuplicate: allowDuplicate == const $CopyWithPlaceholder()
          ? _value.allowDuplicate
          // ignore: cast_nullable_to_non_nullable
          : allowDuplicate as bool,
    );
  }
}

extension $EMAValidationConfigCopyWith on EMAValidationConfig {
  /// Returns a callable class that can be used as follows: `instanceOfEMAValidationConfig.copyWith(...)` or like so:`instanceOfEMAValidationConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EMAValidationConfigCWProxy get copyWith =>
      _$EMAValidationConfigCWProxyImpl(this);
}

abstract class _$EMADisplayConfigCWProxy {
  EMADisplayConfig pointRadius(double pointRadius);

  EMADisplayConfig showCrossPoint(bool showCrossPoint);

  EMADisplayConfig precision(int precision);

  EMADisplayConfig showPeriodInTips(bool showPeriodInTips);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EMADisplayConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EMADisplayConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  EMADisplayConfig call({
    double pointRadius,
    bool showCrossPoint,
    int precision,
    bool showPeriodInTips,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEMADisplayConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEMADisplayConfig.copyWith.fieldName(...)`
class _$EMADisplayConfigCWProxyImpl implements _$EMADisplayConfigCWProxy {
  const _$EMADisplayConfigCWProxyImpl(this._value);

  final EMADisplayConfig _value;

  @override
  EMADisplayConfig pointRadius(double pointRadius) =>
      this(pointRadius: pointRadius);

  @override
  EMADisplayConfig showCrossPoint(bool showCrossPoint) =>
      this(showCrossPoint: showCrossPoint);

  @override
  EMADisplayConfig precision(int precision) => this(precision: precision);

  @override
  EMADisplayConfig showPeriodInTips(bool showPeriodInTips) =>
      this(showPeriodInTips: showPeriodInTips);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EMADisplayConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EMADisplayConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  EMADisplayConfig call({
    Object? pointRadius = const $CopyWithPlaceholder(),
    Object? showCrossPoint = const $CopyWithPlaceholder(),
    Object? precision = const $CopyWithPlaceholder(),
    Object? showPeriodInTips = const $CopyWithPlaceholder(),
  }) {
    return EMADisplayConfig(
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

extension $EMADisplayConfigCopyWith on EMADisplayConfig {
  /// Returns a callable class that can be used as follows: `instanceOfEMADisplayConfig.copyWith(...)` or like so:`instanceOfEMADisplayConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EMADisplayConfigCWProxy get copyWith => _$EMADisplayConfigCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmaParam _$EmaParamFromJson(Map<String, dynamic> json) => EmaParam(
      maxLines: (json['maxLines'] as num?)?.toInt() ?? 10,
      lines: (json['lines'] as List<dynamic>?)
              ?.map((e) => EMALineConfig.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      validation: json['validation'] == null
          ? const EMAValidationConfig()
          : EMAValidationConfig.fromJson(
              json['validation'] as Map<String, dynamic>),
      display: json['display'] == null
          ? const EMADisplayConfig()
          : EMADisplayConfig.fromJson(json['display'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EmaParamToJson(EmaParam instance) => <String, dynamic>{
      'maxLines': instance.maxLines,
      'lines': instance.lines.map((e) => e.toJson()).toList(),
      'validation': instance.validation.toJson(),
      'display': instance.display.toJson(),
    };

EMALineConfig _$EMALineConfigFromJson(Map<String, dynamic> json) =>
    EMALineConfig(
      id: json['id'] as String,
      enabled: json['enabled'] as bool? ?? true,
      period: (json['period'] as num).toInt(),
      color: json['color'] == null
          ? const Color(0xff2196f3)
          : const ColorConverter().fromJson(json['color'] as String),
      width: (json['width'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$EMALineConfigToJson(EMALineConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'enabled': instance.enabled,
      'period': instance.period,
      'color': const ColorConverter().toJson(instance.color),
      'width': instance.width,
    };

EMAValidationConfig _$EMAValidationConfigFromJson(Map<String, dynamic> json) =>
    EMAValidationConfig(
      minPeriod: (json['minPeriod'] as num?)?.toInt() ?? 1,
      maxPeriod: (json['maxPeriod'] as num?)?.toInt() ?? 1000,
      allowDuplicate: json['allowDuplicate'] as bool? ?? false,
    );

Map<String, dynamic> _$EMAValidationConfigToJson(
        EMAValidationConfig instance) =>
    <String, dynamic>{
      'minPeriod': instance.minPeriod,
      'maxPeriod': instance.maxPeriod,
      'allowDuplicate': instance.allowDuplicate,
    };

EMADisplayConfig _$EMADisplayConfigFromJson(Map<String, dynamic> json) =>
    EMADisplayConfig(
      pointRadius: (json['pointRadius'] as num?)?.toDouble() ?? 0.0,
      showCrossPoint: json['showCrossPoint'] as bool? ?? false,
      precision: (json['precision'] as num?)?.toInt() ?? 2,
      showPeriodInTips: json['showPeriodInTips'] as bool? ?? true,
    );

Map<String, dynamic> _$EMADisplayConfigToJson(EMADisplayConfig instance) =>
    <String, dynamic>{
      'pointRadius': instance.pointRadius,
      'showCrossPoint': instance.showCrossPoint,
      'precision': instance.precision,
      'showPeriodInTips': instance.showPeriodInTips,
    };
