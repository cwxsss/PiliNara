/// Demo 034: WebView 生命周期竞态崩溃 & onJsPrompt 加固回归测试
///
/// 针对的修复：
///   1. onAreaChange 生命周期竞态崩溃（Error code 17100001,
///      "The WebviewController must be associated with a Web component"）：
///      组件销毁/尺寸变化瞬间 ArkUI 仍派发 onAreaChange，此时 controller 已与
///      Web 组件解绑，refreshScrollMetricsAsync 内 runJavaScriptExt 同步抛出且
///      未被捕获而冒泡崩溃。修复：InAppWebView.ets 多处 ArkWeb API 补同步 try-catch，
///      OhosWebView.ets 的 .onAreaChange guard 追加 controllerAttached 判断。
///   2. onJsPrompt 链路加固：四个 JS 对话框处理器整体 try-catch、孤儿原生弹框治理、
///      openCustomDialog try-catch + settled 双检查。
///
/// 复现思路：
///   - 频繁改变 WebView 尺寸（制造大量 onAreaChange）
///   - 与 create/dispose 快速循环叠加（制造 controller 解绑窗口）
///   - 叠加 prompt 连发（制造在途 JsResult）
///   若修复生效：全程无崩溃，日志持续输出，pending 最终归零。
import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../common/event_log_panel.dart';
import '../../common/test_button.dart';
import '../../common/test_urls.dart';

const String _kTag = 'InAppWebView_LifecycleCrash';

/// prompt 应答模式
enum _PromptMode {
  confirm,
  nativeDialog,
}

extension _PromptModeLabel on _PromptMode {
  String get label {
    switch (this) {
      case _PromptMode.confirm:
        return 'confirm(正常回复)';
      case _PromptMode.nativeDialog:
        return 'nativeDialog(原生弹窗/孤儿框测试)';
    }
  }
}

class WebviewLifecycleCrashPage extends StatefulWidget {
  const WebviewLifecycleCrashPage({super.key});

  @override
  State<WebviewLifecycleCrashPage> createState() =>
      _WebviewLifecycleCrashPageState();
}

class _WebviewLifecycleCrashPageState extends State<WebviewLifecycleCrashPage> {
  final EventLogController _logger = EventLogController();
  InAppWebViewController? _controller;

  // WebView 挂载标志与实例代号（每次重建 +1，用作 ValueKey 强制重建）
  bool _webViewMounted = false;
  int _instanceSeq = 0;

  // 当前 WebView 高度（用于制造 onAreaChange）
  double _webHeight = 220;

  // prompt 计数
  int _sentCount = 0;
  int _completedCount = 0;
  _PromptMode _promptMode = _PromptMode.confirm;

  // 自动化循环控制
  bool _looping = false;
  int _loopRound = 0;

  @override
  void initState() {
    super.initState();
    dev.log('Page appeared', name: _kTag);
  }

  @override
  void dispose() {
    dev.log('Page disposed', name: _kTag);
    _looping = false;
    _logger.dispose();
    _controller = null;
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  // ── 基础操作 ────────────────────────────────────────────────────────────

  Future<Object?> _mountWebView() async {
    setState(() {
      _instanceSeq++;
      _webViewMounted = true;
    });
    _logger.log(_kTag, '挂载 WebView 实例 #$_instanceSeq');
    return 'mounted #$_instanceSeq';
  }

  Future<Object?> _unmountWebView() async {
    if (!_webViewMounted) return 'already unmounted';
    setState(() {
      _webViewMounted = false;
      _controller = null;
    });
    _logger.log(_kTag,
        '卸载 WebView 实例 #$_instanceSeq (pending=${_sentCount - _completedCount})');
    return 'unmounted';
  }

  /// 制造一串 onAreaChange：连续快速改变 WebView 高度。
  /// 这是复现 17100001 的关键——高频 area-change 命中 controller 解绑窗口。
  Future<Object?> _thrashSize() async {
    _logger.log(_kTag, '=== 尺寸抖动开始（20 次高度变化）===');
    for (int i = 0; i < 20; i++) {
      if (!mounted) break;
      setState(() {
        _webHeight = 120.0 + (i % 5) * 60.0;
      });
      await Future.delayed(const Duration(milliseconds: 16)); // ~1 帧
    }
    if (mounted) setState(() => _webHeight = 220);
    _logger.log(_kTag, '=== 尺寸抖动结束 ===');
    return 'size thrash done';
  }

  Future<void> _sendOnePrompt() async {
    final c = _controller;
    if (c == null) {
      _logger.log(_kTag, 'controller 为空，跳过 prompt');
      return;
    }
    _sentCount++;
    _refresh();
    try {
      await c.evaluateJavascript(
          source:
              "console.log('prompt=' + prompt('msg#$_sentCount', 'default'))");
      _completedCount++;
      _refresh();
    } catch (e) {
      _logger.logError(_kTag, 'prompt #$_sentCount 异常', error: e);
    }
  }

  // ── 组合场景：崩溃复现回归 ────────────────────────────────────────────────

  /// 场景 A：尺寸抖动 + 中途卸载。
  /// 在 area-change 洪流中途卸载 WebView，最大化命中 controller 解绑窗口。
  Future<Object?> _scenarioSizeThrashUnmount() async {
    if (!_webViewMounted) await _mountWebView();
    await Future.delayed(const Duration(milliseconds: 300));
    _logger.log(_kTag, '--- 场景A: 尺寸抖动中途卸载 ---');
    // 不 await：抖动进行时并发卸载
    unawaited(_thrashSize());
    await Future.delayed(const Duration(milliseconds: 120));
    await _unmountWebView();
    return 'scenarioA ok (no crash)';
  }

  /// 场景 B：prompt 连发 + 尺寸抖动 + 立即卸载。
  /// 三重叠加：在途 JsResult + area-change + 解绑。
  Future<Object?> _scenarioPromptSizeUnmount() async {
    if (!_webViewMounted) await _mountWebView();
    await Future.delayed(const Duration(milliseconds: 300));
    _logger.log(_kTag, '--- 场景B: prompt连发 + 尺寸抖动 + 立即卸载 ---');
    for (int i = 0; i < 10; i++) {
      unawaited(_sendOnePrompt());
    }
    unawaited(_thrashSize());
    await Future.delayed(const Duration(milliseconds: 80));
    await _unmountWebView();
    return 'scenarioB ok, pending=${_sentCount - _completedCount}';
  }

  /// 场景 C：原生弹框 + 立即卸载（孤儿弹框回归）。
  /// nativeDialog 模式下 prompt 会弹原生框，立即卸载应关闭该框且不崩溃。
  Future<Object?> _scenarioOrphanDialog() async {
    final prev = _promptMode;
    setState(() => _promptMode = _PromptMode.nativeDialog);
    if (!_webViewMounted) await _mountWebView();
    await Future.delayed(const Duration(milliseconds: 300));
    _logger.log(_kTag, '--- 场景C: 原生弹框 + 立即卸载（孤儿框治理）---');
    unawaited(_sendOnePrompt()); // 触发原生弹框
    await Future.delayed(const Duration(milliseconds: 60));
    await _unmountWebView(); // 立即卸载 → 应关闭弹框
    setState(() => _promptMode = prev);
    return 'scenarioC ok (弹框应已关闭且无崩溃)';
  }

  /// 场景 D：快速 mount→dispose 循环（纯生命周期压力）。
  Future<Object?> _scenarioRapidCycle() async {
    _logger.log(_kTag, '--- 场景D: 快速 mount→dispose 循环 x15 ---');
    for (int i = 0; i < 15; i++) {
      if (!mounted) break;
      await _mountWebView();
      await Future.delayed(const Duration(milliseconds: 80));
      unawaited(_thrashSize());
      await Future.delayed(const Duration(milliseconds: 40));
      await _unmountWebView();
      await Future.delayed(const Duration(milliseconds: 40));
    }
    return 'scenarioD ok (15 轮无崩溃)';
  }

  /// 全自动回归：循环跑 A/B/C/D，直到手动停止。
  Future<Object?> _autoLoop() async {
    if (_looping) {
      _looping = false;
      _logger.log(_kTag, '自动回归：收到停止请求');
      return 'stopping';
    }
    _looping = true;
    _loopRound = 0;
    _logger.log(_kTag, '=== 自动回归开始（循环 A→B→C→D）===');
    while (_looping && mounted) {
      _loopRound++;
      _refresh();
      _logger.log(_kTag, '自动回归第 $_loopRound 轮');
      await _scenarioSizeThrashUnmount();
      if (!_looping) break;
      await _scenarioPromptSizeUnmount();
      if (!_looping) break;
      await _scenarioOrphanDialog();
      if (!_looping) break;
      await _scenarioRapidCycle();
      await Future.delayed(const Duration(milliseconds: 200));
    }
    _looping = false;
    _refresh();
    _logger.log(_kTag, '=== 自动回归停止（共 $_loopRound 轮，全程无崩溃）===');
    return 'looped $_loopRound rounds';
  }

  void _resetCounters() {
    setState(() {
      _sentCount = 0;
      _completedCount = 0;
    });
    _logger.log(_kTag, '计数已重置');
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('[030] 生命周期竞态崩溃回归')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _statusBar(),
            // 高度受 _webHeight 控制的 WebView 容器，尺寸变化触发 onAreaChange
            AnimatedContainer(
              duration: const Duration(milliseconds: 16),
              height: _webHeight,
              color: Colors.black12,
              child: _webViewMounted
                  ? InAppWebView(
                      key: ValueKey('lifecycle_wv_$_instanceSeq'),
                      initialData: InAppWebViewInitialData(data: kSampleHtml),
                      initialSettings: InAppWebViewSettings(
                        javaScriptEnabled: true,
                        isInspectable: true,
                      ),
                      onWebViewCreated: (c) {
                        _controller = c;
                        _logger.log(_kTag, 'onWebViewCreated #$_instanceSeq');
                      },
                      onLoadStop: (c, url) {
                        _logger.log(_kTag, 'onLoadStop: $url');
                      },
                      onJsPrompt: (controller, req) async {
                        _logger.log(_kTag, 'onJsPrompt: ${req.message}');
                        switch (_promptMode) {
                          case _PromptMode.confirm:
                            return JsPromptResponse(
                              handledByClient: true,
                              value: 'ok-#$_sentCount',
                              action: JsPromptResponseAction.CONFIRM,
                            );
                          case _PromptMode.nativeDialog:
                            return null; // 走 defaultBehaviour → 原生弹框
                        }
                      },
                    )
                  : const Center(
                      child: Text('WebView 未挂载',
                          style: TextStyle(color: Colors.black38)),
                    ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Column(children: [
                  _modeRow(),
                  const SizedBox(height: 4),
                  Row(children: [
                    Expanded(child: _btn('挂载', _mountWebView)),
                    const SizedBox(width: 6),
                    Expanded(child: _btn('卸载', _unmountWebView)),
                  ]),
                  _btn('尺寸抖动（复现 onAreaChange）', _thrashSize),
                  const Divider(),
                  _btn('场景A: 尺寸抖动中途卸载', _scenarioSizeThrashUnmount),
                  _btn('场景B: prompt+抖动+立即卸载', _scenarioPromptSizeUnmount),
                  _btn('场景C: 原生弹框+立即卸载（孤儿框）', _scenarioOrphanDialog),
                  _btn('场景D: 快速 mount→dispose x15', _scenarioRapidCycle),
                  const Divider(),
                  _btn(_looping ? '⏹ 停止自动回归' : '▶ 自动回归（循环 A→B→C→D）',
                      _autoLoop),
                  _btn('重置计数', () async {
                    _resetCounters();
                    return 'reset';
                  }),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: EventLogPanel(controller: _logger, height: 150),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          _chip('实例', '#$_instanceSeq', Colors.blueGrey),
          _chip('高度', _webHeight.toStringAsFixed(0), Colors.teal),
          _chip('发送', '$_sentCount', Colors.blue),
          _chip('完成', '$_completedCount', Colors.green),
          _chip('pending', '${_sentCount - _completedCount}', Colors.orange),
          if (_looping) _chip('自动回归', '第$_loopRound轮', Colors.purple),
        ],
      ),
    );
  }

  Widget _modeRow() {
    return Row(
      children: [
        const Text('prompt 模式: ', style: TextStyle(fontSize: 13)),
        Expanded(
          child: DropdownButton<_PromptMode>(
            isExpanded: true,
            value: _promptMode,
            items: _PromptMode.values
                .map((m) => DropdownMenuItem(
                      value: m,
                      child:
                          Text(m.label, style: const TextStyle(fontSize: 13)),
                    ))
                .toList(),
            onChanged: (m) {
              if (m != null) {
                setState(() => _promptMode = m);
                _logger.log(_kTag, 'prompt 模式切换: ${m.label}');
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, String value, Color color) {
    return Chip(
      label: Text('$label: $value', style: const TextStyle(fontSize: 12)),
      backgroundColor: color.withValues(alpha: 0.15),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _btn(String label, Future<Object?> Function() fn) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: AsyncTestButton(
            label: label, tag: _kTag, logger: _logger, onPressed: fn),
      );
}
