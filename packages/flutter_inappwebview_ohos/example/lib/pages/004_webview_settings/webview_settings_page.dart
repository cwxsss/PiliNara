/// Demo 4: WebviewSettings
///
/// 功能说明：展示通过 InAppWebViewSettings 初始化配置 WebView 行为
/// （如 javaScriptEnabled、domStorageEnabled、userAgent、
/// useShouldOverrideUrlLoading 等），并通过控制器的 setSettings/getSettings
/// 在运行时读取与更新配置。
/// 对应接口：
///   - InAppWebViewSettings(javaScriptEnabled, mediaPlaybackRequiresUserGesture, domStorageEnabled, userAgent, applicationNameForUserAgent, useShouldOverrideUrlLoading, useOnLoadResource, useOnDownloadStart, verticalScrollBarEnabled, horizontalScrollBarEnabled, allowFileAccess, mixedContentMode, geolocationEnabled, textZoom, enableNativeEmbedMode)
///   - setSettings(settings): Future<void>
///   - getSettings(): Future<InAppWebViewSettings?>

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String _kTag = 'InAppWebView_WebviewSettings';

/// WebviewSettingsPage - WebView 配置与运行时设置
///
/// 展示配置项的初始化与运行时修改模式。
class WebviewSettingsPage extends StatefulWidget {
  const WebviewSettingsPage({super.key});

  @override
  State<WebviewSettingsPage> createState() => _WebviewSettingsPageState();
}

class _WebviewSettingsPageState extends State<WebviewSettingsPage> {
  // ─── 状态变量 ────────────────────────────────────────────────────────────
  bool _jsEnabled = true;
  bool _domStorageEnabled = true;
  String _userAgent = '';
  bool _useShouldOverride = true;
  bool _useOnLoadResource = false;
  bool _useOnDownloadStart = false;
  bool _verticalScrollBar = true;
  bool _horizontalScrollBar = true;
  bool _allowFileAccess = true;
  int _textZoom = 100;
  bool _mediaGesture = true;
  InAppWebViewSettings? _currentSettings;
  String _resultText = '';

  // ─── 非响应式成员 ─────────────────────────────────────────────────────────
  InAppWebViewController? _controller;
  final TextEditingController _uaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dev.log('Page appeared', name: _kTag);
  }

  @override
  void dispose() {
    dev.log('Page disposed, releasing resources', name: _kTag);
    _uaController.dispose();
    super.dispose();
  }

  // ─── 核心功能方法 ────────────────────────────────────────────────────────

  /// 应用设置到 WebView
  ///
  /// 调用 [setSettings] 实现 {功能描述}。
  Future<void> _applySettings() async {
    dev.log('_applySettings called', name: _kTag);
    setState(() => _resultText = '应用中...');
    try {
      final settings = InAppWebViewSettings(
        javaScriptEnabled: _jsEnabled,
        mediaPlaybackRequiresUserGesture: _mediaGesture,
        domStorageEnabled: _domStorageEnabled,
        userAgent: _uaController.text.isEmpty
            ? _userAgent
            : _uaController.text,
        useShouldOverrideUrlLoading: _useShouldOverride,
        useOnLoadResource: _useOnLoadResource,
        useOnDownloadStart: _useOnDownloadStart,
        verticalScrollBarEnabled: _verticalScrollBar,
        horizontalScrollBarEnabled: _horizontalScrollBar,
        allowFileAccess: _allowFileAccess,
        textZoom: _textZoom,
        enableNativeEmbedMode: true,
      );
      await _controller?.setSettings(settings: settings);
      dev.log('_applySettings succeeded', name: _kTag);
      if (!mounted) return;
      setState(() {
        _currentSettings = settings;
        _resultText = '设置已应用';
      });
    } catch (e, stack) {
      dev.log('_applySettings failed',
          name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() {
        _resultText = '错误：$e';
      });
    }
  }

  /// 读取当前 WebView 设置
  ///
  /// 调用 [getSettings] 实现 {功能描述}。
  Future<void> _readSettings() async {
    dev.log('_readSettings called', name: _kTag);
    setState(() => _resultText = '读取中...');
    try {
      final s = await _controller?.getSettings();
      dev.log('_readSettings succeeded', name: _kTag);
      if (!mounted) return;
      setState(() {
        _currentSettings = s;
        _jsEnabled = s?.javaScriptEnabled ?? true;
        _domStorageEnabled = s?.domStorageEnabled ?? true;
        _userAgent = s?.userAgent ?? '';
        _useShouldOverride = s?.useShouldOverrideUrlLoading ?? true;
        _useOnLoadResource = s?.useOnLoadResource ?? false;
        _useOnDownloadStart = s?.useOnDownloadStart ?? false;
        _verticalScrollBar = s?.verticalScrollBarEnabled ?? true;
        _horizontalScrollBar = s?.horizontalScrollBarEnabled ?? true;
        _allowFileAccess = s?.allowFileAccess ?? true;
        _textZoom = s?.textZoom ?? 100;
        _resultText = '设置已读取';
      });
    } catch (e, stack) {
      dev.log('_readSettings failed',
          name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() {
        _resultText = '错误：$e';
      });
    }
  }

  // ─── UI 构建 ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('[004] WebView配置与运行时设置'),
      ),
      body: Column(
        children: [
          // 设置控件区
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SwitchListTile(
                    title: const Text('javaScriptEnabled'),
                    value: _jsEnabled,
                    onChanged: (v) => setState(() => _jsEnabled = v),
                  ),
                  SwitchListTile(
                    title: const Text('domStorageEnabled'),
                    value: _domStorageEnabled,
                    onChanged: (v) => setState(() => _domStorageEnabled = v),
                  ),
                  SwitchListTile(
                    title: const Text('useShouldOverrideUrlLoading'),
                    value: _useShouldOverride,
                    onChanged: (v) => setState(() => _useShouldOverride = v),
                  ),
                  SwitchListTile(
                    title: const Text('useOnLoadResource'),
                    value: _useOnLoadResource,
                    onChanged: (v) => setState(() => _useOnLoadResource = v),
                  ),
                  SwitchListTile(
                    title: const Text('useOnDownloadStart'),
                    value: _useOnDownloadStart,
                    onChanged: (v) => setState(() => _useOnDownloadStart = v),
                  ),
                  SwitchListTile(
                    title: const Text('verticalScrollBarEnabled'),
                    value: _verticalScrollBar,
                    onChanged: (v) => setState(() => _verticalScrollBar = v),
                  ),
                  SwitchListTile(
                    title: const Text('horizontalScrollBarEnabled'),
                    value: _horizontalScrollBar,
                    onChanged: (v) => setState(() => _horizontalScrollBar = v),
                  ),
                  SwitchListTile(
                    title: const Text('allowFileAccess'),
                    value: _allowFileAccess,
                    onChanged: (v) => setState(() => _allowFileAccess = v),
                  ),
                  SwitchListTile(
                    title: const Text('mediaPlaybackRequiresUserGesture'),
                    value: _mediaGesture,
                    onChanged: (v) => setState(() => _mediaGesture = v),
                  ),
                  TextField(
                    controller: _uaController,
                    decoration: const InputDecoration(
                      labelText: 'userAgent (留空使用默认)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('textZoom: $_textZoom%'),
                  Slider(
                    min: 50,
                    max: 200,
                    divisions: 15,
                    value: _textZoom.toDouble(),
                    onChanged: (v) => setState(() => _textZoom = v.toInt()),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _applySettings,
                          child: const Text('应用设置'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _readSettings,
                          child: const Text('读取设置'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('状态: $_resultText'),
                  Text('JS启用: ${_currentSettings?.javaScriptEnabled}'),
                  Text('UA: ${_currentSettings?.userAgent}'),
                  Text('文字缩放: ${_currentSettings?.textZoom}'),
                  Text('domStorage: ${_currentSettings?.domStorageEnabled}'),
                  Text('useShouldOverride: ${_currentSettings?.useShouldOverrideUrlLoading}'),
                  Text('useOnLoadResource: ${_currentSettings?.useOnLoadResource}'),
                  Text('useOnDownloadStart: ${_currentSettings?.useOnDownloadStart}'),
                  Text('verticalScrollBar: ${_currentSettings?.verticalScrollBarEnabled}'),
                  Text('horizontalScrollBar: ${_currentSettings?.horizontalScrollBarEnabled}'),
                  Text('allowFileAccess: ${_currentSettings?.allowFileAccess}'),
                  Text('mediaGesture: ${_currentSettings?.mediaPlaybackRequiresUserGesture}'),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // WebView 区域
          Expanded(
            flex: 1,
            child: InAppWebView(
              initialUrlRequest:
                  URLRequest(url: WebUri('https://flutter.dev')),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: _jsEnabled,
                domStorageEnabled: _domStorageEnabled,
                useShouldOverrideUrlLoading: _useShouldOverride,
                textZoom: _textZoom,
                allowFileAccess: _allowFileAccess,
                enableNativeEmbedMode: true,
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
