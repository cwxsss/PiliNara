/// Demo 25: 上下文菜单与高级导航
///
/// 功能说明：直观演示三个功能模块：
/// 1. ContextMenu（上下文菜单）—— 长按页面元素弹出自定义菜单项
/// 2. 高级导航历史 —— 通过顶部按钮加载多个站点建立真实历史，再用
///    goForward/goBackOrForward/goTo/canGoBackOrForward 在其间跳转，
///    页面顶部实时显示「当前 URL」与「完整历史列表（高亮当前项）」，
///    可以直观看到导航确实发生了。
/// 3. callAsyncJavaScript —— 执行异步 JS 函数并展示返回值
///
/// 对应接口：
///   - setContextMenu(ContextMenu?): void
///   - ContextMenu(menuItems, onCreateContextMenu, onContextMenuActionItemClicked, onHideContextMenu)
///   - ContextMenuItem(id, title, action)
///   - goForward(): Future<void>
///   - goBackOrForward(steps): Future<void>
///   - goTo(historyItem): Future<void>
///   - canGoBackOrForward(steps): Future<bool>
///   - getCopyBackForwardList(): Future<WebHistory?>
///   - callAsyncJavaScript(functionBody, arguments, contentWorld?): Future<CallAsyncJavaScriptResult?>

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String _kTag = 'InAppWebView_ContextMenuNav';

/// ContextMenuNavPage - 上下文菜单与高级导航
class ContextMenuNavPage extends StatefulWidget {
  const ContextMenuNavPage({super.key});

  @override
  State<ContextMenuNavPage> createState() => _ContextMenuNavPageState();
}

class _ContextMenuNavPageState extends State<ContextMenuNavPage> {
  InAppWebViewController? _controller;

  String _statusText = '页面加载中…';
  bool _statusIsError = false;
  String _menuActionText = '';
  String _asyncJsResult = '';
  bool _contextMenuEnabled = true;

  String _currentUrl = '';
  WebHistory? _history;

  /// 用于建立历史的几个站点
  static const _navSites = <String, String>{
    'example.com': 'https://example.com',
    'flutter.dev': 'https://flutter.dev',
    'github.com': 'https://github.com',
    'wikipedia.org': 'https://wikipedia.org',
  };

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

  void _setStatus(String text, {bool isError = false}) {
    if (!mounted) return;
    setState(() {
      _statusText = text;
      _statusIsError = isError;
    });
  }

  // ─── 构建上下文菜单 ────────────────────────────────────────────────────

  ContextMenu _buildContextMenu() {
    return ContextMenu(
      menuItems: [
        ContextMenuItem(id: 'copy_link', title: '复制链接'),
        ContextMenuItem(id: 'share', title: '分享'),
        ContextMenuItem(id: 'open_external', title: '外部打开'),
      ],
      settings:
          ContextMenuSettings(hideDefaultSystemContextMenuItems: false),
      onCreateContextMenu: (hitTestResult) {
        dev.log('onCreateContextMenu: type=${hitTestResult.type}',
            name: _kTag);
        if (!mounted) return;
        setState(() {
          _menuActionText = '菜单已弹出 | 命中类型: '
              '${hitTestResult.type?.toValue()} | 数据: '
              '${hitTestResult.extra ?? "(无)"}';
        });
      },
      onHideContextMenu: () {
        dev.log('onHideContextMenu', name: _kTag);
        _setStatus('上下文菜单已关闭');
      },
      onContextMenuActionItemClicked: (itemClicked) {
        dev.log('onContextMenuActionItemClicked: ${itemClicked.title}',
            name: _kTag);
        if (!mounted) return;
        setState(() {
          _menuActionText =
              '点击了菜单项: ${itemClicked.title} (id=${itemClicked.id})';
        });
        _setStatus('菜单项「${itemClicked.title}」被点击');
      },
    );
  }

  // ─── 导航历史 ───────────────────────────────────────────────────────────

  /// 加载一个站点以建立历史
  Future<void> _loadSite(String url) async {
    dev.log('_loadSite: $url', name: _kTag);
    _setStatus('加载 $url …');
    await _controller?.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
  }

  Future<void> _goBack() async {
    dev.log('_goBack called', name: _kTag);
    final can = await _controller?.canGoBack() ?? false;
    if (!can) {
      _setStatus('canGoBack=false，已在历史起点');
      return;
    }
    await _controller?.goBack();
    _setStatus('已执行 goBack()');
  }

  Future<void> _goForward() async {
    dev.log('_goForward called', name: _kTag);
    final can = await _controller?.canGoForward() ?? false;
    if (!can) {
      _setStatus('canGoForward=false，已在历史末端');
      return;
    }
    await _controller?.goForward();
    _setStatus('已执行 goForward()');
  }

  Future<void> _goBackOrForward(int steps) async {
    dev.log('_goBackOrForward($steps) called', name: _kTag);
    final can = await _controller?.canGoBackOrForward(steps: steps) ?? false;
    if (!can) {
      _setStatus('canGoBackOrForward($steps)=false，无法移动这么多步');
      return;
    }
    await _controller?.goBackOrForward(steps: steps);
    _setStatus('已执行 goBackOrForward($steps)');
  }

  /// 刷新历史列表展示
  Future<void> _refreshHistory() async {
    dev.log('_refreshHistory called', name: _kTag);
    try {
      final history = await _controller?.getCopyBackForwardList();
      if (!mounted) return;
      setState(() => _history = history);
      _setStatus('已刷新历史列表（共 ${history?.list?.length ?? 0} 项）');
    } catch (e, stack) {
      dev.log('_refreshHistory failed', name: _kTag,
          error: e, stackTrace: stack);
      _setStatus('刷新历史失败：$e', isError: true);
    }
  }

  /// goTo 到指定历史项
  Future<void> _goToItem(WebHistoryItem item) async {
    dev.log('_goToItem: offset=${item.offset} url=${item.url}', name: _kTag);
    await _controller?.goTo(historyItem: item);
    _setStatus('已 goTo(offset=${item.offset}) → ${item.url}');
  }

  Future<void> _toggleContextMenu() async {
    dev.log('_toggleContextMenu called', name: _kTag);
    final c = _controller;
    if (c == null) return;
    final enable = !_contextMenuEnabled;
    await c.setContextMenu(enable ? _buildContextMenu() : null);
    if (!mounted) return;
    setState(() => _contextMenuEnabled = enable);
    _setStatus(enable ? '上下文菜单已启用（长按页面元素）' : '上下文菜单已禁用');
  }

  Future<void> _callAsyncJavaScript() async {
    dev.log('_callAsyncJavaScript called', name: _kTag);
    try {
      final result = await _controller?.callAsyncJavaScript(
        functionBody: '''
          await new Promise(r => setTimeout(r, 300));
          const sum = arguments.a + arguments.b;
          return { sum: sum, title: document.title, url: location.href };
        ''',
        arguments: {'a': 10, 'b': 32},
      );
      dev.log('_callAsyncJavaScript succeeded: ${result?.value}', name: _kTag);
      if (!mounted) return;
      setState(() => _asyncJsResult =
          'value: ${result?.value}\nerror: ${result?.error ?? "(无)"}');
      _setStatus('callAsyncJavaScript 执行完成（10+32 应返回 42）');
    } catch (e, stack) {
      dev.log('_callAsyncJavaScript failed', name: _kTag,
          error: e, stackTrace: stack);
      _setStatus('callAsyncJavaScript 失败：$e', isError: true);
    }
  }

  // ─── UI 构建 ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('[025] 上下文菜单与高级导航')),
      body: Column(
        children: [
          _hintBanner(
            '先点几个站点按钮建立浏览历史，再用 goBack/goForward/goTo 在其间'
            '跳转 —— WebView 会真实翻页，下方历史列表会高亮「当前项」。',
          ),
          // 建立历史：站点按钮
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('① 加载站点建立历史'),
                Wrap(
                  spacing: 8,
                  children: _navSites.entries
                      .map((e) => ElevatedButton(
                            onPressed: () => _loadSite(e.value),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              minimumSize: const Size(0, 32),
                            ),
                            child: Text(e.key,
                                style: const TextStyle(fontSize: 12)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 4),
                _sectionTitle('② 在历史中导航'),
                Wrap(spacing: 8, runSpacing: 4, children: [
                  _btn('goBack', _goBack),
                  _btn('goForward', _goForward),
                  _btn('goBackOrForward(-2)', () => _goBackOrForward(-2)),
                  _btn('goBackOrForward(+2)', () => _goBackOrForward(2)),
                  _btn('刷新历史列表', _refreshHistory),
                ]),
                const SizedBox(height: 4),
                _sectionTitle('③ 其它'),
                Wrap(spacing: 8, runSpacing: 4, children: [
                  ElevatedButton(
                    onPressed: _toggleContextMenu,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _contextMenuEnabled
                          ? Colors.green
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      minimumSize: const Size(0, 34),
                    ),
                    child: Text(
                        _contextMenuEnabled ? '上下文菜单: 开' : '上下文菜单: 关',
                        style: const TextStyle(fontSize: 12)),
                  ),
                  _btn('callAsyncJavaScript', _callAsyncJavaScript),
                ]),
              ],
            ),
          ),
          // 结果 / 当前 URL
          _resultPanel(),
          // 历史列表
          if (_history?.list != null && _history!.list!.isNotEmpty)
            _historyList(),
          const Divider(height: 1),
          // WebView 区域
          Expanded(
            child: InAppWebView(
              initialUrlRequest:
                  URLRequest(url: WebUri(_navSites.values.first)),
              contextMenu: _buildContextMenu(),
              onWebViewCreated: (controller) {
                _controller = controller;
                dev.log('onWebViewCreated', name: _kTag);
              },
              onLoadStop: (controller, url) async {
                if (!mounted) return;
                setState(() => _currentUrl = url?.toString() ?? '');
                // 每次加载完成自动刷新历史列表，让高亮项跟随
                await _refreshHistory();
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
                size: 16, color: _statusIsError ? Colors.red : Colors.blue),
            const SizedBox(width: 6),
            Expanded(
              child: Text(_statusText,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          _statusIsError ? Colors.red : Colors.black87)),
            ),
          ]),
          const SizedBox(height: 4),
          Text('当前 URL: ${_currentUrl.isEmpty ? "(未知)" : _currentUrl}',
              style: const TextStyle(fontSize: 11, color: Colors.teal),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          if (_menuActionText.isNotEmpty)
            Text(_menuActionText,
                style: const TextStyle(fontSize: 11, color: Colors.blue)),
          if (_asyncJsResult.isNotEmpty)
            Text(_asyncJsResult,
                style:
                    const TextStyle(fontSize: 11, color: Colors.purple)),
        ],
      ),
    );
  }

  Widget _historyList() {
    final items = _history!.list!;
    final currentIdx = _history!.currentIndex ?? 0;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      constraints: const BoxConstraints(maxHeight: 110),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(4),
        itemCount: items.length,
        itemBuilder: (ctx, i) {
          final item = items[i];
          final isCurrent = i == currentIdx;
          return InkWell(
            onTap: () => _goToItem(item),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              color: isCurrent ? Colors.amber[100] : null,
              child: Row(children: [
                Icon(
                    isCurrent
                        ? Icons.play_arrow
                        : Icons.circle_outlined,
                    size: 12,
                    color: isCurrent ? Colors.orange : Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '[$i] ${item.title ?? item.url}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isCurrent)
                  const Text('goTo →',
                      style: TextStyle(fontSize: 10, color: Colors.blue)),
              ]),
            ),
          );
        },
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

  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Text(t,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.indigo)),
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
