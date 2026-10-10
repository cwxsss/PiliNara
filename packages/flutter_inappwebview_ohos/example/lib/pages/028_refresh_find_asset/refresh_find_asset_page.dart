/// Demo 28: 刷新外观 / FindSession / AssetLoader
///
/// 功能说明：集中演示三个尚未被其它 demo 覆盖的小模块：
/// 1. PullToRefreshController 外观设置 —— 顶部有一个「指示器预览」跟随
///    颜色/背景色/大小实时变化，下拉 WebView 时能看到真实指示器；
/// 2. FindInteractionController.getActiveFindSession() —— 输入关键词
///    findAll 后，WebView 中的匹配文本会被高亮，同时展示会话统计；
/// 3. WebViewAssetLoader 的三种 PathHandler 构造演示。
///
/// 对应接口：
///   - PullToRefreshController.setColor / setBackgroundColor
///   - PullToRefreshController.setDistanceToTriggerSync / setSlingshotDistance
///   - PullToRefreshController.setIndicatorSize(PullToRefreshSize)
///   - FindInteractionController.setSearchText / findAll / findNext
///   - FindInteractionController.getActiveFindSession(): Future<FindSession?>
///   - WebViewAssetLoader + AssetsPathHandler / ResourcesPathHandler /
///     InternalStoragePathHandler

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String _kTag = 'InAppWebView_RefreshFindAsset';

/// RefreshFindAssetPage - 刷新外观 / FindSession / AssetLoader
class RefreshFindAssetPage extends StatefulWidget {
  const RefreshFindAssetPage({super.key});

  @override
  State<RefreshFindAssetPage> createState() => _RefreshFindAssetPageState();
}

class _RefreshFindAssetPageState extends State<RefreshFindAssetPage> {
  InAppWebViewController? _controller;

  // PullToRefresh 状态
  Color _indicatorColor = Colors.blue;
  Color _bgColor = Colors.white;
  int _triggerDistance = 100;
  int _slingshotDistance = 60;
  int _indicatorSizeIdx = 0; // 0=DEFAULT, 1=LARGE

  // FindSession 状态
  final _searchController = TextEditingController(text: 'flutter');
  String _findSessionInfo = '(未查询)';

  // AssetLoader 信息
  String _assetLoaderInfo = '(未创建)';

  String _statusText = '页面加载中…';
  bool _statusIsError = false;

  late PullToRefreshController _pullToRefreshController;
  late FindInteractionController _findInteractionController;

  /// 下拉刷新用的长页面 HTML，含可查找文本
  static const String _testHtml = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body { font-family: sans-serif; padding: 16px; }
    .box { height: 160px; margin: 10px 0; border-radius: 8px;
           display:flex; align-items:center; justify-content:center;
           font-size:22px; color:#fff; }
    .findable { background:#e3f2fd; padding:8px; margin:8px 0;
                border:1px solid #90caf9; border-radius:6px; }
    #ts { color:#e53935; font-weight:bold; }
  </style>
</head>
<body>
  <h3>下拉刷新 / 查找 / AssetLoader 演示</h3>
  <p>下拉本页可触发刷新（指示器外观由上方设置控制）。</p>
  <p>页面加载时间戳：<span id="ts"></span>（刷新后会变化）</p>
  <div class="findable">flutter inappwebview 是 flutter 的 WebView 插件</div>
  <div class="findable">flutter 是一个跨平台 UI 框架，flutter 很流行</div>
  <div class="findable">再来一句包含 flutter 关键词的可查找文本</div>
  <div class="box" style="background:#e57373">向下滚动继续 1</div>
  <div class="box" style="background:#ba68c8">2</div>
  <div class="box" style="background:#7986cb">3</div>
  <div class="box" style="background:#4db6ac">4</div>
  <script>
    document.getElementById('ts').innerText = new Date().toLocaleTimeString();
  </script>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    dev.log('Page appeared', name: _kTag);
    _pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(
        color: _indicatorColor,
        backgroundColor: _bgColor,
        distanceToTriggerSync: _triggerDistance,
        slingshotDistance: _slingshotDistance,
        size: PullToRefreshSize.DEFAULT,
      ),
      onRefresh: () async {
        dev.log('onRefresh triggered', name: _kTag);
        _setStatus('下拉刷新触发，正在 reload…');
        await _controller?.reload();
      },
    );
    _findInteractionController = FindInteractionController(
      onFindResultReceived:
          (controller, activeMatchOrdinal, numberOfMatches, isDoneCounting) {
        dev.log(
            'onFindResultReceived: $activeMatchOrdinal/$numberOfMatches done=$isDoneCounting',
            name: _kTag);
        if (!mounted || !isDoneCounting) return;
        setState(() => _findSessionInfo =
            'onFindResultReceived → 第 ${activeMatchOrdinal + 1} / '
            '共 $numberOfMatches 个匹配');
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
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

  // ─── PullToRefresh 外观方法 ─────────────────────────────────────────────

  Future<void> _setColor(Color color) async {
    dev.log('_setColor: $color', name: _kTag);
    await _pullToRefreshController.setColor(color);
    setState(() => _indicatorColor = color);
    _setStatus('已设置指示器颜色');
  }

  Future<void> _setBgColor(Color color) async {
    dev.log('_setBgColor: $color', name: _kTag);
    await _pullToRefreshController.setBackgroundColor(color);
    setState(() => _bgColor = color);
    _setStatus('已设置指示器背景色');
  }

  Future<void> _setTriggerDistance(int d) async {
    await _pullToRefreshController.setDistanceToTriggerSync(d);
    setState(() => _triggerDistance = d);
  }

  Future<void> _setSlingshotDistance(int d) async {
    await _pullToRefreshController.setSlingshotDistance(d);
    setState(() => _slingshotDistance = d);
  }

  Future<void> _setIndicatorSize(int idx) async {
    dev.log('_setIndicatorSize: $idx', name: _kTag);
    final size =
        idx == 0 ? PullToRefreshSize.DEFAULT : PullToRefreshSize.LARGE;
    await _pullToRefreshController.setIndicatorSize(size);
    setState(() => _indicatorSizeIdx = idx);
    _setStatus('已设置指示器大小: ${idx == 0 ? "DEFAULT" : "LARGE"}');
  }

  // ─── FindSession 方法 ───────────────────────────────────────────────────

  /// findAll 查找并高亮，随后查询 getActiveFindSession
  Future<void> _findAndQuerySession() async {
    final text = _searchController.text.trim();
    dev.log('_findAndQuerySession: "$text"', name: _kTag);
    if (text.isEmpty) {
      _setStatus('请先输入查找关键词', isError: true);
      return;
    }
    setState(() => _findSessionInfo = '查找中…');
    try {
      await _findInteractionController.setSearchText(text);
      await _findInteractionController.findAll();
      await Future.delayed(const Duration(milliseconds: 500));
      final session = await _findInteractionController.getActiveFindSession();
      dev.log('getActiveFindSession: $session', name: _kTag);
      if (!mounted) return;
      if (session == null) {
        setState(() => _findSessionInfo =
            'getActiveFindSession() 返回 null（部分平台不支持，'
            '但匹配项已在页面高亮，可看 onFindResultReceived 统计）');
      } else {
        setState(() => _findSessionInfo =
            'getActiveFindSession →\n'
            'resultCount: ${session.resultCount}\n'
            'highlightedIndex: ${session.highlightedResultIndex}\n'
            'displayStyle: ${session.searchResultDisplayStyle.toValue()}');
      }
      _setStatus('已查找「$text」，匹配项在 WebView 中高亮');
    } catch (e, stack) {
      dev.log('_findAndQuerySession failed', name: _kTag,
          error: e, stackTrace: stack);
      _setStatus('查找失败：$e', isError: true);
    }
  }

  Future<void> _findNext(bool forward) async {
    await _findInteractionController.findNext(forward: forward);
    _setStatus('findNext(forward=$forward)');
  }

  // ─── WebViewAssetLoader 方法 ────────────────────────────────────────────

  Future<void> _createAssetLoader() async {
    dev.log('_createAssetLoader called', name: _kTag);
    try {
      final assetsHandler = AssetsPathHandler(path: 'assets');
      final resourcesHandler = ResourcesPathHandler(path: 'res');
      final internalHandler = InternalStoragePathHandler(
        path: 'internal',
        directory: 'cache',
      );
      final loader = WebViewAssetLoader(
        pathHandlers: [assetsHandler, resourcesHandler, internalHandler],
      );
      dev.log(
          'WebViewAssetLoader created: ${loader.pathHandlers?.length} handlers, '
          'domain=${loader.domain}',
          name: _kTag);
      if (!mounted) return;
      setState(() {
        _assetLoaderInfo =
            '已创建 WebViewAssetLoader（domain=${loader.domain ?? "默认"}），'
            '含 3 个 PathHandler:\n'
            '1. AssetsPathHandler(path="${assetsHandler.path}")\n'
            '2. ResourcesPathHandler(path="${resourcesHandler.path}")\n'
            '3. InternalStoragePathHandler(path="${internalHandler.path}", '
            'directory="${internalHandler.directory}")\n'
            '用途：让 WebView 通过虚拟域名安全加载本地资源。';
      });
      _setStatus('已创建 WebViewAssetLoader');
    } catch (e, stack) {
      dev.log('_createAssetLoader failed', name: _kTag,
          error: e, stackTrace: stack);
      _setStatus('创建 AssetLoader 失败：$e', isError: true);
    }
  }

  // ─── UI 构建 ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('[028] 刷新外观/查找会话/AssetLoader')),
      body: Column(
        children: [
          _hintBanner(
            '① 调颜色/大小后下拉 WebView 看刷新指示器；② 输入关键词查找，'
            '匹配文本会在页面高亮；③ 创建 AssetLoader 的三种 PathHandler。',
          ),
          SizedBox(
            height: 300,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── PullToRefresh 外观 ──
                  Row(
                    children: [
                      _sectionTitle('① 下拉刷新外观'),
                      const Spacer(),
                      _indicatorPreview(),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Text('指示器色 ', style: TextStyle(fontSize: 12)),
                      _colorDot(_indicatorColor, _setColor),
                      const SizedBox(width: 16),
                      const Text('背景色 ', style: TextStyle(fontSize: 12)),
                      _colorDot(_bgColor, _setBgColor),
                    ],
                  ),
                  _labeledSlider('触发距离', _triggerDistance, 50, 300,
                      (v) => _setTriggerDistance(v)),
                  _labeledSlider('弹性距离', _slingshotDistance, 20, 150,
                      (v) => _setSlingshotDistance(v)),
                  Row(
                    children: [
                      const Text('指示器大小 ', style: TextStyle(fontSize: 12)),
                      ChoiceChip(
                        label: const Text('DEFAULT'),
                        selected: _indicatorSizeIdx == 0,
                        onSelected: (_) => _setIndicatorSize(0),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('LARGE'),
                        selected: _indicatorSizeIdx == 1,
                        onSelected: (_) => _setIndicatorSize(1),
                      ),
                    ],
                  ),
                  const Divider(),

                  // ── FindSession ──
                  _sectionTitle('② 查找与会话查询'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            isDense: true,
                            labelText: '查找关键词',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _findAndQuerySession,
                        child: const Text('查找'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(children: [
                    TextButton.icon(
                      onPressed: () => _findNext(false),
                      icon: const Icon(Icons.keyboard_arrow_up, size: 18),
                      label: const Text('上一个'),
                    ),
                    TextButton.icon(
                      onPressed: () => _findNext(true),
                      icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                      label: const Text('下一个'),
                    ),
                  ]),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(_findSessionInfo,
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 11)),
                  ),
                  const Divider(),

                  // ── AssetLoader ──
                  _sectionTitle('③ WebViewAssetLoader'),
                  const SizedBox(height: 6),
                  ElevatedButton(
                    onPressed: _createAssetLoader,
                    child: const Text(
                        '创建 Assets/Resources/InternalStorage PathHandler'),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(_assetLoaderInfo,
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 11)),
                  ),
                ],
              ),
            ),
          ),
          // 状态条
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: _statusIsError ? Colors.red[50] : Colors.grey[100],
            child: Row(children: [
              Icon(_statusIsError ? Icons.error : Icons.info_outline,
                  size: 16,
                  color: _statusIsError ? Colors.red : Colors.blue),
              const SizedBox(width: 6),
              Expanded(
                child: Text(_statusText,
                    style: TextStyle(
                        fontSize: 12,
                        color:
                            _statusIsError ? Colors.red : Colors.black87)),
              ),
            ]),
          ),
          const Divider(height: 1),
          // WebView 区域
          Expanded(
            child: InAppWebView(
              initialData: InAppWebViewInitialData(data: _testHtml),
              initialSettings: InAppWebViewSettings(
                useShouldOverrideUrlLoading: true,
              ),
              pullToRefreshController: _pullToRefreshController,
              findInteractionController: _findInteractionController,
              onWebViewCreated: (controller) {
                _controller = controller;
                dev.log('onWebViewCreated', name: _kTag);
              },
              onLoadStop: (controller, url) async {
                await _pullToRefreshController.endRefreshing();
                _setStatus('页面加载完成');
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 指示器外观预览（跟随设置实时变化）
  Widget _indicatorPreview() {
    final size = _indicatorSizeIdx == 0 ? 28.0 : 38.0;
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _bgColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade400),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 3)
            ],
          ),
          child: Icon(Icons.refresh, size: size * 0.6, color: _indicatorColor),
        ),
        const Text('预览', style: TextStyle(fontSize: 9, color: Colors.grey)),
      ],
    );
  }

  Widget _labeledSlider(
      String label, int value, int min, int max, ValueChanged<int> onChanged) {
    return Row(
      children: [
        SizedBox(
            width: 64,
            child: Text(label, style: const TextStyle(fontSize: 12))),
        Expanded(
          child: Slider(
            min: min.toDouble(),
            max: max.toDouble(),
            value: value.toDouble(),
            label: '$value',
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        SizedBox(
            width: 34,
            child: Text('$value',
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.right)),
      ],
    );
  }

  Widget _colorDot(Color color, ValueChanged<Color> onSelected) {
    return GestureDetector(
      onTap: () async {
        final c = await _pickColor();
        if (c != null) onSelected(c);
      },
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey),
        ),
      ),
    );
  }

  Future<Color?> _pickColor() async {
    final colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange,
      Colors.purple, Colors.teal, Colors.pink, Colors.indigo,
      Colors.white, Colors.black, Colors.amber, Colors.cyan,
    ];
    return showDialog<Color>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('选择颜色'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((c) {
            return GestureDetector(
              onTap: () => Navigator.pop(ctx, c),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade400),
                ),
              ),
            );
          }).toList(),
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
    return Text(t,
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 14, color: Colors.indigo));
  }
}
