/// Demo 17: PrintJob
///
/// 功能说明：展示 PrintJobController 的打印任务控制能力，包括
/// cancel/restart/dismiss/getInfo/dispose/id/onComplete。
/// 对应接口：
///   - cancel(): Future<void>
///   - restart(): Future<void>
///   - dismiss({bool animated = true}): Future<void>
///   - getInfo(): Future<PrintJobInfo?>
///   - dispose(): void
///   - id: String (getter)
///   - onComplete: PrintJobCompletionHandler? (getter + setter)

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String _kTag = 'InAppWebView_PrintJob';

/// PrintJobPage - 打印任务控制
///
/// 展示 WebView 打印任务的生命周期管理。
class PrintJobPage extends StatefulWidget {
  const PrintJobPage({super.key});

  @override
  State<PrintJobPage> createState() => _PrintJobPageState();
}

class _PrintJobPageState extends State<PrintJobPage> {
  // ─── 状态变量 ────────────────────────────────────────────────────────────
  String _jobId = '';
  String _status = '等待打印请求';
  String _info = '';
  int _callbackCount = 0;
  String _callbackResult = '';

  // ─── 非响应式成员 ─────────────────────────────────────────────────────────
  PrintJobController? _printJobController;
  InAppWebViewController? _controller;

  /// 测试用 HTML
  static const String _testHtml = '''
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>Print Test</title></head>
<body>
<h1>Print Job Demo</h1>
<p>点击下方按钮调用 JS window.print() 触发打印请求。</p>
<button onclick="window.print()">Print</button>
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
    dev.log('Page disposed, releasing resources', name: _kTag);
    _printJobController?.dispose();
    super.dispose();
  }

  // ─── 核心功能方法 ────────────────────────────────────────────────────────

  /// 创建打印任务（通过 onPrintRequest 回调获取）
  /// 注意：OHOS 平台可能不支持 onPrintRequest，此处做平台兼容处理。

  /// 取消打印
  Future<void> _cancel() async {
    dev.log('_cancel called', name: _kTag);
    try {
      await _printJobController?.cancel();
      dev.log('_cancel succeeded', name: _kTag);
      if (!mounted) return;
      setState(() => _status = '已取消');
    } catch (e, stack) {
      dev.log('_cancel failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 重启打印
  Future<void> _restart() async {
    dev.log('_restart called', name: _kTag);
    try {
      await _printJobController?.restart();
      dev.log('_restart succeeded', name: _kTag);
      if (!mounted) return;
      setState(() => _status = '已重启');
    } catch (e, stack) {
      dev.log('_restart failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 关闭打印界面（使用默认 animated=true）
  Future<void> _dismiss() async {
    dev.log('_dismiss called', name: _kTag);
    try {
      await _printJobController?.dismiss();
      dev.log('_dismiss succeeded', name: _kTag);
      if (!mounted) return;
      setState(() => _status = '已关闭打印界面');
    } catch (e, stack) {
      dev.log('_dismiss failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 关闭打印界面（不带动画）
  Future<void> _dismissNoAnimation() async {
    dev.log('_dismissNoAnimation called', name: _kTag);
    try {
      await _printJobController?.dismiss(animated: false);
      dev.log('_dismissNoAnimation succeeded', name: _kTag);
      if (!mounted) return;
      setState(() => _status = '已关闭(无动画)');
    } catch (e, stack) {
      dev.log('_dismissNoAnimation failed',
          name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 获取打印信息
  Future<void> _getInfo() async {
    dev.log('_getInfo called', name: _kTag);
    try {
      final info = await _printJobController?.getInfo();
      dev.log('_getInfo succeeded: $info', name: _kTag);
      if (!mounted) return;
      setState(() {
        _info = info?.toString() ?? 'null';
        _status = '已获取信息';
      });
    } catch (e, stack) {
      dev.log('_getInfo failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 通过 JS 触发打印
  Future<void> _triggerPrint() async {
    dev.log('_triggerPrint called', name: _kTag);
    try {
      await _controller?.evaluateJavascript(source: 'window.print()');
      dev.log('_triggerPrint succeeded', name: _kTag);
      if (!mounted) return;
      setState(() => _status = '已触发打印请求');
    } catch (e, stack) {
      dev.log('_triggerPrint failed',
          name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  // ─── UI 构建 ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('[017] 打印任务控制'),
      ),
      body: Column(
        children: [
          // 操作区
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '展示 PrintJobController 的打印任务生命周期管理。'
                  '点击"触发打印"后，若平台回调 onPrintRequest，'
                  '将创建 PrintJobController 并可控制。',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                        onPressed: _triggerPrint,
                        child: const Text('触发打印')),
                    ElevatedButton(
                        onPressed: _cancel, child: const Text('取消')),
                    ElevatedButton(
                        onPressed: _restart, child: const Text('重启')),
                    ElevatedButton(
                        onPressed: _dismiss,
                        child: const Text('关闭(带动画)')),
                    ElevatedButton(
                        onPressed: _dismissNoAnimation,
                        child: const Text('关闭(无动画)')),
                    ElevatedButton(
                        onPressed: _getInfo, child: const Text('获取信息')),
                  ],
                ),
                const SizedBox(height: 8),
                Text('任务ID: $_jobId'),
                Text('状态: $_status'),
                Text('回调次数: $_callbackCount'),
                Text('回调结果: $_callbackResult'),
                const SizedBox(height: 4),
                SelectableText('PrintJobInfo: $_info'),
              ],
            ),
          ),
          const Divider(height: 1),
          // WebView 区域
          Expanded(
            child: InAppWebView(
              initialData: InAppWebViewInitialData(data: _testHtml),
              onWebViewCreated: (controller) {
                dev.log('onWebViewCreated', name: _kTag);
                _controller = controller;
              },
              onPrintRequest: (controller, url, printJobController) async {
                if (printJobController == null) {
                  dev.log('onPrintRequest: printJobController is null', name: _kTag);
                  return false;
                }
                dev.log(
                  'onPrintRequest: url=$url, jobId=${printJobController.id}',
                  name: _kTag,
                );
                _printJobController = PrintJobController.fromPlatform(
                    platform: printJobController);
                // 注册 onComplete 回调
                _printJobController!.onComplete = (completed, error) async {
                  dev.log(
                    'onComplete: completed=$completed, error=$error',
                    name: _kTag,
                  );
                  if (!mounted) return;
                  setState(() {
                    _callbackCount++;
                    _callbackResult =
                        'completed=$completed, error=$error';
                  });
                };
                if (!mounted) return false;
                setState(() {
                  _jobId = _printJobController!.id;
                  _status = '打印任务已创建';
                });
                return false;
              },
            ),
          ),
        ],
      ),
    );
  }
}
