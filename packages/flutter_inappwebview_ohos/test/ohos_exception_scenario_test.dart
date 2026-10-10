/// OHOS 平台异常场景测试
///
/// 覆盖场景：
///   - MethodChannel 返回 PlatformException
///   - MethodChannel 返回 null（参数缺失）
///   - MethodChannel handler 返回 null（显式 null）
///   - MethodChannel handler 抛出异常
///   - 无效参数类型处理
///
/// 对应用例覆盖度报告：OHOS 平台异常测试缺失

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_ohos/flutter_inappwebview_ohos.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/mock_controller.dart';
import 'helpers/test_bindings.dart';

void main() {
  ensureTestBindings();

  group('OHOS PlatformException scenarios', () {
    const controllerId = 200;
    late OhosInAppWebViewController controller;

    setUp(() {
      mockOhosStaticChannel();
      controller = createMockOhosController(id: controllerId);
    });

    tearDown(() {
      setMockMethodChannelHandler(ohosControllerChannel(controllerId), null);
      setMockMethodChannelHandler(ohosManagerChannel, null);
    });

    test('loadUrl should throw PlatformException when channel returns error',
        () async {
      setMockMethodChannelHandler(
        ohosControllerChannel(controllerId), (MethodCall call) async {
          throw PlatformException(code: 'OHOS_ERROR', message: 'Test error');
        });

      final future = controller.loadUrl(
        urlRequest: URLRequest(url: WebUri('https://example.com')),
      );

      await expectLater(
        future,
        throwsA(isA<PlatformException>()),
      );
    });

    test('evaluateJavascript should propagate channel error as exception',
        () async {
      setMockMethodChannelHandler(
        ohosControllerChannel(controllerId), (MethodCall call) async {
          throw PlatformException(code: 'JS_ERROR', message: 'Eval failed');
        });

      final future = controller.evaluateJavascript(source: 'broken();');

      await expectLater(future, throwsA(isA<PlatformException>()));
    });

    test('getUrl should handle null return from channel gracefully',
        () async {
      setMockMethodChannelHandler(
        ohosControllerChannel(controllerId), (MethodCall call) async {
          return null;
        });

      final result = await controller.getUrl();
      expect(result, isNull);
    });

    test('getTitle should handle null return from channel gracefully',
        () async {
      setMockMethodChannelHandler(
        ohosControllerChannel(controllerId), (MethodCall call) async {
          return null;
        });

      final result = await controller.getTitle();
      expect(result, isNull);
    });

    test('getProgress should handle null return from channel gracefully',
        () async {
      setMockMethodChannelHandler(
        ohosControllerChannel(controllerId), (MethodCall call) async {
          return null;
        });

      final result = await controller.getProgress();
      expect(result, isNull);
    });

    test('canGoBack should return false when channel returns null', () async {
      setMockMethodChannelHandler(
        ohosControllerChannel(controllerId), (MethodCall call) async {
          return null;
        });

      final result = await controller.canGoBack();
      expect(result, false);
    });

    test(
        'scrollTo should throw PlatformException when channel returns error',
        () async {
      setMockMethodChannelHandler(
        ohosControllerChannel(controllerId), (MethodCall call) async {
          throw PlatformException(code: 'OHOS_ERROR', message: 'Scroll failed');
        });

      final future = controller.scrollTo(x: 0, y: 100, animated: false);
      await expectLater(future, throwsA(isA<PlatformException>()));
    });

    test('reload should throw on channel error', () async {
      setMockMethodChannelHandler(
        ohosControllerChannel(controllerId), (MethodCall call) async {
          throw PlatformException(code: 'OHOS_ERROR', message: 'Reload failed');
        });

      final future = controller.reload();
      await expectLater(future, throwsA(isA<PlatformException>()));
    });

    test('goBack should throw on channel error', () async {
      setMockMethodChannelHandler(
        ohosControllerChannel(controllerId), (MethodCall call) async {
          throw PlatformException(code: 'OHOS_ERROR', message: 'goBack failed');
        });

      final future = controller.goBack();
      await expectLater(future, throwsA(isA<PlatformException>()));
    });

    test('setSettings should throw on channel error', () async {
      setMockMethodChannelHandler(
        ohosControllerChannel(controllerId), (MethodCall call) async {
          throw PlatformException(
              code: 'OHOS_ERROR', message: 'SetSettings failed');
        });

      final future =
          controller.setSettings(settings: InAppWebViewSettings());
      await expectLater(future, throwsA(isA<PlatformException>()));
    });

    test('Mixed null and error handling should not corrupt subsequent calls',
        () async {
      // First: error mode
      setMockMethodChannelHandler(
        ohosControllerChannel(controllerId), (MethodCall call) async {
          throw PlatformException(code: 'OHOS_ERROR', message: 'Temporary');
        });
      await expectLater(controller.getUrl(), throwsA(isA<PlatformException>()));

      // Reset to normal
      setMockMethodChannelHandler(
        ohosControllerChannel(controllerId), (MethodCall call) async {
          if (call.method == 'getUrl') return 'https://restored.com';
          return null;
        });

      // Must work normally
      final result = await controller.getUrl();
      expect(result?.toString(), 'https://restored.com');
    });

    test('setAllMediaPlaybackSuspended should throw on channel error',
        () async {
      setMockMethodChannelHandler(
        ohosControllerChannel(controllerId), (MethodCall call) async {
          throw PlatformException(code: 'OHOS_ERROR', message: 'Media error');
        });

      final future =
          controller.setAllMediaPlaybackSuspended(suspended: true);
      await expectLater(future, throwsA(isA<PlatformException>()));
    });

    test('clearAllCache should throw on channel error', () async {
      setMockMethodChannelHandler(
        ohosManagerChannel, (MethodCall call) async {
          throw PlatformException(code: 'OHOS_ERROR', message: 'Cache error');
        });

      final future = controller.clearAllCache(includeDiskFiles: true);
      await expectLater(future, throwsA(isA<PlatformException>()));
    });
  });
}
