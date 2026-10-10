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

import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_ohos/flutter_inappwebview_ohos.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_bindings.dart';

void main() {
  ensureTestBindings();

  group('OhosServiceWorkerController', () {
    const channel = MethodChannel(
      'com.pichillilorenzo/flutter_inappwebview_serviceworkercontroller',
    );

    setUp(() {
      setMockMethodChannelHandler(channel, (call) async {
        switch (call.method) {
          case 'setServiceWorkerClient':
            return null;
          case 'getAllowContentAccess':
            return true;
          case 'getAllowFileAccess':
            return false;
          case 'getBlockNetworkLoads':
            return false;
          case 'getCacheMode':
            return CacheMode.LOAD_DEFAULT.toNativeValue();
          case 'setAllowContentAccess':
          case 'setAllowFileAccess':
          case 'setBlockNetworkLoads':
          case 'setCacheMode':
            return null;
        }
        return null;
      });
    });

    tearDown(() {
      setMockMethodChannelHandler(channel, null);
    });

    test('instance and static should return singleton', () {
      expect(
        identical(
          OhosServiceWorkerController.instance(),
          OhosServiceWorkerController.static(),
        ),
        isTrue,
      );
    });

    test('settings getters and setters should delegate to channel', () async {
      final controller = OhosServiceWorkerController.instance();

      expect(await controller.getAllowContentAccess(), isTrue);
      expect(await controller.getAllowFileAccess(), isFalse);
      expect(await controller.getBlockNetworkLoads(), isFalse);
      expect(await controller.getCacheMode(), CacheMode.LOAD_DEFAULT);

      await controller.setAllowContentAccess(true);
      await controller.setAllowFileAccess(true);
      await controller.setBlockNetworkLoads(true);
      await controller.setCacheMode(CacheMode.LOAD_CACHE_ELSE_NETWORK);
    });

    test('shouldInterceptRequest should invoke service worker client', () async {
      final controller = OhosServiceWorkerController.instance();
      WebResourceRequest? interceptedRequest;

      await controller.setServiceWorkerClient(
        ServiceWorkerClient(
          shouldInterceptRequest: (request) async {
            interceptedRequest = request;
            return WebResourceResponse(
              contentType: 'text/plain',
              data: Uint8List.fromList([1]),
            );
          },
        ),
      );

      await sendPlatformMethodCall(
        channel,
        MethodCall('shouldInterceptRequest', {
          'url': 'https://example.com/sw.js',
          'method': 'GET',
        }),
      );

      expect(interceptedRequest?.url.toString(), 'https://example.com/sw.js');
      await controller.setServiceWorkerClient(null);
    });
  });
}
