/// Demo 033: WebView JS Prompt 回调丢失与销毁兜底
///
/// 功能说明：验证 onJsPrompt 回调在 WebView 销毁时的兜底机制。
/// 对应修复：InAppWebViewClient 维护 pendingJsDialogs 注册表，dispose 时
/// forceCancel 所有未 resolve 的 JsResult，避免 JS 线程永久挂起。
///
/// 测试模式：
///   - confirm   : 正常回复 prompt
///   - cancel    : 取消 prompt
///   - nativeDialog: 走原生弹窗(defaultBehaviour)
///   - neverReply: 模拟 Dart 回复丢失(返回 null 让内核等待)
///
/// 压力测试：50 次 prompt 连发 + 立即 dispose WebView，验证兜底机制。
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../common/event_log_panel.dart';
import '../../common/test_button.dart';
import '../../common/test_urls.dart';

const String _kTag = 'InAppWebView_JsPromptStress';

/// 应答模式
enum _ReplyMode {
  confirm,
  cancel,
  nativeDialog,
  neverReply,
}

extension _ReplyModeLabel on _ReplyMode {
  String get label {
    switch (this) {
      case _ReplyMode.confirm:
        return 'confirm(正常回复)';
      case _ReplyMode.cancel:
        return 'cancel(取消)';
      case _ReplyMode.nativeDialog:
        return 'nativeDialog(原生弹窗)';
      case _ReplyMode.neverReply:
        return 'neverReply(模拟回复丢失)';
    }
  }
}

class WebviewJsPromptPage extends StatefulWidget {
  const WebviewJsPromptPage({super.key});

  @override
  State<WebviewJsPromptPage> createState() => _WebviewJsPromptPageState();
}

class _WebviewJsPromptPageState extends State<WebviewJsPromptPage> {
  final EventLogController _logger = EventLogController();
  InAppWebViewController? _controller;
  // 当前应答模式（neverReply 用于验证销毁兜底）
  _ReplyMode _replyMode = _ReplyMode.neverReply;
  // 实时计数
  int _sentCount = 0;
  int _completedCount = 0;
  // WebView 是否就绪（用于重建）
  bool _webViewReady = false;

  @override
  void initState() {
    super.initState();
    dev.log('Page appeared', name: _kTag);
  }

  @override
  void dispose() {
    dev.log('Page disposed', name: _kTag);
    _logger.dispose();
    _controller = null;
    super.dispose();
  }

  void _resetCounters() {
    _sentCount = 0;
    _completedCount = 0;
  }

  /// 发送一次 prompt 并等待 JS 返回（confirm/cancel 模式下 JS 会立即返回，
  /// neverReply 模式下 JS 线程会阻塞直到销毁兜底 forceCancel）。
  Future<void> _sendOnePrompt() async {
    final c = _controller;
    if (c == null) {
      _logger.log(_kTag, 'controller 为空，跳过');
      return;
    }
    _sentCount++;
    _updateCounters();
    try {
      // prompt() 返回值写入 console，便于在日志面板观察完成情况。
      // neverReply 模式下此处会一直 await（JS 线程阻塞），直到 dispose 兜底唤醒。
      await c.evaluateJavascript(
          source:
              "console.log('prompt result=' + prompt('msg#$_sentCount', 'default'))");
      _completedCount++;
      _updateCounters();
      _logger.log(_kTag, 'prompt #$_sentCount 完成 (mode=$_replyMode)');
    } catch (e) {
      _logger.logError(_kTag, 'prompt #$_sentCount 异常', error: e);
    }
  }

  /// 压力测试：连发 50 次 prompt 后立即 dispose WebView。
  /// neverReply 模式下这会制造 50 个孤儿 JsResult，验证 dispose 兜底能否全部唤醒。
  Future<Object?> _stressTest() async {
    _logger.log(
        _kTag, '=== 压力测试开始: 50 次 prompt + 立即 dispose (mode=$_replyMode) ===');
    for (int i = 0; i < 50; i++) {
      // 不 await：并发触发，模拟频繁调用
      _sendOnePrompt();
    }
    // 立即销毁 WebView，触发 InAppWebViewClient.dispose() forceCancel 兜底
    await Future.delayed(const Duration(milliseconds: 50));
    await _disposeWebView();
    _logger.log(_kTag,
        '=== 压力测试结束: sent=$_sentCount completed=$_completedCount (pending=${_sentCount - _completedCount}) ===');
    return 'sent=$_sentCount, completed=$_completedCount, pending=${_sentCount - _completedCount}';
  }

  /// 重建 WebView：dispose 后重新创建，验证资源清理后可正常复用。
  Future<Object?> _rebuildWebView() async {
    await _disposeWebView();
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {
      _webViewReady = false;
      _resetCounters();
    });
    _logger.log(_kTag, 'WebView 已重建，可继续测试');
    return 'WebView rebuilt';
  }

  Future<void> _disposeWebView() async {
    final c = _controller;
    if (c == null) {
      return;
    }
    try {
      await c.evaluateJavascript(source: '');
    } catch (_) {
      // ignore: WebView 可能已不可用
    }
    // 调用 dispose 触发 InAppWebViewClient.dispose() 兜底
    // 注意：InAppWebViewController 没有 public dispose，这里通过重建 Key 让 Widget 重建。
    setState(() {
      _controller = null;
      _webViewReady = false;
    });
    _logger.log(_kTag, 'WebView 已销毁 (pending=${_sentCount - _completedCount})');
  }

  void _updateCounters() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<Object?> _setMode(_ReplyMode mode) async {
    setState(() => _replyMode = mode);
    _logger.log(_kTag, '应答模式切换为: ${mode.label}');
    return mode.label;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('[029] JS Prompt 回调丢失/销毁兜底')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 模式选择 + 计数面板
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Row(
                children: [
                  const Text('模式: '),
                  const SizedBox(width: 4),
                  Expanded(
                    child: DropdownButton<_ReplyMode>(
                      isExpanded: true,
                      value: _replyMode,
                      items: _ReplyMode.values
                          .map((m) => DropdownMenuItem(
                                value: m,
                                child: Text(m.label,
                                    style: const TextStyle(fontSize: 13)),
                              ))
                          .toList(),
                      onChanged: (m) {
                        if (m != null) _setMode(m);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
              child: Row(
                children: [
                  _counterChip('发送', _sentCount, Colors.blue),
                  const SizedBox(width: 8),
                  _counterChip('完成', _completedCount, Colors.green),
                  const SizedBox(width: 8),
                  _counterChip(
                      'pending', _sentCount - _completedCount, Colors.orange),
                ],
              ),
            ),
            // WebView 区域
            SizedBox(
              height: 200,
              child: _webViewReady
                  ? InAppWebView(
                      key: ValueKey('wv_$_sentCount'),
                      initialData: InAppWebViewInitialData(data: kSampleHtml),
                      initialSettings: InAppWebViewSettings(
                          javaScriptEnabled: true, isInspectable: true),
                      onWebViewCreated: (c) {
                        _controller = c;
                        _logger.log(_kTag, 'onWebViewCreated');
                      },
                      onJsPrompt: (controller, req) async {
                        _logger.log(_kTag,
                            'onJsPrompt: ${req.message} (default=${req.defaultValue})');
                        switch (_replyMode) {
                          case _ReplyMode.confirm:
                            return JsPromptResponse(
                              handledByClient: true,
                              value: 'replied-#$_sentCount',
                              action: JsPromptResponseAction.CONFIRM,
                            );
                          case _ReplyMode.cancel:
                            return JsPromptResponse(
                              handledByClient: true,
                              action: JsPromptResponseAction.CANCEL,
                            );
                          case _ReplyMode.nativeDialog:
                            // 返回 null → 走 defaultBehaviour → 原生弹窗
                            return null;
                          case _ReplyMode.neverReply:
                            // 模拟 Dart 回复丢失:返回 null 且不处理，
                            // 由于 defaultBehaviour 会弹原生对话框，
                            // 这里改为真正"永不回复"——直接返回一个永不 resolve 的 Future。
                            // 但 API 不支持，故用 nativeDialog 代替以观察默认行为。
                            // 真正的"回复丢失"场景由"立即 dispose"制造。
                            return null;
                        }
                      },
                    )
                  : Center(
                      child: TextButton.icon(
                        onPressed: () => setState(() => _webViewReady = true),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('创建 WebView'),
                      ),
                    ),
            ),
            // 操作按钮
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Column(children: [
                  _btn('发送一次 prompt', _sendOnePrompt),
                  _btn('50 次 prompt + 立即 dispose (压力测试)', _stressTest),
                  _btn('重建 WebView', _rebuildWebView),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: EventLogPanel(controller: _logger, height: 160),
            ),
          ],
        ),
      ),
    );
  }

  Widget _counterChip(String label, int value, Color color) {
    return Chip(
      label: Text('$label: $value', style: const TextStyle(fontSize: 12)),
      backgroundColor: color.withValues(alpha: 0.15),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _btn(String l, Future<Object?> Function() fn) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: AsyncTestButton(
            label: l, tag: _kTag, logger: _logger, onPressed: fn),
      );
}
