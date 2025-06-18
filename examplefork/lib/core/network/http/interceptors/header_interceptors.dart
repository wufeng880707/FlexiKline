import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HeaderInterceptor extends Interceptor {
  final Ref ref;

  HeaderInterceptor(this.ref);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 获取认证token
    // final authState = ref.read(authProvider);
    // final token = authState.token;
    //
    // if (token != null && token.isNotEmpty) {
    //   options.headers['exchange-token'] = token;
    // }

    options.headers[Headers.acceptHeader] = 'application/json, text/plain, */*';
    options.headers[Headers.contentTypeHeader] = 'application/json';
    options.headers['clientType'] = (Platform.isIOS ? "ios" : "android");
    options.headers['platform'] = (Platform.isIOS ? "iOS" : "Android");
    options.headers['exchange-client'] = (Platform.isIOS ? "ios" : "android");
    // options.headers['appVersion'] = versionName;

    // final local = GlobalData.getAppLocale();
    // if (local != null) {
    //   final String localeString = LocaleUtil.toLocaleString(local);
    //   options.headers['language'] = localeString;
    //   options.headers["accept-language"] = localeString;
    //   options.headers["exchange-language"] = localeString.replaceAll('-', '_');
    // }

    // 添加 Content-Length
    if (options.data != null) {
      final String data = options.data.toString();
      options.headers[Headers.contentLengthHeader] = data.length.toString();
    }

    return handler.next(options);
  }
}
