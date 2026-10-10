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

  group('OhosChromeSafariBrowser', () {
    const staticChannel =
        MethodChannel('com.pichillilorenzo/flutter_chromesafaribrowser');

    setUp(() {
      OhosInAppWebViewPlatform.registerWith();
      setMockMethodChannelHandler(staticChannel, (call) async {
        switch (call.method) {
          case 'open':
            return null;
          case 'isAvailable':
            return true;
          case 'getMaxToolbarItems':
            return 5;
          case 'getPackageName':
            return 'com.example.browser';
        }
        return null;
      });
    });

    tearDown(() {
      setMockMethodChannelHandler(staticChannel, null);
    });

    test('should expose id and isOpened state', () {
      final browser = OhosInAppWebViewPlatform()
          .createPlatformChromeSafariBrowser(
        const PlatformChromeSafariBrowserCreationParams(),
      ) as OhosChromeSafariBrowser;

      expect(browser.id, isNotEmpty);
      expect(browser.isOpened(), isFalse);
    });

    test('static helpers should delegate to channel', () async {
      expect(await OhosChromeSafariBrowser.static().isAvailable(), isTrue);
      expect(
        await OhosChromeSafariBrowser.static().getMaxToolbarItems(),
        5,
      );
      expect(
        await OhosChromeSafariBrowser.static().getPackageName(),
        'com.example.browser',
      );
    });

    test('open and launchUrl should delegate to channels', () async {
      final browser = OhosInAppWebViewPlatform()
          .createPlatformChromeSafariBrowser(
        const PlatformChromeSafariBrowserCreationParams(),
      ) as OhosChromeSafariBrowser;

      final instanceChannel = MethodChannel(
        'com.pichillilorenzo/flutter_chromesafaribrowser_${browser.id}',
      );
      setMockMethodChannelHandler(instanceChannel, (call) async {
        switch (call.method) {
          case 'launchUrl':
          case 'close':
          case 'mayLaunchUrl':
            return true;
        }
        return null;
      });

      await browser.open(url: WebUri('https://example.com'));
      expect(browser.isOpened(), isTrue);

      await browser.launchUrl(url: WebUri('https://example.com/page'));
      expect(
        await browser.mayLaunchUrl(url: WebUri('https://example.com/page')),
        isTrue,
      );
      await browser.close();

      setMockMethodChannelHandler(instanceChannel, null);
    });
  });
}
