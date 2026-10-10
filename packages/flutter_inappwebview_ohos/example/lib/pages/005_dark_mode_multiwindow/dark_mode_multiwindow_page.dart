/// Demo 5: 高级设置的「可见效果」演示
///
/// 功能说明：直观体现三个设置项各自的作用，每个都配一个「实测」按钮，能看到
/// 开/关时行为的差异，而不只是设置一个布尔值。
///
/// 三个参数分别是做什么的？
///   - domStorageAccess (domStorageEnabled)：是否允许网页使用 localStorage /
///     sessionStorage。关闭后，网页里 window.localStorage 读写会抛异常或无效。
///     实测：写入再读取 localStorage，开→读到值，关→失败。
///   - multiWindowAccess (supportMultipleWindows)：是否允许网页通过
///     window.open() / target="_blank" 打开新窗口，并触发 onCreateWindow 回调。
///     实测：点击调用 window.open，开→触发 onCreateWindow(计数+1)，关→不触发。
///   - fileAccess (allowFileAccess)：是否允许 WebView 通过 file:// 加载本地文件。
///     控制的是对本地文件系统的访问权限（安全项），需以 file:// URL 加载才体现，
///     本页给出说明与当前值。
///
/// 对应接口：
///   - InAppWebViewSettings(domStorageEnabled, supportMultipleWindows, allowFileAccess)
///   - onCreateWindow(controller, createWindowAction): Future<bool?>
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String _kTag = 'InAppWebView_AdvancedSettings';

class DarkModeMultiwindowPage extends StatefulWidget {
  const DarkModeMultiwindowPage({super.key});

  @override
  State<DarkModeMultiwindowPage> createState() =>
      _DarkModeMultiwindowPageState();
}

class _DarkModeMultiwindowPageState extends State<DarkModeMultiwindowPage> {
  bool _domStorageAccess = true;
  bool _multiWindowAccess = true;
  bool _fileAccess = true;

  int _onCreateWindowCount = 0;
  String _domResult = '(未测试)';
  String _multiWindowResult = '(未测试)';

  InAppWebViewController? _controller;

  static const String _testHtml = '''
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<style>body{font-family:sans-serif;padding:16px;font-size:14px} .r{background:#f3f3f3;padding:10px;border-radius:6px;margin-top:8px;white-space:pre-wrap}</style>
</head>
<body>
  <h3>DOM Storage 测试</h3>
  <div class="r" id="dom">等待 Dart 触发测试</div>
  <h3>多窗口测试</h3>
  <div class="r" id="win">等待 Dart 触发测试</div>
  <script>
    function testDomStorage() {
      var out = document.getElementById('dom');
      try {
        window.localStorage.setItem('demo_key', 'demo_value_' + Date.now());
        var v = window.localStorage.getItem('demo_key');
        out.innerText = '✅ localStorage 可用，读到: ' + v;
        return 'ok:' + v;
      } catch (e) {
        out.innerText = '❌ localStorage 不可用: ' + e;
        return 'error:' + e;
      }
    }
    function testOpenWindow() {
      var out = document.getElementById('win');
      try {
        var w = window.open('https://flutter.dev', '_blank');
        out.innerText = '已调用 window.open()，若多窗口开启，Dart 会收到 onCreateWindow';
        return w ? 'called' : 'blocked';
      } catch (e) {
        out.innerText = '❌ window.open 异常: ' + e;
        return 'error';
      }
    }
  </script>
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
    dev.log('Page disposed', name: _kTag);
    super.dispose();
  }

  /// 修改设置需要重建 WebView 才能对 domStorage/multiWindow 等初始化项生效。
  String get _rebuildKey => '$_domStorageAccess$_multiWindowAccess$_fileAccess';

  Future<void> _testDomStorage() async {
    final c = _controller;
    if (c == null) return;
    final r = await c.evaluateJavascript(source: 'testDomStorage()');
    dev.log('domStorage test -> $r', name: _kTag);
    if (!mounted) return;
    setState(() {
      _domResult = _domStorageAccess
          ? '开启：网页应能读写 localStorage（见网页内绿色结果）'
          : '关闭：网页 localStorage 读写应失败（见网页内红色结果）';
    });
  }

  Future<void> _testMultiWindow() async {
    final c = _controller;
    if (c == null) return;
    final before = _onCreateWindowCount;
    await c.evaluateJavascript(source: 'testOpenWindow()');
    // 给 onCreateWindow 回调一点时间触发
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      final triggered = _onCreateWindowCount > before;
      _multiWindowResult = _multiWindowAccess
          ? (triggered
              ? '开启：window.open 触发了 onCreateWindow ✅'
              : '开启：已调用 window.open（等待回调…）')
          : '关闭：window.open 未触发 onCreateWindow ❌（符合预期）';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('[005] 高级设置的可见效果')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                SwitchListTile(
                  dense: true,
                  title: const Text('domStorageAccess（localStorage 可用性）'),
                  subtitle: Text('测试结果: $_domResult',
                      style: const TextStyle(fontSize: 11)),
                  value: _domStorageAccess,
                  onChanged: (v) => setState(() => _domStorageAccess = v),
                ),
                SwitchListTile(
                  dense: true,
                  title: const Text('multiWindowAccess（window.open 是否触发回调）'),
                  subtitle: Text('测试结果: $_multiWindowResult',
                      style: const TextStyle(fontSize: 11)),
                  value: _multiWindowAccess,
                  onChanged: (v) => setState(() => _multiWindowAccess = v),
                ),
                SwitchListTile(
                  dense: true,
                  title: const Text('fileAccess（允许 file:// 访问本地文件）'),
                  subtitle: const Text('安全项：控制 WebView 能否加载本地文件，需 file:// URL 才体现',
                      style: TextStyle(fontSize: 11)),
                  value: _fileAccess,
                  onChanged: (v) => setState(() => _fileAccess = v),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          onPressed: _testDomStorage,
                          child: const Text('实测 DOMStorage')),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                          onPressed: _testMultiWindow,
                          child: const Text('实测 多窗口')),
                    ),
                  ],
                ),
                Text('onCreateWindow 触发次数: $_onCreateWindowCount',
                    style: const TextStyle(fontSize: 12, color: Colors.blue)),
                const Text('提示：改动开关后 WebView 会自动重建以使设置生效',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: InAppWebView(
              key: ValueKey(_rebuildKey),
              initialData: InAppWebViewInitialData(data: _testHtml),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                domStorageEnabled: _domStorageAccess,
                supportMultipleWindows: _multiWindowAccess,
                allowFileAccess: _fileAccess,
                javaScriptCanOpenWindowsAutomatically: _multiWindowAccess,
              ),
              onWebViewCreated: (controller) {
                _controller = controller;
                dev.log('onWebViewCreated', name: _kTag);
              },
              onCreateWindow: (controller, createWindowAction) async {
                dev.log('onCreateWindow: ${createWindowAction.request.url}',
                    name: _kTag);
                if (!mounted) return false;
                setState(() => _onCreateWindowCount++);
                // 返回 false：不实际创建新窗口，仅用于演示回调是否触发
                return false;
              },
            ),
          ),
        ],
      ),
    );
  }
}
