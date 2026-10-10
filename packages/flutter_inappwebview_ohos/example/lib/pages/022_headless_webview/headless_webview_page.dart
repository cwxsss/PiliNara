/// Demo 22: HeadlessInAppWebView
///
/// 功能说明：直观演示无头 WebView 的完整生命周期与尺寸控制能力。
/// 无头 WebView 在后台运行，无 UI，适用于后台抓取、预渲染、数据提取等场景。
///
/// 对应接口：
///   - HeadlessInAppWebView(initialUrlRequest/initialData/initialSettings/initialSize)
///   - run(): Future<void>
///   - isRunning(): bool
///   - getSize(): Future<Size?>
///   - setSize(Size size): Future<void>
///   - dispose(): Future<void>
///   - onWebViewCreated/onLoadStart/onLoadStop/onConsoleMessage 回调
///   - controller.webViewController 获取控制器并执行 JS 抓取页面内容

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String _kTag = 'InAppWebView_HeadlessWebView';

/// HeadlessWebViewPage - 无头 WebView 演示
///
/// 展示 HeadlessInAppWebView 的创建、运行、尺寸控制、后台内容抓取与释放。
class HeadlessWebViewPage extends StatefulWidget {
  const HeadlessWebViewPage({super.key});

  @override
  State<HeadlessWebViewPage> createState() => _HeadlessWebViewPageState();
}

class _HeadlessWebViewPageState extends State<HeadlessWebViewPage> {
  // ─── 状态变量 ────────────────────────────────────────────────────────────
  bool _isRunning = false;
  String? _currentUrl;
  String _pageHtml = '';
  String _pageTitle = '';
  String _consoleLog = '';
  Size? _size;
  String _statusText = '未运行';

  // ─── 非响应式成员 ─────────────────────────────────────────────────────────
  HeadlessInAppWebView? _headlessWebView;
  InAppWebViewController? _controller;

  /// 用于无头加载的测试 HTML
  static const String _testHtml = '''
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>Headless 测试页</title></head>
<body>
  <h1 id="t">Headless WebView 示例</h1>
  <p>这是一个无头 WebView 加载的页面，用户看不见它，但可以执行 JS 抓取内容。</p>
  <ul><li>项 A</li><li>项 B</li><li>项 C</li></ul>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    dev.log('Page appeared', name: _kTag);
  }

  @override
  void dispose() {
    dev.log('Page disposed, releasing resources', name: _kTag);
    _headlessWebView?.dispose();
    super.dispose();
  }

  // ─── 核心功能方法 ────────────────────────────────────────────────────────

  /// 创建并运行无头 WebView
  Future<void> _runHeadless() async {
    dev.log('_runHeadless called', name: _kTag);
    if (_headlessWebView != null && _isRunning) {
      setState(() => _statusText = '已在运行，无需重复启动');
      return;
    }
    setState(() => _statusText = '启动中...');

    _headlessWebView = HeadlessInAppWebView(
      initialSize: const Size(400, 600),
      initialData: InAppWebViewInitialData(data: _testHtml),
      initialSettings: InAppWebViewSettings(javaScriptEnabled: true),
      onWebViewCreated: (controller) {
        dev.log('Headless onWebViewCreated', name: _kTag);
        _controller = controller;
      },
      onLoadStart: (controller, url) {
        dev.log('Headless onLoadStart: $url', name: _kTag);
        if (!mounted) return;
        setState(() {
          _currentUrl = url?.toString();
          _statusText = '加载开始';
        });
      },
      onLoadStop: (controller, url) async {
        dev.log('Headless onLoadStop: $url', name: _kTag);
        if (!mounted) return;
        setState(() {
          _currentUrl = url?.toString();
          _statusText = '加载完成，可抓取内容';
        });
        // 自动抓取标题
        try {
          final title = await _controller?.evaluateJavascript(
              source: 'document.title');
          if (!mounted) return;
          setState(() => _pageTitle = title?.toString() ?? '');
        } catch (e) {
          dev.log('抓取标题失败', name: _kTag, error: e);
        }
      },
      onConsoleMessage: (controller, consoleMessage) {
        dev.log('Headless onConsoleMessage: ${consoleMessage.message}',
            name: _kTag);
        if (!mounted) return;
        setState(() {
          _consoleLog = '${consoleMessage.message}\n$_consoleLog';
        });
      },
    );

    await _headlessWebView!.run();
    final running = _headlessWebView!.isRunning();
    final size = await _headlessWebView!.getSize();
    dev.log('Headless running=$running, size=$size', name: _kTag);
    if (!mounted) return;
    setState(() {
      _isRunning = running;
      _size = size;
      _statusText = running ? '已运行' : '启动失败';
    });
  }

  /// 抓取页面 HTML
  Future<void> _grabHtml() async {
    dev.log('_grabHtml called', name: _kTag);
    try {
      final html = await _controller?.evaluateJavascript(
          source: 'document.body.innerHTML');
      dev.log('_grabHtml succeeded, length=${(html ?? '').length}',
          name: _kTag);
      if (!mounted) return;
      setState(() {
        _pageHtml = (html ?? '').toString();
        _statusText = '已抓取 HTML';
      });
    } catch (e, stack) {
      dev.log('_grabHtml failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _statusText = '错误：$e');
    }
  }

  /// 获取当前尺寸
  Future<void> _getSize() async {
    dev.log('_getSize called', name: _kTag);
    try {
      final size = await _headlessWebView?.getSize();
      dev.log('_getSize succeeded: $size', name: _kTag);
      if (!mounted) return;
      setState(() {
        _size = size;
        _statusText = '尺寸: ${size?.width}x${size?.height}';
      });
    } catch (e, stack) {
      dev.log('_getSize failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _statusText = '错误：$e');
    }
  }

  /// 设置尺寸
  Future<void> _setSize() async {
    dev.log('_setSize called', name: _kTag);
    try {
      const newSize = Size(800, 1200);
      await _headlessWebView?.setSize(newSize);
      dev.log('_setSize succeeded', name: _kTag);
      if (!mounted) return;
      setState(() {
        _size = newSize;
        _statusText = '已设置尺寸为 800x1200';
      });
    } catch (e, stack) {
      dev.log('_setSize failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _statusText = '错误：$e');
    }
  }

  /// 检查运行状态
  Future<void> _checkRunning() async {
    dev.log('_checkRunning called', name: _kTag);
    final running = _headlessWebView?.isRunning() ?? false;
    dev.log('_checkRunning: $running', name: _kTag);
    if (!mounted) return;
    setState(() {
      _isRunning = running;
      _statusText = '运行状态: $running';
    });
  }

  /// 释放无头 WebView
  Future<void> _disposeHeadless() async {
    dev.log('_disposeHeadless called', name: _kTag);
    try {
      await _headlessWebView?.dispose();
      dev.log('_disposeHeadless succeeded', name: _kTag);
      if (!mounted) return;
      setState(() {
        _isRunning = false;
        _headlessWebView = null;
        _controller = null;
        _pageHtml = '';
        _pageTitle = '';
        _consoleLog = '';
        _size = null;
        _statusText = '已释放';
      });
    } catch (e, stack) {
      dev.log('_disposeHeadless failed', name: _kTag, error: e,
          stackTrace: stack);
      if (!mounted) return;
      setState(() => _statusText = '错误：$e');
    }
  }

  // ─── UI 构建 ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('[022] 无头WebView(Headless)')),
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
                    onPressed: _isRunning ? null : _runHeadless,
                    child: const Text('run()')),
                ElevatedButton(
                    onPressed: _isRunning ? _grabHtml : null,
                    child: const Text('抓取HTML')),
                ElevatedButton(
                    onPressed: _isRunning ? _getSize : null,
                    child: const Text('getSize()')),
                ElevatedButton(
                    onPressed: _isRunning ? _setSize : null,
                    child: const Text('setSize(800x1200)')),
                ElevatedButton(
                    onPressed: _checkRunning,
                    child: const Text('isRunning()')),
                ElevatedButton(
                    onPressed: _isRunning ? _disposeHeadless : null,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[100]),
                    child: const Text('dispose()')),
              ],
            ),
          ),
          // 状态展示区
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow('状态', _statusText),
                _infoRow('运行中', '$_isRunning'),
                _infoRow('当前URL', _currentUrl ?? '(无)'),
                _infoRow('尺寸',
                    _size != null ? '${_size!.width}x${_size!.height}' : '(无)'),
                _infoRow('页面标题', _pageTitle.isEmpty ? '(未抓取)' : _pageTitle),
              ],
            ),
          ),
          const Divider(height: 1),
          // 抓取结果区
          Expanded(
            child: _pageHtml.isEmpty && _consoleLog.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'HeadlessInAppWebView 无 UI 运行。\n'
                        '点击 run() 启动，然后点「抓取HTML」\n'
                        '查看后台抓取到的页面内容。',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      if (_pageHtml.isNotEmpty) ...[
                        const Text('抓取的 HTML 内容:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: SelectableText(
                            _pageHtml,
                            style: const TextStyle(
                                fontFamily: 'monospace', fontSize: 12),
                            maxLines: 10,
                          ),
                        ),
                      ],
                      if (_consoleLog.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text('Console 日志:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: SelectableText(
                            _consoleLog,
                            style: const TextStyle(
                                fontFamily: 'monospace', fontSize: 12),
                            maxLines: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text.rich(
        TextSpan(children: [
          TextSpan(text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          TextSpan(text: value),
        ]),
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
