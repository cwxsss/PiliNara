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

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_ohos/flutter_inappwebview_ohos.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_bindings.dart';

void main() {
  ensureTestBindings();

  group('OhosInAppBrowser', () {
    const staticChannel = MethodChannel('com.pichillilorenzo/flutter_inappbrowser');

    setUp(() {
      OhosInAppWebViewPlatform.registerWith();
      setMockMethodChannelHandler(staticChannel, (call) async {
        if (call.method == 'open' || call.method == 'openWithSystemBrowser') {
          return null;
        }
        return null;
      });
    });

    tearDown(() {
      setMockMethodChannelHandler(staticChannel, null);
    });

    test('should expose id and isOpened state', () {
      final browser = OhosInAppWebViewPlatform().createPlatformInAppBrowser(
        const PlatformInAppBrowserCreationParams(),
      ) as OhosInAppBrowser;

      expect(browser.id, isNotEmpty);
      expect(browser.isOpened(), isFalse);
      expect(browser.webViewController, isNull);
    });

    test('openUrlRequest should open browser and expose webViewController',
        () async {
      final browser = OhosInAppWebViewPlatform().createPlatformInAppBrowser(
        const PlatformInAppBrowserCreationParams(),
      ) as OhosInAppBrowser;

      final instanceChannel = MethodChannel(
        'com.pichillilorenzo/flutter_inappbrowser_${browser.id}',
      );
      setMockMethodChannelHandler(instanceChannel, (call) async {
        switch (call.method) {
          case 'show':
          case 'hide':
          case 'close':
          case 'setSettings':
            return null;
          case 'isHidden':
            return false;
          case 'getSettings':
            return {};
        }
        return null;
      });

      await browser.openUrlRequest(
        urlRequest: URLRequest(url: WebUri('https://example.com')),
      );

      expect(browser.isOpened(), isTrue);
      expect(browser.webViewController, isA<OhosInAppWebViewController>());

      await browser.show();
      await browser.hide();
      expect(await browser.isHidden(), isFalse);
      await browser.close();

      setMockMethodChannelHandler(instanceChannel, null);
    });

    test('openWithSystemBrowser should delegate to static channel', () async {
      final browser = OhosInAppWebViewPlatform().createPlatformInAppBrowser(
        const PlatformInAppBrowserCreationParams(),
      ) as OhosInAppBrowser;

      await expectLater(
        browser.openWithSystemBrowser(url: WebUri('https://example.com')),
        completes,
      );
    });

    test('menu items should be addable and removable', () {
      final browser = OhosInAppWebViewPlatform().createPlatformInAppBrowser(
        const PlatformInAppBrowserCreationParams(),
      ) as OhosInAppBrowser;

      final item = InAppBrowserMenuItem(
        id: 1,
        title: 'Share',
        onClick: () {},
      );
      browser.addMenuItem(item);
      expect(browser.removeMenuItem(item), isTrue);
    });
  });
}
