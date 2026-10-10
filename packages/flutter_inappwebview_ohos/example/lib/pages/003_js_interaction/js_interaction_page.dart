/// Demo 3: JsInteraction
///
/// 功能说明：直观展示 JavaScript Handler（JS ↔ Dart 双向通信桥）的作用，而不仅仅
/// 是查看状态。核心演示「JS 调用 → Dart 收到参数并计算 → 返回值回到 JS 并显示」的
/// 完整往返链路，以及 evaluateJavascript 执行 JS 并取回结果。
///
/// 对应接口：
///   - addJavaScriptHandler(handlerName, callback): void
///   - removeJavaScriptHandler(handlerName): JavaScriptHandlerCallback?
///   - hasJavaScriptHandler(handlerName): bool
///   - evaluateJavascript(source): Future<dynamic>
///
/// Handler 是做什么的？
///   网页里的 JS 通过 window.flutter_inappwebview.callHandler('名字', 参数...)
///   把数据发给 Dart；Dart 端注册的回调收到参数、处理后 return 一个值；这个返回值
///   会作为 Promise 的结果回到 JS。这样网页就能调用「原生能力」并拿到结果。
///   本页用一个「计算器 Handler」演示：JS 传两个数 → Dart 求和 → 结果显示回网页。
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String _kTag = 'InAppWebView_JsInteraction';

class JsInteractionPage extends StatefulWidget {
  const JsInteractionPage({super.key});

  @override
  State<JsInteractionPage> createState() => _JsInteractionPageState();
}

class _JsInteractionPageState extends State<JsInteractionPage> {
  InAppWebViewController? _controller;

  bool _handlerRegistered = false;
  int _dartReceivedCount = 0;
  final List<String> _dartLog = [];

  /// 演示页面：两个按钮分别调用「已注册」和「计算器」Handler，并把 Dart 的返回值显示在页面上。
  static const String _testHtml = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body { font-family: sans-serif; padding: 16px; font-size: 15px; }
    button { font-size: 15px; padding: 10px 14px; margin: 6px 0; width: 100%;
             border: none; border-radius: 8px; background: #1976d2; color: #fff; }
    .box { background: #f3f3f3; border-radius: 8px; padding: 12px; margin-top: 10px;
           white-space: pre-wrap; min-height: 20px; }
    .num { display:flex; gap:8px; }
    .num input { flex:1; font-size:15px; padding:8px; }
    h3 { margin: 16px 0 4px; }
  </style>
</head>
<body>
  <h3>① 计算器 Handler（看 Dart 返回值）</h3>
  <div class="num">
    <input id="a" type="number" value="3">
    <input id="b" type="number" value="4">
  </div>
  <button onclick="callSum()">JS 调用 sumHandler(a, b)</button>
  <div class="box" id="sumOut">点击上面按钮，这里显示 Dart 返回的结果</div>

  <h3>② 普通 Handler（Dart 端计数）</h3>
  <button onclick="callEcho()">JS 调用 echoHandler('hello')</button>
  <div class="box" id="echoOut">这里显示 Dart 返回的回执</div>

  <script>
    async function callSum() {
      var a = Number(document.getElementById('a').value);
      var b = Number(document.getElementById('b').value);
      var out = document.getElementById('sumOut');
      if (!window.flutter_inappwebview) { out.innerText = 'bridge 不可用'; return; }
      try {
        // callHandler 返回 Promise，其结果就是 Dart 回调 return 的值
        var result = await window.flutter_inappwebview.callHandler('sumHandler', a, b);
        out.innerText = 'Dart 返回: ' + JSON.stringify(result)
          + '\\n（即 ' + a + ' + ' + b + ' 由 Dart 计算）';
      } catch (e) {
        out.innerText = '调用失败(可能未注册): ' + e;
      }
    }
    async function callEcho() {
      var out = document.getElementById('echoOut');
      if (!window.flutter_inappwebview) { out.innerText = 'bridge 不可用'; return; }
      try {
        var result = await window.flutter_inappwebview.callHandler('echoHandler', 'hello');
        out.innerText = 'Dart 返回: ' + JSON.stringify(result);
      } catch (e) {
        out.innerText = '调用失败(可能未注册): ' + e;
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

  void _log(String msg) {
    dev.log(msg, name: _kTag);
    if (!mounted) return;
    setState(() {
      _dartLog.insert(0, msg);
      if (_dartLog.length > 30) _dartLog.removeLast();
    });
  }

  /// 注册两个 Handler：sumHandler(求和) 和 echoHandler(回显+计数)。
  void _registerHandlers() {
    final c = _controller;
    if (c == null) return;

    c.addJavaScriptHandler(
      handlerName: 'sumHandler',
      callback: (args) {
        // args 是 JS 传来的参数列表：[a, b]
        final a = (args.isNotEmpty ? args[0] : 0) as num;
        final b = (args.length > 1 ? args[1] : 0) as num;
        final sum = a + b;
        _dartReceivedCount++;
        _log('收到 sumHandler(args=$args) → 计算 $a+$b=$sum，返回给 JS');
        // 这个返回值会成为 JS 侧 callHandler 的 Promise 结果
        return {'sum': sum, 'from': 'Dart'};
      },
    );

    c.addJavaScriptHandler(
      handlerName: 'echoHandler',
      callback: (args) {
        _dartReceivedCount++;
        _log('收到 echoHandler(args=$args)，返回回执');
        return {'echo': args.isNotEmpty ? args[0] : null, 'ts': DateTime.now().toIso8601String()};
      },
    );

    setState(() => _handlerRegistered = true);
    _log('已注册 sumHandler / echoHandler');
  }

  void _removeHandlers() {
    final c = _controller;
    if (c == null) return;
    c.removeJavaScriptHandler(handlerName: 'sumHandler');
    c.removeJavaScriptHandler(handlerName: 'echoHandler');
    setState(() => _handlerRegistered = false);
    _log('已移除两个 Handler（此后网页调用会失败）');
  }

  void _checkHandler() {
    final c = _controller;
    if (c == null) return;
    final has = c.hasJavaScriptHandler(handlerName: 'sumHandler') ?? false;
    _log('hasJavaScriptHandler(sumHandler) = $has');
  }

  /// evaluateJavascript：Dart 主动执行 JS 并取回结果（与 Handler 方向相反）。
  Future<void> _evaluateJs() async {
    final c = _controller;
    if (c == null) return;
    final result = await c.evaluateJavascript(
        source: "(function(){ return document.title + ' @ ' + (1+2); })()");
    _log('evaluateJavascript 返回: $result');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('[003] JS Handler 双向通信')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: _handlerRegistered ? Colors.green.shade50 : Colors.orange.shade50,
            padding: const EdgeInsets.all(10),
            child: Text(
              _handlerRegistered
                  ? '✅ Handler 已注册：网页按钮可调用，Dart 会返回结果'
                  : '⚠️ Handler 未注册：先点「注册」，再点网页里的按钮观察返回值',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ElevatedButton(
                    onPressed: _handlerRegistered ? null : _registerHandlers,
                    child: const Text('注册 Handler')),
                ElevatedButton(
                    onPressed: _handlerRegistered ? _removeHandlers : null,
                    child: const Text('移除 Handler')),
                OutlinedButton(
                    onPressed: _checkHandler, child: const Text('检查存在')),
                OutlinedButton(
                    onPressed: _evaluateJs, child: const Text('evaluateJS')),
              ],
            ),
          ),
          // 网页区
          Expanded(
            flex: 3,
            child: InAppWebView(
              initialData: InAppWebViewInitialData(data: _testHtml),
              initialSettings: InAppWebViewSettings(javaScriptEnabled: true),
              onWebViewCreated: (controller) {
                _controller = controller;
                dev.log('onWebViewCreated', name: _kTag);
              },
            ),
          ),
          // Dart 侧调用日志
          Container(
            height: 150,
            width: double.infinity,
            color: Colors.black87,
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dart 侧收到调用: $_dartReceivedCount 次',
                    style: const TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.bold)),
                const Divider(color: Colors.white24, height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: _dartLog.length,
                    itemBuilder: (_, i) => Text(
                      _dartLog[i],
                      style: const TextStyle(
                          color: Colors.lightGreenAccent,
                          fontFamily: 'monospace',
                          fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
