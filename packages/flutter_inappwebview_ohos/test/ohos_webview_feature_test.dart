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

  group('OhosWebViewFeature', () {
    const channel = MethodChannel(
      'com.pichillilorenzo/flutter_inappwebview_webviewfeature',
    );

    setUp(() {
      setMockMethodChannelHandler(channel, (call) async {
        switch (call.method) {
          case 'isFeatureSupported':
            return true;
          case 'isStartupFeatureSupported':
            return false;
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
          OhosWebViewFeature.instance(),
          OhosWebViewFeature.static(),
        ),
        isTrue,
      );
    });

    test('isFeatureSupported and isStartupFeatureSupported should delegate',
        () async {
      final feature = OhosWebViewFeature.instance();
      expect(
        await feature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_LISTENER),
        isTrue,
      );
      expect(
        await feature.isStartupFeatureSupported(
          WebViewFeature.STARTUP_FEATURE_SET_DIRECTORY_BASE_PATHS,
        ),
        isFalse,
      );
    });
  });
}
