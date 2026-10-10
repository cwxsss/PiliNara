/// Demo 14: PullRefresh
///
/// 功能说明：展示 PullToRefreshController 的下拉刷新控制能力
/// （仅覆盖 ohos 支持的接口），包括 setEnabled/beginRefreshing/
/// endRefreshing/isEnabled/isRefreshing。
/// 对应接口：
///   - setEnabled(enabled): Future<void>
///   - beginRefreshing(): Future<void>
///   - endRefreshing(): Future<void>
///   - isEnabled(): Future<bool>
///   - isRefreshing(): Future<bool>

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String _kTag = 'InAppWebView_PullRefresh';

/// PullRefreshPage - 下拉刷新控制
///
/// 展示下拉刷新的启用与手动控制机制。
class PullRefreshPage extends StatefulWidget {
  const PullRefreshPage({super.key});

  @override
  State<PullRefreshPage> createState() => _PullRefreshPageState();
}

class _PullRefreshPageState extends State<PullRefreshPage> {
  // ─── 状态变量 ────────────────────────────────────────────────────────────
  bool _enabled = true;
  bool _refreshing = false;
  String _status = '';

  // ─── 非响应式成员 ─────────────────────────────────────────────────────────
  PullToRefreshController? _pullToRefreshController;
  InAppWebViewController? _controller;

  @override
  void initState() {
    super.initState();
    dev.log('Page appeared', name: _kTag);
    // 创建 PullToRefreshController，注册 onRefresh 回调
    _pullToRefreshController = PullToRefreshController(
      onRefresh: () async {
        dev.log('onRefresh triggered', name: _kTag);
        if (!mounted) return;
        setState(() => _refreshing = true);
        // 模拟刷新操作：重载页面
        await _controller?.reload();
        await Future.delayed(const Duration(seconds: 1));
        await _pullToRefreshController?.endRefreshing();
        if (!mounted) return;
        setState(() => _refreshing = false);
      },
    );
  }

  @override
  void dispose() {
    dev.log('Page disposed, releasing resources', name: _kTag);
    super.dispose();
  }

  // ─── 核心功能方法 ────────────────────────────────────────────────────────

  /// 切换启用/禁用
  Future<void> _toggleEnabled() async {
    dev.log('_toggleEnabled called', name: _kTag);
    try {
      await _pullToRefreshController?.setEnabled(!_enabled);
      dev.log('_toggleEnabled succeeded', name: _kTag);
      if (!mounted) return;
      setState(() {
        _enabled = !_enabled;
        _status = _enabled ? '已启用' : '已禁用';
      });
    } catch (e, stack) {
      dev.log('_toggleEnabled failed',
          name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 开始刷新
  Future<void> _beginRefreshing() async {
    dev.log('_beginRefreshing called', name: _kTag);
    try {
      await _pullToRefreshController?.beginRefreshing();
      dev.log('_beginRefreshing succeeded', name: _kTag);
      if (!mounted) return;
      setState(() {
        _refreshing = true;
        _status = '刷新动画已开始';
      });
    } catch (e, stack) {
      dev.log('_beginRefreshing failed',
          name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 结束刷新
  Future<void> _endRefreshing() async {
    dev.log('_endRefreshing called', name: _kTag);
    try {
      await _pullToRefreshController?.endRefreshing();
      dev.log('_endRefreshing succeeded', name: _kTag);
      if (!mounted) return;
      setState(() {
        _refreshing = false;
        _status = '刷新动画已结束';
      });
    } catch (e, stack) {
      dev.log('_endRefreshing failed',
          name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 查询状态
  Future<void> _queryStatus() async {
    dev.log('_queryStatus called', name: _kTag);
    try {
      final enabled = await _pullToRefreshController?.isEnabled() ?? false;
      final refreshing =
          await _pullToRefreshController?.isRefreshing() ?? false;
      dev.log('_queryStatus succeeded: enabled=$enabled, refreshing=$refreshing',
          name: _kTag);
      if (!mounted) return;
      setState(() {
        _enabled = enabled;
        _refreshing = refreshing;
        _status = '已查询状态';
      });
    } catch (e, stack) {
      dev.log('_queryStatus failed',
          name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  // ─── UI 构建 ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('[014] 下拉刷新控制'),
      ),
      body: Column(
        children: [
          // 操作按钮区
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _toggleEnabled,
                  child: Text(_enabled ? '禁用' : '启用'),
                ),
                ElevatedButton(
                    onPressed: _beginRefreshing,
                    child: const Text('开始刷新')),
                ElevatedButton(
                    onPressed: _endRefreshing,
                    child: const Text('结束刷新')),
                ElevatedButton(
                    onPressed: _queryStatus, child: const Text('查询状态')),
              ],
            ),
          ),
          // 结果展示区
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('状态: $_status'),
                Text('已启用: $_enabled'),
                Text('刷新中: $_refreshing'),
              ],
            ),
          ),
          const Divider(height: 1),
          // WebView 区域
          Expanded(
            child: InAppWebView(
              initialUrlRequest:
                  URLRequest(url: WebUri('https://flutter.dev')),
              pullToRefreshController: _pullToRefreshController,
              onWebViewCreated: (controller) {
                dev.log('onWebViewCreated', name: _kTag);
                _controller = controller;
              },
            ),
          ),
        ],
      ),
    );
  }
}
