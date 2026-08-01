// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vol_ma_param.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$VolMALineConfigCWProxy {
  VolMALineConfig id(String id);

  VolMALineConfig enabled(bool enabled);

  VolMALineConfig period(int period);

  VolMALineConfig color(Color color);

  VolMALineConfig width(double width);

  VolMALineConfig opacity(double opacity);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VolMALineConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VolMALineConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  VolMALineConfig call({
    String id,
    bool enabled,
    int period,
    Color color,
    double width,
    double opacity,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVolMALineConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVolMALineConfig.copyWith.fieldName(...)`
class _$VolMALineConfigCWProxyImpl implements _$VolMALineConfigCWProxy {
  const _$VolMALineConfigCWProxyImpl(this._value);

  final VolMALineConfig _value;

  @override
  VolMALineConfig id(String id) => this(id: id);

  @override
  VolMALineConfig enabled(bool enabled) => this(enabled: enabled);

  @override
  VolMALineConfig period(int period) => this(period: period);

  @override
  VolMALineConfig color(Color color) => this(color: color);

  @override
  VolMALineConfig width(double width) => this(width: width);

  @override
  VolMALineConfig opacity(double opacity) => this(opacity: opacity);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VolMALineConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VolMALineConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  VolMALineConfig call({
    Object? id = const $CopyWithPlaceholder(),
    Object? enabled = const $CopyWithPlaceholder(),
    Object? period = const $CopyWithPlaceholder(),
    Object? color = const $CopyWithPlaceholder(),
    Object? width = const $CopyWithPlaceholder(),
    Object? opacity = const $CopyWithPlaceholder(),
  }) {
    return VolMALineConfig(
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
      opacity: opacity == const $CopyWithPlaceholder()
          ? _value.opacity
          // ignore: cast_nullable_to_non_nullable
          : opacity as double,
    );
  }
}

extension $VolMALineConfigCopyWith on VolMALineConfig {
  /// Returns a callable class that can be used as follows: `instanceOfVolMALineConfig.copyWith(...)` or like so:`instanceOfVolMALineConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VolMALineConfigCWProxy get copyWith => _$VolMALineConfigCWProxyImpl(this);
}

abstract class _$VolMAValidationConfigCWProxy {
  VolMAValidationConfig minPeriod(int minPeriod);

  VolMAValidationConfig maxPeriod(int maxPeriod);

  VolMAValidationConfig allowDuplicate(bool allowDuplicate);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VolMAValidationConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VolMAValidationConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  VolMAValidationConfig call({
    int minPeriod,
    int maxPeriod,
    bool allowDuplicate,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVolMAValidationConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVolMAValidationConfig.copyWith.fieldName(...)`
class _$VolMAValidationConfigCWProxyImpl implements _$VolMAValidationConfigCWProxy {
  const _$VolMAValidationConfigCWProxyImpl(this._value);

  final VolMAValidationConfig _value;

  @override
  VolMAValidationConfig minPeriod(int minPeriod) => this(minPeriod: minPeriod);

  @override
  VolMAValidationConfig maxPeriod(int maxPeriod) => this(maxPeriod: maxPeriod);

  @override
  VolMAValidationConfig allowDuplicate(bool allowDuplicate) => this(allowDuplicate: allowDuplicate);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VolMAValidationConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VolMAValidationConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  VolMAValidationConfig call({
    Object? minPeriod = const $CopyWithPlaceholder(),
    Object? maxPeriod = const $CopyWithPlaceholder(),
    Object? allowDuplicate = const $CopyWithPlaceholder(),
  }) {
    return VolMAValidationConfig(
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

extension $VolMAValidationConfigCopyWith on VolMAValidationConfig {
  /// Returns a callable class that can be used as follows: `instanceOfVolMAValidationConfig.copyWith(...)` or like so:`instanceOfVolMAValidationConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VolMAValidationConfigCWProxy get copyWith => _$VolMAValidationConfigCWProxyImpl(this);
}

abstract class _$VolMAVolumeConfigCWProxy {
  VolMAVolumeConfig useTrendColor(bool useTrendColor);

  VolMAVolumeConfig bullishColor(Color bullishColor);

  VolMAVolumeConfig bearishColor(Color bearishColor);

  VolMAVolumeConfig opacity(double opacity);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VolMAVolumeConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VolMAVolumeConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  VolMAVolumeConfig call({
    bool useTrendColor,
    Color bullishColor,
    Color bearishColor,
    double opacity,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVolMAVolumeConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVolMAVolumeConfig.copyWith.fieldName(...)`
class _$VolMAVolumeConfigCWProxyImpl implements _$VolMAVolumeConfigCWProxy {
  const _$VolMAVolumeConfigCWProxyImpl(this._value);

  final VolMAVolumeConfig _value;

  @override
  VolMAVolumeConfig useTrendColor(bool useTrendColor) => this(useTrendColor: useTrendColor);

  @override
  VolMAVolumeConfig bullishColor(Color bullishColor) => this(bullishColor: bullishColor);

  @override
  VolMAVolumeConfig bearishColor(Color bearishColor) => this(bearishColor: bearishColor);

  @override
  VolMAVolumeConfig opacity(double opacity) => this(opacity: opacity);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VolMAVolumeConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VolMAVolumeConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  VolMAVolumeConfig call({
    Object? useTrendColor = const $CopyWithPlaceholder(),
    Object? bullishColor = const $CopyWithPlaceholder(),
    Object? bearishColor = const $CopyWithPlaceholder(),
    Object? opacity = const $CopyWithPlaceholder(),
  }) {
    return VolMAVolumeConfig(
      useTrendColor: useTrendColor == const $CopyWithPlaceholder()
          ? _value.useTrendColor
          // ignore: cast_nullable_to_non_nullable
          : useTrendColor as bool,
      bullishColor: bullishColor == const $CopyWithPlaceholder()
          ? _value.bullishColor
          // ignore: cast_nullable_to_non_nullable
          : bullishColor as Color,
      bearishColor: bearishColor == const $CopyWithPlaceholder()
          ? _value.bearishColor
          // ignore: cast_nullable_to_non_nullable
          : bearishColor as Color,
      opacity: opacity == const $CopyWithPlaceholder()
          ? _value.opacity
          // ignore: cast_nullable_to_non_nullable
          : opacity as double,
    );
  }
}

extension $VolMAVolumeConfigCopyWith on VolMAVolumeConfig {
  /// Returns a callable class that can be used as follows: `instanceOfVolMAVolumeConfig.copyWith(...)` or like so:`instanceOfVolMAVolumeConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VolMAVolumeConfigCWProxy get copyWith => _$VolMAVolumeConfigCWProxyImpl(this);
}

abstract class _$VolMADisplayConfigCWProxy {
  VolMADisplayConfig pointRadius(double pointRadius);

  VolMADisplayConfig showCrossPoint(bool showCrossPoint);

  VolMADisplayConfig precision(int precision);

  VolMADisplayConfig showPeriodInTips(bool showPeriodInTips);

  VolMADisplayConfig showVolInTips(bool showVolInTips);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VolMADisplayConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VolMADisplayConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  VolMADisplayConfig call({
    double pointRadius,
    bool showCrossPoint,
    int precision,
    bool showPeriodInTips,
    bool showVolInTips,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVolMADisplayConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVolMADisplayConfig.copyWith.fieldName(...)`
class _$VolMADisplayConfigCWProxyImpl implements _$VolMADisplayConfigCWProxy {
  const _$VolMADisplayConfigCWProxyImpl(this._value);

  final VolMADisplayConfig _value;

  @override
  VolMADisplayConfig pointRadius(double pointRadius) => this(pointRadius: pointRadius);

  @override
  VolMADisplayConfig showCrossPoint(bool showCrossPoint) => this(showCrossPoint: showCrossPoint);

  @override
  VolMADisplayConfig precision(int precision) => this(precision: precision);

  @override
  VolMADisplayConfig showPeriodInTips(bool showPeriodInTips) => this(showPeriodInTips: showPeriodInTips);

  @override
  VolMADisplayConfig showVolInTips(bool showVolInTips) => this(showVolInTips: showVolInTips);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VolMADisplayConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VolMADisplayConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  VolMADisplayConfig call({
    Object? pointRadius = const $CopyWithPlaceholder(),
    Object? showCrossPoint = const $CopyWithPlaceholder(),
    Object? precision = const $CopyWithPlaceholder(),
    Object? showPeriodInTips = const $CopyWithPlaceholder(),
    Object? showVolInTips = const $CopyWithPlaceholder(),
  }) {
    return VolMADisplayConfig(
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
      showVolInTips: showVolInTips == const $CopyWithPlaceholder()
          ? _value.showVolInTips
          // ignore: cast_nullable_to_non_nullable
          : showVolInTips as bool,
    );
  }
}

extension $VolMADisplayConfigCopyWith on VolMADisplayConfig {
  /// Returns a callable class that can be used as follows: `instanceOfVolMADisplayConfig.copyWith(...)` or like so:`instanceOfVolMADisplayConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VolMADisplayConfigCWProxy get copyWith => _$VolMADisplayConfigCWProxyImpl(this);
}

abstract class _$VolMaParamCWProxy {
  VolMaParam maxLines(int maxLines);

  VolMaParam lines(List<VolMALineConfig> lines);

  VolMaParam validation(VolMAValidationConfig validation);

  VolMaParam volume(VolMAVolumeConfig volume);

  VolMaParam display(VolMADisplayConfig display);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VolMaParam(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VolMaParam(...).copyWith(id: 12, name: "My name")
  /// ````
  VolMaParam call({
    int maxLines,
    List<VolMALineConfig> lines,
    VolMAValidationConfig validation,
    VolMAVolumeConfig volume,
    VolMADisplayConfig display,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVolMaParam.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVolMaParam.copyWith.fieldName(...)`
class _$VolMaParamCWProxyImpl implements _$VolMaParamCWProxy {
  const _$VolMaParamCWProxyImpl(this._value);

  final VolMaParam _value;

  @override
  VolMaParam maxLines(int maxLines) => this(maxLines: maxLines);

  @override
  VolMaParam lines(List<VolMALineConfig> lines) => this(lines: lines);

  @override
  VolMaParam validation(VolMAValidationConfig validation) => this(validation: validation);

  @override
  VolMaParam volume(VolMAVolumeConfig volume) => this(volume: volume);

  @override
  VolMaParam display(VolMADisplayConfig display) => this(display: display);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VolMaParam(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VolMaParam(...).copyWith(id: 12, name: "My name")
  /// ````
  VolMaParam call({
    Object? maxLines = const $CopyWithPlaceholder(),
    Object? lines = const $CopyWithPlaceholder(),
    Object? validation = const $CopyWithPlaceholder(),
    Object? volume = const $CopyWithPlaceholder(),
    Object? display = const $CopyWithPlaceholder(),
  }) {
    return VolMaParam(
      maxLines: maxLines == const $CopyWithPlaceholder()
          ? _value.maxLines
          // ignore: cast_nullable_to_non_nullable
          : maxLines as int,
      lines: lines == const $CopyWithPlaceholder()
          ? _value.lines
          // ignore: cast_nullable_to_non_nullable
          : lines as List<VolMALineConfig>,
      validation: validation == const $CopyWithPlaceholder()
          ? _value.validation
          // ignore: cast_nullable_to_non_nullable
          : validation as VolMAValidationConfig,
      volume: volume == const $CopyWithPlaceholder()
          ? _value.volume
          // ignore: cast_nullable_to_non_nullable
          : volume as VolMAVolumeConfig,
      display: display == const $CopyWithPlaceholder()
          ? _value.display
          // ignore: cast_nullable_to_non_nullable
          : display as VolMADisplayConfig,
    );
  }
}

extension $VolMaParamCopyWith on VolMaParam {
  /// Returns a callable class that can be used as follows: `instanceOfVolMaParam.copyWith(...)` or like so:`instanceOfVolMaParam.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VolMaParamCWProxy get copyWith => _$VolMaParamCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VolMALineConfig _$VolMALineConfigFromJson(Map<String, dynamic> json) => VolMALineConfig(
      id: json['id'] as String,
      enabled: json['enabled'] as bool? ?? true,
      period: (json['period'] as num).toInt(),
      color: const ColorConverter().fromJson(json['color'] as String),
      width: (json['width'] as num?)?.toDouble() ?? 1.0,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 0.8,
    );

Map<String, dynamic> _$VolMALineConfigToJson(VolMALineConfig instance) => <String, dynamic>{
      'id': instance.id,
      'enabled': instance.enabled,
      'period': instance.period,
      'color': const ColorConverter().toJson(instance.color),
      'width': instance.width,
      'opacity': instance.opacity,
    };

VolMAValidationConfig _$VolMAValidationConfigFromJson(Map<String, dynamic> json) => VolMAValidationConfig(
      minPeriod: (json['minPeriod'] as num?)?.toInt() ?? 1,
      maxPeriod: (json['maxPeriod'] as num?)?.toInt() ?? 1000,
      allowDuplicate: json['allowDuplicate'] as bool? ?? false,
    );

Map<String, dynamic> _$VolMAValidationConfigToJson(VolMAValidationConfig instance) => <String, dynamic>{
      'minPeriod': instance.minPeriod,
      'maxPeriod': instance.maxPeriod,
      'allowDuplicate': instance.allowDuplicate,
    };

VolMAVolumeConfig _$VolMAVolumeConfigFromJson(Map<String, dynamic> json) => VolMAVolumeConfig(
      useTrendColor: json['useTrendColor'] as bool? ?? true,
      bullishColor: json['bullishColor'] == null
          ? const Color(0xff4caf50)
          : const ColorConverter().fromJson(json['bullishColor'] as String),
      bearishColor: json['bearishColor'] == null
          ? const Color(0xfff44336)
          : const ColorConverter().fromJson(json['bearishColor'] as String),
      opacity: (json['opacity'] as num?)?.toDouble() ?? 0.6,
    );

Map<String, dynamic> _$VolMAVolumeConfigToJson(VolMAVolumeConfig instance) => <String, dynamic>{
      'useTrendColor': instance.useTrendColor,
      'bullishColor': const ColorConverter().toJson(instance.bullishColor),
      'bearishColor': const ColorConverter().toJson(instance.bearishColor),
      'opacity': instance.opacity,
    };

VolMADisplayConfig _$VolMADisplayConfigFromJson(Map<String, dynamic> json) => VolMADisplayConfig(
      pointRadius: (json['pointRadius'] as num?)?.toDouble() ?? 0.0,
      showCrossPoint: json['showCrossPoint'] as bool? ?? false,
      precision: (json['precision'] as num?)?.toInt() ?? 0,
      showPeriodInTips: json['showPeriodInTips'] as bool? ?? true,
      showVolInTips: json['showVolInTips'] as bool? ?? true,
    );

Map<String, dynamic> _$VolMADisplayConfigToJson(VolMADisplayConfig instance) => <String, dynamic>{
      'pointRadius': instance.pointRadius,
      'showCrossPoint': instance.showCrossPoint,
      'precision': instance.precision,
      'showPeriodInTips': instance.showPeriodInTips,
      'showVolInTips': instance.showVolInTips,
    };

VolMaParam _$VolMaParamFromJson(Map<String, dynamic> json) => VolMaParam(
      maxLines: (json['maxLines'] as num?)?.toInt() ?? 10,
      lines: (json['lines'] as List<dynamic>).map((e) => VolMALineConfig.fromJson(e as Map<String, dynamic>)).toList(),
      validation: json['validation'] == null
          ? const VolMAValidationConfig()
          : VolMAValidationConfig.fromJson(json['validation'] as Map<String, dynamic>),
      volume: json['volume'] == null
          ? const VolMAVolumeConfig()
          : VolMAVolumeConfig.fromJson(json['volume'] as Map<String, dynamic>),
      display: json['display'] == null
          ? const VolMADisplayConfig()
          : VolMADisplayConfig.fromJson(json['display'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VolMaParamToJson(VolMaParam instance) => <String, dynamic>{
      'maxLines': instance.maxLines,
      'lines': instance.lines.map((e) => e.toJson()).toList(),
      'validation': instance.validation.toJson(),
      'volume': instance.volume.toJson(),
      'display': instance.display.toJson(),
    };
