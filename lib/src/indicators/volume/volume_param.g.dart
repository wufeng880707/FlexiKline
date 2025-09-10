// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'volume_param.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$VolumeBarConfigCWProxy {
  VolumeBarConfig useTrendColor(bool useTrendColor);

  VolumeBarConfig bullishColor(Color bullishColor);

  VolumeBarConfig bearishColor(Color bearishColor);

  VolumeBarConfig opacity(double opacity);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VolumeBarConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VolumeBarConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  VolumeBarConfig call({
    bool useTrendColor,
    Color bullishColor,
    Color bearishColor,
    double opacity,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVolumeBarConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVolumeBarConfig.copyWith.fieldName(...)`
class _$VolumeBarConfigCWProxyImpl implements _$VolumeBarConfigCWProxy {
  const _$VolumeBarConfigCWProxyImpl(this._value);

  final VolumeBarConfig _value;

  @override
  VolumeBarConfig useTrendColor(bool useTrendColor) =>
      this(useTrendColor: useTrendColor);

  @override
  VolumeBarConfig bullishColor(Color bullishColor) =>
      this(bullishColor: bullishColor);

  @override
  VolumeBarConfig bearishColor(Color bearishColor) =>
      this(bearishColor: bearishColor);

  @override
  VolumeBarConfig opacity(double opacity) => this(opacity: opacity);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VolumeBarConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VolumeBarConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  VolumeBarConfig call({
    Object? useTrendColor = const $CopyWithPlaceholder(),
    Object? bullishColor = const $CopyWithPlaceholder(),
    Object? bearishColor = const $CopyWithPlaceholder(),
    Object? opacity = const $CopyWithPlaceholder(),
  }) {
    return VolumeBarConfig(
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

extension $VolumeBarConfigCopyWith on VolumeBarConfig {
  /// Returns a callable class that can be used as follows: `instanceOfVolumeBarConfig.copyWith(...)` or like so:`instanceOfVolumeBarConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VolumeBarConfigCWProxy get copyWith => _$VolumeBarConfigCWProxyImpl(this);
}

abstract class _$VolumeDisplayConfigCWProxy {
  VolumeDisplayConfig precision(int precision);

  VolumeDisplayConfig showVolInTips(bool showVolInTips);

  VolumeDisplayConfig compactDisplay(bool compactDisplay);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VolumeDisplayConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VolumeDisplayConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  VolumeDisplayConfig call({
    int precision,
    bool showVolInTips,
    bool compactDisplay,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVolumeDisplayConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVolumeDisplayConfig.copyWith.fieldName(...)`
class _$VolumeDisplayConfigCWProxyImpl implements _$VolumeDisplayConfigCWProxy {
  const _$VolumeDisplayConfigCWProxyImpl(this._value);

  final VolumeDisplayConfig _value;

  @override
  VolumeDisplayConfig precision(int precision) => this(precision: precision);

  @override
  VolumeDisplayConfig showVolInTips(bool showVolInTips) =>
      this(showVolInTips: showVolInTips);

  @override
  VolumeDisplayConfig compactDisplay(bool compactDisplay) =>
      this(compactDisplay: compactDisplay);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VolumeDisplayConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VolumeDisplayConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  VolumeDisplayConfig call({
    Object? precision = const $CopyWithPlaceholder(),
    Object? showVolInTips = const $CopyWithPlaceholder(),
    Object? compactDisplay = const $CopyWithPlaceholder(),
  }) {
    return VolumeDisplayConfig(
      precision: precision == const $CopyWithPlaceholder()
          ? _value.precision
          // ignore: cast_nullable_to_non_nullable
          : precision as int,
      showVolInTips: showVolInTips == const $CopyWithPlaceholder()
          ? _value.showVolInTips
          // ignore: cast_nullable_to_non_nullable
          : showVolInTips as bool,
      compactDisplay: compactDisplay == const $CopyWithPlaceholder()
          ? _value.compactDisplay
          // ignore: cast_nullable_to_non_nullable
          : compactDisplay as bool,
    );
  }
}

extension $VolumeDisplayConfigCopyWith on VolumeDisplayConfig {
  /// Returns a callable class that can be used as follows: `instanceOfVolumeDisplayConfig.copyWith(...)` or like so:`instanceOfVolumeDisplayConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VolumeDisplayConfigCWProxy get copyWith =>
      _$VolumeDisplayConfigCWProxyImpl(this);
}

abstract class _$VolumeParamCWProxy {
  VolumeParam showInMain(bool showInMain);

  VolumeParam heightRatio(double heightRatio);

  VolumeParam volume(VolumeBarConfig volume);

  VolumeParam display(VolumeDisplayConfig display);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VolumeParam(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VolumeParam(...).copyWith(id: 12, name: "My name")
  /// ````
  VolumeParam call({
    bool showInMain,
    double heightRatio,
    VolumeBarConfig volume,
    VolumeDisplayConfig display,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVolumeParam.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVolumeParam.copyWith.fieldName(...)`
class _$VolumeParamCWProxyImpl implements _$VolumeParamCWProxy {
  const _$VolumeParamCWProxyImpl(this._value);

  final VolumeParam _value;

  @override
  VolumeParam showInMain(bool showInMain) => this(showInMain: showInMain);

  @override
  VolumeParam heightRatio(double heightRatio) => this(heightRatio: heightRatio);

  @override
  VolumeParam volume(VolumeBarConfig volume) => this(volume: volume);

  @override
  VolumeParam display(VolumeDisplayConfig display) => this(display: display);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VolumeParam(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VolumeParam(...).copyWith(id: 12, name: "My name")
  /// ````
  VolumeParam call({
    Object? showInMain = const $CopyWithPlaceholder(),
    Object? heightRatio = const $CopyWithPlaceholder(),
    Object? volume = const $CopyWithPlaceholder(),
    Object? display = const $CopyWithPlaceholder(),
  }) {
    return VolumeParam(
      showInMain: showInMain == const $CopyWithPlaceholder()
          ? _value.showInMain
          // ignore: cast_nullable_to_non_nullable
          : showInMain as bool,
      heightRatio: heightRatio == const $CopyWithPlaceholder()
          ? _value.heightRatio
          // ignore: cast_nullable_to_non_nullable
          : heightRatio as double,
      volume: volume == const $CopyWithPlaceholder()
          ? _value.volume
          // ignore: cast_nullable_to_non_nullable
          : volume as VolumeBarConfig,
      display: display == const $CopyWithPlaceholder()
          ? _value.display
          // ignore: cast_nullable_to_non_nullable
          : display as VolumeDisplayConfig,
    );
  }
}

extension $VolumeParamCopyWith on VolumeParam {
  /// Returns a callable class that can be used as follows: `instanceOfVolumeParam.copyWith(...)` or like so:`instanceOfVolumeParam.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VolumeParamCWProxy get copyWith => _$VolumeParamCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VolumeBarConfig _$VolumeBarConfigFromJson(Map<String, dynamic> json) =>
    VolumeBarConfig(
      useTrendColor: json['useTrendColor'] as bool? ?? true,
      bullishColor: json['bullishColor'] == null
          ? const Color(0xff4caf50)
          : const ColorConverter().fromJson(json['bullishColor'] as String),
      bearishColor: json['bearishColor'] == null
          ? const Color(0xfff44336)
          : const ColorConverter().fromJson(json['bearishColor'] as String),
      opacity: (json['opacity'] as num?)?.toDouble() ?? 0.6,
    );

Map<String, dynamic> _$VolumeBarConfigToJson(VolumeBarConfig instance) =>
    <String, dynamic>{
      'useTrendColor': instance.useTrendColor,
      'bullishColor': const ColorConverter().toJson(instance.bullishColor),
      'bearishColor': const ColorConverter().toJson(instance.bearishColor),
      'opacity': instance.opacity,
    };

VolumeDisplayConfig _$VolumeDisplayConfigFromJson(Map<String, dynamic> json) =>
    VolumeDisplayConfig(
      precision: (json['precision'] as num?)?.toInt() ?? 0,
      showVolInTips: json['showVolInTips'] as bool? ?? true,
      compactDisplay: json['compactDisplay'] as bool? ?? true,
    );

Map<String, dynamic> _$VolumeDisplayConfigToJson(
        VolumeDisplayConfig instance) =>
    <String, dynamic>{
      'precision': instance.precision,
      'showVolInTips': instance.showVolInTips,
      'compactDisplay': instance.compactDisplay,
    };

VolumeParam _$VolumeParamFromJson(Map<String, dynamic> json) => VolumeParam(
      showInMain: json['showInMain'] as bool? ?? true,
      heightRatio: (json['heightRatio'] as num?)?.toDouble() ?? 0.3,
      volume: json['volume'] == null
          ? const VolumeBarConfig()
          : VolumeBarConfig.fromJson(json['volume'] as Map<String, dynamic>),
      display: json['display'] == null
          ? const VolumeDisplayConfig()
          : VolumeDisplayConfig.fromJson(
              json['display'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VolumeParamToJson(VolumeParam instance) =>
    <String, dynamic>{
      'showInMain': instance.showInMain,
      'heightRatio': instance.heightRatio,
      'volume': instance.volume.toJson(),
      'display': instance.display.toJson(),
    };
