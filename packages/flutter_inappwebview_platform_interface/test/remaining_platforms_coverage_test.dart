import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_controller.dart';
import 'helpers/fake_platforms.dart';
import 'helpers/test_platform.dart';

void main() {
  group('PlatformInAppWebViewController', () {
    late FakePlatformInAppWebViewController controller;

    setUp(() {
      installFakeInAppWebViewPlatform();
      controller = FakePlatformInAppWebViewController(id: 'wv-1');
    });

    test('navigation and content helpers should return fake values', () async {
      expect(controller.getViewId(), 'wv-1');
      expect((await controller.getUrl())?.rawValue, 'https://example.com');
      expect(await controller.getTitle(), 'Example');
      expect(await controller.getProgress(), 100);
      expect(await controller.getHtml(), contains('html'));
      expect((await controller.getFavicons()).first.url.rawValue,
          contains('favicon'));

      await controller.loadUrl(
        urlRequest: URLRequest(url: WebUri('https://example.com')),
      );
      await controller.postUrl(
        url: WebUri('https://example.com'),
        postData: Uint8List.fromList([1]),
      );
      await controller.loadData(data: '<html></html>');
      await controller.loadFile(assetFilePath: 'assets/index.html');
      await controller.reload();
      expect(await controller.canGoBack(), isTrue);
      expect(await controller.canGoForward(), isFalse);
      await controller.goBack();
      await controller.goForward();
      await controller.goBackOrForward(steps: -1);
      expect(await controller.isLoading(), isFalse);
      await controller.stopLoading();
    });

    test('javascript css handlers and settings should delegate', () async {
      expect(await controller.evaluateJavascript(source: '1+1'), 'ok');
      await controller.injectJavascriptFileFromUrl(
        urlFile: WebUri('https://example.com/a.js'),
      );
      expect(
        await controller.injectJavascriptFileFromAsset(
          assetFilePath: 'assets/a.js',
        ),
        'ok',
      );
      await controller.injectCSSCode(source: 'body{}');
      await controller.injectCSSFileFromUrl(
        urlFile: WebUri('https://example.com/a.css'),
      );
      await controller.injectCSSFileFromAsset(assetFilePath: 'assets/a.css');

      controller.addJavaScriptHandler(
        handlerName: 'ping',
        callback: (args) => 'pong',
      );
      expect(controller.hasJavaScriptHandler(handlerName: 'ping'), isTrue);
      expect(
          controller.removeJavaScriptHandler(handlerName: 'ping'), isNotNull);

      expect(await controller.takeScreenshot(), isNotNull);
      await controller.setSettings(
        settings: InAppWebViewSettings(javaScriptEnabled: true),
      );
      expect((await controller.getSettings())?.javaScriptEnabled, isTrue);
      expect(await controller.getCopyBackForwardList(), isNotNull);
    });

    test('scroll zoom print archive and media helpers', () async {
      await controller.clearCache();
      await controller.scrollTo(x: 0, y: 10);
      await controller.scrollBy(x: 1, y: 1);
      await controller.zoomBy(zoomFactor: 1.1);
      expect(await controller.getZoomScale(), isNotNull);
      expect(await controller.getSelectedText(), isNotNull);
      expect(await controller.getHitTestResult(), isNotNull);
      expect(await controller.printCurrentPage(), isNotNull);
      expect(
        await controller.saveWebArchive(
          filePath: '/tmp/a.mht',
          autoname: false,
        ),
        isNotNull,
      );
      expect(await controller.isSecureContext(), isTrue);
      expect(await controller.createPdf(), isNotNull);
      expect(await controller.createWebArchiveData(), isNotNull);
    });

    test('web message and DevTools helpers', () async {
      final channel = await controller.createWebMessageChannel();
      expect(channel, isNotNull);
      await controller.postWebMessage(
        message: WebMessage(data: 'hi'),
        targetOrigin: WebUri('*'),
      );
      await controller.addWebMessageListener(
        PlatformWebMessageListener(
          PlatformWebMessageListenerCreationParams(jsObjectName: 'bridge'),
        ),
      );

      await controller.openDevTools();
      await controller.callDevToolsProtocolMethod(
        methodName: 'Runtime.evaluate',
      );
      await controller.addDevToolsProtocolEventListener(
        eventName: 'Log.entryAdded',
        callback: (_) {},
      );
      await controller.removeDevToolsProtocolEventListener(
        eventName: 'Log.entryAdded',
      );

      controller.dispose();
      expect(controller.disposed, isTrue);
    });

    test('static helpers should delegate to platform', () async {
      expect(
        await PlatformInAppWebViewController.static().getDefaultUserAgent(),
        isNotNull,
      );
    });
  });

  group('Browser Headless ChromeSafari', () {
    setUp(installFakeInAppWebViewPlatform);

    test('PlatformInAppBrowser openUrlRequest show hide close', () async {
      final browser = PlatformInAppBrowser(
        const PlatformInAppBrowserCreationParams(),
      );
      expect(browser.id, isNotEmpty);
      await browser.openUrlRequest(
        urlRequest: URLRequest(url: WebUri('https://example.com')),
      );
      expect(browser.isOpened(), isTrue);
      await browser.show();
      await browser.hide();
      expect(await browser.isHidden(), isA<bool>());
      await browser.close();
      browser.dispose();
    });

    test('PlatformChromeSafariBrowser open close and static', () async {
      expect(await PlatformChromeSafariBrowser.static().isAvailable(), isTrue);
      final browser = PlatformChromeSafariBrowser(
        const PlatformChromeSafariBrowserCreationParams(),
      );
      await browser.open(url: WebUri('https://example.com'));
      expect(browser.isOpened(), isTrue);
      await browser.close();
      browser.dispose();
    });

    test('PlatformHeadlessInAppWebView run size dispose', () async {
      final headless = PlatformHeadlessInAppWebView(
        PlatformHeadlessInAppWebViewCreationParams(
          controllerFromPlatform: (c) => c,
        ),
      );
      await headless.run();
      expect(headless.isRunning(), isTrue);
      await headless.setSize(const Size(320, 480));
      expect(await headless.getSize(), isNotNull);
      await headless.dispose();
      expect(headless.isRunning(), isFalse);
    });
  });

  group('WebMessage PathHandler WebAuth', () {
    setUp(installFakeInAppWebViewPlatform);

    test('WebMessageChannel Port Listener ReplyProxy', () async {
      final port = FakePlatformWebMessagePort(index: 0);
      await port.setWebMessageCallback((_) async {});
      await port.postMessage(WebMessage(data: 'hello'));
      expect(port.toMap()['index'], 0);
      await port.close();

      final channel = FakePlatformWebMessageChannel(id: 'channel-1');
      expect(channel.id, 'channel-1');
      channel.dispose();

      final listener = FakePlatformWebMessageListener(
        jsObjectName: 'obj',
      );
      expect(listener.jsObjectName, 'obj');
      expect(listener.toMap()['jsObjectName'], 'obj');
      listener.dispose();

      final reply = FakePlatformJavaScriptReplyProxy(listener);
      await reply.postMessage(WebMessage(data: 'pong'));
    });

    test('PathHandlers and WebViewAssetLoader', () {
      final assets = PlatformAssetsPathHandler(
        PlatformAssetsPathHandlerCreationParams(
          PlatformPathHandlerCreationParams(path: '/assets/'),
        ),
      );
      expect(assets.path, '/assets/');
      expect(assets.toMap()['path'], '/assets/');

      final resources = PlatformResourcesPathHandler(
        PlatformResourcesPathHandlerCreationParams(
          PlatformPathHandlerCreationParams(path: '/res/'),
        ),
      );
      expect(resources.toMap()['path'], '/res/');

      final internal = PlatformInternalStoragePathHandler(
        PlatformInternalStoragePathHandlerCreationParams(
          PlatformPathHandlerCreationParams(path: '/files/'),
          directory: 'documents',
        ),
      );
      expect(internal.directory, 'documents');

      final custom = PlatformCustomPathHandler(
        PlatformCustomPathHandlerCreationParams(
          PlatformPathHandlerCreationParams(path: '/custom/'),
        ),
      );
      expect(custom.toMap()['path'], '/custom/');

      final loader = WebViewAssetLoader(pathHandlers: [assets, resources]);
      expect(loader.toMap()['pathHandlers'], isNotEmpty);
    });

    test('WebAuthenticationSession create start cancel dispose', () async {
      expect(
        await PlatformWebAuthenticationSession.static().isAvailable(),
        isTrue,
      );
      final session = await PlatformWebAuthenticationSession.static().create(
        url: WebUri('https://example.com/oauth'),
        callbackURLScheme: 'app',
        onComplete: (_, __) async {},
      );
      expect(session.url.rawValue, contains('oauth'));
      expect(await session.canStart(), isTrue);
      expect(await session.start(), isTrue);
      await session.cancel();
      await session.dispose();
    });
  });

  group('InAppWebViewWidget and KeepAlive', () {
    setUp(installFakeInAppWebViewPlatform);

    test('PlatformInAppWebViewWidget build and dispose', () {
      final widget = PlatformInAppWebViewWidget(
        PlatformInAppWebViewWidgetCreationParams(
          controllerFromPlatform: (c) => c,
        ),
      );
      expect(widget.build(_FakeBuildContext()), isA<Widget>());
      widget.dispose();
    });

    test('InAppWebViewKeepAlive exposes id', () {
      final keepAlive = InAppWebViewKeepAlive();
      expect(keepAlive.id, isNotEmpty);
    });
  });
}

class _FakeBuildContext implements BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
