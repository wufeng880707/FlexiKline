// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ma_param.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MaParamCWProxy {
  MaParam maxLines(int maxLines);

  MaParam lines(List<MALineConfig> lines);

  MaParam validation(MAValidationConfig validation);

  MaParam display(MADisplayConfig display);

  MaParam defaultColors(List<Color> defaultColors);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MaParam(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MaParam(...).copyWith(id: 12, name: "My name")
  /// ````
  MaParam call({
    int maxLines,
    List<MALineConfig> lines,
    MAValidationConfig validation,
    MADisplayConfig display,
    List<Color> defaultColors,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMaParam.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMaParam.copyWith.fieldName(...)`
class _$MaParamCWProxyImpl implements _$MaParamCWProxy {
  const _$MaParamCWProxyImpl(this._value);

  final MaParam _value;

  @override
  MaParam maxLines(int maxLines) => this(maxLines: maxLines);

  @override
  MaParam lines(List<MALineConfig> lines) => this(lines: lines);

  @override
  MaParam validation(MAValidationConfig validation) => this(validation: validation);

  @override
  MaParam display(MADisplayConfig display) => this(display: display);

  @override
  MaParam defaultColors(List<Color> defaultColors) => this(defaultColors: defaultColors);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MaParam(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MaParam(...).copyWith(id: 12, name: "My name")
  /// ````
  MaParam call({
    Object? maxLines = const $CopyWithPlaceholder(),
    Object? lines = const $CopyWithPlaceholder(),
    Object? validation = const $CopyWithPlaceholder(),
    Object? display = const $CopyWithPlaceholder(),
    Object? defaultColors = const $CopyWithPlaceholder(),
  }) {
    return MaParam(
      maxLines: maxLines == const $CopyWithPlaceholder()
          ? _value.maxLines
          // ignore: cast_nullable_to_non_nullable
          : maxLines as int,
      lines: lines == const $CopyWithPlaceholder()
          ? _value.lines
          // ignore: cast_nullable_to_non_nullable
          : lines as List<MALineConfig>,
      validation: validation == const $CopyWithPlaceholder()
          ? _value.validation
          // ignore: cast_nullable_to_non_nullable
          : validation as MAValidationConfig,
      display: display == const $CopyWithPlaceholder()
          ? _value.display
          // ignore: cast_nullable_to_non_nullable
          : display as MADisplayConfig,
      defaultColors: defaultColors == const $CopyWithPlaceholder()
          ? _value.defaultColors
          // ignore: cast_nullable_to_non_nullable
          : defaultColors as List<Color>,
    );
  }
}

extension $MaParamCopyWith on MaParam {
  /// Returns a callable class that can be used as follows: `instanceOfMaParam.copyWith(...)` or like so:`instanceOfMaParam.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MaParamCWProxy get copyWith => _$MaParamCWProxyImpl(this);
}

abstract class _$MALineConfigCWProxy {
  MALineConfig id(String id);

  MALineConfig enabled(bool enabled);

  MALineConfig period(int period);

  MALineConfig color(Color color);

  MALineConfig width(double width);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MALineConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MALineConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  MALineConfig call({
    String id,
    bool enabled,
    int period,
    Color color,
    double width,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMALineConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMALineConfig.copyWith.fieldName(...)`
class _$MALineConfigCWProxyImpl implements _$MALineConfigCWProxy {
  const _$MALineConfigCWProxyImpl(this._value);

  final MALineConfig _value;

  @override
  MALineConfig id(String id) => this(id: id);

  @override
  MALineConfig enabled(bool enabled) => this(enabled: enabled);

  @override
  MALineConfig period(int period) => this(period: period);

  @override
  MALineConfig color(Color color) => this(color: color);

  @override
  MALineConfig width(double width) => this(width: width);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MALineConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MALineConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  MALineConfig call({
    Object? id = const $CopyWithPlaceholder(),
    Object? enabled = const $CopyWithPlaceholder(),
    Object? period = const $CopyWithPlaceholder(),
    Object? color = const $CopyWithPlaceholder(),
    Object? width = const $CopyWithPlaceholder(),
  }) {
    return MALineConfig(
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

extension $MALineConfigCopyWith on MALineConfig {
  /// Returns a callable class that can be used as follows: `instanceOfMALineConfig.copyWith(...)` or like so:`instanceOfMALineConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MALineConfigCWProxy get copyWith => _$MALineConfigCWProxyImpl(this);
}

abstract class _$MAValidationConfigCWProxy {
  MAValidationConfig minPeriod(int minPeriod);

  MAValidationConfig maxPeriod(int maxPeriod);

  MAValidationConfig allowDuplicate(bool allowDuplicate);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MAValidationConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MAValidationConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  MAValidationConfig call({
    int minPeriod,
    int maxPeriod,
    bool allowDuplicate,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMAValidationConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMAValidationConfig.copyWith.fieldName(...)`
class _$MAValidationConfigCWProxyImpl implements _$MAValidationConfigCWProxy {
  const _$MAValidationConfigCWProxyImpl(this._value);

  final MAValidationConfig _value;

  @override
  MAValidationConfig minPeriod(int minPeriod) => this(minPeriod: minPeriod);

  @override
  MAValidationConfig maxPeriod(int maxPeriod) => this(maxPeriod: maxPeriod);

  @override
  MAValidationConfig allowDuplicate(bool allowDuplicate) => this(allowDuplicate: allowDuplicate);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MAValidationConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MAValidationConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  MAValidationConfig call({
    Object? minPeriod = const $CopyWithPlaceholder(),
    Object? maxPeriod = const $CopyWithPlaceholder(),
    Object? allowDuplicate = const $CopyWithPlaceholder(),
  }) {
    return MAValidationConfig(
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

extension $MAValidationConfigCopyWith on MAValidationConfig {
  /// Returns a callable class that can be used as follows: `instanceOfMAValidationConfig.copyWith(...)` or like so:`instanceOfMAValidationConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MAValidationConfigCWProxy get copyWith => _$MAValidationConfigCWProxyImpl(this);
}

abstract class _$MADisplayConfigCWProxy {
  MADisplayConfig pointRadius(double pointRadius);

  MADisplayConfig showCrossPoint(bool showCrossPoint);

  MADisplayConfig precision(int precision);

  MADisplayConfig showPeriodInTips(bool showPeriodInTips);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MADisplayConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MADisplayConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  MADisplayConfig call({
    double pointRadius,
    bool showCrossPoint,
    int precision,
    bool showPeriodInTips,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMADisplayConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMADisplayConfig.copyWith.fieldName(...)`
class _$MADisplayConfigCWProxyImpl implements _$MADisplayConfigCWProxy {
  const _$MADisplayConfigCWProxyImpl(this._value);

  final MADisplayConfig _value;

  @override
  MADisplayConfig pointRadius(double pointRadius) => this(pointRadius: pointRadius);

  @override
  MADisplayConfig showCrossPoint(bool showCrossPoint) => this(showCrossPoint: showCrossPoint);

  @override
  MADisplayConfig precision(int precision) => this(precision: precision);

  @override
  MADisplayConfig showPeriodInTips(bool showPeriodInTips) => this(showPeriodInTips: showPeriodInTips);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MADisplayConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MADisplayConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  MADisplayConfig call({
    Object? pointRadius = const $CopyWithPlaceholder(),
    Object? showCrossPoint = const $CopyWithPlaceholder(),
    Object? precision = const $CopyWithPlaceholder(),
    Object? showPeriodInTips = const $CopyWithPlaceholder(),
  }) {
    return MADisplayConfig(
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

extension $MADisplayConfigCopyWith on MADisplayConfig {
  /// Returns a callable class that can be used as follows: `instanceOfMADisplayConfig.copyWith(...)` or like so:`instanceOfMADisplayConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MADisplayConfigCWProxy get copyWith => _$MADisplayConfigCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MaParam _$MaParamFromJson(Map<String, dynamic> json) => MaParam(
      maxLines: (json['maxLines'] as num?)?.toInt() ?? 10,
      lines: (json['lines'] as List<dynamic>?)?.map((e) => MALineConfig.fromJson(e as Map<String, dynamic>)).toList() ??
          const [],
      validation: json['validation'] == null
          ? const MAValidationConfig()
          : MAValidationConfig.fromJson(json['validation'] as Map<String, dynamic>),
      display: json['display'] == null
          ? const MADisplayConfig()
          : MADisplayConfig.fromJson(json['display'] as Map<String, dynamic>),
      defaultColors: (json['defaultColors'] as List<dynamic>?)
              ?.map((e) => const ColorConverter().fromJson(e as String))
              .toList() ??
          const [
            Color(0xffffff00),
            Color(0xffff69b4),
            Color(0xff9c27b0),
            Color(0xff4caf50),
            Color(0xff26a69a),
            Color(0xff9575cd),
            Color(0xffaed581),
            Color(0xffff8a65),
            Color(0xff42a5f5),
            Color(0xfff44336)
          ],
    );

Map<String, dynamic> _$MaParamToJson(MaParam instance) => <String, dynamic>{
      'maxLines': instance.maxLines,
      'lines': instance.lines.map((e) => e.toJson()).toList(),
      'validation': instance.validation.toJson(),
      'display': instance.display.toJson(),
      'defaultColors': instance.defaultColors.map(const ColorConverter().toJson).toList(),
    };

MALineConfig _$MALineConfigFromJson(Map<String, dynamic> json) => MALineConfig(
      id: json['id'] as String,
      enabled: json['enabled'] as bool? ?? true,
      period: (json['period'] as num).toInt(),
      color: json['color'] == null ? const Color(0xff2196f3) : const ColorConverter().fromJson(json['color'] as String),
      width: (json['width'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$MALineConfigToJson(MALineConfig instance) => <String, dynamic>{
      'id': instance.id,
      'enabled': instance.enabled,
      'period': instance.period,
      'color': const ColorConverter().toJson(instance.color),
      'width': instance.width,
    };

MAValidationConfig _$MAValidationConfigFromJson(Map<String, dynamic> json) => MAValidationConfig(
      minPeriod: (json['minPeriod'] as num?)?.toInt() ?? 1,
      maxPeriod: (json['maxPeriod'] as num?)?.toInt() ?? 1000,
      allowDuplicate: json['allowDuplicate'] as bool? ?? false,
    );

Map<String, dynamic> _$MAValidationConfigToJson(MAValidationConfig instance) => <String, dynamic>{
      'minPeriod': instance.minPeriod,
      'maxPeriod': instance.maxPeriod,
      'allowDuplicate': instance.allowDuplicate,
    };

MADisplayConfig _$MADisplayConfigFromJson(Map<String, dynamic> json) => MADisplayConfig(
      pointRadius: (json['pointRadius'] as num?)?.toDouble() ?? 0.0,
      showCrossPoint: json['showCrossPoint'] as bool? ?? false,
      precision: (json['precision'] as num?)?.toInt() ?? 2,
      showPeriodInTips: json['showPeriodInTips'] as bool? ?? true,
    );

Map<String, dynamic> _$MADisplayConfigToJson(MADisplayConfig instance) => <String, dynamic>{
      'pointRadius': instance.pointRadius,
      'showCrossPoint': instance.showCrossPoint,
      'precision': instance.precision,
      'showPeriodInTips': instance.showPeriodInTips,
    };
