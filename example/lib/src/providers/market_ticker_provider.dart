// Copyright 2024 Andy.Zhao
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:example/src/config.dart';
import 'package:flexi_formatter/flexi_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/export.dart';
import '../repo/okx_api.dart' as api;

final random = math.Random();

/// 提供单个交易对的市场行情数据
/// 
/// 功能特性：
/// - 支持实时数据更新（当 realTimeUpdateKlineData 为 true 时）
/// - 自动取消请求避免内存泄漏
/// - 参数验证和错误处理
/// - 智能缓存机制
final marketTickerProvider = FutureProvider.autoDispose.family<MarketTicker?, String>(
  (ref, instId) async {
    // 参数验证
    if (instId.isEmpty) {
      throw ArgumentError('instId cannot be empty');
    }

    final cancelToken = CancelToken();
    ref.onDispose(() {
      cancelToken.cancel();
    });

    try {
      final resp = await api.getMarketTicker(
        instId,
        cancelToken: cancelToken,
      );

      // 只在成功获取数据且需要实时更新时才设置定时器
      if (resp.success && realTimeUpdateKlineData) {
        // 使用更合理的更新间隔（1-3秒）
        final delayMs = 1000 + random.nextInt(2000);
        Future.delayed(
          Duration(milliseconds: delayMs),
          () {
            // 使用try-catch避免ref被销毁后的错误
            try {
              ref.invalidateSelf();
            } catch (e) {
              // ref已被销毁，忽略错误
            }
          },
        );
      }

      if (resp.success && resp.data != null) {
        ref.keepAlive();
        return resp.data;
      }
      
      // 记录错误但不抛出异常
      if (!resp.success) {
        // TODO: 可以在这里添加日志记录
        // logger.w('Failed to fetch market ticker for $instId: ${resp.message}');
      }
      
      return null;
    } catch (e) {
      // 如果是取消操作，不需要抛出异常
      if (e is DioException && e.type == DioExceptionType.cancel) {
        return null;
      }
      rethrow;
    }
  },
  name: 'marketTicker',
);

final marketTickerListProvider = FutureProvider.autoDispose.family<List<MarketTicker>, String>(
  (ref, instType) async {
    // 参数验证
    if (instType.isEmpty) {
      throw ArgumentError('instType cannot be empty');
    }

    final cancelToken = CancelToken();
    ref.onDispose(() {
      cancelToken.cancel();
    });

    try {
      final resp = await api.getMarketTickerList(
        instType: instType,
        cancelToken: cancelToken,
      );

      if (resp.success && resp.data?.isNotEmpty == true) {
        ref.keepAlive();
        
        // 创建副本并排序，避免修改原始数据
        final sortedList = List<MarketTicker>.from(resp.data!)
          ..sort(_compareMarketTickersByVolume);
        
        return sortedList;
      }

      // 记录错误但返回空列表而非抛出异常
      if (!resp.success) {
        // TODO: 可以在这里添加日志记录
        // logger.w('Failed to fetch market ticker list for $instType: ${resp.message}');
      }

      return const [];
    } catch (e) {
      // 如果是取消操作，返回空列表
      if (e is DioException && e.type == DioExceptionType.cancel) {
        return const [];
      }
      rethrow;
    }
  },
  name: 'marketTickerList',
);

/// 比较MarketTicker的交易量，用于排序
/// 按24小时交易量降序排列（交易量大的在前）
int _compareMarketTickersByVolume(MarketTicker a, MarketTicker b) {
  final aVol = a.volCcy24h.d;
  final bVol = b.volCcy24h.d;
  
  // 处理空值情况：空值排在后面
  if (aVol == null && bVol == null) return 0;
  if (aVol == null) return 1;
  if (bVol == null) return -1;
  
  // 按交易量降序排列（大的在前）
  return bVol.compareTo(aVol);
}
