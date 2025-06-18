import 'package:dio/dio.dart';

abstract class AppException implements Exception {
  final int code;
  final String message;

  AppException({required this.code, required this.message});
}

// 网络层异常
class NetworkException extends AppException {
  NetworkException({required super.code, required super.message});
}

// 服务器业务异常（如 401 未登录）
class ServerException extends AppException {
  ServerException({required super.code, required super.message});
}

// 本地解析异常
class ParseException extends AppException {
  ParseException({required super.code, required super.message});
}

// 统一包裹请求方法
Future<T> safeRequest<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (e) {
    // throw _convertDioError(e); // 转换为自定义异常
    throw Exception(e); // 转换为自定义异常
  } on FormatException catch (e) {
    throw ParseException(code: -1, message: '数据解析失败');
  } catch (e) {
    throw Exception(e); // 转换为自定义异常
    // throw AppException(code: -999, message: '未知错误');
  }
}
