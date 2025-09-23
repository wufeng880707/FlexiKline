// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_bar_config.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TimeBarConfigCWProxy {
  TimeBarConfig key(String key);

  TimeBarConfig bar(String bar);

  TimeBarConfig multiplier(int multiplier);

  TimeBarConfig timeUnit(TimeUnit timeUnit);

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
    String key,
    String bar,
    int multiplier,
    TimeUnit timeUnit,
    String showName,
    bool isUtc,
    String locale,
    int sortOrder,
    bool intraDay,
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
  TimeBarConfig multiplier(int multiplier) => this(multiplier: multiplier);

  @override
  TimeBarConfig timeUnit(TimeUnit timeUnit) => this(timeUnit: timeUnit);

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
    Object? multiplier = const $CopyWithPlaceholder(),
    Object? timeUnit = const $CopyWithPlaceholder(),
    Object? showName = const $CopyWithPlaceholder(),
    Object? isUtc = const $CopyWithPlaceholder(),
    Object? locale = const $CopyWithPlaceholder(),
    Object? sortOrder = const $CopyWithPlaceholder(),
    Object? intraDay = const $CopyWithPlaceholder(),
    Object? nextUpdateCalculator = const $CopyWithPlaceholder(),
  }) {
    return TimeBarConfig(
      key: key == const $CopyWithPlaceholder()
          ? _value.key
          // ignore: cast_nullable_to_non_nullable
          : key as String,
      bar: bar == const $CopyWithPlaceholder()
          ? _value.bar
          // ignore: cast_nullable_to_non_nullable
          : bar as String,
      multiplier: multiplier == const $CopyWithPlaceholder()
          ? _value.multiplier
          // ignore: cast_nullable_to_non_nullable
          : multiplier as int,
      timeUnit: timeUnit == const $CopyWithPlaceholder()
          ? _value.timeUnit
          // ignore: cast_nullable_to_non_nullable
          : timeUnit as TimeUnit,
      showName: showName == const $CopyWithPlaceholder()
          ? _value.showName
          // ignore: cast_nullable_to_non_nullable
          : showName as String,
      isUtc: isUtc == const $CopyWithPlaceholder()
          ? _value.isUtc
          // ignore: cast_nullable_to_non_nullable
          : isUtc as bool,
      locale: locale == const $CopyWithPlaceholder()
          ? _value.locale
          // ignore: cast_nullable_to_non_nullable
          : locale as String,
      sortOrder: sortOrder == const $CopyWithPlaceholder()
          ? _value.sortOrder
          // ignore: cast_nullable_to_non_nullable
          : sortOrder as int,
      intraDay: intraDay == const $CopyWithPlaceholder()
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
      multiplier: (json['multiplier'] as num).toInt(),
      timeUnit: $enumDecode(_$TimeUnitEnumMap, json['timeUnit']),
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
      'multiplier': instance.multiplier,
      'timeUnit': _$TimeUnitEnumMap[instance.timeUnit]!,
      'showName': instance.showName,
      'isUtc': instance.isUtc,
      'locale': instance.locale,
      'sortOrder': instance.sortOrder,
      'intraDay': instance.intraDay,
    };

const _$TimeUnitEnumMap = {
  TimeUnit.year: 'year',
  TimeUnit.month: 'month',
  TimeUnit.week: 'week',
  TimeUnit.day: 'day',
  TimeUnit.hour: 'hour',
  TimeUnit.minute: 'minute',
  TimeUnit.second: 'second',
  TimeUnit.millisecond: 'millisecond',
  TimeUnit.microsecond: 'microsecond',
};
