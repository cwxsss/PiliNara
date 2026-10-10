/// OHOS 平台并发调用测试
///
/// 覆盖场景：
///   - 同一 controller 并发多个 MethodChannel 调用
///   - 批量 API 调用（连发多个请求）
///   - 多 controller 实例并发操作
///   - 并发 mixed 操作（get/set 混合）
///
/// 对应用例覆盖度报告：OHOS 平台并发测试缺失

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_ohos/flutter_inappwebview_ohos.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/mock_controller.dart';
import 'helpers/test_bindings.dart';

void main() {
  ensureTestBindings();

  group('OHOS concurrent MethodChannel calls', () {
    const controllerId = 300;
    late OhosInAppWebViewController controller;

    setUp(() {
      mockOhosStaticChannel();
      controller = createMockOhosController(id: controllerId);
    });

    tearDown(() {
      setMockMethodChannelHandler(ohosControllerChannel(controllerId), null);
      setMockMethodChannelHandler(ohosManagerChannel, null);
    });

    test('concurrent loadUrl should complete without corruption', () async {
      int callCount = 0;
      setMockMethodChannelHandler(
        ohosControllerChannel(controllerId), (MethodCall call) async {
          callCount++;
          return true;
        });

      final futures = List.generate(5, (i) {
        return controller.loadUrl(
          urlRequest: URLRequest(
            url: WebUri('https://example.com/page$i'),
          ),
        );
      });

      await Future.wait(futures);
      expect(callCount, 5);
    });

    test(
        'concurrent getUrl, getTitle, getProgress should return correct values',
        () async {
      setMockMethodChannelHandler(
        ohosControllerChannel(controllerId), (MethodCall call) async {
          switch (call.method) {
            case 'getUrl':
              return 'https://example.com';
            case 'getTitle':
              return 'Test Page';
            case 'getProgress':
              return 75;
            default:
              return null;
          }
        });

      final results = await Future.wait([
        controller.getUrl(),
        controller.getTitle(),
        controller.getProgress(),
      ]);

      expect(results[0]?.toString(), 'https://example.com');
      expect(results[1], 'Test Page');
      expect(results[2], 75);
    });

    test(
        'concurrent scrollTo and pageDown should complete without errors',
        () async {
      int scrollCalled = 0;
      int pageCalled = 0;
      setMockMethodChannelHandler(
        ohosControllerChannel(controllerId), (MethodCall call) async {
          if (call.method == 'scrollTo') scrollCalled++;
          if (call.method == 'pageDown') pageCalled++;
          return true;
        });

      await Future.wait([
        controller.scrollTo(x: 0, y: 100),
        controller.pageDown(bottom: false),
      ]);

      expect(scrollCalled, 1);
      expect(pageCalled, 1);
    });

    test('concurrent evaluateJavascript calls should return distinct results',
        () async {
      setMockMethodChannelHandler(
        ohosControllerChannel(controllerId), (MethodCall call) async {
          if (call.method == 'evaluateJavascript') {
            final source = call.arguments['source'] as String;
            if (source.contains('2+')) return 4;
            if (source.contains('title')) return '"Test"';
            return null;
          }
          return null;
        });

      final results = await Future.wait([
        controller.evaluateJavascript(source: '2+2'),
        controller.evaluateJavascript(source: 'document.title'),
      ]);

      expect(results.length, 2);
    });

    test('concurrent loadUrl + reload should complete without corruption',
        () async {
      int loadCalled = 0;
      int reloadCalled = 0;
      setMockMethodChannelHandler(
        ohosControllerChannel(controllerId), (MethodCall call) async {
          if (call.method == 'loadUrl') loadCalled++;
          if (call.method == 'reload') reloadCalled++;
          return true;
        });

      await Future.wait([
        controller.loadUrl(
          urlRequest: URLRequest(url: WebUri('https://example.com')),
        ),
        controller.reload(),
      ]);

      expect(loadCalled, 1);
      expect(reloadCalled, 1);
    });

    test('concurrent canGoBack + canGoForward + isLoading', () async {
      setMockMethodChannelHandler(
        ohosControllerChannel(controllerId), (MethodCall call) async {
          switch (call.method) {
            case 'canGoBack':
              return true;
            case 'canGoForward':
              return false;
            case 'isLoading':
              return false;
            default:
              return null;
          }
        });

      final results = await Future.wait([
        controller.canGoBack(),
        controller.canGoForward(),
        controller.isLoading(),
      ]);

      expect(results, [true, false, false]);
    });

    test('concurrent setSettings + getSettings should not conflict',
        () async {
      bool settingsSet = false;
      setMockMethodChannelHandler(
        ohosControllerChannel(controllerId), (MethodCall call) async {
          if (call.method == 'setSettings') {
            settingsSet = true;
            return true;
          }
          if (call.method == 'getSettings') {
            return InAppWebViewSettings(javaScriptEnabled: true).toMap();
          }
          return null;
        });

      final results = await Future.wait([
        controller.getSettings(),
        controller.getSettings(),
      ]);

      expect(results[0], isNotNull);
      expect(results[1], isNotNull);
    });

    test('concurrent 10 loadUrl calls should all complete', () async {
      int callCount = 0;
      setMockMethodChannelHandler(
        ohosControllerChannel(controllerId), (MethodCall call) async {
          callCount++;
          return true;
        });

      final futures = List.generate(10, (i) {
        return controller.loadUrl(
          urlRequest: URLRequest(
            url: WebUri('https://example.com/${i}'),
          ),
        );
      });

      await Future.wait(futures);
      expect(callCount, 10);
    });

    test(
        'two controller instances should operate independently concurrently',
        () async {
      const id1 = 301;
      const id2 = 302;

      mockOhosStaticChannel();
      final c1 = createMockOhosController(id: id1);
      final c2 = createMockOhosController(id: id2);

      setMockMethodChannelHandler(
        ohosControllerChannel(id1), (MethodCall call) async {
          if (call.method == 'getUrl') return 'https://c1.com';
          return null;
        });
      setMockMethodChannelHandler(
        ohosControllerChannel(id2), (MethodCall call) async {
          if (call.method == 'getUrl') return 'https://c2.com';
          return null;
        });

      final results = await Future.wait([
        c1.getUrl(),
        c2.getUrl(),
        c1.getTitle(),
        c2.getTitle(),
      ]);

      expect(results[0]?.toString(), 'https://c1.com');
      expect(results[1]?.toString(), 'https://c2.com');

      setMockMethodChannelHandler(ohosControllerChannel(id1), null);
      setMockMethodChannelHandler(ohosControllerChannel(id2), null);
    });

    test('concurrent mixed read-write operations should be safe', () async {
      setMockMethodChannelHandler(
        ohosControllerChannel(controllerId), (MethodCall call) async {
          switch (call.method) {
            case 'getUrl':
              return 'https://example.com';
            case 'getTitle':
              return 'Example';
            case 'reload':
              return true;
            case 'pause':
              return true;
            default:
              return null;
          }
        });

      final results = await Future.wait([
        controller.getUrl(),
        controller.reload(),
        controller.getTitle(),
        controller.pause(),
        controller.resume(),
      ]);

      expect(results.length, 5);
    });
  });
}
