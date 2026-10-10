/// Demo 23: 页面内容提取
///
/// 功能说明：直观演示 InAppWebViewController 的内容提取类 API，
/// 一键抓取页面的 HTML、标题、meta 标签、主题色、favicon、选中文字、
/// 命中测试结果、SSL 证书及截图，并展示在页面上。
///
/// 对应接口：
///   - getHtml(): Future<String?>
///   - getTitle(): Future<String?>
///   - getMetaTags(): Future<List<MetaTag>>
///   - getMetaThemeColor(): Future<Color?>
///   - getFavicons(): Future<List<Favicon>>
///   - getSelectedText(): Future<String?>
///   - getHitTestResult(): Future<InAppWebViewHitTestResult?>
///   - getCertificate(): Future<SslCertificate?>
///   - takeScreenshot(): Future<Uint8List?>
///   - getUrl(): Future<WebUri?>

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// ContentExtractPage - 页面内容提取演示
class ContentExtractPage extends StatefulWidget {
  const ContentExtractPage({super.key});

  @override
  State<ContentExtractPage> createState() => _ContentExtractPageState();
}

class _ContentExtractPageState extends State<ContentExtractPage> {
  InAppWebViewController? _controller;

  String _statusText = '等待加载完成...';
  String _htmlSnippet = '';
  String _metaInfo = '';
  String _faviconInfo = '';
  String _selectedText = '';
  String _hitTestInfo = '';
  String _certInfo = '';
  String _urlInfo = '';
  Uint8List? _screenshot;

  bool _loading = false;

  /// 测试页 HTML，含 meta 标签、主题色、favicon 链接、可选中文字
  static const String _testHtml = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="内容提取测试页">
  <meta name="theme-color" content="#1976d2">
  <link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'><circle cx='8' cy='8' r='6' fill='red'/></svg>">
  <title>内容提取测试</title>
</head>
<body>
  <h1>内容提取测试页</h1>
  <p id="select-me">请选中这段文字然后点击「获取选中文本」按钮。</p>
  <a href="https://flutter.dev">Flutter 官网链接</a>
  <img alt="占位图" src="https://placehold.co/100x100" width="100">
</body>
</html>
''';

  Future<void> _extractAll() async {
    final c = _controller;
    if (c == null) return;
    setState(() {
      _loading = true;
      _statusText = '提取中...';
    });
    try {
      // 并行抓取大部分信息
      final results = await Future.wait([
        c.getUrl(),
        c.getHtml(),
        c.getMetaTags(),
        c.getMetaThemeColor(),
        c.getFavicons(),
        c.getHitTestResult(),
        c.getCertificate(),
      ]);
      final url = results[0] as WebUri?;
      final html = results[1] as String? ?? '';
      final metas = results[2] as List<MetaTag>? ?? [];
      final themeColor = results[3] as Color?;
      final favicons = results[4] as List<Favicon>? ?? [];
      final hitTest = results[5] as InAppWebViewHitTestResult?;
      final cert = results[6] as SslCertificate?;

      _urlInfo = url?.toString() ?? '(无)';
      _htmlSnippet = html.length > 500 ? '${html.substring(0, 500)}...' : html;
      _metaInfo = metas.map((m) =>
          '${m.name ?? '(无名称)'}=${m.content ?? '(无内容)'}').join('\n');
      if (_metaInfo.isEmpty) _metaInfo = '(无 meta 标签)';
      _faviconInfo = favicons.isEmpty
          ? '(无 favicon)'
          : favicons.map((f) =>
              '${f.rel ?? 'icon'}: ${f.url.toString()}').join('\n');
      _hitTestInfo = hitTest != null
          ? 'type=${hitTest.type?.toValue()} extra=${hitTest.extra}'
          : '(无命中结果)';

      // 主题色
      if (themeColor != null) {
        _metaInfo += '\ntheme-color: $themeColor';
      }

      // 证书信息
      if (cert != null) {
        _certInfo = 'issuedBy=${cert.issuedBy}\n'
            'issuedTo=${cert.issuedTo}\n'
            'validNotBeforeDate=${cert.validNotBeforeDate}\n'
            'validNotAfterDate=${cert.validNotAfterDate}';
      } else {
        _certInfo = '(无 SSL 证书，非 HTTPS 或未加载)';
      }

      // 截图单独执行（较耗时）
      final screenshot = await c.takeScreenshot();
      _screenshot = screenshot;

      // 选中文字（需要用户先在页面上选中文字）
      final selected = await c.getSelectedText();
      _selectedText = selected ?? '(未选中文字)';

      setState(() {
        _loading = false;
        _statusText = '提取完成';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _statusText = '错误：$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('[023] 页面内容提取')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: Colors.amber[50],
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      '操作步骤：\n'
                      '1. 等待页面加载完成\n'
                      '2. 可在 WebView 中长按选中一段文字\n'
                      '3. 点击「一键提取全部」按钮\n'
                      '4. 查看 HTML / meta / favicon / 选中文字 / 命中测试 / 证书 / 截图',
                      style: TextStyle(fontSize: 13, height: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _loading ? null : _extractAll,
                        child: Text(_loading ? '提取中...' : '一键提取全部'),
                      ),
                    ),
                    if (_screenshot != null) ...[
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => setState(() => _screenshot = null),
                        child: const Text('清除截图'),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text('状态: $_statusText',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('URL: $_urlInfo'),
              ],
            ),
          ),
          const Divider(height: 1),
          // WebView 区域（固定高度）
          SizedBox(
            height: 220,
            child: InAppWebView(
              initialData: InAppWebViewInitialData(data: _testHtml),
              initialSettings:
                  InAppWebViewSettings(useShouldOverrideUrlLoading: true),
              onLoadStop: (controller, url) {
                _controller = controller;
                setState(() => _statusText = '页面加载完成，可提取内容');
              },
            ),
          ),
          const Divider(height: 1),
          // 结果展示区
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _section('页面 HTML（前500字符）', _htmlSnippet),
                _section('Meta 标签', _metaInfo),
                _section('Favicon', _faviconInfo),
                _section('选中文字', _selectedText),
                _section('命中测试 (HitTestResult)', _hitTestInfo),
                _section('SSL 证书', _certInfo),
                if (_screenshot != null) ...[
                  const Text('页面截图:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      _screenshot!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Text('截图显示失败'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(6),
          ),
          child: SelectableText(
            content.isEmpty ? '(空)' : content,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      ],
    );
  }
}
