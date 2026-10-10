/// Demo 21: KeepAliveInstance
///
/// 功能说明：直观演示 InAppWebViewKeepAlive 的作用——被 KeepAlive 复用的
/// WebView 实例在 Widget 从树上移除再重建后，其页面状态（滚动位置、输入内容、
/// JS 运行时状态）会被保留；而普通 WebView 每次重建都会重新加载、状态丢失。
///
/// 同时演示单实例与多实例的区别：不同的 InAppWebViewKeepAlive 实例拥有各自
/// 独立的 id，对应各自独立、互不影响的被保留 WebView。
///
/// 重要 API 说明：
///   - InAppWebViewKeepAlive() — 隐式默认构造，自动生成唯一 id。
///   - InAppWebView(keepAlive: ...) — 传入同一个 KeepAlive 实例，即可在 Widget
///     重建后复用同一个原生 WebView 实例。
///   - InAppWebViewControllerKeepAliveProps — 独立的数据类，用于在保活场景下
///     持有并恢复控制器级别的状态（javaScriptHandlersMap / userScripts /
///     webMessageListeners 等），使这些注册项在实例复用后依然有效。
///
/// 对应接口：
///   - InAppWebViewKeepAlive()
///   - InAppWebView(keepAlive: InAppWebViewKeepAlive)
///   - InAppWebViewControllerKeepAliveProps({...})

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String _kTag = 'InAppWebView_KeepAliveInstance';

/// 演示用页面：含一个计数器、滚动区域与输入框，便于观察状态是否被保留。
const String _demoHtml = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body { font-family: sans-serif; margin: 0; padding: 12px; }
    .box { height: 80px; margin: 6px 0; border-radius: 6px;
           display: flex; align-items: center; justify-content: center;
           color: #fff; font-size: 18px; }
    #counter { font-size: 22px; font-weight: bold; color: #d32f2f; }
    input { width: 90%; padding: 8px; font-size: 16px; }
    button { padding: 8px 16px; font-size: 16px; margin-top: 8px; }
  </style>
</head>
<body>
  <h3>计数器: <span id="counter">0</span></h3>
  <button onclick="document.getElementById('counter').innerText =
      (parseInt(document.getElementById('counter').innerText) + 1)">+1</button>
  <p>输入框（重建后观察是否保留）:</p>
  <input id="txt" placeholder="在这里输入文字..." />
  <p>下面是可滚动内容，滚动后观察位置是否保留:</p>
  <div class="box" style="background:#e57373">1</div>
  <div class="box" style="background:#ba68c8">2</div>
  <div class="box" style="background:#7986cb">3</div>
  <div class="box" style="background:#4db6ac">4</div>
  <div class="box" style="background:#aed581">5</div>
  <div class="box" style="background:#ffb74d">6</div>
  <div class="box" style="background:#a1887f">7</div>
  <div class="box" style="background:#90a4ae">8</div>
</body>
</html>
''';

/// KeepaliveInstancePage - KeepAlive 实例
class KeepaliveInstancePage extends StatefulWidget {
  const KeepaliveInstancePage({super.key});

  @override
  State<KeepaliveInstancePage> createState() => _KeepaliveInstancePageState();
}

class _KeepaliveInstancePageState extends State<KeepaliveInstancePage> {
  // ─── 状态变量 ────────────────────────────────────────────────────────────
  /// 是否显示 WebView 区域。切换它会把 WebView 从 Widget 树上移除/重新插入，
  /// 是本 Demo 观察“状态是否被保留”的核心开关。
  bool _showWebViews = true;

  /// 单实例模式使用的 KeepAlive 实例。始终复用同一个，实现状态保活。
  final InAppWebViewKeepAlive _keepAliveA = InAppWebViewKeepAlive();

  /// 多实例模式：每个实例独立保活，互不影响。
  final List<InAppWebViewKeepAlive> _multiInstances = [];

  /// 当前展示模式：single（单实例对比）/ multi（多实例）。
  String _mode = 'single';

  String _propsInfo = '';

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

  /// 切换 WebView 的显示/隐藏，用于验证状态保活。
  void _toggleShow() {
    setState(() => _showWebViews = !_showWebViews);
  }

  /// 创建一个新的独立 KeepAlive 实例（多实例模式）。
  void _addInstance() {
    setState(() {
      _multiInstances.add(InAppWebViewKeepAlive());
      _mode = 'multi';
    });
  }

  /// 演示 InAppWebViewControllerKeepAliveProps 的构造与用途。
  ///
  /// 它不是 KeepAlive 实例本身，而是“控制器保活属性包”：在实例被复用时，
  /// 用于持有/恢复 JS handler、注入脚本、WebMessage 通道等控制器级注册项，
  /// 保证这些注册在 WebView 复用后依然生效。
  void _explainProps() {
    dev.log('_explainProps called', name: _kTag);
    final props = InAppWebViewControllerKeepAliveProps(
      javaScriptHandlersMap: {},
      userScripts: {},
      webMessageListenerObjNames: {},
      injectedScriptsFromURL: {},
      webMessageChannels: {},
      webMessageListeners: {},
    );
    setState(() {
      _propsInfo = '类型: ${props.runtimeType}\n'
          'javaScriptHandlersMap: ${props.javaScriptHandlersMap}\n'
          'userScripts 条数: ${props.userScripts.length}\n'
          'injectedScriptsFromURL: ${props.injectedScriptsFromURL}\n\n'
          '用途：保活场景下持有并恢复控制器级状态\n'
          '（JS handler / 注入脚本 / WebMessage 等）。';
    });
  }

  // ─── UI 构建 ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('[021] KeepAlive实例'),
      ),
      body: Column(
        children: [
          _buildControls(),
          const Divider(height: 1),
          Expanded(
            child: _showWebViews
                ? (_mode == 'single' ? _buildSingleCompare() : _buildMulti())
                : const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'WebView 已从 Widget 树移除。\n'
                        '点击「显示 WebView」重新插入，观察：\n'
                        '• KeepAlive WebView：计数/输入/滚动位置保留\n'
                        '• 普通 WebView：状态全部重置（重新加载）',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, height: 1.6),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Colors.amber[50],
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                '操作步骤：\n'
                '1. 在下方 WebView 中点几次 +1、输入文字、向下滚动\n'
                '2. 点「隐藏 WebView」再点「显示 WebView」\n'
                '3. 对比：KeepAlive 一侧状态保留，普通一侧被重置',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: _toggleShow,
                child: Text(_showWebViews ? '隐藏 WebView' : '显示 WebView'),
              ),
              ElevatedButton(
                onPressed: () => setState(() => _mode = 'single'),
                child: const Text('单实例对比'),
              ),
              ElevatedButton(
                onPressed: _addInstance,
                child: const Text('新增独立实例'),
              ),
              ElevatedButton(
                onPressed: _explainProps,
                child: const Text('Props 说明'),
              ),
            ],
          ),
          if (_propsInfo.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: SelectableText(
                _propsInfo,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 单实例对比：左 KeepAlive（保活）、右普通（不保活）。
  Widget _buildSingleCompare() {
    return Row(
      children: [
        Expanded(child: _labeledWebView('KeepAlive（保活）', _keepAliveA)),
        const VerticalDivider(width: 1),
        Expanded(child: _labeledWebView('普通（不保活）', null)),
      ],
    );
  }

  /// 多实例：每个 KeepAlive 实例独立保活，互不影响。
  Widget _buildMulti() {
    if (_multiInstances.isEmpty) {
      return const Center(child: Text('点「新增独立实例」创建独立保活 WebView'));
    }
    return ListView.builder(
      itemCount: _multiInstances.length,
      itemBuilder: (context, i) => SizedBox(
        height: 260,
        child: _labeledWebView('独立实例 #${i + 1}', _multiInstances[i]),
      ),
    );
  }

  /// 带标题的 WebView。keepAlive 为 null 时创建普通（不保活）WebView。
  Widget _labeledWebView(String label, InAppWebViewKeepAlive? keepAlive) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6),
          color: keepAlive != null ? Colors.green[100] : Colors.grey[200],
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        Expanded(
          child: InAppWebView(
            keepAlive: keepAlive,
            initialData: InAppWebViewInitialData(
              data: _demoHtml,
              baseUrl: WebUri('https://localhost/'),
            ),
            onWebViewCreated: (controller) {
              dev.log('onWebViewCreated: $label', name: _kTag);
            },
          ),
        ),
      ],
    );
  }
}
