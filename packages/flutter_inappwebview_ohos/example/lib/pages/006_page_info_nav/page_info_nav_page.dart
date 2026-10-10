/// Demo 6: PageInfoNav
///
/// 功能说明：展示通过控制器查询页面信息（getUrl/getTitle/getProgress/
/// getOriginalUrl）、检查与执行导航历史（canGoBack/canGoForward/goBack/
/// reload/loadUrl/postUrl/loadData）。
/// 对应接口：
///   - getUrl(): Future<WebUri?>
///   - getTitle(): Future<String?>
///   - getProgress(): Future<int?>
///   - getOriginalUrl(): Future<WebUri?>
///   - canGoBack(): Future<bool>
///   - canGoForward(): Future<bool>
///   - goBack(): Future<void>
///   - reload(): Future<void>
///   - loadUrl(urlRequest, allowingReadAccessTo?): Future<void>
///   - postUrl(url, postData): Future<void>
///   - loadData(data, mimeType, encoding, ...): Future<void>

import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String _kTag = 'InAppWebView_PageInfoNav';

/// PageInfoNavPage - 页面信息查询与导航历史
///
/// 展示页面状态查询与导航控制的完整链路。
class PageInfoNavPage extends StatefulWidget {
  const PageInfoNavPage({super.key});

  @override
  State<PageInfoNavPage> createState() => _PageInfoNavPageState();
}

class _PageInfoNavPageState extends State<PageInfoNavPage> {
  // ─── 状态变量 ────────────────────────────────────────────────────────────
  String? _url;
  String? _title;
  int? _progress;
  String? _originalUrl;
  bool _canBack = false;
  bool _canForward = false;
  int _navCallCount = 0;
  int _navDoneCount = 0;
  String _resultText = '';

  // ─── 非响应式成员 ─────────────────────────────────────────────────────────
  InAppWebViewController? _controller;

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

  // ─── 核心功能方法 ────────────────────────────────────────────────────────

  /// 查询页面信息
  ///
  /// 并行调用 getUrl/getTitle/getProgress/getOriginalUrl/canGoBack/canGoForward。
  Future<void> _queryInfo() async {
    dev.log('_queryInfo called', name: _kTag);
    setState(() {
      _navCallCount++;
      _resultText = '查询中...';
    });
    try {
      final results = await Future.wait([
        _controller?.getUrl() ?? Future.value(null),
        _controller?.getTitle() ?? Future.value(null),
        _controller?.getProgress() ?? Future.value(null),
        _controller?.getOriginalUrl() ?? Future.value(null),
        _controller?.canGoBack() ?? Future.value(false),
        _controller?.canGoForward() ?? Future.value(false),
      ]);
      dev.log('_queryInfo succeeded', name: _kTag);
      if (!mounted) return;
      setState(() {
        _url = (results[0] as WebUri?)?.toString();
        _title = results[1] as String?;
        _progress = results[2] as int?;
        _originalUrl = (results[3] as WebUri?)?.toString();
        _canBack = results[4] as bool;
        _canForward = results[5] as bool;
        _navDoneCount++;
        _resultText = '查询完成';
      });
    } catch (e, stack) {
      dev.log('_queryInfo failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() {
        _resultText = '错误：$e';
      });
    }
  }

  /// 重载页面
  Future<void> _reload() async {
    dev.log('_reload called', name: _kTag);
    try {
      await _controller?.reload();
      dev.log('_reload succeeded', name: _kTag);
      if (!mounted) return;
      setState(() => _resultText = '已重载');
    } catch (e, stack) {
      dev.log('_reload failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _resultText = '错误：$e');
    }
  }

  /// 加载新 URL
  Future<void> _loadUrl() async {
    dev.log('_loadUrl called', name: _kTag);
    try {
      await _controller?.loadUrl(
          urlRequest:
              URLRequest(url: WebUri('https://github.com')));
      dev.log('_loadUrl succeeded', name: _kTag);
      if (!mounted) return;
      setState(() => _resultText = '已加载新URL');
    } catch (e, stack) {
      dev.log('_loadUrl failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _resultText = '错误：$e');
    }
  }

  /// POST 请求
  Future<void> _postUrl() async {
    dev.log('_postUrl called', name: _kTag);
    try {
      final Uint8List postData =
          Uint8List.fromList(utf8.encode('a=1'));
      await _controller?.postUrl(
          url: WebUri('https://example.com'), postData: postData);
      dev.log('_postUrl succeeded', name: _kTag);
      if (!mounted) return;
      setState(() => _resultText = '已POST');
    } catch (e, stack) {
      dev.log('_postUrl failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _resultText = '错误：$e');
    }
  }

  /// 加载数据
  Future<void> _loadData() async {
    dev.log('_loadData called', name: _kTag);
    try {
      await _controller?.loadData(data: '<h1>Loaded</h1>');
      dev.log('_loadData succeeded', name: _kTag);
      if (!mounted) return;
      setState(() => _resultText = '已加载数据');
    } catch (e, stack) {
      dev.log('_loadData failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _resultText = '错误：$e');
    }
  }

  /// 返回上一页
  Future<void> _goBack() async {
    dev.log('_goBack called', name: _kTag);
    try {
      await _controller?.goBack();
      dev.log('_goBack succeeded', name: _kTag);
      if (!mounted) return;
      setState(() => _resultText = '已返回（partially 支持）');
    } catch (e, stack) {
      dev.log('_goBack failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _resultText = '错误：$e');
    }
  }

  // ─── UI 构建 ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('[006] 页面信息查询与导航历史'),
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
                    onPressed: _queryInfo, child: const Text('查询信息')),
                ElevatedButton(
                    onPressed: _reload, child: const Text('重载')),
                ElevatedButton(
                    onPressed: _loadUrl, child: const Text('加载新URL')),
                ElevatedButton(
                    onPressed: _postUrl, child: const Text('POST请求')),
                ElevatedButton(
                    onPressed: _loadData, child: const Text('加载数据')),
                ElevatedButton(
                    onPressed: _goBack, child: const Text('返回')),
              ],
            ),
          ),
          // 结果展示区
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('状态: $_resultText'),
                Text('URL: $_url'),
                Text('标题: $_title'),
                Text('进度: $_progress'),
                Text('原始URL: $_originalUrl'),
                Text('可返回: $_canBack'),
                Text('可前进: $_canForward'),
                Text('调用/完成: $_navCallCount/$_navDoneCount'),
              ],
            ),
          ),
          const Divider(height: 1),
          // WebView 区域
          Expanded(
            child: InAppWebView(
              initialUrlRequest:
                  URLRequest(url: WebUri('https://flutter.dev')),
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
