/// Demo 1: WebViewCreateLoad
///
/// 功能说明：展示 InAppWebView 核心组件的创建与初始加载流程，包括通过
/// initialUrlRequest、initialFile、initialData 三种方式指定加载内容，
/// 并通过 onWebViewCreated、onLoadStart、onLoadStop、onProgressChanged 回调
/// 监听加载全生命周期。
/// 对应接口：
///   - InAppWebView(initialUrlRequest)
///   - InAppWebView(initialFile)
///   - InAppWebView(initialData)
///   - onWebViewCreated(controller): void
///   - onLoadStart(controller, url): void
///   - onLoadStop(controller, url): void
///   - onProgressChanged(controller, progress): void

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// ─── 日志 Tag ─────────────────────────────────────────────────────────────
const String _kTag = 'InAppWebView_WebViewCreateLoad';

/// WebViewCreateLoadPage - 内联 WebView 创建与加载
///
/// 展示 InAppWebView 的三种初始化加载方式与加载生命周期回调。
class WebViewCreateLoadPage extends StatefulWidget {
  const WebViewCreateLoadPage({super.key});

  @override
  State<WebViewCreateLoadPage> createState() => _WebViewCreateLoadPageState();
}

class _WebViewCreateLoadPageState extends State<WebViewCreateLoadPage> {
  // ─── 状态变量（触发 UI 更新） ────────────────────────────────────────────
  double _progress = 0;
  String? _currentUrl;
  int _loadStartCount = 0;
  int _loadStopCount = 0;
  String _loadMode = 'url';

  // ─── 非响应式成员 ─────────────────────────────────────────────────────────
  InAppWebViewController? _controller;
  final TextEditingController _urlController =
      TextEditingController(text: 'https://flutter.dev');

  /// 重载当前页面
  Future<void> _reload() async {
    dev.log('_reload called', name: _kTag);
    try {
      await _controller?.reload();
      dev.log('_reload succeeded', name: _kTag);
    } catch (e, stack) {
      dev.log('_reload failed', name: _kTag, error: e, stackTrace: stack);
    }
  }

  @override
  void initState() {
    super.initState();
    dev.log('Page appeared', name: _kTag);
  }

  @override
  void dispose() {
    dev.log('Page disposed, releasing resources', name: _kTag);
    _urlController.dispose();
    super.dispose();
  }

  // ─── 核心功能方法 ────────────────────────────────────────────────────────

  /// 切换为 URL 加载模式
  void _switchToUrl() {
    dev.log('_switchToUrl called', name: _kTag);
    setState(() {
      _loadMode = 'url';
      _progress = 0;
      _loadStartCount = 0;
      _loadStopCount = 0;
    });
  }

  /// 切换为本地文件加载模式
  void _switchToFile() {
    dev.log('_switchToFile called', name: _kTag);
    setState(() {
      _loadMode = 'file';
      _progress = 0;
      _loadStartCount = 0;
      _loadStopCount = 0;
    });
  }

  /// 切换为 HTML 数据加载模式
  void _switchToData() {
    dev.log('_switchToData called', name: _kTag);
    setState(() {
      _loadMode = 'data';
      _progress = 0;
      _loadStartCount = 0;
      _loadStopCount = 0;
    });
  }

  // ─── UI 构建 ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('[001] 内联WebView创建与加载'),
      ),
      body: Column(
        children: [
          // 控制区域
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'URL',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _switchToUrl,
                        child: const Text('加载 URL'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _switchToFile,
                        child: const Text('加载本地文件'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _switchToData,
                        child: const Text('加载 HTML 数据'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 进度条
                LinearProgressIndicator(value: _progress),
                const SizedBox(height: 8),
                Text('进度: ${(_progress * 100).toInt()}%'),
                Text('当前URL: $_currentUrl'),
                Text('onLoadStart 次数: $_loadStartCount'),
                Text('onLoadStop 次数: $_loadStopCount'),
                Text('加载模式: $_loadMode'),
                const SizedBox(height: 8),
                ElevatedButton(
                    onPressed: _reload, child: const Text('重载页面')),
              ],
            ),
          ),
          const Divider(height: 1),
          // WebView 区域
          Expanded(
            child: _buildWebView(),
          ),
        ],
      ),
    );
  }

  /// 根据当前 _loadMode 构建对应的 InAppWebView
  Widget _buildWebView() {
    return InAppWebView(
      // initialFile/initialData/initialUrlRequest 仅在原生视图创建时读取一次。
      // 用随加载模式变化的 key 强制重建视图，切换模式后 makeInitialLoad 才会重新执行。
      key: ValueKey('load_$_loadMode'),
      initialUrlRequest:
          _loadMode == 'url' ? URLRequest(url: WebUri(_urlController.text)) : null,
      initialFile: _loadMode == 'file' ? 'assets/index.html' : null,
      initialData: _loadMode == 'data'
          ? InAppWebViewInitialData(
              data: '<h1>Hello from InAppWebView!</h1>',
              mimeType: 'text/html',
              encoding: 'utf-8',
            )
          : null,
      initialSettings: InAppWebViewSettings(
        useShouldOverrideUrlLoading: true,
      ),
      onWebViewCreated: (controller) {
        dev.log('onWebViewCreated', name: _kTag);
        _controller = controller;
      },
      onLoadStart: (controller, url) {
        dev.log('onLoadStart: $url', name: _kTag);
        if (!mounted) return;
        setState(() {
          _loadStartCount++;
          _currentUrl = url?.toString();
        });
      },
      onLoadStop: (controller, url) {
        dev.log('onLoadStop: $url', name: _kTag);
        if (!mounted) return;
        setState(() {
          _loadStopCount++;
          _currentUrl = url?.toString();
        });
      },
      onProgressChanged: (controller, progress) {
        dev.log('onProgressChanged: $progress', name: _kTag);
        if (!mounted) return;
        setState(() {
          _progress = progress / 100;
        });
      },
    );
  }
}
