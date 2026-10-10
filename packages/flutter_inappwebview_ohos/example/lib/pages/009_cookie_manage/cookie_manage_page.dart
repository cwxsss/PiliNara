/// Demo 9: CookieManage
///
/// 功能说明：展示 CookieManager 的完整 Cookie 增删改查能力，包括
/// setCookie/getCookies/getCookie/deleteCookie/deleteCookies/deleteAllCookies/
/// getAllCookies/removeSessionCookies。
/// 对应接口：
///   - setCookie(url, name, value, ...): Future<bool>
///   - getCookies(url, ...): Future<List<Cookie>>
///   - getCookie(url, name, ...): Future<Cookie?>
///   - deleteCookie(url, name, ...): Future<bool>
///   - deleteCookies(url, ...): Future<bool>
///   - deleteAllCookies(): Future<bool>
///   - getAllCookies(): Future<List<Cookie>>
///   - removeSessionCookies(): Future<bool>

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String _kTag = 'InAppWebView_CookieManage';

/// CookieManagePage - Cookie 管理
///
/// 展示 WebView Cookie 的读写与清理流程。
class CookieManagePage extends StatefulWidget {
  const CookieManagePage({super.key});

  @override
  State<CookieManagePage> createState() => _CookieManagePageState();
}

class _CookieManagePageState extends State<CookieManagePage> {
  // ─── 状态变量 ────────────────────────────────────────────────────────────
  List<Cookie> _cookies = [];
  Cookie? _singleCookie;
  int _callCount = 0;
  int _doneCount = 0;
  String _status = '';

  // ─── 非响应式成员 ─────────────────────────────────────────────────────────
  static final WebUri _testUrl = WebUri('https://flutter.dev');

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

  /// 设置 Cookie
  Future<void> _setCookie() async {
    dev.log('_setCookie called', name: _kTag);
    setState(() {
      _callCount++;
      _status = '设置中';
    });
    try {
      await CookieManager.instance().setCookie(
        url: _testUrl,
        name: 'token',
        value: 'abc123',
      );
      dev.log('_setCookie succeeded', name: _kTag);
      if (!mounted) return;
      setState(() {
        _doneCount++;
        _status = '已设置 token=abc123';
      });
    } catch (e, stack) {
      dev.log('_setCookie failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 查询所有 Cookie
  Future<void> _getCookies() async {
    dev.log('_getCookies called', name: _kTag);
    try {
      final cookies =
          await CookieManager.instance().getCookies(url: _testUrl);
      dev.log('_getCookies succeeded: ${cookies.length} cookies',
          name: _kTag);
      if (!mounted) return;
      setState(() {
        _cookies = cookies;
        _status = '查询到 ${cookies.length} 个Cookie';
      });
    } catch (e, stack) {
      dev.log('_getCookies failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 查询单个 Cookie
  Future<void> _getCookie() async {
    dev.log('_getCookie called', name: _kTag);
    try {
      final cookie = await CookieManager.instance()
          .getCookie(url: _testUrl, name: 'token');
      dev.log('_getCookie succeeded: $cookie', name: _kTag);
      if (!mounted) return;
      setState(() {
        _singleCookie = cookie;
        _status = cookie != null
            ? '单个Cookie: ${cookie.name}=${cookie.value}'
            : 'Cookie不存在';
      });
    } catch (e, stack) {
      dev.log('_getCookie failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 删除单个 Cookie
  Future<void> _deleteCookie() async {
    dev.log('_deleteCookie called', name: _kTag);
    try {
      await CookieManager.instance()
          .deleteCookie(url: _testUrl, name: 'token');
      dev.log('_deleteCookie succeeded', name: _kTag);
      if (!mounted) return;
      setState(() => _status = '已删除单个Cookie');
    } catch (e, stack) {
      dev.log('_deleteCookie failed',
          name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 删除 URL 全部 Cookie
  Future<void> _deleteCookies() async {
    dev.log('_deleteCookies called', name: _kTag);
    try {
      await CookieManager.instance().deleteCookies(url: _testUrl);
      dev.log('_deleteCookies succeeded', name: _kTag);
      if (!mounted) return;
      setState(() => _status = '已删除URL全部Cookie');
    } catch (e, stack) {
      dev.log('_deleteCookies failed',
          name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 删除所有 Cookie
  Future<void> _deleteAllCookies() async {
    dev.log('_deleteAllCookies called', name: _kTag);
    try {
      await CookieManager.instance().deleteAllCookies();
      dev.log('_deleteAllCookies succeeded', name: _kTag);
      if (!mounted) return;
      setState(() {
        _cookies = [];
        _status = '已删除所有Cookie';
      });
    } catch (e, stack) {
      dev.log('_deleteAllCookies failed',
          name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 删除会话 Cookie
  Future<void> _removeSessionCookies() async {
    dev.log('_removeSessionCookies called', name: _kTag);
    try {
      await CookieManager.instance().removeSessionCookies();
      dev.log('_removeSessionCookies succeeded', name: _kTag);
      if (!mounted) return;
      setState(() => _status = '已删除会话Cookie');
    } catch (e, stack) {
      dev.log('_removeSessionCookies failed',
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
        title: const Text('[009] Cookie管理'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 操作按钮区
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                    onPressed: _setCookie, child: const Text('设置Cookie')),
                ElevatedButton(
                    onPressed: _getCookies,
                    child: const Text('查询所有Cookie')),
                ElevatedButton(
                    onPressed: _getCookie, child: const Text('查询单个')),
                ElevatedButton(
                    onPressed: _deleteCookie, child: const Text('删除单个')),
                ElevatedButton(
                    onPressed: _deleteCookies,
                    child: const Text('删除URL全部')),
                ElevatedButton(
                    onPressed: _deleteAllCookies,
                    child: const Text('删除所有Cookie')),
                ElevatedButton(
                    onPressed: _removeSessionCookies,
                    child: const Text('删除会话Cookie')),
              ],
            ),
            const SizedBox(height: 16),
            // 结果展示区
            Text('调用/完成: $_callCount/$_doneCount'),
            Text('状态: $_status'),
            const SizedBox(height: 8),
            const Text('Cookie 列表:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...(_cookies.map((c) => Text(
                '  ${c.name}=${c.value} (domain=${c.domain}, path=${c.path})'))),
            if (_singleCookie != null)
              Text(
                  '单个Cookie: ${_singleCookie!.name}=${_singleCookie!.value}'),
          ],
        ),
      ),
    );
  }
}
