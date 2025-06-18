// @Title:  kline_data_client
// @Author: tomodel
// @Update: 2025/6/5 19:13
// @Description:

import 'package:dio/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

import '../../../../core/network/http/response/response_data.dart';

part 'kline_data_client.g.dart';

@RestApi(baseUrl: 'https://kline.aivora.com/')
abstract class KlineDataClient {
  // 注意类名拼写一致性
  factory KlineDataClient(Dio dio, {String baseUrl}) = _KlineDataClient;

  @GET('/v1/future/market/kline')
  Future<ResponseData> publicMarketKlineNetRequest(@Queries() Map<String, dynamic> queries);
}
