/// Demo 12: FindContent
///
/// 功能说明：展示 FindInteractionController 的页内查找能力，包括
/// findAll/findNext/clearMatches/setSearchText/getSearchText 与
/// onFindResultReceived 回调。
/// 对应接口：
///   - findAll(find?): Future<void>
///   - findNext(forward?): Future<void>
///   - clearMatches(): Future<void>
///   - setSearchText(searchText?): Future<void>
///   - getSearchText(): Future<String?>
///   - onFindResultReceived(controller, activeMatchOrdinal, numberOfMatches, isDoneCounting): void

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String _kTag = 'InAppWebView_FindContent';

/// FindContentPage - 页面内容查找
///
/// 展示页面文本查找与高亮机制。
class FindContentPage extends StatefulWidget {
  const FindContentPage({super.key});

  @override
  State<FindContentPage> createState() => _FindContentPageState();
}

class _FindContentPageState extends State<FindContentPage> {
  // ─── 双计数器（诊断回调链路） ────────────────────────────────────────────
  int _findCallCount = 0;
  int _findCallbackCount = 0;

  // ─── 状态变量 ────────────────────────────────────────────────────────────
  int _activeMatch = 0;
  int _totalMatches = 0;
  bool _doneCounting = false;
  String? _searchText;

  // ─── 非响应式成员 ─────────────────────────────────────────────────────────
  FindInteractionController? _findController;
  final TextEditingController _searchInputController =
      TextEditingController(text: 'Flutter');

  /// 测试用 HTML，含多段可查找文本
  static const String _testHtml = '''
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>Find Test</title></head>
<body>
<h1>Flutter Find Interaction Demo</h1>
<p>Flutter is a popular cross-platform framework. Flutter uses Dart.</p>
<p>You can search for "Flutter" in this page.</p>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    dev.log('Page appeared', name: _kTag);
    // 创建 FindInteractionController 并注册回调
    _findController = FindInteractionController(
      onFindResultReceived: (controller, activeMatchOrdinal,
          numberOfMatches, isDoneCounting) {
        dev.log(
          'onFindResultReceived: active=$activeMatchOrdinal, '
          'total=$numberOfMatches, done=$isDoneCounting',
          name: _kTag,
        );
        if (!mounted) return;
        setState(() {
          _findCallbackCount++;
          _activeMatch = activeMatchOrdinal;
          _totalMatches = numberOfMatches;
          _doneCounting = isDoneCounting;
        });
      },
    );
  }

  @override
  void dispose() {
    dev.log('Page disposed, releasing resources', name: _kTag);
    _searchInputController.dispose();
    super.dispose();
  }

  // ─── 核心功能方法 ────────────────────────────────────────────────────────

  /// 查找全部
  Future<void> _findAll() async {
    dev.log('_findAll called', name: _kTag);
    setState(() => _findCallCount++);
    try {
      await _findController?.findAll(find: _searchInputController.text);
      dev.log('_findAll succeeded', name: _kTag);
    } catch (e, stack) {
      dev.log('_findAll failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _totalMatches = 0);
    }
  }

  /// 下一个
  Future<void> _findNext() async {
    dev.log('_findNext called', name: _kTag);
    try {
      await _findController?.findNext(forward: true);
      dev.log('_findNext succeeded', name: _kTag);
    } catch (e, stack) {
      dev.log('_findNext failed', name: _kTag, error: e, stackTrace: stack);
    }
  }

  /// 上一个
  Future<void> _findPrev() async {
    dev.log('_findPrev called', name: _kTag);
    try {
      await _findController?.findNext(forward: false);
      dev.log('_findPrev succeeded', name: _kTag);
    } catch (e, stack) {
      dev.log('_findPrev failed', name: _kTag, error: e, stackTrace: stack);
    }
  }

  /// 清除高亮
  Future<void> _clearMatches() async {
    dev.log('_clearMatches called', name: _kTag);
    try {
      await _findController?.clearMatches();
      dev.log('_clearMatches succeeded', name: _kTag);
      if (!mounted) return;
      setState(() {
        _totalMatches = 0;
        _activeMatch = 0;
      });
    } catch (e, stack) {
      dev.log('_clearMatches failed',
          name: _kTag, error: e, stackTrace: stack);
    }
  }

  /// 设置搜索词
  Future<void> _setSearchText() async {
    dev.log('_setSearchText called', name: _kTag);
    try {
      await _findController
          ?.setSearchText(_searchInputController.text);
      dev.log('_setSearchText succeeded', name: _kTag);
    } catch (e, stack) {
      dev.log('_setSearchText failed',
          name: _kTag, error: e, stackTrace: stack);
    }
  }

  /// 获取搜索词
  Future<void> _getSearchText() async {
    dev.log('_getSearchText called', name: _kTag);
    try {
      final text = await _findController?.getSearchText();
      dev.log('_getSearchText succeeded: $text', name: _kTag);
      if (!mounted) return;
      setState(() => _searchText = text);
    } catch (e, stack) {
      dev.log('_getSearchText failed',
          name: _kTag, error: e, stackTrace: stack);
    }
  }

  // ─── UI 构建 ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('[012] 页面内容查找'),
      ),
      body: Column(
        children: [
          // 操作区
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _searchInputController,
                  decoration: const InputDecoration(
                    labelText: '搜索词',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                        onPressed: _findAll,
                        child: const Text('查找全部')),
                    ElevatedButton(
                        onPressed: _findNext, child: const Text('下一个')),
                    ElevatedButton(
                        onPressed: _findPrev, child: const Text('上一个')),
                    ElevatedButton(
                        onPressed: _clearMatches,
                        child: const Text('清除高亮')),
                    ElevatedButton(
                        onPressed: _setSearchText,
                        child: const Text('设置搜索词')),
                    ElevatedButton(
                        onPressed: _getSearchText,
                        child: const Text('获取搜索词')),
                  ],
                ),
                const SizedBox(height: 8),
                // 诊断区域（双计数器）
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('诊断信息',
                            style:
                                TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('触发次数: $_findCallCount'),
                        Text('回调次数: $_findCallbackCount'),
                        Text('当前匹配序号: $_activeMatch'),
                        Text('总匹配数: $_totalMatches'),
                        Text('计数完成: $_doneCounting'),
                        Text('搜索词: $_searchText'),
                        if (_findCallCount > 0 &&
                            _findCallbackCount == 0)
                          const Text(
                            '⚠️ 已触发但回调未收到，请检查监听注册',
                            style: TextStyle(color: Colors.orange),
                          ),
                        if (_findCallbackCount > 0 &&
                            _findCallCount == _findCallbackCount)
                          const Text(
                            '✅ 链路正常',
                            style: TextStyle(color: Colors.green),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // WebView 区域
          Expanded(
            child: InAppWebView(
              initialData: InAppWebViewInitialData(data: _testHtml),
              findInteractionController: _findController,
            ),
          ),
        ],
      ),
    );
  }
}
