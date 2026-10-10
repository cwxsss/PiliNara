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
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_bindings.dart';

void main() {
  ensureTestBindings();

  group('OhosWebStorageManager', () {
    const channel = MethodChannel(
      'com.pichillilorenzo/flutter_inappwebview_webstoragemanager',
    );

    setUp(() {
      setMockMethodChannelHandler(channel, (call) async {
        switch (call.method) {
          case 'getOrigins':
            return [
              {'origin': 'https://example.com', 'quota': 100, 'usage': 50},
            ];
          case 'deleteAllData':
          case 'deleteOrigin':
            return null;
          case 'getQuotaForOrigin':
            return 100;
          case 'getUsageForOrigin':
            return 50;
        }
        return null;
      });
    });

    tearDown(() {
      setMockMethodChannelHandler(channel, null);
    });

    test('instance should return singleton', () {
      expect(
        identical(
          OhosWebStorageManager.instance(),
          OhosWebStorageManager.instance(),
        ),
        isTrue,
      );
    });

    test('getOrigins should parse origin list', () async {
      final origins = await OhosWebStorageManager.instance().getOrigins();
      expect(origins.length, 1);
      expect(origins.first.origin, 'https://example.com');
      expect(origins.first.quota, 100);
      expect(origins.first.usage, 50);
    });

    test('deleteAllData and deleteOrigin should delegate to channel', () async {
      final manager = OhosWebStorageManager.instance();
      await expectLater(manager.deleteAllData(), completes);
      await expectLater(
        manager.deleteOrigin(origin: 'https://example.com'),
        completes,
      );
    });

    test('getQuotaForOrigin and getUsageForOrigin should return values',
        () async {
      final manager = OhosWebStorageManager.instance();
      expect(
        await manager.getQuotaForOrigin(origin: 'https://example.com'),
        100,
      );
      expect(
        await manager.getUsageForOrigin(origin: 'https://example.com'),
        50,
      );
    });
  });
}
