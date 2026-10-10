/// Demo 8: 缩放控制
///
/// 功能说明：直观演示 WebView 的缩放相关 API，主动触发缩放并实时显示缩放比例，
/// 而不只是被动等待手势。
///
/// 对应接口：
///   - zoomBy(zoomFactor): Future<void>   按倍数缩放
///   - zoomIn() / zoomOut(): Future<bool> 逐级放大/缩小
///   - getZoomScale(): Future<double?>    读取当前缩放比例
///   - onZoomScaleChanged(controller, oldScale, newScale)  缩放变化回调
///   - InAppWebViewSettings.textZoom      文字缩放（不改变布局缩放）
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String _kTag = 'InAppWebView_ZoomControl';

class ZoomControlPage extends StatefulWidget {
  const ZoomControlPage({super.key});

  @override
  State<ZoomControlPage> createState() => _ZoomControlPageState();
}

class _ZoomControlPageState extends State<ZoomControlPage> {
  double _zoomScale = 1.0;
  int _textZoom = 100;
  String _lastAction = '(无)';
  int _zoomEventCount = 0;

  InAppWebViewController? _controller;

  /// 一段有明显文字和色块的页面，缩放效果一眼可见。
  static const String _testHtml = '''
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<style>
  body{font-family:sans-serif;padding:16px}
  h1{color:#1976d2}
  .card{background:#ffecb3;border-radius:10px;padding:16px;margin:10px 0;font-size:18px}
  p{line-height:1.6}
</style></head>
<body>
  <h1>缩放演示页面</h1>
  <div class="card">这是一个色块卡片，缩放时它和文字会一起变大/变小。</div>
  <p>普通段落文字。textZoom 只改变文字大小，zoomBy/zoomIn/zoomOut 改变整体布局缩放。观察两者区别。</p>
  <div class="card">再来一个卡片，方便观察布局缩放的整体效果。</div>
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

  Future<void> _zoomBy(double factor) async {
    final c = _controller;
    if (c == null) return;
    await c.zoomBy(zoomFactor: factor);
    setState(() => _lastAction = 'zoomBy($factor)');
    await _readScale();
  }

  Future<void> _zoomIn() async {
    final c = _controller;
    if (c == null) return;
    final ok = await c.zoomIn();
    setState(() => _lastAction = 'zoomIn() -> $ok');
    await _readScale();
  }

  Future<void> _zoomOut() async {
    final c = _controller;
    if (c == null) return;
    final ok = await c.zoomOut();
    setState(() => _lastAction = 'zoomOut() -> $ok');
    await _readScale();
  }

  Future<void> _readScale() async {
    final c = _controller;
    if (c == null) return;
    final s = await c.getZoomScale();
    if (!mounted || s == null) return;
    setState(() => _zoomScale = s);
  }

  Future<void> _applyTextZoom() async {
    final c = _controller;
    if (c == null) return;
    await c.setSettings(settings: InAppWebViewSettings(textZoom: _textZoom));
    setState(() => _lastAction = 'textZoom = $_textZoom%');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('[008] 缩放控制')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.blue.shade50,
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('当前缩放比例: ${_zoomScale.toStringAsFixed(2)}x',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text('最近操作: $_lastAction', style: const TextStyle(fontSize: 12)),
                Text('onZoomScaleChanged 触发: $_zoomEventCount 次',
                    style: const TextStyle(fontSize: 12, color: Colors.blue)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(onPressed: _zoomIn, child: const Text('zoomIn')),
                ElevatedButton(onPressed: _zoomOut, child: const Text('zoomOut')),
                OutlinedButton(
                    onPressed: () => _zoomBy(1.5), child: const Text('zoomBy 1.5x')),
                OutlinedButton(
                    onPressed: () => _zoomBy(2.0), child: const Text('zoomBy 2.0x')),
                OutlinedButton(
                    onPressed: () => _zoomBy(0.5), child: const Text('zoomBy 0.5x')),
                OutlinedButton(
                    onPressed: _readScale, child: const Text('读取比例')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Text('textZoom '),
                Expanded(
                  child: Slider(
                    min: 50,
                    max: 200,
                    divisions: 15,
                    value: _textZoom.toDouble(),
                    label: '$_textZoom%',
                    onChanged: (v) => setState(() => _textZoom = v.toInt()),
                  ),
                ),
                Text('$_textZoom%'),
                TextButton(onPressed: _applyTextZoom, child: const Text('应用')),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: InAppWebView(
              initialData: InAppWebViewInitialData(data: _testHtml),
              initialSettings: InAppWebViewSettings(
                textZoom: _textZoom,
                supportZoom: true,
                builtInZoomControls: true,
              ),
              onWebViewCreated: (controller) {
                _controller = controller;
                dev.log('onWebViewCreated', name: _kTag);
              },
              onZoomScaleChanged: (controller, oldScale, newScale) {
                dev.log('onZoomScaleChanged: $oldScale -> $newScale',
                    name: _kTag);
                if (!mounted) return;
                setState(() {
                  _zoomScale = newScale;
                  _zoomEventCount++;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
