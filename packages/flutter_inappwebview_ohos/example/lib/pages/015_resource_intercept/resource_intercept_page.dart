/// Demo 15: 资源加载拦截
///
/// 功能说明：直观展示 shouldInterceptRequest 拦截资源请求的两种效果——放行原始
/// 请求，或用自定义响应「替换」掉原始内容；并展示 CustomPathHandler 处理本地资源。
///
/// 对应接口：
///   - shouldInterceptRequest(controller, request): Future<WebResourceResponse?>
///       返回 null → 放行原始请求；返回 WebResourceResponse → 用它替换响应内容
///   - shouldInterceptAjaxRequest：拦截 XHR/fetch
///   - WebViewAssetLoader + CustomPathHandler：本地资源处理
import 'dart:developer' as dev;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String _kTag = 'InAppWebView_ResourceIntercept';

class ResourceInterceptPage extends StatefulWidget {
  const ResourceInterceptPage({super.key});

  @override
  State<ResourceInterceptPage> createState() => _ResourceInterceptPageState();
}

class _ResourceInterceptPageState extends State<ResourceInterceptPage> {
  InAppWebViewController? _controller;

  // 是否把对某个图片的请求替换为自定义内容
  bool _replaceImage = true;
  int _interceptCount = 0;
  int _ajaxCount = 0;
  int _assetHandleCount = 0;
  final List<String> _log = [];
  late final CustomPathHandler _customHandler;

  static const String _testHtml = '''
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<style>body{font-family:sans-serif;padding:16px;font-size:15px}
button{font-size:15px;padding:10px;margin:6px 0;width:100%;background:#1976d2;color:#fff;border:none;border-radius:8px}
img{max-width:100%;border:1px solid #ccc;margin-top:8px}
#result{background:#f3f3f3;padding:10px;border-radius:6px;margin-top:8px;white-space:pre-wrap}</style></head>
<body>
  <h3>资源拦截演示</h3>
  <p>下面这张图的请求会被 Dart 拦截：</p>
  <img id="pic" src="https://example.com/original-image.png"
       onerror="this.alt='(图片请求被处理)'">
  <button onclick="loadAjax()">发送 AJAX 请求</button>
  <div id="result">AJAX 结果显示处</div>
  <script>
    function loadAjax(){
      var xhr=new XMLHttpRequest();
      xhr.open('GET','https://jsonplaceholder.typicode.com/todos/1');
      xhr.onload=function(){document.getElementById('result').innerText='AJAX 返回:\\n'+xhr.responseText;};
      xhr.onerror=function(){document.getElementById('result').innerText='AJAX 出错';};
      xhr.send();
    }
  </script>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    dev.log('Page appeared', name: _kTag);
    _customHandler = _MyCustomPathHandler(
      path: 'custom/',
      onHandle: () {
        if (!mounted) return;
        setState(() => _assetHandleCount++);
      },
    );
  }

  @override
  void dispose() {
    dev.log('Page disposed', name: _kTag);
    super.dispose();
  }

  void _logLine(String s) {
    dev.log(s, name: _kTag);
    if (!mounted) return;
    setState(() {
      _log.insert(0, s);
      if (_log.length > 30) _log.removeLast();
    });
  }

  Future<void> _reload() async => _controller?.reload();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('[015] 资源加载拦截')),
      body: Column(
        children: [
          SwitchListTile(
            dense: true,
            title: const Text('替换图片请求的响应'),
            subtitle: const Text(
                '开：拦截到 original-image.png 时返回自定义 SVG；关：放行(返回null)',
                style: TextStyle(fontSize: 11)),
            value: _replaceImage,
            onChanged: (v) {
              setState(() => _replaceImage = v);
              _reload();
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                    child: Text('资源拦截:$_interceptCount  AJAX:$_ajaxCount  '
                        'PathHandler:$_assetHandleCount',
                        style: const TextStyle(fontSize: 12))),
                TextButton(
                    onPressed: () => setState(() => _log.clear()),
                    child: const Text('清空')),
                TextButton(onPressed: _reload, child: const Text('重载')),
              ],
            ),
          ),
          SizedBox(
            height: 110,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6)),
              child: ListView.builder(
                itemCount: _log.length,
                itemBuilder: (_, i) => Text(_log[i],
                    style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
              ),
            ),
          ),
          const Divider(height: 8),
          Expanded(
            child: InAppWebView(
              initialData: InAppWebViewInitialData(data: _testHtml),
              initialSettings: InAppWebViewSettings(
                useShouldInterceptRequest: true,
                useShouldInterceptAjaxRequest: true,
                javaScriptEnabled: true,
                webViewAssetLoader: WebViewAssetLoader(
                  pathHandlers: [_customHandler],
                ),
              ),
              onWebViewCreated: (controller) {
                _controller = controller;
                dev.log('onWebViewCreated', name: _kTag);
              },
              shouldInterceptRequest: (controller, request) async {
                final url = request.url.toString();
                _interceptCount++;
                // 命中目标图片且开关开启 → 用自定义 SVG 替换
                if (_replaceImage && url.contains('original-image.png')) {
                  _logLine('替换: $url → 自定义SVG');
                  final svg = '<svg xmlns="http://www.w3.org/2000/svg" width="300" '
                      'height="80"><rect width="100%" height="100%" fill="#4caf50"/>'
                      '<text x="12" y="46" fill="white" font-size="20">'
                      'Replaced by Dart</text></svg>';
                  return WebResourceResponse(
                    contentType: 'image/svg+xml',
                    contentEncoding: 'utf-8',
                    data: Uint8List.fromList(svg.codeUnits),
                  );
                }
                _logLine('放行: $url');
                return null;
              },
              shouldInterceptAjaxRequest: (controller, ajaxRequest) async {
                _ajaxCount++;
                _logLine('AJAX拦截: ${ajaxRequest.url}');
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MyCustomPathHandler extends CustomPathHandler {
  _MyCustomPathHandler({required super.path, required this.onHandle});

  final VoidCallback onHandle;

  @override
  Future<WebResourceResponse?> handle(String path) async {
    dev.log('_MyCustomPathHandler.handle: $path', name: _kTag);
    onHandle();
    return WebResourceResponse(
      contentType: 'text/html',
      contentEncoding: 'utf-8',
      data: Uint8List.fromList(
          '<h1>Custom Path Handler Response: $path</h1>'.codeUnits),
    );
  }
}
