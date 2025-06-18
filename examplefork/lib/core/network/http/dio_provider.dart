import 'dart:io';

import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'interceptors/filter_request_interceptor.dart';
import 'interceptors/header_interceptors.dart';
import 'interceptors/response_interceptors.dart';

// 定义 Provider
final dioProvider = Provider<Dio>((ref) {
  final options = BaseOptions(
    connectTimeout: const Duration(milliseconds: 15000), // 连接超时时间
    receiveTimeout: const Duration(milliseconds: 15000), // 响应超时时间
  );

  final dio = Dio(options);
  if (kDebugMode) {
    final List<String> excludedPaths = [
      'fe-co-api/user/get_user_config',
      'fe-co-api/position/get_assets_list',
      'fe-co-api/order/trigger_order_list',
      'fe-co-api/order/current_order_list',
      'fe-ex-api/message/v4/get_no_read_message_count',
      'fe-ex-api/finance/total_account_balance',
      'fe-ex-api/finance/v4/account_balance',
    ];
    dio.interceptors.addAll([
      FilteredLogInterceptor(
        excludedPaths: excludedPaths,
        inner: LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
      ),
      FilteredLogInterceptor(
        excludedPaths: excludedPaths,
        inner: CurlLoggerDioInterceptor(printOnSuccess: true),
      ),
    ]);
  }

  dio.interceptors.addAll([HeaderInterceptor(ref), ResponseInterceptor(ref)]);

  return dio;
});
