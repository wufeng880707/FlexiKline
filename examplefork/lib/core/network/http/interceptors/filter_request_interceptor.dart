import 'package:dio/dio.dart';

class FilteredLogInterceptor extends Interceptor {
  final List<String> excludedPaths;
  final Interceptor inner;

  FilteredLogInterceptor({required this.excludedPaths, Interceptor? inner}) : inner = inner ?? Interceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_shouldLog(options)) {
      inner.onRequest(options, handler);
    } else {
      handler.next(options); // 跳过打印
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (_shouldLog(response.requestOptions)) {
      inner.onResponse(response, handler);
    } else {
      handler.next(response);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_shouldLog(err.requestOptions)) {
      inner.onError(err, handler);
    } else {
      handler.next(err);
    }
  }

  bool _shouldLog(RequestOptions options) {
    return !excludedPaths.any((excluded) => options.path.contains(excluded));
  }
}
