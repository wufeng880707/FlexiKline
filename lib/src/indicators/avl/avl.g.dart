// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avl.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AVLIndicatorCWProxy {
  AVLIndicator zIndex(int zIndex);

  AVLIndicator height(double height);

  AVLIndicator padding(EdgeInsets padding);

  AVLIndicator calcParam(AVLParam calcParam);

  AVLIndicator tipsPadding(EdgeInsets tipsPadding);

  AVLIndicator tickCount(int tickCount);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AVLIndicator(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AVLIndicator(...).copyWith(id: 12, name: "My name")
  /// ````
  AVLIndicator call({
    int zIndex,
    double height,
    EdgeInsets padding,
    AVLParam calcParam,
    EdgeInsets tipsPadding,
    int tickCount,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAVLIndicator.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAVLIndicator.copyWith.fieldName(...)`
class _$AVLIndicatorCWProxyImpl implements _$AVLIndicatorCWProxy {
  const _$AVLIndicatorCWProxyImpl(this._value);

  final AVLIndicator _value;

  @override
  AVLIndicator zIndex(int zIndex) => this(zIndex: zIndex);

  @override
  AVLIndicator height(double height) => this(height: height);

  @override
  AVLIndicator padding(EdgeInsets padding) => this(padding: padding);

  @override
  AVLIndicator calcParam(AVLParam calcParam) => this(calcParam: calcParam);

  @override
  AVLIndicator tipsPadding(EdgeInsets tipsPadding) => this(tipsPadding: tipsPadding);

  @override
  AVLIndicator tickCount(int tickCount) => this(tickCount: tickCount);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AVLIndicator(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AVLIndicator(...).copyWith(id: 12, name: "My name")
  /// ````
  AVLIndicator call({
    Object? zIndex = const $CopyWithPlaceholder(),
    Object? height = const $CopyWithPlaceholder(),
    Object? padding = const $CopyWithPlaceholder(),
    Object? calcParam = const $CopyWithPlaceholder(),
    Object? tipsPadding = const $CopyWithPlaceholder(),
    Object? tickCount = const $CopyWithPlaceholder(),
  }) {
    return AVLIndicator(
      zIndex: zIndex == const $CopyWithPlaceholder()
          ? _value.zIndex
          // ignore: cast_nullable_to_non_nullable
          : zIndex as int,
      height: height == const $CopyWithPlaceholder()
          ? _value.height
          // ignore: cast_nullable_to_non_nullable
          : height as double,
      padding: padding == const $CopyWithPlaceholder()
          ? _value.padding
          // ignore: cast_nullable_to_non_nullable
          : padding as EdgeInsets,
      calcParam: calcParam == const $CopyWithPlaceholder()
          ? _value.calcParam
          // ignore: cast_nullable_to_non_nullable
          : calcParam as AVLParam,
      tipsPadding: tipsPadding == const $CopyWithPlaceholder()
          ? _value.tipsPadding
          // ignore: cast_nullable_to_non_nullable
          : tipsPadding as EdgeInsets,
      tickCount: tickCount == const $CopyWithPlaceholder()
          ? _value.tickCount
          // ignore: cast_nullable_to_non_nullable
          : tickCount as int,
    );
  }
}

extension $AVLIndicatorCopyWith on AVLIndicator {
  /// Returns a callable class that can be used as follows: `instanceOfAVLIndicator.copyWith(...)` or like so:`instanceOfAVLIndicator.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AVLIndicatorCWProxy get copyWith => _$AVLIndicatorCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AVLIndicator _$AVLIndicatorFromJson(Map<String, dynamic> json) => AVLIndicator(
      zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
      height: (json['height'] as num).toDouble(),
      padding: json['padding'] == null
          ? defaultMainIndicatorPadding
          : const EdgeInsetsConverter().fromJson(json['padding'] as Map<String, dynamic>),
      calcParam:
          json['calcParam'] == null ? const AVLParam() : AVLParam.fromJson(json['calcParam'] as Map<String, dynamic>),
      tipsPadding: const EdgeInsetsConverter().fromJson(json['tipsPadding'] as Map<String, dynamic>),
      tickCount: (json['tickCount'] as num?)?.toInt() ?? defaultSubTickCount,
    );

Map<String, dynamic> _$AVLIndicatorToJson(AVLIndicator instance) => <String, dynamic>{
      'height': instance.height,
      'padding': const EdgeInsetsConverter().toJson(instance.padding),
      'zIndex': instance.zIndex,
      'calcParam': instance.calcParam.toJson(),
      'tipsPadding': const EdgeInsetsConverter().toJson(instance.tipsPadding),
      'tickCount': instance.tickCount,
    };
