/// Demo 13: ProxyConfig
///
/// 功能说明：展示 ProxyController 的网络代理设置与清除能力，包括
/// setProxyOverride/clearProxyOverride。
/// 对应接口：
///   - setProxyOverride(settings): Future<void>
///   - clearProxyOverride(): Future<void>

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String _kTag = 'InAppWebView_ProxyConfig';

/// ProxyConfigPage - 网络代理配置
///
/// 展示 WebView 网络代理配置机制。
class ProxyConfigPage extends StatefulWidget {
  const ProxyConfigPage({super.key});

  @override
  State<ProxyConfigPage> createState() => _ProxyConfigPageState();
}

class _ProxyConfigPageState extends State<ProxyConfigPage> {
  // ─── 状态变量 ────────────────────────────────────────────────────────────
  String _status = '';
  int _callCount = 0;
  int _doneCount = 0;

  // ─── 非响应式成员 ─────────────────────────────────────────────────────────
  final TextEditingController _hostController =
      TextEditingController(text: '127.0.0.1');
  final TextEditingController _portController =
      TextEditingController(text: '8888');

  @override
  void initState() {
    super.initState();
    dev.log('Page appeared', name: _kTag);
  }

  @override
  void dispose() {
    dev.log('Page disposed, releasing resources', name: _kTag);
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  // ─── 核心功能方法 ────────────────────────────────────────────────────────

  /// 应用代理
  ///
  /// 调用 [setProxyOverride] 设置代理。
  Future<void> _applyProxy() async {
    dev.log('_applyProxy called', name: _kTag);
    setState(() {
      _callCount++;
      _status = '应用中';
    });
    try {
      final settings = ProxySettings(
        proxyRules: [
          ProxyRule(
            url:
                'http://${_hostController.text}:${_portController.text}',
          ),
        ],
      );
      await ProxyController.instance()
          .setProxyOverride(settings: settings);
      dev.log('_applyProxy succeeded', name: _kTag);
      if (!mounted) return;
      setState(() {
        _doneCount++;
        _status = '代理已应用 ${_hostController.text}:${_portController.text}';
      });
    } catch (e, stack) {
      dev.log('_applyProxy failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 清除代理
  Future<void> _clearProxy() async {
    dev.log('_clearProxy called', name: _kTag);
    setState(() => _status = '清除中');
    try {
      await ProxyController.instance().clearProxyOverride();
      dev.log('_clearProxy succeeded', name: _kTag);
      if (!mounted) return;
      setState(() => _status = '代理已清除');
    } catch (e, stack) {
      dev.log('_clearProxy failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  // ─── UI 构建 ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('[013] 网络代理配置'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 说明区域
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '展示 ProxyController 的 setProxyOverride 和 '
                  'clearProxyOverride 能力。设置代理后 WebView 流量'
                  '将经指定代理服务器转发。',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 代理配置输入区
            TextField(
              controller: _hostController,
              decoration: const InputDecoration(
                labelText: '代理主机',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _portController,
              decoration: const InputDecoration(
                labelText: '代理端口',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // 操作按钮区
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyProxy,
                    child: const Text('应用代理'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _clearProxy,
                    child: const Text('清除代理'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 结果展示区
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('状态: $_status'),
                  Text('调用/完成: $_callCount/$_doneCount'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
