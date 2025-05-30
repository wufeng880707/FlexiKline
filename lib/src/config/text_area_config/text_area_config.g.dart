// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_area_config.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TextAreaConfigCWProxy {
  TextAreaConfig style(TextStyle style);

  TextAreaConfig textAlign(TextAlign textAlign);

  TextAreaConfig strutStyle(StrutStyle? strutStyle);

  TextAreaConfig textWidth(double? textWidth);

  TextAreaConfig minWidth(double? minWidth);

  TextAreaConfig maxWidth(double? maxWidth);

  TextAreaConfig maxLines(int? maxLines);

  TextAreaConfig background(Color? background);

  TextAreaConfig padding(EdgeInsets? padding);

  TextAreaConfig border(BorderSide? border);

  TextAreaConfig borderRadius(BorderRadius? borderRadius);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TextAreaConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TextAreaConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  TextAreaConfig call({
    TextStyle style,
    TextAlign textAlign,
    StrutStyle? strutStyle,
    double? textWidth,
    double? minWidth,
    double? maxWidth,
    int? maxLines,
    Color? background,
    EdgeInsets? padding,
    BorderSide? border,
    BorderRadius? borderRadius,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTextAreaConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTextAreaConfig.copyWith.fieldName(...)`
class _$TextAreaConfigCWProxyImpl implements _$TextAreaConfigCWProxy {
  const _$TextAreaConfigCWProxyImpl(this._value);

  final TextAreaConfig _value;

  @override
  TextAreaConfig style(TextStyle style) => this(style: style);

  @override
  TextAreaConfig textAlign(TextAlign textAlign) => this(textAlign: textAlign);

  @override
  TextAreaConfig strutStyle(StrutStyle? strutStyle) =>
      this(strutStyle: strutStyle);

  @override
  TextAreaConfig textWidth(double? textWidth) => this(textWidth: textWidth);

  @override
  TextAreaConfig minWidth(double? minWidth) => this(minWidth: minWidth);

  @override
  TextAreaConfig maxWidth(double? maxWidth) => this(maxWidth: maxWidth);

  @override
  TextAreaConfig maxLines(int? maxLines) => this(maxLines: maxLines);

  @override
  TextAreaConfig background(Color? background) => this(background: background);

  @override
  TextAreaConfig padding(EdgeInsets? padding) => this(padding: padding);

  @override
  TextAreaConfig border(BorderSide? border) => this(border: border);

  @override
  TextAreaConfig borderRadius(BorderRadius? borderRadius) =>
      this(borderRadius: borderRadius);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TextAreaConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TextAreaConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  TextAreaConfig call({
    Object? style = const $CopyWithPlaceholder(),
    Object? textAlign = const $CopyWithPlaceholder(),
    Object? strutStyle = const $CopyWithPlaceholder(),
    Object? textWidth = const $CopyWithPlaceholder(),
    Object? minWidth = const $CopyWithPlaceholder(),
    Object? maxWidth = const $CopyWithPlaceholder(),
    Object? maxLines = const $CopyWithPlaceholder(),
    Object? background = const $CopyWithPlaceholder(),
    Object? padding = const $CopyWithPlaceholder(),
    Object? border = const $CopyWithPlaceholder(),
    Object? borderRadius = const $CopyWithPlaceholder(),
  }) {
    return TextAreaConfig(
      style: style == const $CopyWithPlaceholder()
          ? _value.style
          // ignore: cast_nullable_to_non_nullable
          : style as TextStyle,
      textAlign: textAlign == const $CopyWithPlaceholder()
          ? _value.textAlign
          // ignore: cast_nullable_to_non_nullable
          : textAlign as TextAlign,
      strutStyle: strutStyle == const $CopyWithPlaceholder()
          ? _value.strutStyle
          // ignore: cast_nullable_to_non_nullable
          : strutStyle as StrutStyle?,
      textWidth: textWidth == const $CopyWithPlaceholder()
          ? _value.textWidth
          // ignore: cast_nullable_to_non_nullable
          : textWidth as double?,
      minWidth: minWidth == const $CopyWithPlaceholder()
          ? _value.minWidth
          // ignore: cast_nullable_to_non_nullable
          : minWidth as double?,
      maxWidth: maxWidth == const $CopyWithPlaceholder()
          ? _value.maxWidth
          // ignore: cast_nullable_to_non_nullable
          : maxWidth as double?,
      maxLines: maxLines == const $CopyWithPlaceholder()
          ? _value.maxLines
          // ignore: cast_nullable_to_non_nullable
          : maxLines as int?,
      background: background == const $CopyWithPlaceholder()
          ? _value.background
          // ignore: cast_nullable_to_non_nullable
          : background as Color?,
      padding: padding == const $CopyWithPlaceholder()
          ? _value.padding
          // ignore: cast_nullable_to_non_nullable
          : padding as EdgeInsets?,
      border: border == const $CopyWithPlaceholder()
          ? _value.border
          // ignore: cast_nullable_to_non_nullable
          : border as BorderSide?,
      borderRadius: borderRadius == const $CopyWithPlaceholder()
          ? _value.borderRadius
          // ignore: cast_nullable_to_non_nullable
          : borderRadius as BorderRadius?,
    );
  }
}

extension $TextAreaConfigCopyWith on TextAreaConfig {
  /// Returns a callable class that can be used as follows: `instanceOfTextAreaConfig.copyWith(...)` or like so:`instanceOfTextAreaConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TextAreaConfigCWProxy get copyWith => _$TextAreaConfigCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TextAreaConfig _$TextAreaConfigFromJson(Map<String, dynamic> json) =>
    TextAreaConfig(
      style: json['style'] == null
          ? const TextStyle(
              fontSize: defaulTextSize,
              overflow: TextOverflow.ellipsis,
              height: defaultTextHeight)
          : const TextStyleConverter()
              .fromJson(json['style'] as Map<String, dynamic>),
      textAlign: json['textAlign'] == null
          ? TextAlign.start
          : const TextAlignConvert().fromJson(json['textAlign'] as String),
      strutStyle: _$JsonConverterFromJson<Map<String, dynamic>, StrutStyle>(
          json['strutStyle'], const StrutStyleConverter().fromJson),
      textWidth: (json['textWidth'] as num?)?.toDouble(),
      minWidth: (json['minWidth'] as num?)?.toDouble(),
      maxWidth: (json['maxWidth'] as num?)?.toDouble(),
      maxLines: (json['maxLines'] as num?)?.toInt(),
      background: _$JsonConverterFromJson<String, Color>(
          json['background'], const ColorConverter().fromJson),
      padding: _$JsonConverterFromJson<Map<String, dynamic>, EdgeInsets>(
          json['padding'], const EdgeInsetsConverter().fromJson),
      border: _$JsonConverterFromJson<Map<String, dynamic>, BorderSide>(
          json['border'], const BorderSideConvert().fromJson),
      borderRadius: _$JsonConverterFromJson<Map<String, dynamic>, BorderRadius>(
          json['borderRadius'], const BorderRadiusConverter().fromJson),
    );

Map<String, dynamic> _$TextAreaConfigToJson(TextAreaConfig instance) =>
    <String, dynamic>{
      'style': const TextStyleConverter().toJson(instance.style),
      'textAlign': const TextAlignConvert().toJson(instance.textAlign),
      if (_$JsonConverterToJson<Map<String, dynamic>, StrutStyle>(
              instance.strutStyle, const StrutStyleConverter().toJson)
          case final value?)
        'strutStyle': value,
      if (instance.textWidth case final value?) 'textWidth': value,
      if (instance.minWidth case final value?) 'minWidth': value,
      if (instance.maxWidth case final value?) 'maxWidth': value,
      if (instance.maxLines case final value?) 'maxLines': value,
      if (_$JsonConverterToJson<String, Color>(
              instance.background, const ColorConverter().toJson)
          case final value?)
        'background': value,
      if (_$JsonConverterToJson<Map<String, dynamic>, EdgeInsets>(
              instance.padding, const EdgeInsetsConverter().toJson)
          case final value?)
        'padding': value,
      if (_$JsonConverterToJson<Map<String, dynamic>, BorderSide>(
              instance.border, const BorderSideConvert().toJson)
          case final value?)
        'border': value,
      if (_$JsonConverterToJson<Map<String, dynamic>, BorderRadius>(
              instance.borderRadius, const BorderRadiusConverter().toJson)
          case final value?)
        'borderRadius': value,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
