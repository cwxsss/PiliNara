/// Demo 27: 高级设置项
///
/// 功能说明：集中演示 InAppWebViewSettings 中尚未被其它 demo 覆盖的
/// 设置项。内嵌测试页专门为「肉眼可见对照」设计：
///   - blockNetworkImage：开启后网络图片不再显示；
///   - minimumFontSize：调大后原本 6px 的小字会被强制放大；
///   - initialScale：改变后整页缩放比例可见变化；
///   - databaseEnabled：页面内按钮测试 openDatabase 是否可用；
///   - preferredContentMode：切换移动/桌面 UA。
/// 「应用设置」后自动 reload 使其生效，并可「读取当前设置」回读确认。
///
/// 对应接口（InAppWebViewSettings，ohos Support = yes/partially）：
///   - blockNetworkImage / blockNetworkLoads / minimumFontSize
///   - minimumLogicalFontSize / databaseEnabled / initialScale
///   - javaScriptCanOpenWindowsAutomatically / mixedContentMode
///   - allowFileAccessFromFileURLs / allowUniversalAccessFromFileURLs
///   - clearCache / layoutAlgorithm / preferredContentMode
///   - hardwareAcceleration / needInitialFocus

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String _kTag = 'InAppWebView_AdvancedSettings';

/// AdvancedSettingsPage - 高级设置项演示
class AdvancedSettingsPage extends StatefulWidget {
  const AdvancedSettingsPage({super.key});

  @override
  State<AdvancedSettingsPage> createState() => _AdvancedSettingsPageState();
}

class _AdvancedSettingsPageState extends State<AdvancedSettingsPage> {
  InAppWebViewController? _controller;

  // 开关类设置
  bool _blockNetworkImage = false;
  bool _blockNetworkLoads = false;
  bool _databaseEnabled = true;
  bool _jsCanOpenWindows = false;
  bool _allowFileAccessFromFileURLs = false;
  bool _allowUniversalAccessFromFileURLs = false;
  bool _hardwareAcceleration = true;
  bool _needInitialFocus = true;
  bool _clearCacheOnLoad = false;

  // 数值类设置
  int _minimumFontSize = 8;
  int _minimumLogicalFontSize = 8;
  int _initialScale = 0;

  // 枚举类设置
  int _mixedContentModeIdx = 0;
  int _layoutAlgorithmIdx = 0;
  int _preferredContentModeIdx = 0;

  String _statusText = '调整下方设置后点「应用设置 + 重载」，观察 WebView 变化';
  bool _statusIsError = false;
  String _readbackText = '';

  /// 测试页 HTML：为每个可见设置准备对照元素
  static const String _testHtml = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body { font-family: sans-serif; padding: 16px; }
    .row { padding:10px; margin:8px 0; border-radius:8px; background:#f5f5f5; }
    .tag { font-weight:bold; color:#1976d2; }
    img { width: 90px; height:90px; margin-top:6px; border:1px solid #ccc; }
    .tiny { font-size:6px; color:#333; }
    .db-result { margin-top:6px; padding:6px; border-radius:4px;
                 background:#eee; font-size:13px; }
    button { padding:8px 12px; border:none; border-radius:5px;
             background:#388e3c; color:#fff; font-size:14px; }
  </style>
</head>
<body>
  <div class="row">
    <span class="tag">blockNetworkImage</span> —— 下面这张网络图片，开启后应消失：
    <br><img src="https://placehold.co/90x90/1976d2/fff?text=IMG">
  </div>
  <div class="row">
    <span class="tag">minimumFontSize</span> —— 下面这行是 6px 小字，调大后会被放大：
    <p class="tiny">这是 6px 的极小文字 tiny text 12345 tiny text</p>
  </div>
  <div class="row">
    <span class="tag">initialScale</span> —— 改变缩放后整页比例会变化。
  </div>
  <div class="row">
    <span class="tag">databaseEnabled</span> ——
    <button onclick="testDb()">测试 openDatabase</button>
    <div class="db-result" id="db-area">（点上方按钮测试）</div>
  </div>
  <div class="row">
    <span class="tag">preferredContentMode</span> —— 当前 UA：
    <div class="db-result" id="ua-area"></div>
  </div>
  <script>
    document.getElementById('ua-area').innerText = navigator.userAgent;
    function testDb() {
      var el = document.getElementById('db-area');
      try {
        if (typeof openDatabase === 'undefined') {
          el.innerText = 'openDatabase 不存在（databaseEnabled=false 或不支持）';
          el.style.background = '#ffcdd2';
          return;
        }
        var db = openDatabase('test', '1.0', 'test db', 1024);
        el.innerText = '✓ 数据库已成功打开';
        el.style.background = '#c8e6c9';
      } catch(e) {
        el.innerText = '✗ 数据库错误: ' + e.message;
        el.style.background = '#ffcdd2';
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

  void _setStatus(String text, {bool isError = false}) {
    if (!mounted) return;
    setState(() {
      _statusText = text;
      _statusIsError = isError;
    });
  }

  // ─── 核心功能方法 ────────────────────────────────────────────────────────

  Future<void> _applySettings() async {
    dev.log('_applySettings called', name: _kTag);
    final c = _controller;
    if (c == null) {
      _setStatus('控制器未就绪', isError: true);
      return;
    }
    _setStatus('应用中…');
    try {
      final mixedContentModes = [
        MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
        MixedContentMode.MIXED_CONTENT_NEVER_ALLOW,
        MixedContentMode.MIXED_CONTENT_COMPATIBILITY_MODE,
      ];
      final layoutAlgorithms = [
        LayoutAlgorithm.NORMAL,
        LayoutAlgorithm.TEXT_AUTOSIZING,
        LayoutAlgorithm.NARROW_COLUMNS,
      ];
      final contentModes = [
        UserPreferredContentMode.RECOMMENDED,
        UserPreferredContentMode.MOBILE,
        UserPreferredContentMode.DESKTOP,
      ];
      await c.setSettings(
        settings: InAppWebViewSettings(
          blockNetworkImage: _blockNetworkImage,
          blockNetworkLoads: _blockNetworkLoads,
          minimumFontSize: _minimumFontSize,
          minimumLogicalFontSize: _minimumLogicalFontSize,
          databaseEnabled: _databaseEnabled,
          initialScale: _initialScale,
          javaScriptCanOpenWindowsAutomatically: _jsCanOpenWindows,
          mixedContentMode: mixedContentModes[_mixedContentModeIdx],
          allowFileAccessFromFileURLs: _allowFileAccessFromFileURLs,
          allowUniversalAccessFromFileURLs:
              _allowUniversalAccessFromFileURLs,
          layoutAlgorithm: layoutAlgorithms[_layoutAlgorithmIdx],
          preferredContentMode: contentModes[_preferredContentModeIdx],
          hardwareAcceleration: _hardwareAcceleration,
          needInitialFocus: _needInitialFocus,
          clearCache: _clearCacheOnLoad,
        ),
      );
      await c.reload();
      dev.log('_applySettings succeeded', name: _kTag);
      _setStatus('设置已应用并重载，观察 WebView 中各对照区变化');
    } catch (e, stack) {
      dev.log('_applySettings failed', name: _kTag,
          error: e, stackTrace: stack);
      _setStatus('应用失败：$e', isError: true);
    }
  }

  Future<void> _getSettings() async {
    dev.log('_getSettings called', name: _kTag);
    final c = _controller;
    if (c == null) return;
    try {
      final s = await c.getSettings();
      if (s == null) {
        setState(() => _readbackText = 'getSettings() 返回 null');
        return;
      }
      if (!mounted) return;
      setState(() {
        _readbackText = 'blockNetworkImage=${s.blockNetworkImage}\n'
            'blockNetworkLoads=${s.blockNetworkLoads}\n'
            'minimumFontSize=${s.minimumFontSize}\n'
            'minimumLogicalFontSize=${s.minimumLogicalFontSize}\n'
            'databaseEnabled=${s.databaseEnabled}\n'
            'initialScale=${s.initialScale}\n'
            'mixedContentMode=${s.mixedContentMode}\n'
            'layoutAlgorithm=${s.layoutAlgorithm}\n'
            'preferredContentMode=${s.preferredContentMode}\n'
            'hardwareAcceleration=${s.hardwareAcceleration}\n'
            'needInitialFocus=${s.needInitialFocus}';
      });
      _setStatus('已读取当前设置（见下方回读区）');
    } catch (e, stack) {
      dev.log('_getSettings failed', name: _kTag,
          error: e, stackTrace: stack);
      _setStatus('读取失败：$e', isError: true);
    }
  }

  // ─── UI 构建 ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('[027] 高级设置项')),
      body: Column(
        children: [
          _hintBanner(
            'WebView 里每块灰色区域对应一个设置项。调整下方控件后点「应用设置'
            ' + 重载」，即可看到图片消失、小字放大、缩放变化、数据库可用性、UA'
            ' 变化等直观效果。',
          ),
          // 设置控制区
          SizedBox(
            height: 300,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionTitle('可见效果设置'),
                  _switchTile('blockNetworkImage（屏蔽网络图片）',
                      _blockNetworkImage,
                      (v) => setState(() => _blockNetworkImage = v)),
                  _switchTile('databaseEnabled（启用 Web SQL）',
                      _databaseEnabled,
                      (v) => setState(() => _databaseEnabled = v)),
                  _sliderTile('minimumFontSize（最小字号）',
                      _minimumFontSize, 0, 40,
                      (v) => setState(() => _minimumFontSize = v.round())),
                  _sliderTile('initialScale（初始缩放 %）',
                      _initialScale, 0, 200,
                      (v) => setState(() => _initialScale = v.round())),
                  _dropdownTile('preferredContentMode',
                      ['RECOMMENDED', 'MOBILE', 'DESKTOP'],
                      _preferredContentModeIdx,
                      (v) => setState(() => _preferredContentModeIdx = v)),
                  const Divider(),
                  _sectionTitle('其它设置'),
                  _switchTile('blockNetworkLoads', _blockNetworkLoads,
                      (v) => setState(() => _blockNetworkLoads = v)),
                  _switchTile('jsCanOpenWindowsAuto', _jsCanOpenWindows,
                      (v) => setState(() => _jsCanOpenWindows = v)),
                  _switchTile('allowFileAccessFromFileURLs',
                      _allowFileAccessFromFileURLs,
                      (v) => setState(
                          () => _allowFileAccessFromFileURLs = v)),
                  _switchTile('allowUniversalAccessFromFileURLs',
                      _allowUniversalAccessFromFileURLs,
                      (v) => setState(
                          () => _allowUniversalAccessFromFileURLs = v)),
                  _switchTile('hardwareAcceleration', _hardwareAcceleration,
                      (v) => setState(() => _hardwareAcceleration = v)),
                  _switchTile('needInitialFocus', _needInitialFocus,
                      (v) => setState(() => _needInitialFocus = v)),
                  _switchTile('clearCache(onLoad)', _clearCacheOnLoad,
                      (v) => setState(() => _clearCacheOnLoad = v)),
                  _sliderTile('minimumLogicalFontSize',
                      _minimumLogicalFontSize, 0, 40,
                      (v) =>
                          setState(() => _minimumLogicalFontSize = v.round())),
                  _dropdownTile('mixedContentMode',
                      ['ALWAYS_ALLOW', 'NEVER_ALLOW', 'COMPATIBILITY'],
                      _mixedContentModeIdx,
                      (v) => setState(() => _mixedContentModeIdx = v)),
                  _dropdownTile('layoutAlgorithm',
                      ['NORMAL', 'TEXT_AUTOSIZING', 'NARROW_COLUMNS'],
                      _layoutAlgorithmIdx,
                      (v) => setState(() => _layoutAlgorithmIdx = v)),
                ],
              ),
            ),
          ),
          // 操作按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _applySettings,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('应用设置 + 重载'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _getSettings,
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('读取当前设置'),
                  ),
                ),
              ],
            ),
          ),
          // 状态 + 回读
          _resultPanel(),
          const Divider(height: 1),
          // WebView 区域
          Expanded(
            child: InAppWebView(
              initialData: InAppWebViewInitialData(data: _testHtml),
              initialSettings: InAppWebViewSettings(
                databaseEnabled: true,
                useShouldOverrideUrlLoading: true,
              ),
              onWebViewCreated: (controller) {
                _controller = controller;
                dev.log('onWebViewCreated', name: _kTag);
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
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(maxHeight: 110),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: SingleChildScrollView(
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
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _statusIsError
                            ? Colors.red
                            : Colors.black87)),
              ),
            ]),
            if (_readbackText.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(_readbackText,
                  style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Colors.teal)),
            ],
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
      child: Text(text, style: const TextStyle(fontSize: 12, height: 1.4)),
    );
  }

  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 2),
      child: Text(t,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.indigo)),
    );
  }

  Widget _switchTile(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontSize: 13)),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _sliderTile(String label, int value, int min, int max,
      ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(
            width: 170,
            child: Text('$label: $value',
                style: const TextStyle(fontSize: 12))),
        Expanded(
          child: Slider(
            min: min.toDouble(),
            max: max.toDouble(),
            value: value.toDouble().clamp(min.toDouble(), max.toDouble()),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _dropdownTile(String label, List<String> options, int valueIdx,
      ValueChanged<int> onChanged) {
    return Row(
      children: [
        SizedBox(
            width: 170,
            child: Text(label, style: const TextStyle(fontSize: 12))),
        Expanded(
          child: DropdownButton<int>(
            isExpanded: true,
            value: valueIdx,
            items: List.generate(
                options.length,
                (i) => DropdownMenuItem(
                    value: i,
                    child: Text(options[i],
                        style: const TextStyle(fontSize: 12)))),
            onChanged: (v) => onChanged(v ?? 0),
          ),
        ),
      ],
    );
  }
}
