/// Demo 19: WebUri Parse
///
/// 功能说明：展示 WebUri 的 URI 解析能力，包括所有属性与方法。
/// 对应接口：
///   - WebUri(source) / WebUri.uri(uri)
///   - 属性: rawValue, uriValue, isValidUri, scheme, host, port, path, query,
///     fragment, origin, authority, userInfo, queryParameters, pathSegments
///   - 方法: isScheme(scheme), normalizePath(), removeFragment(), replace({...}),
///     resolve(reference), resolveUri(reference), toFilePath({windows?})

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String _kTag = 'InAppWebView_WebUriParse';

/// WeburiParsePage - WebUri URI 解析
///
/// 展示 WebUri 的 URI 解析与变换能力。
class WeburiParsePage extends StatefulWidget {
  const WeburiParsePage({super.key});

  @override
  State<WeburiParsePage> createState() => _WeburiParsePageState();
}

class _WeburiParsePageState extends State<WeburiParsePage> {
  // ─── 状态变量 ────────────────────────────────────────────────────────────
  String _parseResult = '';
  String _methodResult = '';
  String _status = '';

  // ─── 非响应式成员 ─────────────────────────────────────────────────────────
  final TextEditingController _uriController =
      TextEditingController(
    text: 'https://user:pass@example.com:8080/path/to/page?key1=value1&key2=value2#section',
  );

  @override
  void initState() {
    super.initState();
    dev.log('Page appeared', name: _kTag);
  }

  @override
  void dispose() {
    dev.log('Page disposed, releasing resources', name: _kTag);
    _uriController.dispose();
    super.dispose();
  }

  // ─── 核心功能方法 ────────────────────────────────────────────────────────

  /// 解析 URI 并展示所有属性
  Future<void> _parseUri() async {
    dev.log('_parseUri called', name: _kTag);
    try {
      final uri = WebUri(_uriController.text);
      dev.log('_parseUri succeeded: valid=${uri.isValidUri}',
          name: _kTag);
      if (!mounted) return;
      setState(() {
        _parseResult = '''
rawValue: ${uri.rawValue}
uriValue: ${uri.uriValue}
isValidUri: ${uri.isValidUri}
scheme: ${uri.scheme}
host: ${uri.host}
port: ${uri.port}
path: ${uri.path}
query: ${uri.query}
fragment: ${uri.fragment}
origin: ${uri.origin}
authority: ${uri.authority}
userInfo: ${uri.userInfo}
hasScheme: ${uri.hasScheme}
hasAuthority: ${uri.hasAuthority}
hasAbsolutePath: ${uri.hasAbsolutePath}
hasPort: ${uri.hasPort}
hasQuery: ${uri.hasQuery}
hasFragment: ${uri.hasFragment}
hasEmptyPath: ${uri.hasEmptyPath}
isAbsolute: ${uri.isAbsolute}
pathSegments: ${uri.pathSegments}
queryParameters: ${uri.queryParameters}
''';
        _status = '解析完成';
      });
    } catch (e, stack) {
      dev.log('_parseUri failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() {
        _parseResult = '';
        _status = '错误：$e';
      });
    }
  }

  /// 测试方法
  Future<void> _testMethods() async {
    dev.log('_testMethods called', name: _kTag);
    try {
      final uri = WebUri(_uriController.text);
      final sb = StringBuffer();

      // isScheme
      sb.writeln('isScheme("https"): ${uri.isScheme("https")}');

      // normalizePath → Uri
      final normalized = uri.normalizePath();
      sb.writeln('normalizePath(): $normalized (type: ${normalized.runtimeType})');

      // removeFragment → Uri
      final noFrag = uri.removeFragment();
      sb.writeln('removeFragment(): $noFrag (type: ${noFrag.runtimeType})');

      // replace → Uri
      final replaced = uri.replace(
        scheme: 'http',
        fragment: 'new-section',
      );
      sb.writeln('replace(scheme:http, fragment:new-section): $replaced (type: ${replaced.runtimeType})');

      // resolve → Uri
      final resolved = uri.resolve('/relative/path');
      sb.writeln('resolve("/relative/path"): $resolved (type: ${resolved.runtimeType})');

      // resolveUri → Uri
      final resolvedUri = uri.resolveUri(Uri.parse('/another/path'));
      sb.writeln('resolveUri(Uri.parse("/another/path")): $resolvedUri (type: ${resolvedUri.runtimeType})');

      // toFilePath → String (only works for file: or empty scheme URIs)
      try {
        final filePath = uri.toFilePath();
        sb.writeln('toFilePath(): $filePath (type: ${filePath.runtimeType})');
      } catch (e) {
        sb.writeln('toFilePath(): 不支持 (https URI 无法提取文件路径)');
        sb.writeln('  → 原因: $e');
      }
      // Also test with a file: URI to show it works
      try {
        final fileUri = WebUri('file:///path/to/file.txt');
        final fileResult = fileUri.toFilePath();
        sb.writeln('toFilePath(file://): $fileResult');
      } catch (e) {
        sb.writeln('toFilePath(file://): $e');
      }

      // toString
      sb.writeln('toString(): ${uri.toString()}');

      dev.log('_testMethods succeeded', name: _kTag);
      if (!mounted) return;
      setState(() {
        _methodResult = sb.toString();
        _status = '方法测试完成';
      });
    } catch (e, stack) {
      dev.log('_testMethods failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  // ─── UI 构建 ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('[019] WebUri URI解析'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _uriController,
              decoration: const InputDecoration(
                labelText: 'URI 字符串',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _parseUri,
                    child: const Text('解析属性'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testMethods,
                    child: const Text('测试方法'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('状态: $_status'),
            const SizedBox(height: 16),
            if (_parseResult.isNotEmpty) ...[
              const Text('属性解析结果:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: SelectableText(
                  _parseResult,
                  style: const TextStyle(
                      fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
            if (_methodResult.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('方法测试结果:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: SelectableText(
                  _methodResult,
                  style: const TextStyle(
                      fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
