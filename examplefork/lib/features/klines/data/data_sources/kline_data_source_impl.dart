import 'package:dio/dio.dart';
import 'package:example/core/network/http/response/response_data.dart';
import 'package:example/features/klines/data/repositories/kline_data_source_repository.dart';
import 'package:example/features/klines/data/request/kline_data_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/http/dio_provider.dart';

// 定义 Provider
final klineDataSourceProvider = Provider<KlineDataSourceRepository>((ref) {
  final dio = ref.read(dioProvider);
  return KlineDataSourceImpl(dio);
});

class KlineDataSourceImpl extends KlineDataSourceRepository {
  final KlineDataClient _apiClient;

  KlineDataSourceImpl(Dio dio) : _apiClient = KlineDataClient(dio);

  @override
  Future<ResponseData> publicMarketKlineRequest(Map<String, dynamic> parameter) {
    return _apiClient.publicMarketKlineNetRequest(parameter);
  }
}
