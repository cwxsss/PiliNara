/// Demo 10: WebstorageLocal
///
/// 功能说明：展示通过 WebStorage.localStorage/sessionStorage 访问本地存储，
/// 并使用 setItem/getItem/removeItem/clear/length/key 管理存储项。
/// 对应接口：
///   - WebStorage.localStorage: LocalStorage
///   - WebStorage.sessionStorage: SessionStorage
///   - length(): Future<int?>
///   - setItem(key, value): Future<void>
///   - getItem(key): Future<dynamic>
///   - removeItem(key): Future<void>
///   - clear(): Future<void>
///   - key(index): Future<String>

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String _kTag = 'InAppWebView_WebstorageLocal';

/// WebstorageLocalPage - WebStorage 本地存储管理
///
/// 展示 WebView 本地存储的读写与遍历能力。
class WebstorageLocalPage extends StatefulWidget {
  const WebstorageLocalPage({super.key});

  @override
  State<WebstorageLocalPage> createState() => _WebstorageLocalPageState();
}

class _WebstorageLocalPageState extends State<WebstorageLocalPage> {
  // ─── 状态变量 ────────────────────────────────────────────────────────────
  int? _length;
  dynamic _item;
  String? _keyAt0;
  String _status = '';

  // ─── 非响应式成员 ─────────────────────────────────────────────────────────
  InAppWebViewController? _controller;

  /// 测试用 HTML，确保 localStorage 可用
  static const String _testHtml = '''
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>Storage Test</title></head>
<body><h1>WebStorage Local Demo</h1></body>
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
    super.dispose();
  }

  /// 获取 localStorage 实例（通过 controller.webStorage）
  LocalStorage? get _localStorage =>
      _controller?.webStorage.localStorage;

  /// 获取 sessionStorage 实例
  SessionStorage? get _sessionStorage =>
      _controller?.webStorage.sessionStorage;

  // ─── 核心功能方法 ────────────────────────────────────────────────────────

  /// setItem
  Future<void> _setItem() async {
    dev.log('_setItem called', name: _kTag);
    try {
      await _localStorage?.setItem(key: 'k1', value: 'v1');
      dev.log('_setItem succeeded', name: _kTag);
      if (!mounted) return;
      setState(() => _status = '已设置 k1=v1');
    } catch (e, stack) {
      dev.log('_setItem failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// getItem
  Future<void> _getItem() async {
    dev.log('_getItem called', name: _kTag);
    try {
      final item = await _localStorage?.getItem(key: 'k1');
      dev.log('_getItem succeeded: $item', name: _kTag);
      if (!mounted) return;
      setState(() {
        _item = item;
        _status = 'getItem: $item';
      });
    } catch (e, stack) {
      dev.log('_getItem failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// removeItem
  Future<void> _removeItem() async {
    dev.log('_removeItem called', name: _kTag);
    try {
      await _localStorage?.removeItem(key: 'k1');
      dev.log('_removeItem succeeded', name: _kTag);
      if (!mounted) return;
      setState(() => _status = '已移除 k1');
    } catch (e, stack) {
      dev.log('_removeItem failed',
          name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// length
  Future<void> _getLength() async {
    dev.log('_getLength called', name: _kTag);
    try {
      final len = await _localStorage?.length();
      dev.log('_getLength succeeded: $len', name: _kTag);
      if (!mounted) return;
      setState(() {
        _length = len;
        _status = 'length: $len';
      });
    } catch (e, stack) {
      dev.log('_getLength failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// key(0)
  Future<void> _keyAt() async {
    dev.log('_keyAt called', name: _kTag);
    try {
      final key = await _localStorage?.key(index: 0);
      dev.log('_keyAt succeeded: $key', name: _kTag);
      if (!mounted) return;
      setState(() {
        _keyAt0 = key;
        _status = 'key(0): $key';
      });
    } catch (e, stack) {
      dev.log('_keyAt failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// clear
  Future<void> _clear() async {
    dev.log('_clear called', name: _kTag);
    try {
      await _localStorage?.clear();
      dev.log('_clear succeeded', name: _kTag);
      if (!mounted) return;
      setState(() {
        _length = 0;
        _status = '已清空 localStorage';
      });
    } catch (e, stack) {
      dev.log('_clear failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 设置 sessionStorage 项（使用 _sessionStorage getter）
  Future<void> _setSessionItem() async {
    dev.log('_setSessionItem called', name: _kTag);
    try {
      await _sessionStorage?.setItem(key: 'sessionKey', value: 'sessionValue');
      dev.log('_setSessionItem succeeded', name: _kTag);
      if (!mounted) return;
      setState(() => _status = '已设置 sessionStorage sessionKey=sessionValue');
    } catch (e, stack) {
      dev.log('_setSessionItem failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  // ─── UI 构建 ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('[010] WebStorage本地存储管理'),
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
                    onPressed: _setItem, child: const Text('setItem')),
                ElevatedButton(
                    onPressed: _getItem, child: const Text('getItem')),
                ElevatedButton(
                    onPressed: _removeItem, child: const Text('removeItem')),
                ElevatedButton(
                    onPressed: _getLength, child: const Text('length')),
                ElevatedButton(
                    onPressed: _keyAt, child: const Text('key(0)')),
                ElevatedButton(
                    onPressed: _clear, child: const Text('clear')),
                ElevatedButton(
                    onPressed: _setSessionItem,
                    child: const Text('session.setItem')),
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
                Text('length: $_length'),
                Text('getItem结果: $_item'),
                Text('key(0): $_keyAt0'),
              ],
            ),
          ),
          const Divider(height: 1),
          // WebView 区域
          Expanded(
            child: InAppWebView(
              // localStorage/sessionStorage 依赖真实来源(origin)。使用 initialData 时
              // 必须提供 baseUrl，否则页面运行在 about:blank(opaque origin)，
              // WebStorage 不可用，导致 setItem/getItem/length/key 全部无效。
              initialData: InAppWebViewInitialData(
                data: _testHtml,
                baseUrl: WebUri('https://localhost/'),
              ),
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
