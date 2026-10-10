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
import 'package:flutter_inappwebview_ohos/src/inappwebview_platform.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_bindings.dart';

URLProtectionSpace _sampleProtectionSpace() {
  return URLProtectionSpace(
    host: 'example.com',
    protocol: 'https',
    realm: 'realm',
    port: 443,
  );
}

URLCredential _sampleCredential() {
  return URLCredential(username: 'user', password: 'pass');
}

void main() {
  ensureTestBindings();

  group('OhosHttpAuthCredentialDatabase', () {
    const channel = MethodChannel(
      'com.pichillilorenzo/flutter_inappwebview_credential_database',
    );

    setUp(() {
      setMockMethodChannelHandler(channel, (call) async {
        switch (call.method) {
          case 'getAllAuthCredentials':
            return [
              {
                'protectionSpace': {
                  'host': 'example.com',
                  'protocol': 'https',
                  'realm': 'realm',
                  'port': 443,
                },
                'credentials': [
                  {'username': 'user', 'password': 'pass'},
                ],
              },
            ];
          case 'getHttpAuthCredentials':
            return [
              {'username': 'user', 'password': 'pass'},
            ];
          case 'setHttpAuthCredential':
          case 'removeHttpAuthCredential':
          case 'removeHttpAuthCredentials':
          case 'clearAllAuthCredentials':
            return null;
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
          OhosHttpAuthCredentialDatabase.instance(),
          OhosHttpAuthCredentialDatabase.instance(),
        ),
        isTrue,
      );
    });

    test('getAllAuthCredentials should parse credentials', () async {
      final all =
          await OhosHttpAuthCredentialDatabase.instance().getAllAuthCredentials();
      expect(all.length, 1);
      expect(all.first.protectionSpace?.host, 'example.com');
      expect(all.first.credentials?.first.username, 'user');
    });

    test('getHttpAuthCredentials should parse credential list', () async {
      final credentials = await OhosHttpAuthCredentialDatabase.instance()
          .getHttpAuthCredentials(protectionSpace: _sampleProtectionSpace());
      expect(credentials.length, 1);
      expect(credentials.first.username, 'user');
    });

    test('set, remove, and clear should delegate to channel', () async {
      final db = OhosHttpAuthCredentialDatabase.instance();
      final space = _sampleProtectionSpace();
      final credential = _sampleCredential();

      await expectLater(
        db.setHttpAuthCredential(
          protectionSpace: space,
          credential: credential,
        ),
        completes,
      );
      await expectLater(
        db.removeHttpAuthCredential(
          protectionSpace: space,
          credential: credential,
        ),
        completes,
      );
      await expectLater(
        db.removeHttpAuthCredentials(protectionSpace: space),
        completes,
      );
      await expectLater(db.clearAllAuthCredentials(), completes);
    });

    test('dispose should complete without error', () {
      final db = OhosHttpAuthCredentialDatabase(
        OhosHttpAuthCredentialDatabaseCreationParams(
          const PlatformHttpAuthCredentialDatabaseCreationParams(),
        ),
      );
      expect(() => db.dispose(), returnsNormally);
    });

    test('platform factory should create database with dispose support', () {
      OhosInAppWebViewPlatform.registerWith();
      final db = OhosInAppWebViewPlatform()
          .createPlatformHttpAuthCredentialDatabase(
        const PlatformHttpAuthCredentialDatabaseCreationParams(),
      );
      expect(db, isA<OhosHttpAuthCredentialDatabase>());
      expect(() => db.dispose(), returnsNormally);
    });
  });
}
