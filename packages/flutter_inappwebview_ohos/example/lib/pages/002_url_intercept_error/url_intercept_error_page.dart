/// Demo 2: URL 拦截与错误处理
///
/// 功能说明：每个回调都配一个「能主动触发」的按钮，点击后能直观看到该回调被调用
/// 及其效果，而不只是看计数器。
///
/// 对应接口：
///   - shouldOverrideUrlLoading：拦截导航，可放行(ALLOW)或取消(CANCEL)
///   - onReceivedError：页面/资源加载失败（如域名无法解析）
///   - onReceivedHttpError：服务器返回 4xx/5xx
///   - onConsoleMessage：接收网页 console.log/warn/error
///   - onPermissionRequest / onGeolocationPermissionsShowPrompt：权限请求
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String _kTag = 'InAppWebView_UrlInterceptError';

class UrlInterceptErrorPage extends StatefulWidget {
  const UrlInterceptErrorPage({super.key});

  @override
  State<UrlInterceptErrorPage> createState() => _UrlInterceptErrorPageState();
}

class _UrlInterceptErrorPageState extends State<UrlInterceptErrorPage> {
  InAppWebViewController? _controller;

  // 是否拦截（CANCEL）自定义 scheme 的导航
  bool _blockCustomScheme = true;
  final List<_Event> _events = [];

  /// 内含多种可触发回调的链接与脚本。
  static const String _testHtml = '''
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<style>body{font-family:sans-serif;padding:16px;font-size:15px}
a,button{display:block;margin:8px 0;font-size:15px;padding:10px;background:#1976d2;color:#fff;
border:none;border-radius:8px;text-decoration:none;text-align:center}</style></head>
<body>
  <h3>点击触发各类回调</h3>
  <a href="myapp://pay?order=123">① 自定义 scheme 链接 (触发 shouldOverrideUrlLoading)</a>
  <a href="https://flutter.dev">② 普通 https 链接 (放行导航)</a>
  <button onclick="console.log('来自网页的 console.log: ' + new Date().toLocaleTimeString())">③ 触发 console.log</button>
  <button onclick="console.error('来自网页的 console.error')">④ 触发 console.error</button>
  <button onclick="location.href='https://this-domain-should-not-exist-xyz-123.com'">⑤ 加载坏域名 (触发 onReceivedError)</button>
  <button onclick="location.href='https://httpstat.us/404'">⑥ 加载 404 (触发 onReceivedHttpError)</button>
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

  void _add(String type, String detail, Color color) {
    dev.log('$type: $detail', name: _kTag);
    if (!mounted) return;
    setState(() {
      _events.insert(0, _Event(type, detail, color));
      if (_events.length > 40) _events.removeLast();
    });
  }

  Future<void> _reload() async => _controller?.reload();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('[002] URL拦截与错误处理')),
      body: Column(
        children: [
          SwitchListTile(
            dense: true,
            title: const Text('拦截自定义 scheme（返回 CANCEL）'),
            subtitle: const Text('开：点①链接被拦截不跳转；关：放行（会因无法处理而报错）',
                style: TextStyle(fontSize: 11)),
            value: _blockCustomScheme,
            onChanged: (v) => setState(() => _blockCustomScheme = v),
          ),
          Row(
            children: [
              const SizedBox(width: 12),
              const Text('事件日志', style: TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(
                  onPressed: () => setState(() => _events.clear()),
                  child: const Text('清空')),
              TextButton(onPressed: _reload, child: const Text('重载')),
              const SizedBox(width: 8),
            ],
          ),
          // 事件日志区
          SizedBox(
            height: 140,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: _events.isEmpty
                  ? const Center(
                      child: Text('点击网页里的按钮触发回调',
                          style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _events.length,
                      itemBuilder: (_, i) {
                        final e = _events[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black87),
                              children: [
                                TextSpan(
                                    text: '${e.type}  ',
                                    style: TextStyle(
                                        color: e.color,
                                        fontWeight: FontWeight.bold)),
                                TextSpan(text: e.detail),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          const Divider(height: 8),
          Expanded(
            child: InAppWebView(
              initialData: InAppWebViewInitialData(data: _testHtml),
              initialSettings: InAppWebViewSettings(
                useShouldOverrideUrlLoading: true,
                javaScriptEnabled: true,
              ),
              onWebViewCreated: (controller) {
                _controller = controller;
                dev.log('onWebViewCreated', name: _kTag);
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final url = navigationAction.request.url;
                final scheme = url?.scheme ?? '';
                final isHttp = scheme == 'http' || scheme == 'https';
                if (!isHttp && _blockCustomScheme) {
                  _add('拦截', '$url → CANCEL（自定义 scheme 被拦截）', Colors.orange);
                  return NavigationActionPolicy.CANCEL;
                }
                _add('导航', '$url → ALLOW', Colors.green);
                return NavigationActionPolicy.ALLOW;
              },
              onReceivedError: (controller, request, error) {
                _add('加载错误', '${error.type}: ${error.description}', Colors.red);
              },
              onReceivedHttpError: (controller, request, response) {
                _add('HTTP错误', 'status=${response.statusCode} ${request.url}',
                    Colors.red);
              },
              onConsoleMessage: (controller, consoleMessage) {
                _add('Console[${consoleMessage.messageLevel}]',
                    consoleMessage.message, Colors.blueGrey);
              },
              onPermissionRequest: (controller, permissionRequest) async {
                _add('权限请求', '${permissionRequest.resources}', Colors.purple);
                return PermissionResponse(
                  resources: permissionRequest.resources,
                  action: PermissionResponseAction.GRANT,
                );
              },
              onGeolocationPermissionsShowPrompt: (controller, origin) async {
                _add('地理位置权限', origin, Colors.purple);
                return GeolocationPermissionShowPromptResponse(
                    origin: origin, allow: true, retain: false);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Event {
  _Event(this.type, this.detail, this.color);
  final String type;
  final String detail;
  final Color color;
}
