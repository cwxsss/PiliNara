/// Demo 11: WebstorageManager
///
/// 功能说明：展示 WebStorageManager 管理所有来源的 Web Storage 数据，
/// 包括 getOrigins/deleteAllData/deleteOrigin/getQuotaForOrigin/getUsageForOrigin。
/// 对应接口：
///   - getOrigins(): Future<List<WebStorageOrigin>>
///   - deleteAllData(): Future<void>
///   - deleteOrigin(origin): Future<void>
///   - getQuotaForOrigin(origin): Future<int>
///   - getUsageForOrigin(origin): Future<int>

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String _kTag = 'InAppWebView_WebstorageManager';

/// WebstorageManagerPage - WebStorageManager 存储管理
///
/// 展示跨来源存储管理与配额查询能力。
class WebstorageManagerPage extends StatefulWidget {
  const WebstorageManagerPage({super.key});

  @override
  State<WebstorageManagerPage> createState() => _WebstorageManagerPageState();
}

class _WebstorageManagerPageState extends State<WebstorageManagerPage> {
  // ─── 状态变量 ────────────────────────────────────────────────────────────
  List<WebStorageOrigin> _origins = [];
  int? _quota;
  int? _usage;
  String _status = '';
  String _selectedOrigin = '';

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

  /// 查询所有来源
  Future<void> _getOrigins() async {
    dev.log('_getOrigins called', name: _kTag);
    try {
      final origins = await WebStorageManager.instance().getOrigins();
      dev.log('_getOrigins succeeded: ${origins.length} origins',
          name: _kTag);
      if (!mounted) return;
      setState(() {
        _origins = origins;
        _status = '查询到 ${origins.length} 个来源';
        if (origins.isNotEmpty && _selectedOrigin.isEmpty) {
          _selectedOrigin = origins.first.origin ?? '';
        }
      });
    } catch (e, stack) {
      dev.log('_getOrigins failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 查询配额
  Future<void> _getQuota() async {
    dev.log('_getQuota called', name: _kTag);
    if (_selectedOrigin.isEmpty) {
      setState(() => _status = '请先查询来源并选择');
      return;
    }
    try {
      final quota = await WebStorageManager.instance()
          .getQuotaForOrigin(origin: _selectedOrigin);
      dev.log('_getQuota succeeded: $quota', name: _kTag);
      if (!mounted) return;
      setState(() {
        _quota = quota;
        _status = '配额: $quota';
      });
    } catch (e, stack) {
      dev.log('_getQuota failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 查询用量
  Future<void> _getUsage() async {
    dev.log('_getUsage called', name: _kTag);
    if (_selectedOrigin.isEmpty) {
      setState(() => _status = '请先查询来源并选择');
      return;
    }
    try {
      final usage = await WebStorageManager.instance()
          .getUsageForOrigin(origin: _selectedOrigin);
      dev.log('_getUsage succeeded: $usage', name: _kTag);
      if (!mounted) return;
      setState(() {
        _usage = usage;
        _status = '用量: $usage';
      });
    } catch (e, stack) {
      dev.log('_getUsage failed', name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 删除指定来源
  Future<void> _deleteOrigin() async {
    dev.log('_deleteOrigin called', name: _kTag);
    if (_selectedOrigin.isEmpty) {
      setState(() => _status = '请先查询来源并选择');
      return;
    }
    try {
      await WebStorageManager.instance()
          .deleteOrigin(origin: _selectedOrigin);
      dev.log('_deleteOrigin succeeded', name: _kTag);
      if (!mounted) return;
      setState(() {
        _status = '已删除 $_selectedOrigin';
        _origins = _origins
            .where((o) => o.origin != _selectedOrigin)
            .toList();
      });
    } catch (e, stack) {
      dev.log('_deleteOrigin failed',
          name: _kTag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() => _status = '错误：$e');
    }
  }

  /// 删除所有数据
  Future<void> _deleteAllData() async {
    dev.log('_deleteAllData called', name: _kTag);
    try {
      await WebStorageManager.instance().deleteAllData();
      dev.log('_deleteAllData succeeded', name: _kTag);
      if (!mounted) return;
      setState(() {
        _origins = [];
        _status = '已清空所有数据';
      });
    } catch (e, stack) {
      dev.log('_deleteAllData failed',
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
        title: const Text('[011] WebStorageManager存储管理'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                    onPressed: _getOrigins, child: const Text('查询来源')),
                ElevatedButton(
                    onPressed: _getQuota, child: const Text('查询配额')),
                ElevatedButton(
                    onPressed: _getUsage, child: const Text('查询用量')),
                ElevatedButton(
                    onPressed: _deleteOrigin,
                    child: const Text('删除指定来源')),
                ElevatedButton(
                    onPressed: _deleteAllData,
                    child: const Text('删除所有数据')),
              ],
            ),
            const SizedBox(height: 16),
            Text('状态: $_status'),
            Text('配额: $_quota'),
            Text('用量: $_usage'),
            const SizedBox(height: 8),
            const Text('来源列表:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ..._origins.map((o) => Text(
                '  origin=${o.origin}, quota=${o.quota}, usage=${o.usage}')),
          ],
        ),
      ),
    );
  }
}
