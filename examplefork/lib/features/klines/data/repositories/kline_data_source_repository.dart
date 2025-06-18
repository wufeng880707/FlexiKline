import '../../../../core/network/http/response/response_data.dart';

abstract class KlineDataSourceRepository {
  Future<ResponseData> publicMarketKlineRequest(Map<String, dynamic> parameter);
}
