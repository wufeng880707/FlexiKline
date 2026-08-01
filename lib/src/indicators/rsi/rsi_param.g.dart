// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rsi_param.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RSILineConfigCWProxy {
  RSILineConfig id(String id);

  RSILineConfig enabled(bool enabled);

  RSILineConfig period(int period);

  RSILineConfig color(Color color);

  RSILineConfig width(double width);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RSILineConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RSILineConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  RSILineConfig call({
    String id,
    bool enabled,
    int period,
    Color color,
    double width,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRSILineConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRSILineConfig.copyWith.fieldName(...)`
class _$RSILineConfigCWProxyImpl implements _$RSILineConfigCWProxy {
  const _$RSILineConfigCWProxyImpl(this._value);

  final RSILineConfig _value;

  @override
  RSILineConfig id(String id) => this(id: id);

  @override
  RSILineConfig enabled(bool enabled) => this(enabled: enabled);

  @override
  RSILineConfig period(int period) => this(period: period);

  @override
  RSILineConfig color(Color color) => this(color: color);

  @override
  RSILineConfig width(double width) => this(width: width);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RSILineConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RSILineConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  RSILineConfig call({
    Object? id = const $CopyWithPlaceholder(),
    Object? enabled = const $CopyWithPlaceholder(),
    Object? period = const $CopyWithPlaceholder(),
    Object? color = const $CopyWithPlaceholder(),
    Object? width = const $CopyWithPlaceholder(),
  }) {
    return RSILineConfig(
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

extension $RSILineConfigCopyWith on RSILineConfig {
  /// Returns a callable class that can be used as follows: `instanceOfRSILineConfig.copyWith(...)` or like so:`instanceOfRSILineConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RSILineConfigCWProxy get copyWith => _$RSILineConfigCWProxyImpl(this);
}

abstract class _$RSIValidationConfigCWProxy {
  RSIValidationConfig minPeriod(int minPeriod);

  RSIValidationConfig maxPeriod(int maxPeriod);

  RSIValidationConfig allowDuplicate(bool allowDuplicate);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RSIValidationConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RSIValidationConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  RSIValidationConfig call({
    int minPeriod,
    int maxPeriod,
    bool allowDuplicate,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRSIValidationConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRSIValidationConfig.copyWith.fieldName(...)`
class _$RSIValidationConfigCWProxyImpl implements _$RSIValidationConfigCWProxy {
  const _$RSIValidationConfigCWProxyImpl(this._value);

  final RSIValidationConfig _value;

  @override
  RSIValidationConfig minPeriod(int minPeriod) => this(minPeriod: minPeriod);

  @override
  RSIValidationConfig maxPeriod(int maxPeriod) => this(maxPeriod: maxPeriod);

  @override
  RSIValidationConfig allowDuplicate(bool allowDuplicate) => this(allowDuplicate: allowDuplicate);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RSIValidationConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RSIValidationConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  RSIValidationConfig call({
    Object? minPeriod = const $CopyWithPlaceholder(),
    Object? maxPeriod = const $CopyWithPlaceholder(),
    Object? allowDuplicate = const $CopyWithPlaceholder(),
  }) {
    return RSIValidationConfig(
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

extension $RSIValidationConfigCopyWith on RSIValidationConfig {
  /// Returns a callable class that can be used as follows: `instanceOfRSIValidationConfig.copyWith(...)` or like so:`instanceOfRSIValidationConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RSIValidationConfigCWProxy get copyWith => _$RSIValidationConfigCWProxyImpl(this);
}

abstract class _$RSIReferenceConfigCWProxy {
  RSIReferenceConfig enabled(bool enabled);

  RSIReferenceConfig overbought(double overbought);

  RSIReferenceConfig oversold(double oversold);

  RSIReferenceConfig lineWidth(double lineWidth);

  RSIReferenceConfig color(Color color);

  RSIReferenceConfig dashWidth(double dashWidth);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RSIReferenceConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RSIReferenceConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  RSIReferenceConfig call({
    bool enabled,
    double overbought,
    double oversold,
    double lineWidth,
    Color color,
    double dashWidth,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRSIReferenceConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRSIReferenceConfig.copyWith.fieldName(...)`
class _$RSIReferenceConfigCWProxyImpl implements _$RSIReferenceConfigCWProxy {
  const _$RSIReferenceConfigCWProxyImpl(this._value);

  final RSIReferenceConfig _value;

  @override
  RSIReferenceConfig enabled(bool enabled) => this(enabled: enabled);

  @override
  RSIReferenceConfig overbought(double overbought) => this(overbought: overbought);

  @override
  RSIReferenceConfig oversold(double oversold) => this(oversold: oversold);

  @override
  RSIReferenceConfig lineWidth(double lineWidth) => this(lineWidth: lineWidth);

  @override
  RSIReferenceConfig color(Color color) => this(color: color);

  @override
  RSIReferenceConfig dashWidth(double dashWidth) => this(dashWidth: dashWidth);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RSIReferenceConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RSIReferenceConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  RSIReferenceConfig call({
    Object? enabled = const $CopyWithPlaceholder(),
    Object? overbought = const $CopyWithPlaceholder(),
    Object? oversold = const $CopyWithPlaceholder(),
    Object? lineWidth = const $CopyWithPlaceholder(),
    Object? color = const $CopyWithPlaceholder(),
    Object? dashWidth = const $CopyWithPlaceholder(),
  }) {
    return RSIReferenceConfig(
      enabled: enabled == const $CopyWithPlaceholder()
          ? _value.enabled
          // ignore: cast_nullable_to_non_nullable
          : enabled as bool,
      overbought: overbought == const $CopyWithPlaceholder()
          ? _value.overbought
          // ignore: cast_nullable_to_non_nullable
          : overbought as double,
      oversold: oversold == const $CopyWithPlaceholder()
          ? _value.oversold
          // ignore: cast_nullable_to_non_nullable
          : oversold as double,
      lineWidth: lineWidth == const $CopyWithPlaceholder()
          ? _value.lineWidth
          // ignore: cast_nullable_to_non_nullable
          : lineWidth as double,
      color: color == const $CopyWithPlaceholder()
          ? _value.color
          // ignore: cast_nullable_to_non_nullable
          : color as Color,
      dashWidth: dashWidth == const $CopyWithPlaceholder()
          ? _value.dashWidth
          // ignore: cast_nullable_to_non_nullable
          : dashWidth as double,
    );
  }
}

extension $RSIReferenceConfigCopyWith on RSIReferenceConfig {
  /// Returns a callable class that can be used as follows: `instanceOfRSIReferenceConfig.copyWith(...)` or like so:`instanceOfRSIReferenceConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RSIReferenceConfigCWProxy get copyWith => _$RSIReferenceConfigCWProxyImpl(this);
}

abstract class _$RSIDisplayConfigCWProxy {
  RSIDisplayConfig pointRadius(double pointRadius);

  RSIDisplayConfig showCrossPoint(bool showCrossPoint);

  RSIDisplayConfig precision(int precision);

  RSIDisplayConfig showPeriodInTips(bool showPeriodInTips);

  RSIDisplayConfig showReferenceValue(bool showReferenceValue);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RSIDisplayConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RSIDisplayConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  RSIDisplayConfig call({
    double pointRadius,
    bool showCrossPoint,
    int precision,
    bool showPeriodInTips,
    bool showReferenceValue,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRSIDisplayConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRSIDisplayConfig.copyWith.fieldName(...)`
class _$RSIDisplayConfigCWProxyImpl implements _$RSIDisplayConfigCWProxy {
  const _$RSIDisplayConfigCWProxyImpl(this._value);

  final RSIDisplayConfig _value;

  @override
  RSIDisplayConfig pointRadius(double pointRadius) => this(pointRadius: pointRadius);

  @override
  RSIDisplayConfig showCrossPoint(bool showCrossPoint) => this(showCrossPoint: showCrossPoint);

  @override
  RSIDisplayConfig precision(int precision) => this(precision: precision);

  @override
  RSIDisplayConfig showPeriodInTips(bool showPeriodInTips) => this(showPeriodInTips: showPeriodInTips);

  @override
  RSIDisplayConfig showReferenceValue(bool showReferenceValue) => this(showReferenceValue: showReferenceValue);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RSIDisplayConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RSIDisplayConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  RSIDisplayConfig call({
    Object? pointRadius = const $CopyWithPlaceholder(),
    Object? showCrossPoint = const $CopyWithPlaceholder(),
    Object? precision = const $CopyWithPlaceholder(),
    Object? showPeriodInTips = const $CopyWithPlaceholder(),
    Object? showReferenceValue = const $CopyWithPlaceholder(),
  }) {
    return RSIDisplayConfig(
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
      showReferenceValue: showReferenceValue == const $CopyWithPlaceholder()
          ? _value.showReferenceValue
          // ignore: cast_nullable_to_non_nullable
          : showReferenceValue as bool,
    );
  }
}

extension $RSIDisplayConfigCopyWith on RSIDisplayConfig {
  /// Returns a callable class that can be used as follows: `instanceOfRSIDisplayConfig.copyWith(...)` or like so:`instanceOfRSIDisplayConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RSIDisplayConfigCWProxy get copyWith => _$RSIDisplayConfigCWProxyImpl(this);
}

abstract class _$RsiParamCWProxy {
  RsiParam maxLines(int maxLines);

  RsiParam lines(List<RSILineConfig> lines);

  RsiParam validation(RSIValidationConfig validation);

  RsiParam reference(RSIReferenceConfig reference);

  RsiParam display(RSIDisplayConfig display);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RsiParam(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RsiParam(...).copyWith(id: 12, name: "My name")
  /// ````
  RsiParam call({
    int maxLines,
    List<RSILineConfig> lines,
    RSIValidationConfig validation,
    RSIReferenceConfig reference,
    RSIDisplayConfig display,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRsiParam.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRsiParam.copyWith.fieldName(...)`
class _$RsiParamCWProxyImpl implements _$RsiParamCWProxy {
  const _$RsiParamCWProxyImpl(this._value);

  final RsiParam _value;

  @override
  RsiParam maxLines(int maxLines) => this(maxLines: maxLines);

  @override
  RsiParam lines(List<RSILineConfig> lines) => this(lines: lines);

  @override
  RsiParam validation(RSIValidationConfig validation) => this(validation: validation);

  @override
  RsiParam reference(RSIReferenceConfig reference) => this(reference: reference);

  @override
  RsiParam display(RSIDisplayConfig display) => this(display: display);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RsiParam(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RsiParam(...).copyWith(id: 12, name: "My name")
  /// ````
  RsiParam call({
    Object? maxLines = const $CopyWithPlaceholder(),
    Object? lines = const $CopyWithPlaceholder(),
    Object? validation = const $CopyWithPlaceholder(),
    Object? reference = const $CopyWithPlaceholder(),
    Object? display = const $CopyWithPlaceholder(),
  }) {
    return RsiParam(
      maxLines: maxLines == const $CopyWithPlaceholder()
          ? _value.maxLines
          // ignore: cast_nullable_to_non_nullable
          : maxLines as int,
      lines: lines == const $CopyWithPlaceholder()
          ? _value.lines
          // ignore: cast_nullable_to_non_nullable
          : lines as List<RSILineConfig>,
      validation: validation == const $CopyWithPlaceholder()
          ? _value.validation
          // ignore: cast_nullable_to_non_nullable
          : validation as RSIValidationConfig,
      reference: reference == const $CopyWithPlaceholder()
          ? _value.reference
          // ignore: cast_nullable_to_non_nullable
          : reference as RSIReferenceConfig,
      display: display == const $CopyWithPlaceholder()
          ? _value.display
          // ignore: cast_nullable_to_non_nullable
          : display as RSIDisplayConfig,
    );
  }
}

extension $RsiParamCopyWith on RsiParam {
  /// Returns a callable class that can be used as follows: `instanceOfRsiParam.copyWith(...)` or like so:`instanceOfRsiParam.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RsiParamCWProxy get copyWith => _$RsiParamCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RSILineConfig _$RSILineConfigFromJson(Map<String, dynamic> json) => RSILineConfig(
      id: json['id'] as String,
      enabled: json['enabled'] as bool? ?? true,
      period: (json['period'] as num).toInt(),
      color: const ColorConverter().fromJson(json['color'] as String),
      width: (json['width'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$RSILineConfigToJson(RSILineConfig instance) => <String, dynamic>{
      'id': instance.id,
      'enabled': instance.enabled,
      'period': instance.period,
      'color': const ColorConverter().toJson(instance.color),
      'width': instance.width,
    };

RSIValidationConfig _$RSIValidationConfigFromJson(Map<String, dynamic> json) => RSIValidationConfig(
      minPeriod: (json['minPeriod'] as num?)?.toInt() ?? 1,
      maxPeriod: (json['maxPeriod'] as num?)?.toInt() ?? 1000,
      allowDuplicate: json['allowDuplicate'] as bool? ?? false,
    );

Map<String, dynamic> _$RSIValidationConfigToJson(RSIValidationConfig instance) => <String, dynamic>{
      'minPeriod': instance.minPeriod,
      'maxPeriod': instance.maxPeriod,
      'allowDuplicate': instance.allowDuplicate,
    };

RSIReferenceConfig _$RSIReferenceConfigFromJson(Map<String, dynamic> json) => RSIReferenceConfig(
      enabled: json['enabled'] as bool? ?? true,
      overbought: (json['overbought'] as num?)?.toDouble() ?? 70.0,
      oversold: (json['oversold'] as num?)?.toDouble() ?? 30.0,
      lineWidth: (json['lineWidth'] as num?)?.toDouble() ?? 0.5,
      color: json['color'] == null ? const Color(0x66666666) : const ColorConverter().fromJson(json['color'] as String),
      dashWidth: (json['dashWidth'] as num?)?.toDouble() ?? 2.0,
    );

Map<String, dynamic> _$RSIReferenceConfigToJson(RSIReferenceConfig instance) => <String, dynamic>{
      'enabled': instance.enabled,
      'overbought': instance.overbought,
      'oversold': instance.oversold,
      'lineWidth': instance.lineWidth,
      'color': const ColorConverter().toJson(instance.color),
      'dashWidth': instance.dashWidth,
    };

RSIDisplayConfig _$RSIDisplayConfigFromJson(Map<String, dynamic> json) => RSIDisplayConfig(
      pointRadius: (json['pointRadius'] as num?)?.toDouble() ?? 0.0,
      showCrossPoint: json['showCrossPoint'] as bool? ?? false,
      precision: (json['precision'] as num?)?.toInt() ?? 2,
      showPeriodInTips: json['showPeriodInTips'] as bool? ?? true,
      showReferenceValue: json['showReferenceValue'] as bool? ?? true,
    );

Map<String, dynamic> _$RSIDisplayConfigToJson(RSIDisplayConfig instance) => <String, dynamic>{
      'pointRadius': instance.pointRadius,
      'showCrossPoint': instance.showCrossPoint,
      'precision': instance.precision,
      'showPeriodInTips': instance.showPeriodInTips,
      'showReferenceValue': instance.showReferenceValue,
    };

RsiParam _$RsiParamFromJson(Map<String, dynamic> json) => RsiParam(
      maxLines: (json['maxLines'] as num?)?.toInt() ?? 10,
      lines: (json['lines'] as List<dynamic>).map((e) => RSILineConfig.fromJson(e as Map<String, dynamic>)).toList(),
      validation: json['validation'] == null
          ? const RSIValidationConfig()
          : RSIValidationConfig.fromJson(json['validation'] as Map<String, dynamic>),
      reference: json['reference'] == null
          ? const RSIReferenceConfig()
          : RSIReferenceConfig.fromJson(json['reference'] as Map<String, dynamic>),
      display: json['display'] == null
          ? const RSIDisplayConfig()
          : RSIDisplayConfig.fromJson(json['display'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RsiParamToJson(RsiParam instance) => <String, dynamic>{
      'maxLines': instance.maxLines,
      'lines': instance.lines.map((e) => e.toJson()).toList(),
      'validation': instance.validation.toJson(),
      'reference': instance.reference.toJson(),
      'display': instance.display.toJson(),
    };
