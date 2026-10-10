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

import 'helpers/mock_controller.dart';
import 'helpers/test_bindings.dart';

void main() {
  ensureTestBindings();

  group('OhosWebStorage', () {
    late OhosInAppWebViewPlatform platform;

    setUp(() {
      platform = OhosInAppWebViewPlatform();
      InAppWebViewPlatform.instance = platform;
    });

    test('should expose localStorage and sessionStorage', () {
      final controller = platform.createPlatformInAppWebViewController(
        const PlatformInAppWebViewControllerCreationParams(id: 10),
      );
      final localStorage = platform.createPlatformLocalStorage(
        PlatformLocalStorageCreationParams(
          PlatformStorageCreationParams(
            controller: controller,
            webStorageType: WebStorageType.LOCAL_STORAGE,
          ),
        ),
      );
      final sessionStorage = platform.createPlatformSessionStorage(
        PlatformSessionStorageCreationParams(
          PlatformStorageCreationParams(
            controller: controller,
            webStorageType: WebStorageType.SESSION_STORAGE,
          ),
        ),
      );

      final webStorage = platform.createPlatformWebStorage(
        PlatformWebStorageCreationParams(
          localStorage: localStorage,
          sessionStorage: sessionStorage,
        ),
      );

      expect(webStorage.localStorage, same(localStorage));
      expect(webStorage.sessionStorage, same(sessionStorage));

      webStorage.dispose();
    });
  });

  group('OhosLocalStorage and OhosSessionStorage', () {
    tearDown(() {
      setMockMethodChannelHandler(
        const MethodChannel('com.pichillilorenzo/flutter_inappwebview_20'),
        null,
      );
    });

    test('localStorage API should delegate through evaluateJavascript', () async {
      final controller = createMockOhosController(
        id: 20,
        handler: mockEvaluateJavascriptHandler,
      );
      final localStorage = OhosLocalStorage.defaultStorage(controller: controller);

      await localStorage.setItem(key: 'k1', value: 'v1');
      expect(await localStorage.getItem(key: 'k1'), 'value');

      final items = await localStorage.getItems();
      expect(items.length, 1);
      expect(items.first.key, 'k1');

      await localStorage.removeItem(key: 'k1');
      await localStorage.clear();
      localStorage.dispose();
    });

    test('sessionStorage API should delegate through evaluateJavascript', () async {
      final controller = createMockOhosController(
        id: 20,
        handler: mockEvaluateJavascriptHandler,
      );
      final sessionStorage =
          OhosSessionStorage.defaultStorage(controller: controller);

      await sessionStorage.setItem(key: 's1', value: 42);
      expect(await sessionStorage.getItem(key: 's1'), 'value');
      sessionStorage.dispose();
    });

    test('length should accept numeric evaluateJavascript results', () async {
      final controller = createMockOhosController(
        id: 21,
        handler: (call) async {
          if (call.method == 'evaluateJavascript') {
            return 2;
          }
          return null;
        },
      );
      final localStorage = OhosLocalStorage.defaultStorage(controller: controller);
      expect(await localStorage.length(), 2);
      localStorage.dispose();
      setMockMethodChannelHandler(
        const MethodChannel('com.pichillilorenzo/flutter_inappwebview_21'),
        null,
      );
    });
  });

  group('OhosHeadlessInAppWebView', () {
    test('should expose id after construction', () {
      OhosInAppWebViewPlatform.registerWith();
      final headless = OhosInAppWebViewPlatform().createPlatformHeadlessInAppWebView(
        const PlatformHeadlessInAppWebViewCreationParams(),
      );
      expect(headless.id, isNotEmpty);
    });
  });
}
