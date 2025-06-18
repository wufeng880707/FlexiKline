import 'dart:async';

/// 初始化任务管理器（支持优先级并行）
class InitializationManager {
  final List<AsyncInitTask> _tasks = [];
  final Map<String, InitResult> _results = {};

  /// 添加初始化任务
  void addTask({
    required String name,
    required Future Function() task,
    int priority = 0,
    int retryCount = 2,
    Duration timeout = const Duration(seconds: 10),
  }) {
    _tasks.add(
      AsyncInitTask(
        name: name,
        task: task,
        priority: priority,
        retryCount: retryCount,
        timeout: timeout,
      ),
    );
  }

  /// 执行所有任务（同优先级并行，不同优先级串行）
  Future<Map<String, InitResult>> execute() async {
    // 按优先级分组
    final groupedTasks = _groupTasksByPriority();

    // 按优先级从高到低排序
    final sortedPriorities = groupedTasks.keys.toList()..sort((a, b) => b.compareTo(a));

    for (final priority in sortedPriorities) {
      final tasks = groupedTasks[priority]!;
      await _executePriorityGroup(tasks);
    }

    return _results;
  }

  /// 按优先级分组任务
  Map<int, List<AsyncInitTask>> _groupTasksByPriority() {
    final groups = <int, List<AsyncInitTask>>{};
    for (final task in _tasks) {
      groups.putIfAbsent(task.priority, () => []).add(task);
    }
    return groups;
  }

  /// 执行同一优先级的任务组（并行）
  Future<void> _executePriorityGroup(List<AsyncInitTask> tasks) async {
    final futures = tasks.map((task) => _runTaskWithRetry(task)).toList();
    await Future.wait(futures);
  }

  /// 执行单个任务（带重试机制）
  Future<void> _runTaskWithRetry(AsyncInitTask task) async {
    int attempts = 0;
    while (attempts <= task.retryCount) {
      try {
        // 带超时的任务执行
        print('Initialization start [${task.name}]');
        final result = await task.task().timeout(
          task.timeout,
          onTimeout: () => throw TimeoutException(""),
        );
        print('Initialization end [${task.name}]');
        _results[task.name] = InitResult.success(result);
        return;
      } catch (e, stack) {
        if (attempts == task.retryCount) {
          _results[task.name] = InitResult.failure(e, stack);
          _logError(task.name, e, stack);
        }
        attempts++;
        await Future.delayed(Duration(seconds: attempts));
      }
    }
  }

  void _logError(String name, Object error, StackTrace stack) {
    print('Initialization failed [$name]: $error\n$stack');
  }
}

/// 初始化任务模型
class AsyncInitTask {
  final String name;
  final Future Function() task;
  final int priority;
  final int retryCount;
  final Duration timeout;

  AsyncInitTask({
    required this.name,
    required this.task,
    required this.priority,
    required this.retryCount,
    required this.timeout,
  });
}

/// 初始化结果模型
class InitResult {
  final dynamic data;
  final Object? error;
  final StackTrace? stack;

  InitResult.success(this.data) : error = null, stack = null;

  InitResult.failure(this.error, this.stack) : data = null;

  bool get isSuccess => error == null;
}
