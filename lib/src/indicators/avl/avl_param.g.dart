// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avl_param.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AVLParamCWProxy {
  AVLParam dummy(int dummy);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AVLParam(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AVLParam(...).copyWith(id: 12, name: "My name")
  /// ````
  AVLParam call({
    int? dummy,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAVLParam.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAVLParam.copyWith.fieldName(...)`
class _$AVLParamCWProxyImpl implements _$AVLParamCWProxy {
  const _$AVLParamCWProxyImpl(this._value);

  final AVLParam _value;

  @override
  AVLParam dummy(int dummy) => this(dummy: dummy);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AVLParam(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AVLParam(...).copyWith(id: 12, name: "My name")
  /// ````
  AVLParam call({
    Object? dummy = const $CopyWithPlaceholder(),
  }) {
    return AVLParam(
      dummy: dummy == const $CopyWithPlaceholder() || dummy == null
          ? _value.dummy
          // ignore: cast_nullable_to_non_nullable
          : dummy as int,
    );
  }
}

extension $AVLParamCopyWith on AVLParam {
  /// Returns a callable class that can be used as follows: `instanceOfAVLParam.copyWith(...)` or like so:`instanceOfAVLParam.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AVLParamCWProxy get copyWith => _$AVLParamCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AVLParam _$AVLParamFromJson(Map<String, dynamic> json) => AVLParam(
      dummy: (json['dummy'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$AVLParamToJson(AVLParam instance) => <String, dynamic>{
      'dummy': instance.dummy,
    };
