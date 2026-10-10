/// Demo 26: 回调事件合集
///
/// 功能说明：集中演示 README 接口说明中尚未被其它 demo 覆盖的
/// InAppWebView 回调事件。内嵌测试页里每个按钮触发一类回调，
/// 触发后：
///   - 对应事件卡片会「点亮」并显示累计触发次数；
///   - 顶部实时滚动事件日志，最新一条高亮；
/// 让"哪个回调被触发了、触发了几次、带了什么参数"一目了然。
///
/// 对应接口（均为 ohos Support = yes）：
///   - onLoadResource(controller, LoadedResource): void
///   - onDownloadStartRequest(controller, DownloadStartRequest): void
///   - onCloseWindow(controller): void
///   - onFormResubmission(controller, WebUri?): void
///   - onOverScrolled(controller, x, y, clampedX, clampedY): void
///   - onEnterFullscreen(controller): void
///   - onExitFullscreen(controller): void
///   - onPrintRequest(controller, WebUri?): Future<bool?>
///   - onGeolocationPermissionsShowPrompt(controller, origin): void
///   - onRenderProcessGone(controller, RenderProcessGoneDetail): void
///   - onRenderProcessResponsive(controller): void

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String _kTag = 'InAppWebView_CallbackEvents';

/// CallbackEventsPage - 回调事件合集
class CallbackEventsPage extends StatefulWidget {
  const CallbackEventsPage({super.key});

  @override
  State<CallbackEventsPage> createState() => _CallbackEventsPageState();
}

class _CallbackEventsPageState extends State<CallbackEventsPage> {
  /// 所有被监控的回调名（用于生成事件卡片，即使未触发也显示为灰色）
  static const _allEvents = <String>[
    'onLoadResource',
    'onDownloadStartRequest',
    'onEnterFullscreen',
    'onExitFullscreen',
    'onPrintRequest',
    'onGeolocationPermissionsShowPrompt',
    'onCloseWindow',
    'onFormResubmission',
    'onOverScrolled',
    'onRenderProcessGone',
    'onRenderProcessResponsive',
  ];

  final Map<String, int> _eventCounts = {};
  final List<_LogEntry> _eventLog = [];
  String _lastEvent = '';

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

  void _recordEvent(String name, [String? detail]) {
    dev.log('Event: $name ${detail ?? ""}', name: _kTag);
    if (!mounted) return;
    setState(() {
      _eventCounts[name] = (_eventCounts[name] ?? 0) + 1;
      _lastEvent = name;
      _eventLog.insert(0, _LogEntry(name, detail ?? ''));
      if (_eventLog.length > 60) _eventLog.removeLast();
    });
  }

  void _clearLog() {
    setState(() {
      _eventCounts.clear();
      _eventLog.clear();
      _lastEvent = '';
    });
  }

  /// 触发各种事件的测试 HTML 页面
  static const String _testHtml = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body { font-family: sans-serif; padding: 16px; }
    button { display:block; margin:8px 0; padding:12px; width:100%;
             font-size:15px; border:none; border-radius:6px; color:#fff; }
    .btn-load { background:#1976d2; }
    .btn-download { background:#388e3c; }
    .btn-fullscreen { background:#f57c00; }
    .btn-print { background:#7b1fa2; }
    .btn-geo { background:#c62828; }
    .btn-form { background:#00838f; }
    .btn-close { background:#5d4037; }
    .scroll-area { height: 1200px; margin-top:12px;
                   background: linear-gradient(#e3f2fd,#fff);
                   border-radius:8px; padding:12px; }
  </style>
</head>
<body>
  <h3>回调事件测试页</h3>
  <p>点击按钮触发对应回调，观察上方卡片点亮与事件日志。</p>

  <button class="btn-load" onclick="loadImg()">onLoadResource（加载图片资源）</button>
  <button class="btn-download" onclick="triggerDownload()">onDownloadStartRequest（触发下载）</button>
  <button class="btn-fullscreen" onclick="enterFs()">onEnterFullscreen（进入全屏）</button>
  <button class="btn-print" onclick="window.print()">onPrintRequest（调用打印）</button>
  <button class="btn-geo" onclick="getGeo()">onGeolocationPermissionsShowPrompt（定位授权）</button>
  <button class="btn-close" onclick="window.close()">onCloseWindow（关闭窗口）</button>
  <button class="btn-form" onclick="document.forms[0].requestSubmit()">onFormResubmission（重复提交表单）</button>

  <form method="post" action="https://example.com/submit">
    <input name="q" value="test" type="hidden">
  </form>

  <div class="scroll-area">↓ 用力向下/向上滑动到底可触发 onOverScrolled ↓</div>

  <script>
    function loadImg() {
      var img = new Image();
      img.src = 'https://placehold.co/60x60?t=' + Date.now();
      document.body.appendChild(img);
    }
    function triggerDownload() {
      var a = document.createElement('a');
      a.href = 'https://placehold.co/100x100.png?d=' + Date.now();
      a.download = 'test.png';
      a.click();
    }
    function enterFs() {
      var elem = document.documentElement;
      if (elem.requestFullscreen) elem.requestFullscreen();
      else if (elem.webkitRequestFullscreen) elem.webkitRequestFullscreen();
    }
    function getGeo() {
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(function(){}, function(){});
      }
    }
  </script>
</body>
</html>
''';

  // ─── UI 构建 ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('[026] 回调事件合集'),
        actions: [
          IconButton(
            tooltip: '清空计数与日志',
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearLog,
          ),
        ],
      ),
      body: Column(
        children: [
          _hintBanner(
            '点击 WebView 内的按钮触发各类回调。触发后对应卡片会变绿并显示'
            '次数，事件日志实时滚动、最新一条高亮。全屏/滚动需在页面内操作。',
          ),
          // 事件卡片网格
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _allEvents.map(_eventChip).toList(),
            ),
          ),
          // 事件日志
          _logPanel(),
          const Divider(height: 1),
          // WebView 区域
          Expanded(
            child: InAppWebView(
              initialData: InAppWebViewInitialData(data: _testHtml),
              initialSettings: InAppWebViewSettings(
                useOnLoadResource: true,
                useOnDownloadStart: true,
                supportMultipleWindows: true,
                javaScriptCanOpenWindowsAutomatically: true,
                geolocationEnabled: true,
              ),
              onWebViewCreated: (controller) {
                dev.log('onWebViewCreated', name: _kTag);
              },
              onLoadResource: (controller, resource) {
                _recordEvent('onLoadResource', resource.url?.toString());
              },
              onDownloadStartRequest: (controller, request) {
                _recordEvent('onDownloadStartRequest',
                    'url=${request.url} mime=${request.mimeType}');
              },
              onCloseWindow: (controller) {
                _recordEvent('onCloseWindow');
              },
              onFormResubmission: (controller, url) async {
                _recordEvent('onFormResubmission', url?.toString());
                return null;
              },
              onOverScrolled: (controller, x, y, clampedX, clampedY) {
                _recordEvent('onOverScrolled',
                    'x=$x y=$y clampedX=$clampedX clampedY=$clampedY');
              },
              onEnterFullscreen: (controller) {
                _recordEvent('onEnterFullscreen');
              },
              onExitFullscreen: (controller) {
                _recordEvent('onExitFullscreen');
              },
              onPrintRequest: (controller, url, printJobController) async {
                _recordEvent('onPrintRequest', url?.toString());
                return false;
              },
              onGeolocationPermissionsShowPrompt: (controller, origin) async {
                _recordEvent(
                    'onGeolocationPermissionsShowPrompt', 'origin=$origin');
                return null;
              },
              onRenderProcessGone: (controller, detail) {
                _recordEvent('onRenderProcessGone',
                    'didCrash=${detail.didCrash} priority=${detail.rendererPriorityAtExit}');
              },
              onRenderProcessResponsive: (controller, url) async {
                _recordEvent('onRenderProcessResponsive', url?.toString());
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _eventChip(String name) {
    final count = _eventCounts[name] ?? 0;
    final fired = count > 0;
    final isLatest = name == _lastEvent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: fired ? Colors.green[100] : Colors.grey[200],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLatest ? Colors.orange : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            fired ? Icons.check_circle : Icons.circle_outlined,
            size: 13,
            color: fired ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            name,
            style: TextStyle(
                fontSize: 11,
                color: fired ? Colors.black87 : Colors.grey[600],
                fontWeight: fired ? FontWeight.w600 : FontWeight.normal),
          ),
          if (fired) ...[
            const SizedBox(width: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('$count',
                  style: const TextStyle(
                      fontSize: 10, color: Colors.white)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _logPanel() {
    return SizedBox(
      height: 120,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: _eventLog.isEmpty
            ? const Center(
                child: Text('(暂无事件，去下方页面点按钮触发)',
                    style: TextStyle(fontSize: 12, color: Colors.grey)))
            : ListView.builder(
                itemCount: _eventLog.length,
                itemBuilder: (ctx, i) {
                  final e = _eventLog[i];
                  final highlight = i == 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    color: highlight ? Colors.amber[100] : null,
                    child: Text(
                      '[${e.name}] ${e.detail}',
                      style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: highlight
                              ? FontWeight.bold
                              : FontWeight.normal),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _hintBanner(String text) {
    return Container(
      width: double.infinity,
      color: Colors.blue[50],
      padding: const EdgeInsets.all(10),
      child: Text(text, style: const TextStyle(fontSize: 12, height: 1.4)),
    );
  }
}

/// 日志条目
class _LogEntry {
  final String name;
  final String detail;
  const _LogEntry(this.name, this.detail);
}
