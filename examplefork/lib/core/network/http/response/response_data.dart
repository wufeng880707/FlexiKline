/**
 * ResponseData 专注于 API 响应的数据结构
 */

import '../constants/http_constant.dart';

// 模型转换器类型
typedef JsonConverter<T> = T Function(dynamic json);

class ResponseData<T> {
  final String code;
  final String msg;
  final bool? success;
  final T? data;

  static String _codeFromJson(dynamic value) {
    if (value is int) {
      return value.toString();
    }
    return value?.toString() ?? '';
  }

  const ResponseData({required this.code, required this.msg, this.success = false, this.data});

  factory ResponseData.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT) {
    try {
      // if (T is IssueDetailsModel) {
      //   logd(
      //     "_codeFromJson(json[HttpConstant.code]):${_codeFromJson(json[HttpConstant.code])}",
      //   );
      //   logd("json[HttpConstant.message]:${json[HttpConstant.message]}");
      //   logd("json[HttpConstant.success]:${json[HttpConstant.success]}");
      //   logd(
      //     "_nullableGenericFromJson(json[HttpConstant.data]):${_nullableGenericFromJson(json[HttpConstant.data], fromJsonT)}",
      //   );
      //   logd("xxxxxxfromJsonT:${fromJsonT(json[HttpConstant.data])}");
      // }

      return ResponseData<T>(
        code: _codeFromJson(json[HttpConstant.code]),
        msg: json[HttpConstant.message] as String,
        success: json[HttpConstant.success] as bool? ?? false,
        data: _nullableGenericFromJson(json[HttpConstant.data], fromJsonT),
      );
    } on TypeError catch (e) {
      return ResponseData<T>(code: '-1', msg: '', success: false, data: null);
    } catch (e) {
      return ResponseData<T>(code: '-1', msg: '12', success: false, data: null);
    }
  }

  factory ResponseData.customError({
    required String code,
    required String msg,
    required bool success,
  }) {
    try {
      return ResponseData(code: code, msg: msg, success: success);
    } catch (e) {
      // 解析失败时返回错误响应
      return ResponseData<T>(code: '-1', msg: '', success: false, data: null);
    }
  }

  factory ResponseData.failureFromJson(Map<String, dynamic> json) {
    return ResponseData(
      code: json[HttpConstant.code],
      msg: json[HttpConstant.message],
      success: json[HttpConstant.success],
      data: null,
    );
  }

  factory ResponseData.successData({required T data}) =>
      ResponseData(code: '0', msg: '', success: true, data: data);

  bool get isSuccess => success! && code == '0';

  Map<String, dynamic> toMap() {
    return {'code': code, 'msg': msg, 'success': success, 'data': data};
  }

  static T? _nullableGenericFromJson<T>(Object? input, T Function(Object? json) fromJson) {
    return input == null ? null : fromJson(input);
  }

  static Object? _nullableGenericToJson<T>(T? input, Object? Function(T value) toJson) {
    return input == null ? null : toJson(input);
  }

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) => <String, dynamic>{
    'code': code,
    'msg': msg,
    'success': success,
    'data': _nullableGenericToJson(data, toJsonT),
  };
}
