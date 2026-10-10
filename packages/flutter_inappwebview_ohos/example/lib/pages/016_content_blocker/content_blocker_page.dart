/// Demo 16: 内容拦截规则 (ContentBlocker)
///
/// 功能说明：直观展示三类 ContentBlocker 规则的实际效果。页面里放了一张会被
/// BLOCK 的图片、一个会被 CSS_DISPLAY_NONE 隐藏的广告条，切换规则并重载即可看到
/// 页面内容随规则变化。
///
/// 对应接口：
///   - ContentBlocker(trigger, action)
///   - ContentBlockerTrigger(urlFilter, resourceType, ...)
///   - ContentBlockerAction(type, selector)
///   - ContentBlockerActionType.BLOCK / CSS_DISPLAY_NONE / MAKE_HTTPS
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String _kTag = 'InAppWebView_ContentBlocker';

class ContentBlockerPage extends StatefulWidget {
  const ContentBlockerPage({super.key});

  @override
  State<ContentBlockerPage> createState() => _ContentBlockerPageState();
}

class _ContentBlockerPageState extends State<ContentBlockerPage> {
  bool _blockImage = true;
  bool _cssHide = true;
  bool _makeHttps = false;

  int _appliedCount = 0;
  String _status = '尚未应用规则';

  InAppWebViewController? _controller;

  /// 页面含：一张来自 via.placeholder.com 的图片（可被 BLOCK）、一个 .ad-banner
  /// 广告条（可被 CSS 隐藏）、以及正常内容。
  static const String _testHtml = '''
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<style>
  body{font-family:sans-serif;padding:16px;font-size:15px}
  .ad-banner{background:#e53935;color:#fff;padding:16px;border-radius:8px;margin:10px 0;text-align:center;font-weight:bold}
  .normal{background:#e8f5e9;padding:16px;border-radius:8px;margin:10px 0}
  img{max-width:100%;border:1px solid #ccc;display:block;margin:10px 0}
</style></head>
<body>
  <h3>ContentBlocker 效果演示</h3>
  <p>① 下面这张图片会被 BLOCK 规则拦截（加载失败）：</p>
  <img src="https://via.placeholder.com/300x100.png?text=Ad+Image"
       onerror="this.insertAdjacentHTML('afterend','<p style=color:red>↑ 图片被拦截，未加载</p>')">
  <p>② 下面这个红色广告条会被 CSS_DISPLAY_NONE 隐藏：</p>
  <div class="ad-banner">我是广告横幅 .ad-banner</div>
  <div class="normal">③ 我是正常内容，不受规则影响，始终可见。</div>
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

  List<ContentBlocker> _buildBlockers() {
    final blockers = <ContentBlocker>[];
    if (_blockImage) {
      blockers.add(ContentBlocker(
        trigger: ContentBlockerTrigger(
          urlFilter: '.*placeholder\\.com.*',
          resourceType: const [ContentBlockerTriggerResourceType.IMAGE],
        ),
        action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK),
      ));
    }
    if (_cssHide) {
      blockers.add(ContentBlocker(
        trigger: ContentBlockerTrigger(urlFilter: '.*'),
        action: ContentBlockerAction(
          type: ContentBlockerActionType.CSS_DISPLAY_NONE,
          selector: '.ad-banner',
        ),
      ));
    }
    if (_makeHttps) {
      blockers.add(ContentBlocker(
        trigger: ContentBlockerTrigger(urlFilter: 'http://.*'),
        action: ContentBlockerAction(type: ContentBlockerActionType.MAKE_HTTPS),
      ));
    }
    return blockers;
  }

  Future<void> _applyAndReload() async {
    final c = _controller;
    if (c == null) return;
    try {
      final blockers = _buildBlockers();
      await c.setSettings(
          settings: InAppWebViewSettings(contentBlockers: blockers));
      await c.reload();
      if (!mounted) return;
      setState(() {
        _appliedCount = blockers.length;
        _status = '已应用 ${blockers.length} 条规则并重载';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = '错误: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('[016] 内容拦截规则')),
      body: Column(
        children: [
          SwitchListTile(
            dense: true,
            title: const Text('BLOCK：拦截图片请求'),
            subtitle: const Text('拦截 placeholder.com 的图片，使其无法加载',
                style: TextStyle(fontSize: 11)),
            value: _blockImage,
            onChanged: (v) => setState(() => _blockImage = v),
          ),
          SwitchListTile(
            dense: true,
            title: const Text('CSS_DISPLAY_NONE：隐藏元素'),
            subtitle: const Text('用选择器 .ad-banner 隐藏广告横幅',
                style: TextStyle(fontSize: 11)),
            value: _cssHide,
            onChanged: (v) => setState(() => _cssHide = v),
          ),
          SwitchListTile(
            dense: true,
            title: const Text('MAKE_HTTPS：升级到 HTTPS'),
            subtitle: const Text('把 http:// 请求升级为 https://',
                style: TextStyle(fontSize: 11)),
            value: _makeHttps,
            onChanged: (v) => setState(() => _makeHttps = v),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyAndReload,
                    child: const Text('应用规则并重载'),
                  ),
                ),
                const SizedBox(width: 12),
                Text('规则数: $_appliedCount'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text('状态: $_status', style: const TextStyle(fontSize: 12)),
          ),
          const Divider(height: 1),
          Expanded(
            child: InAppWebView(
              initialData: InAppWebViewInitialData(data: _testHtml),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                contentBlockers: _buildBlockers(),
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
}
