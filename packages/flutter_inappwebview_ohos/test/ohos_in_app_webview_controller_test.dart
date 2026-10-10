/*
* Copyright (c) 2024 Hunan OpenValley Digital Industry Development Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_ohos/flutter_inappwebview_ohos.dart';
import 'package:flutter_inappwebview_ohos/src/web_message/web_message_listener.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/mock_controller.dart';
import 'helpers/test_bindings.dart';

void main() {
  ensureTestBindings();

  group('OhosInAppWebViewController basics', () {
    const controllerId = 42;
    late OhosInAppWebViewController controller;

    setUp(() {
      mockOhosStaticChannel();
      controller = createMockOhosController(id: controllerId);
    });

    tearDown(() {
      setMockMethodChannelHandler(ohosControllerChannel(controllerId), null);
      setMockMethodChannelHandler(ohosManagerChannel, null);
    });

    test('static should return singleton', () {
      expect(
        identical(
          OhosInAppWebViewController.static(),
          OhosInAppWebViewController.static(),
        ),
        isTrue,
      );
    });

    test('getViewId should return controller id', () {
      expect(controller.getViewId(), controllerId);
    });

    test('getUrl, getTitle, and getProgress should delegate to channel',
        () async {
      expect((await controller.getUrl())?.toString(), 'https://example.com');
      expect(await controller.getTitle(), 'Example');
      expect(await controller.getProgress(), 100);
      expect(
        (await controller.getOriginalUrl())?.toString(),
        'https://example.com/original',
      );
    });

    test('webStorage should expose local and session storage', () {
      expect(controller.webStorage.localStorage, isA<OhosLocalStorage>());
      expect(controller.webStorage.sessionStorage, isA<OhosSessionStorage>());
    });
  });

  group('OhosInAppWebViewController navigation', () {
    const controllerId = 43;
    late OhosInAppWebViewController controller;

    setUp(() {
      mockOhosStaticChannel();
      controller = createMockOhosController(id: controllerId);
    });

    tearDown(() {
      setMockMethodChannelHandler(ohosControllerChannel(controllerId), null);
      setMockMethodChannelHandler(ohosManagerChannel, null);
    });

    test('load and navigation methods should delegate to channel', () async {
      await controller.loadUrl(
        urlRequest: URLRequest(url: WebUri('https://example.com')),
      );
      await controller.postUrl(
        url: WebUri('https://example.com/post'),
        postData: Uint8List.fromList([1, 2]),
      );
      await controller.loadData(data: '<html></html>');
      await controller.loadFile(assetFilePath: 'assets/index.html');
      await controller.reload();
      await controller.goBack();
      await controller.goForward();
      await controller.goBackOrForward(steps: -1);
      await controller.stopLoading();

      expect(await controller.canGoBack(), isTrue);
      expect(await controller.canGoForward(), isFalse);
      expect(await controller.canGoBackOrForward(steps: -1), isTrue);
      expect(await controller.isLoading(), isFalse);
    });

    test('goTo and getCopyBackForwardList should delegate to channel', () async {
      final history = await controller.getCopyBackForwardList();
      expect(history?.currentIndex, 0);
      expect(history?.list?.length, 1);

      await controller.goTo(
        historyItem: history!.list!.first,
      );
    });

    test('clearHistory should delegate to channel', () async {
      await expectLater(controller.clearHistory(), completes);
    });
  });

  group('OhosInAppWebViewController settings and scripts', () {
    const controllerId = 44;
    late OhosInAppWebViewController controller;

    setUp(() {
      mockOhosStaticChannel();
      controller = createMockOhosController(id: controllerId);
    });

    tearDown(() {
      setMockMethodChannelHandler(ohosControllerChannel(controllerId), null);
      setMockMethodChannelHandler(ohosManagerChannel, null);
    });

    test('setSettings and getSettings should delegate to channel', () async {
      await controller.setSettings(
        settings: InAppWebViewSettings(javaScriptEnabled: true),
      );
      final settings = await controller.getSettings();
      expect(settings?.javaScriptEnabled, isTrue);
    });

    test('user scripts should be tracked locally and sent to channel', () async {
      final script = UserScript(
        source: 'window.test = 1;',
        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
        groupName: 'group-a',
      );

      await controller.addUserScript(userScript: script);
      expect(controller.hasUserScript(userScript: script), isTrue);

      await controller.addUserScripts(userScripts: [script]);
      expect(await controller.removeUserScript(userScript: script), isTrue);
      expect(controller.hasUserScript(userScript: script), isFalse);

      await controller.addUserScript(userScript: script);
      await controller.removeUserScriptsByGroupName(groupName: 'group-a');
      expect(controller.hasUserScript(userScript: script), isFalse);

      await controller.addUserScript(userScript: script);
      await controller.removeAllUserScripts();
      expect(controller.hasUserScript(userScript: script), isFalse);
    });

    test('injectJavascript and injectCSS should delegate to channel', () async {
      await controller.injectJavascriptFileFromUrl(
        urlFile: WebUri('https://example.com/app.js'),
      );
      await controller.injectCSSCode(source: 'body { color: red; }');
      await controller.injectCSSFileFromUrl(
        urlFile: WebUri('https://example.com/app.css'),
      );
      expect(
        await controller.evaluateJavascript(source: '1 + 1'),
        'js-result',
      );
    });

    test('callAsyncJavaScript should decode channel response', () async {
      final result = await controller.callAsyncJavaScript(
        functionBody: 'return arguments[0];',
        arguments: {'key': 'value'},
      );
      expect(result?.value, 'ok');
      expect(result?.error, isNull);
    });
  });

  group('OhosInAppWebViewController javascript handlers', () {
    const controllerId = 45;
    late OhosInAppWebViewController controller;
    late MethodChannel channel;

    setUp(() {
      mockOhosStaticChannel();
      controller = createMockOhosController(id: controllerId);
      channel = ohosControllerChannel(controllerId);
    });

    tearDown(() {
      setMockMethodChannelHandler(channel, null);
      setMockMethodChannelHandler(ohosManagerChannel, null);
    });

    test('addJavaScriptHandler should register and invoke handler', () async {
      List<dynamic>? receivedArgs;
      controller.addJavaScriptHandler(
        handlerName: 'myHandler',
        callback: (args) {
          receivedArgs = args;
          return {'ok': true};
        },
      );
      expect(controller.hasJavaScriptHandler(handlerName: 'myHandler'), isTrue);
      expect(
        controller.removeJavaScriptHandler(handlerName: 'myHandler'),
        isNotNull,
      );

      controller.addJavaScriptHandler(
        handlerName: 'myHandler',
        callback: (args) {
          receivedArgs = args;
          return {'ok': true};
        },
      );

      final response = await sendPlatformMethodCall(
        channel,
        MethodCall('onCallJsHandler', {
          'handlerName': 'myHandler',
          'args': jsonEncode([
            {'key': 'value'},
          ]),
        }),
      );

      expect(receivedArgs?.length, 1);
      expect(jsonDecode(response as String), {'ok': true});
    });

    test('forbidden handler names should assert in debug mode', () {
      expect(
        () => controller.addJavaScriptHandler(
          handlerName: 'onLoadResource',
          callback: (_) {},
        ),
        throwsAssertionError,
      );
    });
  });

  group('OhosInAppWebViewController scroll and zoom', () {
    const controllerId = 46;
    late OhosInAppWebViewController controller;

    setUp(() {
      mockOhosStaticChannel();
      controller = createMockOhosController(id: controllerId);
    });

    tearDown(() {
      setMockMethodChannelHandler(ohosControllerChannel(controllerId), null);
      setMockMethodChannelHandler(ohosManagerChannel, null);
    });

    test('scroll, zoom, and page methods should delegate to channel', () async {
      await controller.scrollTo(x: 0, y: 100, animated: true);
      await controller.scrollBy(x: 0, y: 50);
      expect(await controller.getScrollX(), 10);
      expect(await controller.getScrollY(), 20);
      expect(await controller.canScrollVertically(), isTrue);
      expect(await controller.canScrollHorizontally(), isFalse);

      await controller.zoomBy(zoomFactor: 1.2, animated: true);
      expect(await controller.getZoomScale(), 1.5);
      expect(await controller.zoomIn(), isTrue);
      expect(await controller.zoomOut(), isTrue);
      expect(await controller.pageDown(bottom: true), isTrue);
      expect(await controller.pageUp(top: true), isTrue);
    });

    test('getContentHeight and getContentWidth should delegate to channel',
        () async {
      expect(await controller.getContentHeight(), 500);
      expect(await controller.getContentWidth(), 320);
    });
  });

  group('OhosInAppWebViewController page info', () {
    const controllerId = 47;
    late OhosInAppWebViewController controller;

    setUp(() {
      mockOhosStaticChannel();
      controller = createMockOhosController(id: controllerId);
    });

    tearDown(() {
      setMockMethodChannelHandler(ohosControllerChannel(controllerId), null);
      setMockMethodChannelHandler(ohosManagerChannel, null);
    });

    test('getHtml should use evaluateJavascript when JS is enabled', () async {
      expect(await controller.getHtml(), '<html></html>');
    });

    test('getMetaTags and getMetaThemeColor should parse JS/channel data',
        () async {
      final metaTags = await controller.getMetaTags();
      expect(metaTags.length, 1);
      expect(metaTags.first.name, 'theme-color');

      final themeColor = await controller.getMetaThemeColor();
      expect(themeColor, isNotNull);
    });

    test('getFavicons should return empty list when no links found', () async {
      expect(await controller.getFavicons(), isEmpty);
    });

    test('getSelectedText and getHitTestResult should delegate to channel',
        () async {
      expect(await controller.getSelectedText(), 'selection');
      final hitTest = await controller.getHitTestResult();
      expect(hitTest?.extra, 'https://example.com/link');
    });

    test('requestFocusNodeHref and requestImageRef should parse channel data',
        () async {
      final focus = await controller.requestFocusNodeHref();
      expect(focus?.url?.toString(), 'https://example.com/focus');

      final imageRef = await controller.requestImageRef();
      expect(imageRef?.url?.toString(), 'https://example.com/img.png');
    });

    test('takeScreenshot should return bytes from channel', () async {
      final screenshot = await controller.takeScreenshot();
      expect(screenshot, Uint8List.fromList([1, 2, 3]));
    });
  });

  group('OhosInAppWebViewController web message', () {
    const controllerId = 48;
    late OhosInAppWebViewController controller;

    setUp(() {
      mockOhosStaticChannel();
      controller = createMockOhosController(id: controllerId);
    });

    tearDown(() {
      setMockMethodChannelHandler(ohosControllerChannel(controllerId), null);
      setMockMethodChannelHandler(ohosManagerChannel, null);
    });

    test('createWebMessageChannel should parse channel response', () async {
      final webMessageChannel = await controller.createWebMessageChannel();
      expect(webMessageChannel, isA<OhosWebMessageChannel>());
      expect(webMessageChannel?.id, 'wm-test');
    });

    test('postWebMessage and addWebMessageListener should delegate', () async {
      await controller.postWebMessage(
        message: WebMessage(data: 'hello'),
        targetOrigin: WebUri('https://example.com'),
      );

      final listener = OhosWebMessageListener(
        OhosWebMessageListenerCreationParams(
          allowedOriginRules: {'https://example.com'},
          jsObjectName: 'Bridge',
        ),
      );
      await controller.addWebMessageListener(listener);
      expect(controller.hasWebMessageListener(listener), isTrue);
    });
  });

  group('OhosInAppWebViewController lifecycle and cache', () {
    const controllerId = 49;
    late OhosInAppWebViewController controller;

    setUp(() {
      mockOhosStaticChannel();
      controller = createMockOhosController(id: controllerId);
    });

    tearDown(() {
      setMockMethodChannelHandler(ohosControllerChannel(controllerId), null);
      setMockMethodChannelHandler(ohosManagerChannel, null);
    });

    test('pause, resume, and timer methods should delegate to channel', () async {
      await controller.pause();
      await controller.resume();
      await controller.pauseTimers();
      await controller.resumeTimers();
    });

    test('clearFormData, clearSslPreferences, and isInFullscreen should delegate',
        () async {
      await controller.clearFormData();
      await controller.clearSslPreferences();
      expect(await controller.isInFullscreen(), isFalse);
      expect(await controller.isSecureContext(), isTrue);
    });

    test('printCurrentPage should return print job controller', () async {
      final printJob = await controller.printCurrentPage();
      expect(printJob, isA<OhosPrintJobController>());
    });

    test('saveWebArchive should return file path from channel', () async {
      expect(
        await controller.saveWebArchive(
          filePath: '/data/archive.mht',
        ),
        '/data/archive.mht',
      );
    });

    test('dispose should clear handlers without throwing', () {
      controller.addJavaScriptHandler(handlerName: 'h', callback: (_) {});
      expect(() => controller.dispose(), returnsNormally);
    });
  });

  group('OhosInAppWebViewController static channel methods', () {
    const controllerId = 50;
    late OhosInAppWebViewController controller;

    setUp(() {
      mockOhosStaticChannel();
      controller = createMockOhosController(id: controllerId);
    });

    tearDown(() {
      setMockMethodChannelHandler(ohosControllerChannel(controllerId), null);
      setMockMethodChannelHandler(ohosManagerChannel, null);
    });

    test('static helpers should delegate to manager channel', () async {
      expect(await controller.getDefaultUserAgent(), 'Mozilla/test');
      expect(
        (await controller.getSafeBrowsingPrivacyPolicyUrl())?.toString(),
        'https://example.com/policy',
      );
      expect(
        await controller.setSafeBrowsingAllowlist(
          hosts: ['example.com'],
        ),
        isTrue,
      );
      expect(await controller.getVariationsHeader(), 'variation-header');
      expect(await controller.isMultiProcessEnabled(), isTrue);
      expect(await controller.startSafeBrowsing(), isTrue);

      final packageInfo = await controller.getCurrentWebViewPackage();
      expect(packageInfo?.packageName, 'com.test.webview');

      await controller.setWebContentsDebuggingEnabled(true);
      await controller.clearClientCertPreferences();
      await controller.clearAllCache(includeDiskFiles: true);

      final keepAlive = InAppWebViewKeepAlive();
      await controller.disposeKeepAlive(keepAlive);
    });
  });

  group('OhosInAppWebViewController callbacks', () {
    const controllerId = 51;
    late MethodChannel channel;

    tearDown(() {
      setMockMethodChannelHandler(channel, null);
      setMockMethodChannelHandler(ohosManagerChannel, null);
    });

    test('onLoadStart and onLoadStop should invoke webview callbacks', () async {
      WebUri? startUrl;
      WebUri? stopUrl;

      mockOhosStaticChannel();
      final controller = createMockOhosController(
        id: controllerId,
        webviewParams: PlatformInAppWebViewWidgetCreationParams(
          onLoadStart: (_, url) {
            startUrl = url;
          },
          onLoadStop: (_, url) {
            stopUrl = url;
          },
        ),
      );
      channel = ohosControllerChannel(controllerId);

      await sendPlatformMethodCall(
        channel,
        MethodCall('onLoadStart', {'url': 'https://example.com/start'}),
      );
      await sendPlatformMethodCall(
        channel,
        MethodCall('onLoadStop', {'url': 'https://example.com/stop'}),
      );

      expect(startUrl?.toString(), 'https://example.com/start');
      expect(stopUrl?.toString(), 'https://example.com/stop');
    });

    test('setContextMenu and clearFocus should delegate to channel', () async {
      mockOhosStaticChannel();
      final controller = createMockOhosController(id: controllerId);
      channel = ohosControllerChannel(controllerId);

      await controller.setContextMenu(ContextMenu());
      await controller.clearFocus();
    });
  });
}
