// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_bar_config.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TimeBarConfigCWProxy {
  TimeBarConfig key(String key);

  TimeBarConfig bar(String bar);

  TimeBarConfig milliseconds(int milliseconds);

  TimeBarConfig multiplier(int multiplier);

  TimeBarConfig timespan(Timespan timespan);

  TimeBarConfig showName(String showName);

  TimeBarConfig isUtc(bool isUtc);

  TimeBarConfig locale(String locale);

  TimeBarConfig sortOrder(int sortOrder);

  TimeBarConfig intraDay(bool intraDay);

  TimeBarConfig nextUpdateCalculator(
      DateTime Function(DateTime, bool)? nextUpdateCalculator);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TimeBarConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TimeBarConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  TimeBarConfig call({
    String? key,
    String? bar,
    int? milliseconds,
    int? multiplier,
    Timespan? timespan,
    String? showName,
    bool? isUtc,
    String? locale,
    int? sortOrder,
    bool? intraDay,
    DateTime Function(DateTime, bool)? nextUpdateCalculator,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTimeBarConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTimeBarConfig.copyWith.fieldName(...)`
class _$TimeBarConfigCWProxyImpl implements _$TimeBarConfigCWProxy {
  const _$TimeBarConfigCWProxyImpl(this._value);

  final TimeBarConfig _value;

  @override
  TimeBarConfig key(String key) => this(key: key);

  @override
  TimeBarConfig bar(String bar) => this(bar: bar);

  @override
  TimeBarConfig milliseconds(int milliseconds) =>
      this(milliseconds: milliseconds);

  @override
  TimeBarConfig multiplier(int multiplier) => this(multiplier: multiplier);

  @override
  TimeBarConfig timespan(Timespan timespan) => this(timespan: timespan);

  @override
  TimeBarConfig showName(String showName) => this(showName: showName);

  @override
  TimeBarConfig isUtc(bool isUtc) => this(isUtc: isUtc);

  @override
  TimeBarConfig locale(String locale) => this(locale: locale);

  @override
  TimeBarConfig sortOrder(int sortOrder) => this(sortOrder: sortOrder);

  @override
  TimeBarConfig intraDay(bool intraDay) => this(intraDay: intraDay);

  @override
  TimeBarConfig nextUpdateCalculator(
          DateTime Function(DateTime, bool)? nextUpdateCalculator) =>
      this(nextUpdateCalculator: nextUpdateCalculator);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TimeBarConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TimeBarConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  TimeBarConfig call({
    Object? key = const $CopyWithPlaceholder(),
    Object? bar = const $CopyWithPlaceholder(),
    Object? milliseconds = const $CopyWithPlaceholder(),
    Object? multiplier = const $CopyWithPlaceholder(),
    Object? timespan = const $CopyWithPlaceholder(),
    Object? showName = const $CopyWithPlaceholder(),
    Object? isUtc = const $CopyWithPlaceholder(),
    Object? locale = const $CopyWithPlaceholder(),
    Object? sortOrder = const $CopyWithPlaceholder(),
    Object? intraDay = const $CopyWithPlaceholder(),
    Object? nextUpdateCalculator = const $CopyWithPlaceholder(),
  }) {
    return TimeBarConfig(
      key: key == const $CopyWithPlaceholder() || key == null
          ? _value.key
          // ignore: cast_nullable_to_non_nullable
          : key as String,
      bar: bar == const $CopyWithPlaceholder() || bar == null
          ? _value.bar
          // ignore: cast_nullable_to_non_nullable
          : bar as String,
      milliseconds:
          milliseconds == const $CopyWithPlaceholder() || milliseconds == null
              ? _value.milliseconds
              // ignore: cast_nullable_to_non_nullable
              : milliseconds as int,
      multiplier:
          multiplier == const $CopyWithPlaceholder() || multiplier == null
              ? _value.multiplier
              // ignore: cast_nullable_to_non_nullable
              : multiplier as int,
      timespan: timespan == const $CopyWithPlaceholder() || timespan == null
          ? _value.timespan
          // ignore: cast_nullable_to_non_nullable
          : timespan as Timespan,
      showName: showName == const $CopyWithPlaceholder() || showName == null
          ? _value.showName
          // ignore: cast_nullable_to_non_nullable
          : showName as String,
      isUtc: isUtc == const $CopyWithPlaceholder() || isUtc == null
          ? _value.isUtc
          // ignore: cast_nullable_to_non_nullable
          : isUtc as bool,
      locale: locale == const $CopyWithPlaceholder() || locale == null
          ? _value.locale
          // ignore: cast_nullable_to_non_nullable
          : locale as String,
      sortOrder: sortOrder == const $CopyWithPlaceholder() || sortOrder == null
          ? _value.sortOrder
          // ignore: cast_nullable_to_non_nullable
          : sortOrder as int,
      intraDay: intraDay == const $CopyWithPlaceholder() || intraDay == null
          ? _value.intraDay
          // ignore: cast_nullable_to_non_nullable
          : intraDay as bool,
      nextUpdateCalculator: nextUpdateCalculator == const $CopyWithPlaceholder()
          ? _value.nextUpdateCalculator
          // ignore: cast_nullable_to_non_nullable
          : nextUpdateCalculator as DateTime Function(DateTime, bool)?,
    );
  }
}

extension $TimeBarConfigCopyWith on TimeBarConfig {
  /// Returns a callable class that can be used as follows: `instanceOfTimeBarConfig.copyWith(...)` or like so:`instanceOfTimeBarConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TimeBarConfigCWProxy get copyWith => _$TimeBarConfigCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeBarConfig _$TimeBarConfigFromJson(Map<String, dynamic> json) =>
    TimeBarConfig(
      key: json['key'] as String,
      bar: json['bar'] as String,
      milliseconds: (json['milliseconds'] as num).toInt(),
      multiplier: (json['multiplier'] as num).toInt(),
      timespan: $enumDecode(_$TimespanEnumMap, json['timespan']),
      showName: json['showName'] as String,
      isUtc: json['isUtc'] as bool? ?? false,
      locale: json['locale'] as String? ?? 'en',
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      intraDay: json['intraDay'] as bool? ?? false,
    );

Map<String, dynamic> _$TimeBarConfigToJson(TimeBarConfig instance) =>
    <String, dynamic>{
      'key': instance.key,
      'bar': instance.bar,
      'milliseconds': instance.milliseconds,
      'multiplier': instance.multiplier,
      'timespan': _$TimespanEnumMap[instance.timespan]!,
      'showName': instance.showName,
      'isUtc': instance.isUtc,
      'locale': instance.locale,
      'sortOrder': instance.sortOrder,
      'intraDay': instance.intraDay,
    };

const _$TimespanEnumMap = {
  Timespan.second: 'second',
  Timespan.minute: 'minute',
  Timespan.hour: 'hour',
  Timespan.day: 'day',
  Timespan.week: 'week',
  Timespan.month: 'month',
  Timespan.quarter: 'quarter',
  Timespan.year: 'year',
};
