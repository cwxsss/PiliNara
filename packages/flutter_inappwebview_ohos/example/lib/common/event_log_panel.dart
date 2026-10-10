/// 通用事件日志面板
///
/// 提供方法用于在 Demo 页面收集 / 展示 / 清空事件日志，
/// 同一份事件流既写入 UI，也通过 dev.log 输出到控制台。
import 'dart:developer' as dev;

import 'package:flutter/material.dart';

const String _kTag = 'InAppWebView_EventLogPanel';

/// 单条事件记录
class EventLogEntry {
  EventLogEntry({
    required this.time,
    required this.tag,
    required this.message,
    this.isError = false,
  });

  final DateTime time;
  final String tag;
  final String message;
  final bool isError;
}

/// 事件日志面板控制器，用于在 Demo 页面外部维护日志列表。
class EventLogController extends ChangeNotifier {
  EventLogController({this.maxEntries = 300});

  final int maxEntries;
  final List<EventLogEntry> _entries = <EventLogEntry>[];

  List<EventLogEntry> get entries => List.unmodifiable(_entries);

  /// 写入一条普通事件
  void log(String tag, String message) {
    _push(EventLogEntry(
      time: DateTime.now(),
      tag: tag,
      message: message,
    ));
    dev.log(message, name: tag);
  }

  /// 写入一条错误事件
  void logError(String tag, String message,
      {Object? error, StackTrace? stackTrace}) {
    _push(EventLogEntry(
      time: DateTime.now(),
      tag: tag,
      message: message,
      isError: true,
    ));
    dev.log(message, name: tag, error: error, stackTrace: stackTrace);
  }

  void clear() {
    _entries.clear();
    notifyListeners();
    dev.log('Event log cleared', name: _kTag);
  }

  void _push(EventLogEntry entry) {
    _entries.add(entry);
    if (_entries.length > maxEntries) {
      _entries.removeRange(0, _entries.length - maxEntries);
    }
    notifyListeners();
  }
}

/// 事件日志面板 Widget，订阅 [EventLogController] 自动重建。
class EventLogPanel extends StatelessWidget {
  const EventLogPanel({
    super.key,
    required this.controller,
    this.height = 220,
    this.title = '事件日志',
  });

  final EventLogController controller;
  final double height;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final entries = controller.entries.reversed.toList(growable: false);
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$title (${entries.length})',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: controller.clear,
                    child: const Text('清空',
                        style: TextStyle(color: Colors.white70)),
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 8),
              Expanded(
                child: entries.isEmpty
                    ? const Center(
                        child: Text('（暂无事件）',
                            style: TextStyle(color: Colors.white38)),
                      )
                    : ListView.builder(
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final e = entries[index];
                          final ts =
                              '${e.time.hour.toString().padLeft(2, '0')}:${e.time.minute.toString().padLeft(2, '0')}:${e.time.second.toString().padLeft(2, '0')}.${e.time.millisecond.toString().padLeft(3, '0')}';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: SelectableText(
                              '[$ts] ${e.tag}: ${e.message}',
                              style: TextStyle(
                                color: e.isError
                                    ? Colors.redAccent
                                    : Colors.lightGreenAccent,
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
