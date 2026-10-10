/// Demo 24: 缓存与状态管理
///
/// 功能说明：直观演示 InAppWebViewController 的缓存清理、历史清理、
/// SSL 偏好、焦点控制、加载状态、定时器暂停/恢复、网页归档保存等
/// 状态管理类 API。
///
/// 直观化设计：
///   - 内嵌页面带有「JS 定时器动画」（旋转方块 + 秒表 + 递增计数器），
///     点 pauseTimers 时动画会肉眼可见地冻结，resumeTimers 后恢复；
///   - clearHistory 前后通过 canGoBack() 对比，证明历史确实被清空；
///   - isLoading / isSecureContext / getDefaultUserAgent 的返回值实时展示。
///
/// 对应接口：
///   - clearAllCache(includeDiskFiles): Future<void> (静态)
///   - clearCache(): Future<void> (已废弃，建议用 clearAllCache)
///   - clearFocus(): Future<void>
///   - clearHistory(): Future<void>
///   - clearSslPreferences(): Future<void>
///   - getDefaultUserAgent(): Future<String> (静态)
///   - isLoading(): Future<bool>
///   - stopLoading(): Future<void>
///   - pauseTimers(): Future<void>
///   - resumeTimers(): Future<void>
///   - saveWebArchive(filePath, autoname): Future<String?>
///   - isSecureContext(): Future<bool>

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String _kTag = 'InAppWebView_CacheState';

/// CacheStatePage - 缓存与状态管理
class CacheStatePage extends StatefulWidget {
  const CacheStatePage({super.key});

  @override
  State<CacheStatePage> createState() => _CacheStatePageState();
}

class _CacheStatePageState extends State<CacheStatePage> {
  InAppWebViewController? _controller;

  String _statusText = '页面加载中…';
  bool _statusIsError = false;
  bool _timersPaused = false;

  // 各接口返回值实时展示
  String _uaValue = '(点按钮获取)';
  String _loadingValue = '(点按钮查询)';
  String _secureValue = '(点按钮查询)';
  String _historyValue = '(点按钮查询)';
  String _archiveValue = '(点按钮保存)';

  /// 内嵌测试页：用 setInterval 驱动一个可见动画 + 秒表 + 计数器，
  /// 这样 pauseTimers / resumeTimers 的效果一眼可见。
  static const String _testHtml = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body { font-family: sans-serif; padding: 16px; text-align:center;
           background:#fafafa; }
    #box { width:80px; height:80px; margin:16px auto; border-radius:12px;
           background:linear-gradient(135deg,#42a5f5,#7e57c2);
           animation: spin 1.5s linear infinite; }
    @keyframes spin { to { transform: rotate(360deg); } }
    .num { font-size:40px; font-weight:bold; color:#1976d2; }
    .label { color:#666; font-size:13px; }
    a { display:inline-block; margin:8px; padding:8px 14px;
        background:#1976d2; color:#fff; border-radius:6px;
        text-decoration:none; }
  </style>
</head>
<body>
  <h3>JS 定时器动画</h3>
  <div id="box"></div>
  <div class="num" id="counter">0</div>
  <div class="label">setInterval 每 100ms 自增（暂停定时器时会冻结）</div>
  <div class="num" id="clock" style="color:#e53935">00:00.0</div>
  <div class="label">JS 秒表</div>
  <hr>
  <div class="label">点击下方链接可建立浏览历史（用于测试 clearHistory）</div>
  <a href="https://flutter.dev">打开 flutter.dev</a>
  <a href="https://github.com">打开 github.com</a>
  <script>
    var n = 0, t = 0;
    setInterval(function(){ n++; document.getElementById('counter').innerText = n; }, 100);
    setInterval(function(){
      t += 0.1;
      var m = Math.floor(t/60), s = (t%60).toFixed(1);
      document.getElementById('clock').innerText =
        (m<10?'0':'')+m+':'+(s<10?'0':'')+s;
    }, 100);
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

  // ─── 结果记录辅助 ─────────────────────────────────────────────────────────

  void _setStatus(String text, {bool isError = false}) {
    if (!mounted) return;
    setState(() {
      _statusText = text;
      _statusIsError = isError;
    });
  }

  Future<void> _run(String label, Future<void> Function() action) async {
    dev.log('$label called', name: _kTag);
    _setStatus('$label 执行中…');
    try {
      await action();
      dev.log('$label succeeded', name: _kTag);
    } catch (e, stack) {
      dev.log('$label failed', name: _kTag, error: e, stackTrace: stack);
      _setStatus('$label 失败：$e', isError: true);
    }
  }

  // ─── 核心功能方法 ────────────────────────────────────────────────────────

  Future<void> _getDefaultUserAgent() => _run('getDefaultUserAgent', () async {
        final ua = await InAppWebViewController.getDefaultUserAgent();
        if (!mounted) return;
        setState(() => _uaValue = ua);
        _setStatus('已获取默认 UA');
      });

  Future<void> _clearAllCache() => _run('clearAllCache', () async {
        await InAppWebViewController.clearAllCache(includeDiskFiles: true);
        _setStatus('已清除所有缓存（含磁盘文件）');
      });

  Future<void> _clearCache() => _run('clearCache(已废弃)', () async {
        await _controller?.clearCache();
        _setStatus('已调用实例方法 clearCache（已废弃）');
      });

  Future<void> _clearFocus() => _run('clearFocus', () async {
        await _controller?.clearFocus();
        _setStatus('已清除 WebView 焦点');
      });

  /// 清除历史前后各查一次 canGoBack，用对比证明历史被清空
  Future<void> _clearHistory() => _run('clearHistory', () async {
        final before = await _controller?.canGoBack() ?? false;
        await _controller?.clearHistory();
        final after = await _controller?.canGoBack() ?? false;
        if (!mounted) return;
        setState(() => _historyValue =
            'clearHistory 前 canGoBack=$before → 后 canGoBack=$after');
        _setStatus('已清除历史记录');
      });

  Future<void> _clearSslPreferences() =>
      _run('clearSslPreferences', () async {
        await _controller?.clearSslPreferences();
        _setStatus('已清除 SSL 偏好（下次访问将重新校验证书）');
      });

  Future<void> _checkLoading() => _run('isLoading', () async {
        final loading = await _controller?.isLoading() ?? false;
        if (!mounted) return;
        setState(() => _loadingValue = loading ? 'true（加载中）' : 'false（空闲）');
        _setStatus('isLoading = $loading');
      });

  Future<void> _stopLoading() => _run('stopLoading', () async {
        await _controller?.stopLoading();
        _setStatus('已停止当前加载');
      });

  Future<void> _togglePauseTimers() {
    if (_timersPaused) {
      return _run('resumeTimers', () async {
        await _controller?.resumeTimers();
        if (!mounted) return;
        setState(() => _timersPaused = false);
        _setStatus('已恢复定时器 —— 观察上方动画/秒表恢复运行');
      });
    }
    return _run('pauseTimers', () async {
      await _controller?.pauseTimers();
      if (!mounted) return;
      setState(() => _timersPaused = true);
      _setStatus('已暂停定时器 —— 观察上方动画/秒表已冻结');
    });
  }

  Future<void> _saveWebArchive() => _run('saveWebArchive', () async {
        final path = await _controller?.saveWebArchive(
          filePath: 'cache_archive',
          autoname: true,
        );
        if (!mounted) return;
        setState(() => _archiveValue = path ?? '(返回 null / 保存失败)');
        _setStatus('已调用 saveWebArchive');
      });

  Future<void> _checkSecureContext() => _run('isSecureContext', () async {
        final secure = await _controller?.isSecureContext() ?? false;
        if (!mounted) return;
        setState(() =>
            _secureValue = secure ? 'true（安全上下文）' : 'false（非安全上下文）');
        _setStatus('isSecureContext = $secure');
      });

  // ─── UI 构建 ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('[024] 缓存与状态管理')),
      body: Column(
        children: [
          _hintBanner(
            '内嵌页有一个 JS 定时器动画 + 秒表。点「暂停/恢复定时器」可看到它'
            '冻结与恢复；其余接口的返回值会实时显示在下方结果区。',
          ),
          // 控制区（分组、可滚动）
          SizedBox(
            height: 250,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 最直观的一组：定时器暂停/恢复
                  _sectionTitle('定时器控制（效果最直观）'),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _togglePauseTimers,
                      icon: Icon(_timersPaused
                          ? Icons.play_arrow
                          : Icons.pause),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _timersPaused ? Colors.orange : Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      label: Text(_timersPaused
                          ? 'resumeTimers（恢复动画）'
                          : 'pauseTimers（冻结动画）'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _sectionTitle('状态查询'),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _btn('isLoading', _checkLoading),
                    _btn('isSecureContext', _checkSecureContext),
                    _btn('getDefaultUserAgent', _getDefaultUserAgent),
                    _btn('stopLoading', _stopLoading),
                  ]),
                  const SizedBox(height: 8),
                  _sectionTitle('清理操作'),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _btn('clearAllCache', _clearAllCache),
                    _btn('clearCache(废弃)', _clearCache),
                    _btn('clearFocus', _clearFocus),
                    _btn('clearHistory', _clearHistory),
                    _btn('clearSslPreferences', _clearSslPreferences),
                    _btn('saveWebArchive', _saveWebArchive),
                  ]),
                ],
              ),
            ),
          ),
          // 结果区
          _resultPanel(),
          const Divider(height: 1),
          // WebView 区域
          Expanded(
            child: InAppWebView(
              initialData: InAppWebViewInitialData(data: _testHtml),
              onWebViewCreated: (controller) {
                _controller = controller;
                dev.log('onWebViewCreated', name: _kTag);
              },
              onLoadStop: (controller, url) {
                _controller = controller;
                _setStatus('页面加载完成，可执行操作');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultPanel() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(_statusIsError ? Icons.error : Icons.info_outline,
                size: 16,
                color: _statusIsError ? Colors.red : Colors.blue),
            const SizedBox(width: 6),
            Expanded(
              child: Text(_statusText,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _statusIsError ? Colors.red : Colors.black87)),
            ),
          ]),
          const SizedBox(height: 6),
          _kv('isLoading', _loadingValue),
          _kv('isSecureContext', _secureValue),
          _kv('clearHistory', _historyValue),
          _kv('saveWebArchive', _archiveValue),
          _kv('defaultUserAgent', _uaValue, wrap: true),
        ],
      ),
    );
  }

  Widget _kv(String k, String v, {bool wrap = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: RichText(
        maxLines: wrap ? 3 : 1,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: const TextStyle(fontSize: 11, color: Colors.black87),
          children: [
            TextSpan(
                text: '$k: ',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.teal)),
            TextSpan(text: v),
          ],
        ),
      ),
    );
  }

  Widget _hintBanner(String text) {
    return Container(
      width: double.infinity,
      color: Colors.blue[50],
      padding: const EdgeInsets.all(10),
      child: Text(text,
          style: const TextStyle(fontSize: 12, height: 1.4)),
    );
  }

  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Text(t,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 13, color: Colors.indigo)),
    );
  }

  Widget _btn(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: const Size(0, 34),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
