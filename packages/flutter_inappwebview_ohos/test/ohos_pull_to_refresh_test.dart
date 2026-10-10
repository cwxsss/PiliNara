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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_ohos/flutter_inappwebview_ohos.dart';
import 'package:flutter_inappwebview_ohos/src/pull_to_refresh/pull_to_refresh_controller.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_bindings.dart';

void main() {
  ensureTestBindings();

  group('OhosPullToRefreshController appearance', () {
    test('setColor, setBackgroundColor, setDistanceToTriggerSync, setSize should delegate',
        () async {
      final controller = OhosPullToRefreshController(
        OhosPullToRefreshControllerCreationParams(
          settings: PullToRefreshSettings(enabled: true),
        ),
      );
      controller.init(42);

      final methodChannel = MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_pull_to_refresh_42',
      );
      final invoked = <String>[];
      setMockMethodChannelHandler(methodChannel, (call) async {
        invoked.add(call.method);
        if (call.method == 'getDefaultSlingshotDistance') {
          return 100;
        }
        return true;
      });

      await controller.setColor(const Color(0xFFFF0000));
      await controller.setBackgroundColor(const Color(0xFFFFFFFF));
      await controller.setDistanceToTriggerSync(200);
      await controller.setSlingshotDistance(80);
      await controller.setSize(AndroidPullToRefreshSize.LARGE);
      expect(await controller.getDefaultSlingshotDistance(), 100);

      expect(invoked, contains('setColor'));
      expect(invoked, contains('setBackgroundColor'));
      expect(invoked, contains('setDistanceToTriggerSync'));
      expect(invoked, contains('setSlingshotDistance'));
      expect(invoked, contains('setSize'));

      controller.dispose();
      setMockMethodChannelHandler(methodChannel, null);
    });
  });
}
