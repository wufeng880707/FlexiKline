import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 用于监控和调试 Provider 状态的变化
class AppProviderObserver extends ProviderObserver {
  AppProviderObserver();

  /// 方法参数说明：
  ///   - provider: 发生变化的 Provider 实例
  ///   - previousValue: 变化前的旧值
  ///   - newValue: 变化后的新值
  ///   - container: Provider 容器实例
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) async {
    if (kDebugMode) {
      // 如果未指定名字, 或名字以下划线开头, 不打印日志.
      if (provider.name == null || provider.name!.startsWith('_')) return;
      debugPrint(
        'PROVIDER    : ${provider.name ?? '<NO NAME>'}\n'
        '  Type      : ${provider.runtimeType}\n'
        '  Old value : $previousValue\n'
        '  New value : $newValue',
      );
    }
  }
}
