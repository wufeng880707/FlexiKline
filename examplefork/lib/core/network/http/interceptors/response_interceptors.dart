import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../response/response_data.dart';

class ResponseInterceptor extends Interceptor {
  final Ref ref;

  ResponseInterceptor(this.ref);

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.statusCode == 200) {
      final adaptedSuccessRs = adapterSuccessData(response);
      handler.next(adaptedSuccessRs);
    } else {
      final adaptedErrorRs = adapterErrorData(response);
      handler.next(adaptedErrorRs);
    }
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response != null) {
      final adaptedErrorRs = adapterErrorData(err.response!);
      handler.resolve(adaptedErrorRs);
      return;
    }
    // 处理网络连接失败等情况
    final response = Response(
      requestOptions: err.requestOptions,
      statusCode: 200,
      data: ResponseData(code: '-1', msg: '错误', success: false).toMap(),
    );
    handler.resolve(response);
  }

  Response adapterErrorData(Response response) {
    //用户未登录或会话失效
    if (response.statusCode == 10021) {
      // ref.read(authProvider.notifier).updateToken('');
      // ref.read(authProvider.notifier).updateUserInfo(null);
    } else if (response.statusCode == 401) {
      // onBackLogin();
    } else if (response.data != null && response.data is Map) {
      final status = response.data['status'];
      ResponseData responseData = ResponseData(
        code: status is int ? status.toString() : (status ?? ''),
        msg: response.data['error'] ?? '',
        success: false,
      );
      response.data = responseData.toMap();
    } else {
      ResponseData responseData = ResponseData(
        code: response.statusCode.toString(),
        msg: response.statusMessage ?? '',
        success: false,
      );
      response.data = responseData.toMap();
    }
    response.statusCode = 200;
    return response;
  }

  Response adapterSuccessData(Response response) {
    if (response.data != null && response.data is Map) {
      if (response.data['code'] == '10002') {}
    }
    return response;
  }

  // void onBackLogin() {
  //   ref.read(authProvider.notifier).clearAuthData();
  //   final lastRoute = RouterOutEx.currentRouterPath();
  //   if (lastRoute != PageNames.login) {
  //     RouterUtils.popUntilPath(PageNames.main);
  //     RouterUtils.pushTopNoRepeat(PageNames.login);
  //   }
  // }
}
