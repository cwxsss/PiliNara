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

import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_ohos/flutter_inappwebview_ohos.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_bindings.dart';

void main() {
  ensureTestBindings();

  group('OhosHeadlessInAppWebView', () {
    const sharedChannel = MethodChannel(
      'com.pichillilorenzo/flutter_headless_inappwebview',
    );
    const managerChannel = MethodChannel(
      'com.pichillilorenzo/flutter_inappwebview_manager',
    );

    setUp(() {
      OhosInAppWebViewPlatform.registerWith();
      setMockMethodChannelHandler(managerChannel, (_) async => null);
    });

    tearDown(() {
      setMockMethodChannelHandler(managerChannel, null);
    });

    test('run should create webViewController and set isRunning', () async {
      final headless = OhosInAppWebViewPlatform()
          .createPlatformHeadlessInAppWebView(
        const PlatformHeadlessInAppWebViewCreationParams(),
      ) as OhosHeadlessInAppWebView;

      expect(headless.isRunning(), isFalse);
      expect(headless.webViewController, isNull);

      setMockMethodChannelHandler(sharedChannel, (call) async {
        if (call.method == 'run') {
          return null;
        }
        return null;
      });

      final instanceChannel = MethodChannel(
        'com.pichillilorenzo/flutter_headless_inappwebview_${headless.id}',
      );
      setMockMethodChannelHandler(instanceChannel, (call) async {
        switch (call.method) {
          case 'dispose':
          case 'setSize':
            return null;
          case 'getSize':
            return {'width': 100.0, 'height': 200.0};
        }
        return null;
      });

      await headless.run();
      expect(headless.isRunning(), isTrue);
      expect(headless.webViewController, isA<OhosInAppWebViewController>());

      await headless.setSize(const Size(100, 200));
      final size = await headless.getSize();
      expect(size?.width, 100);
      expect(size?.height, 200);

      await headless.dispose();
      expect(headless.isRunning(), isFalse);

      setMockMethodChannelHandler(sharedChannel, null);
      setMockMethodChannelHandler(instanceChannel, null);
    });

    test('run should be idempotent', () async {
      final headless = OhosInAppWebViewPlatform()
          .createPlatformHeadlessInAppWebView(
        const PlatformHeadlessInAppWebViewCreationParams(),
      ) as OhosHeadlessInAppWebView;

      var runCount = 0;
      setMockMethodChannelHandler(sharedChannel, (call) async {
        if (call.method == 'run') {
          runCount++;
        }
        return null;
      });

      final instanceChannel = MethodChannel(
        'com.pichillilorenzo/flutter_headless_inappwebview_${headless.id}',
      );
      setMockMethodChannelHandler(instanceChannel, (_) async => null);

      await headless.run();
      await headless.run();
      expect(runCount, 1);

      await headless.dispose();
      setMockMethodChannelHandler(sharedChannel, null);
      setMockMethodChannelHandler(instanceChannel, null);
    });
  });
}
