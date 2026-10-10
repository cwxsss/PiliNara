/// Demo 20: InAppBrowser
///
/// 功能说明：展示 InAppBrowser 的独立浏览器窗口控制能力，包括
/// openUrlRequest/show/hide/close/setSettings/getSettings/isHidden/isOpened。
/// 对应接口：
///   - openUrlRequest({required urlRequest, settings?}): Future<void>
///   - show(): Future<void>
///   - hide(): Future<void>
///   - close(): Future<void>
///   - setSettings({required settings}): Future<void>
///   - getSettings(): Future<InAppBrowserClassSettings?>
///   - isHidden(): Future<bool>
///   - isOpened(): bool
///   - 回调: onBrowserCreated/onLoadStart/onLoadStop/onReceivedError/onExit

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String _kTag = 'InAppWebView_InAppBrowser';

/// InappBrowserPage - 独立浏览器窗口控制
///
/// 展示 InAppBrowser 作为独立浏览器窗口的生命周期管理。
class InappBrowserPage extends StatefulWidget {
  const InappBrowserPage({super.key});

  @override
  State<InappBrowserPage> createState() => _InappBrowserPageState();
}

class _InappBrowserPageState extends State<InappBrowserPage> {
  // ─── 状态变量 ────────────────────────────────────────────────────────────
  bool _isOpened = false;
  bool _isHidden = false;
  String _status = '未打开';
  String _lastUrl = '';
  int _loadCount = 0;

  // ─── 非响应式成员 ─────────────────────────────────────────────────────────
  late final _MyInAppBrowser _browser;
  final TextEditingController _urlController =
      TextEditingController(text: 'https://flutter.dev');

  @override
  void initState() {
    super.initState();
    dev.log('Page appeared', name: _kTag);
    _browser = _MyInAppBrowser(
      onStatusChanged: (open, hidden, url, loadCount) {
        if (!mounted) return;
        setState(() {
          _isOpened = open;
          _isHidden = hidden;
          if (url != null) _lastUrl = url;
          if (loadCount != null) _loadCount = loadCount;
        });
      },
    );
  }

  @override
  void dispose() {
    dev.log('Page disposed, releasing resources', name: _kTag);
    _browser.dispose();
    _urlController.dispose();
    super.dispose();
  }

  // ─── 核心功能方法 ────────────────────────────────────────────────────────

  /// 打开 URL
  Future<void> _openUrl() async {
    dev.log('_openUrl called', name: _kTag);
    setState(() => _status = '打开中');
    try {
      await _browser.openUrlRequest(
        urlRequest:
            URLRequest(url: WebUri(_urlController.text)),
      );
      dev.log('_openUrl succeeded', name: _kTag);
      if (!mounted) return;
      setState(() {
        _isOpened = _browser.isOpened();
        _status = '已打开';
      });
    } catch (e, stack) {
      dev.log('_openUrl failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 显示
  Future<void> _show() async {
    dev.log('_show called', name: _kTag);
    try {
      await _browser.show();
      dev.log('_show succeeded', name: _kTag);
      if (!mounted) return;
      setState(() {
        _isHidden = false;
        _status = '已显示';
      });
    } catch (e, stack) {
      dev.log('_show failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 隐藏
  Future<void> _hide() async {
    dev.log('_hide called', name: _kTag);
    try {
      await _browser.hide();
      dev.log('_hide succeeded', name: _kTag);
      if (!mounted) return;
      setState(() {
        _isHidden = true;
        _status = '已隐藏';
      });
    } catch (e, stack) {
      dev.log('_hide failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 关闭
  Future<void> _close() async {
    dev.log('_close called', name: _kTag);
    try {
      await _browser.close();
      dev.log('_close succeeded', name: _kTag);
      if (!mounted) return;
      setState(() {
        _isOpened = false;
        _isHidden = false;
        _status = '已关闭';
      });
    } catch (e, stack) {
      dev.log('_close failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 查询状态
  Future<void> _queryStatus() async {
    dev.log('_queryStatus called', name: _kTag);
    try {
      final opened = _browser.isOpened();
      final hidden = await _browser.isHidden();
      dev.log('_queryStatus succeeded: opened=$opened, hidden=$hidden',
          name: _kTag);
      if (!mounted) return;
      setState(() {
        _isOpened = opened;
        _isHidden = hidden;
        _status = '已查询';
      });
    } catch (e, stack) {
      dev.log('_queryStatus failed',
          name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 读取设置
  Future<void> _getSettings() async {
    dev.log('_getSettings called', name: _kTag);
    try {
      final settings = await _browser.getSettings();
      dev.log('_getSettings succeeded', name: _kTag);
      if (!mounted) return;
      setState(() {
        _status = '设置: ${settings?.toString() ?? "null"}';
      });
    } catch (e, stack) {
      dev.log('_getSettings failed',
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
        title: const Text('[020] 独立浏览器窗口'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 说明
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'InAppBrowser 生命周期管理',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '展示独立浏览器窗口的打开/显示/隐藏/关闭操作。'
                      '注意：OHOS 平台对 InAppBrowser.openUrlRequest '
                      '的支持可能受限，若遇到错误请查看日志。',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // URL 输入区
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: '目标 URL',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),

            // 操作按钮区
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                    onPressed: _openUrl, child: const Text('打开')),
                ElevatedButton(
                    onPressed: _show, child: const Text('显示')),
                ElevatedButton(
                    onPressed: _hide, child: const Text('隐藏')),
                ElevatedButton(
                    onPressed: _close, child: const Text('关闭')),
                ElevatedButton(
                    onPressed: _queryStatus,
                    child: const Text('查询状态')),
                ElevatedButton(
                    onPressed: _getSettings,
                    child: const Text('读取设置')),
              ],
            ),
            const SizedBox(height: 16),

            // 结果展示区
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('状态: $_status'),
                  Text('已打开: $_isOpened'),
                  Text('已隐藏: $_isHidden'),
                  Text('最近URL: $_lastUrl'),
                  Text('加载次数: $_loadCount'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 自定义 InAppBrowser 子类，重写回调以更新 UI 状态
class _MyInAppBrowser extends InAppBrowser {
  _MyInAppBrowser({required this.onStatusChanged});

  /// 状态变更回调
  final void Function(
    bool isOpened,
    bool isHidden,
    String? lastUrl,
    int? loadCount,
  ) onStatusChanged;

  int _loadCount = 0;

  @override
  void onBrowserCreated() {
    dev.log('onBrowserCreated', name: _kTag);
    onStatusChanged(true, false, null, _loadCount);
  }

  @override
  void onLoadStart(WebUri? url) {
    dev.log('onLoadStart: $url', name: _kTag);
    _loadCount++;
    onStatusChanged(true, false, url?.toString(), _loadCount);
  }

  @override
  void onLoadStop(WebUri? url) {
    dev.log('onLoadStop: $url', name: _kTag);
    onStatusChanged(true, false, url?.toString(), _loadCount);
  }

  @override
  void onReceivedError(
      WebResourceRequest request, WebResourceError error) {
    dev.log(
      'onReceivedError: ${error.description}',
      name: _kTag,
      error: error,
    );
  }

  @override
  void onExit() {
    dev.log('onExit', name: _kTag);
    _loadCount = 0;
    onStatusChanged(false, false, null, 0);
  }
}
