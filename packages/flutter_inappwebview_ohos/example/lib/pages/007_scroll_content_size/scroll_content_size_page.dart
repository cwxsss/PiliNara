/// Demo 7: ScrollContentSize
///
/// 功能说明：展示通过 getScrollX/getScrollY/scrollTo/scrollBy/pageUp/pageDown
/// 控制页面滚动，通过 canScrollVertically/canScrollHorizontally 检查可滚动方向，
/// 通过 getContentHeight/getContentWidth 获取内容尺寸，以及 pause/resume
/// 暂停恢复 WebView。
/// 对应接口：
///   - getScrollX(): Future<int?>
///   - getScrollY(): Future<int?>
///   - scrollTo(x, y, animated?): Future<void>
///   - scrollBy(x, y, animated?): Future<void>
///   - canScrollVertically(): Future<bool>
///   - canScrollHorizontally(): Future<bool>
///   - getContentHeight(): Future<int?>
///   - getContentWidth(): Future<int?>
///   - pageDown(bottom): Future<bool>
///   - pageUp(top): Future<bool>
///   - pause(): Future<void>
///   - resume(): Future<void>

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String _kTag = 'InAppWebView_ScrollContentSize';

/// ScrollContentSizePage - 滚动与内容尺寸控制
///
/// 展示滚动控制与内容尺寸查询能力。
class ScrollContentSizePage extends StatefulWidget {
  const ScrollContentSizePage({super.key});

  @override
  State<ScrollContentSizePage> createState() => _ScrollContentSizePageState();
}

class _ScrollContentSizePageState extends State<ScrollContentSizePage> {
  // ─── 状态变量 ────────────────────────────────────────────────────────────
  int _scrollX = 0;
  int _scrollY = 0;
  bool _canScrollV = false;
  bool _canScrollH = false;
  int? _contentHeight;
  int? _contentWidth;
  bool _paused = false;
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

  /// 查询滚动位置与内容尺寸
  Future<void> _queryScroll() async {
    dev.log('_queryScroll called', name: _kTag);
    setState(() => _resultText = '查询中...');
    try {
      final results = await Future.wait([
        _controller?.getScrollX() ?? Future.value(0),
        _controller?.getScrollY() ?? Future.value(0),
        _controller?.canScrollVertically() ?? Future.value(false),
        _controller?.canScrollHorizontally() ?? Future.value(false),
        _controller?.getContentHeight() ?? Future.value(null),
        _controller?.getContentWidth() ?? Future.value(null),
      ]);
      dev.log('_queryScroll succeeded', name: _kTag);
      if (!mounted) return;
      setState(() {
        _scrollX = results[0] as int? ?? 0;
        _scrollY = results[1] as int? ?? 0;
        _canScrollV = results[2] as bool;
        _canScrollH = results[3] as bool;
        _contentHeight = results[4] as int?;
        _contentWidth = results[5] as int?;
        _resultText = '查询完成';
      });
    } catch (e, stack) {
      dev.log('_queryScroll failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _resultText = '错误：$e');
    }
  }

  /// 滚动到 (0, 500)
  Future<void> _scrollTo() async {
    dev.log('_scrollTo called', name: _kTag);
    try {
      await _controller?.scrollTo(x: 0, y: 500);
      dev.log('_scrollTo succeeded', name: _kTag);
      if (!mounted) return;
      setState(() => _resultText = '已滚动到(0,500)');
      await _queryScroll();
    } catch (e, stack) {
      dev.log('_scrollTo failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _resultText = '错误：$e');
    }
  }

  /// 滚动增量 (0, 200)
  Future<void> _scrollBy() async {
    dev.log('_scrollBy called', name: _kTag);
    try {
      await _controller?.scrollBy(x: 0, y: 200);
      dev.log('_scrollBy succeeded', name: _kTag);
      if (!mounted) return;
      setState(() => _resultText = '已滚动增量(0,200)');
      await _queryScroll();
    } catch (e, stack) {
      dev.log('_scrollBy failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _resultText = '错误：$e');
    }
  }

  /// 向上翻页
  Future<void> _pageUp() async {
    dev.log('_pageUp called', name: _kTag);
    try {
      await _controller?.pageUp(top: true);
      dev.log('_pageUp succeeded', name: _kTag);
      if (!mounted) return;
      setState(() => _resultText = '已向上翻页');
    } catch (e, stack) {
      dev.log('_pageUp failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _resultText = '错误：$e');
    }
  }

  /// 向下翻页
  Future<void> _pageDown() async {
    dev.log('_pageDown called', name: _kTag);
    try {
      await _controller?.pageDown(bottom: false);
      dev.log('_pageDown succeeded', name: _kTag);
      if (!mounted) return;
      setState(() => _resultText = '已向下翻页');
    } catch (e, stack) {
      dev.log('_pageDown failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _resultText = '错误：$e');
    }
  }

  /// 暂停 WebView
  Future<void> _pause() async {
    dev.log('_pause called', name: _kTag);
    try {
      await _controller?.pause();
      dev.log('_pause succeeded', name: _kTag);
      if (!mounted) return;
      setState(() {
        _paused = true;
        _resultText = '已暂停';
      });
    } catch (e, stack) {
      dev.log('_pause failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _resultText = '错误：$e');
    }
  }

  /// 恢复 WebView
  Future<void> _resume() async {
    dev.log('_resume called', name: _kTag);
    try {
      await _controller?.resume();
      dev.log('_resume succeeded', name: _kTag);
      if (!mounted) return;
      setState(() {
        _paused = false;
        _resultText = '已恢复';
      });
    } catch (e, stack) {
      dev.log('_resume failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _resultText = '错误：$e');
    }
  }

  // ─── UI 构建 ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('[007] 滚动与内容尺寸控制'),
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
                    onPressed: _queryScroll, child: const Text('查询滚动')),
                ElevatedButton(
                    onPressed: _scrollTo, child: const Text('滚动到(0,500)')),
                ElevatedButton(
                    onPressed: _scrollBy, child: const Text('滚动增量(0,200)')),
                ElevatedButton(
                    onPressed: _pageUp, child: const Text('向上翻页')),
                ElevatedButton(
                    onPressed: _pageDown, child: const Text('向下翻页')),
                ElevatedButton(
                    onPressed: _paused ? _resume : _pause,
                    child: Text(_paused ? '恢复' : '暂停')),
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
                Text('滚动X: $_scrollX'),
                Text('滚动Y: $_scrollY'),
                Text('可纵向滚动: $_canScrollV'),
                Text('可横向滚动: $_canScrollH'),
                Text('内容高度: $_contentHeight'),
                Text('内容宽度: $_contentWidth'),
                Text('已暂停: $_paused'),
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
