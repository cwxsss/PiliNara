/// Demo 18: HttpAuth
///
/// 功能说明：展示 HttpAuthCredentialDatabase 的 HTTP 认证凭据管理能力，
/// 包括 getAllAuthCredentials/getHttpAuthCredentials/setHttpAuthCredential/
/// removeHttpAuthCredential/removeHttpAuthCredentials/clearAllAuthCredentials。
/// 对应接口：
///   - getAllAuthCredentials(): Future<List<URLProtectionSpaceHttpAuthCredentials>>
///   - getHttpAuthCredentials({required protectionSpace}): Future<List<URLCredential>>
///   - setHttpAuthCredential({required protectionSpace, required credential}): Future<void>
///   - removeHttpAuthCredential({required protectionSpace, required credential}): Future<void>
///   - removeHttpAuthCredentials({required protectionSpace}): Future<void>
///   - clearAllAuthCredentials(): Future<void>

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String _kTag = 'InAppWebView_HttpAuth';

/// HttpAuthPage - HTTP认证凭据管理
///
/// 展示跨来源 HTTP 认证凭据的增删查改能力。
class HttpAuthPage extends StatefulWidget {
  const HttpAuthPage({super.key});

  @override
  State<HttpAuthPage> createState() => _HttpAuthPageState();
}

class _HttpAuthPageState extends State<HttpAuthPage> {
  // ─── 状态变量 ────────────────────────────────────────────────────────────
  List<URLProtectionSpaceHttpAuthCredentials> _allCreds = [];
  String _status = '';
  int _callCount = 0;
  int _doneCount = 0;

  // ─── 非响应式成员 ─────────────────────────────────────────────────────────
  final TextEditingController _hostController =
      TextEditingController(text: 'example.com');
  final TextEditingController _userController =
      TextEditingController(text: 'admin');
  final TextEditingController _passController =
      TextEditingController(text: 'password123');

  @override
  void initState() {
    super.initState();
    dev.log('Page appeared', name: _kTag);
  }

  @override
  void dispose() {
    dev.log('Page disposed, releasing resources', name: _kTag);
    _hostController.dispose();
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  // ─── 辅助方法 ────────────────────────────────────────────────────────────

  /// 构造 URLProtectionSpace
  URLProtectionSpace _buildSpace() {
    return URLProtectionSpace(
      host: _hostController.text,
      protocol: 'http',
      port: 80,
      realm: 'protected area',
    );
  }

  /// 构造 URLCredential
  URLCredential _buildCredential() {
    return URLCredential(
      username: _userController.text,
      password: _passController.text,
    );
  }

  // ─── 核心功能方法 ────────────────────────────────────────────────────────

  /// 查询所有凭据
  Future<void> _getAllAuthCredentials() async {
    dev.log('_getAllAuthCredentials called', name: _kTag);
    setState(() {
      _callCount++;
      _status = '查询中';
    });
    try {
      final result =
          await HttpAuthCredentialDatabase.instance()
              .getAllAuthCredentials();
      dev.log('_getAllAuthCredentials succeeded: ${result.length} spaces',
          name: _kTag);
      if (!mounted) return;
      setState(() {
        _allCreds = result;
        _doneCount++;
        _status = '查询到 ${result.length} 个保护空间';
      });
    } catch (e, stack) {
      dev.log('_getAllAuthCredentials failed',
          name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 添加凭据
  Future<void> _setHttpAuthCredential() async {
    dev.log('_setHttpAuthCredential called', name: _kTag);
    setState(() => _status = '添加中');
    try {
      await HttpAuthCredentialDatabase.instance().setHttpAuthCredential(
        protectionSpace: _buildSpace(),
        credential: _buildCredential(),
      );
      dev.log('_setHttpAuthCredential succeeded', name: _kTag);
      if (!mounted) return;
      setState(() {
        _doneCount++;
        _status = '已添加凭据: ${_userController.text}@${_hostController.text}';
      });
    } catch (e, stack) {
      dev.log('_setHttpAuthCredential failed',
          name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 查询指定空间凭据
  Future<void> _getHttpAuthCredentials() async {
    dev.log('_getHttpAuthCredentials called', name: _kTag);
    setState(() => _status = '查询中');
    try {
      final creds = await HttpAuthCredentialDatabase.instance()
          .getHttpAuthCredentials(protectionSpace: _buildSpace());
      dev.log('_getHttpAuthCredentials succeeded: ${creds.length} creds',
          name: _kTag);
      if (!mounted) return;
      setState(() {
        _doneCount++;
        _status = '空间 ${_hostController.text} 有 ${creds.length} 条凭据';
      });
    } catch (e, stack) {
      dev.log('_getHttpAuthCredentials failed',
          name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 删除指定凭据
  Future<void> _removeHttpAuthCredential() async {
    dev.log('_removeHttpAuthCredential called', name: _kTag);
    setState(() => _status = '删除中');
    try {
      await HttpAuthCredentialDatabase.instance().removeHttpAuthCredential(
        protectionSpace: _buildSpace(),
        credential: _buildCredential(),
      );
      dev.log('_removeHttpAuthCredential succeeded', name: _kTag);
      if (!mounted) return;
      setState(() {
        _doneCount++;
        _status = '已删除凭据: ${_userController.text}@${_hostController.text}';
      });
    } catch (e, stack) {
      dev.log('_removeHttpAuthCredential failed',
          name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 删除空间所有凭据
  Future<void> _removeHttpAuthCredentials() async {
    dev.log('_removeHttpAuthCredentials called', name: _kTag);
    setState(() => _status = '删除中');
    try {
      await HttpAuthCredentialDatabase.instance()
          .removeHttpAuthCredentials(protectionSpace: _buildSpace());
      dev.log('_removeHttpAuthCredentials succeeded', name: _kTag);
      if (!mounted) return;
      setState(() {
        _doneCount++;
        _status = '已清空空间 ${_hostController.text} 的所有凭据';
      });
    } catch (e, stack) {
      dev.log('_removeHttpAuthCredentials failed',
          name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 清空所有凭据
  Future<void> _clearAllAuthCredentials() async {
    dev.log('_clearAllAuthCredentials called', name: _kTag);
    setState(() => _status = '清空中');
    try {
      await HttpAuthCredentialDatabase.instance().clearAllAuthCredentials();
      dev.log('_clearAllAuthCredentials succeeded', name: _kTag);
      if (!mounted) return;
      setState(() {
        _allCreds = [];
        _doneCount++;
        _status = '已清空所有凭据';
      });
    } catch (e, stack) {
      dev.log('_clearAllAuthCredentials failed',
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
        title: const Text('[018] HTTP认证凭据管理'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 输入区
            TextField(
              controller: _hostController,
              decoration: const InputDecoration(
                labelText: '主机 (Host)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _userController,
                    decoration: const InputDecoration(
                      labelText: '用户名',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _passController,
                    decoration: const InputDecoration(
                      labelText: '密码',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 操作按钮区
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                    onPressed: _setHttpAuthCredential,
                    child: const Text('添加凭据')),
                ElevatedButton(
                    onPressed: _getHttpAuthCredentials,
                    child: const Text('查询空间凭据')),
                ElevatedButton(
                    onPressed: _getAllAuthCredentials,
                    child: const Text('查询所有')),
                ElevatedButton(
                    onPressed: _removeHttpAuthCredential,
                    child: const Text('删除凭据')),
                ElevatedButton(
                    onPressed: _removeHttpAuthCredentials,
                    child: const Text('清空空间')),
                ElevatedButton(
                    onPressed: _clearAllAuthCredentials,
                    child: const Text('清空全部')),
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
                  const SizedBox(height: 8),
                  const Text('所有保护空间:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ..._allCreds.map((e) {
                    final space = e.protectionSpace;
                    final creds = e.credentials;
                    return Text(
                      '  host=${space?.host}, '
                      'creds=${creds?.length ?? 0}',
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
