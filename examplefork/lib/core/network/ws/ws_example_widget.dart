import 'package:example/core/network/ws/ws_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ws_client.dart';

/// WebSocket使用示例Widget
class WsExampleWidget extends ConsumerStatefulWidget {
  const WsExampleWidget({super.key});

  @override
  ConsumerState<WsExampleWidget> createState() => _WsExampleWidgetState();
}

class _WsExampleWidgetState extends ConsumerState<WsExampleWidget> {
  final TextEditingController _symbolController = TextEditingController(text: 'e_btcusdt');
  final TextEditingController _intervalController = TextEditingController(text: '15m');

  @override
  void initState() {
    super.initState();
    // 自动连接WebSocket
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(klineWsServiceProvider).connect();
    });
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _intervalController.dispose();
    ref.read(klineWsServiceProvider).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(wsConnectionStateProvider);
    final messages = ref.watch(wsMessageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket 示例'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(klineWsServiceProvider).connect();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 连接状态显示
          Container(
            padding: const EdgeInsets.all(16),
            child: connectionState.when(
              data: (state) => _buildConnectionStatus(state),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('错误: $error'),
            ),
          ),

          // 控制面板
          _buildControlPanel(),

          // 消息显示区域
          Expanded(
            child: messages.when(
              data: (message) => _buildMessageDisplay(message),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('错误: $error')),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建连接状态显示
  Widget _buildConnectionStatus(WsConnectionState state) {
    Color statusColor;
    String statusText;

    switch (state) {
      case WsConnectionState.connected:
        statusColor = Colors.green;
        statusText = '已连接';
        break;
      case WsConnectionState.connecting:
        statusColor = Colors.orange;
        statusText = '连接中...';
        break;
      case WsConnectionState.reconnecting:
        statusColor = Colors.orange;
        statusText = '重连中...';
        break;
      case WsConnectionState.disconnected:
        statusColor = Colors.grey;
        statusText = '未连接';
        break;
      case WsConnectionState.error:
        statusColor = Colors.red;
        statusText = '连接错误';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// 构建控制面板
  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 交易对输入
          TextField(
            controller: _symbolController,
            decoration: const InputDecoration(
              labelText: '交易对',
              hintText: '例如: e_btcusdt',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // 时间间隔输入
          TextField(
            controller: _intervalController,
            decoration: const InputDecoration(
              labelText: '时间间隔',
              hintText: '例如: 15m, 1h, 1d',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // 操作按钮
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final wsService = ref.read(klineWsServiceProvider);
                    wsService.subscribeKline(_symbolController.text, _intervalController.text);
                  },
                  child: const Text('订阅'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final wsService = ref.read(klineWsServiceProvider);
                    wsService.unsubscribeKline(_symbolController.text, _intervalController.text);
                  },
                  child: const Text('取消订阅'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建消息显示
  Widget _buildMessageDisplay(WsMessage message) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getMessageIcon(message.type), color: _getMessageColor(message.type), size: 20),
              const SizedBox(width: 8),
              Text(
                _getMessageTypeText(message.type),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getMessageColor(message.type),
                ),
              ),
              const Spacer(),
              Text(
                _formatTimestamp(message.timestamp),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('数据: ${message.data}', style: const TextStyle(fontFamily: 'monospace')),
        ],
      ),
    );
  }

  /// 获取消息类型图标
  IconData _getMessageIcon(WsMessageType type) {
    switch (type) {
      case WsMessageType.text:
        return Icons.message;
      case WsMessageType.binary:
        return Icons.data_array;
      case WsMessageType.ping:
        return Icons.send;
      case WsMessageType.pong:
        return Icons.reply;
    }
  }

  /// 获取消息类型颜色
  Color _getMessageColor(WsMessageType type) {
    switch (type) {
      case WsMessageType.text:
        return Colors.blue;
      case WsMessageType.binary:
        return Colors.purple;
      case WsMessageType.ping:
        return Colors.orange;
      case WsMessageType.pong:
        return Colors.green;
    }
  }

  /// 获取消息类型文本
  String _getMessageTypeText(WsMessageType type) {
    switch (type) {
      case WsMessageType.text:
        return '文本消息';
      case WsMessageType.binary:
        return '二进制消息';
      case WsMessageType.ping:
        return 'Ping';
      case WsMessageType.pong:
        return 'Pong';
    }
  }

  /// 格式化时间戳
  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
  }
}
