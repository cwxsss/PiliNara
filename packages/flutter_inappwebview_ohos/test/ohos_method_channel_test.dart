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
import 'package:flutter_inappwebview_ohos/src/find_interaction/find_interaction_controller.dart';
import 'package:flutter_inappwebview_ohos/src/pull_to_refresh/pull_to_refresh_controller.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_bindings.dart';

void main() {
  ensureTestBindings();

  group('OhosCookieManager', () {
    const channel =
        MethodChannel('com.pichillilorenzo/flutter_inappwebview_cookiemanager');

    setUp(() {
      setMockMethodChannelHandler(channel, (call) async {
        switch (call.method) {
          case 'setCookie':
            return true;
          case 'getCookies':
            return [mockCookieMap()];
          case 'deleteCookie':
            return true;
          case 'deleteCookies':
            return true;
          case 'deleteAllCookies':
            return true;
          case 'removeSessionCookies':
            return true;
        }
        return null;
      });
    });

    tearDown(() {
      setMockMethodChannelHandler(channel, null);
    });

    test('instance should return singleton', () {
      final first = OhosCookieManager.instance();
      final second = OhosCookieManager.instance();
      expect(identical(first, second), isTrue);
    });

    test('setCookie and getCookie should use method channel', () async {
      final manager = OhosCookieManager.instance();
      final url = WebUri('https://example.com');

      expect(
        await manager.setCookie(url: url, name: 'session', value: 'abc'),
        isTrue,
      );

      final cookie = await manager.getCookie(url: url, name: 'session');
      expect(cookie?.name, 'session');
      expect(cookie?.value, 'abc');
    });

    test('getCookies should parse cookie list', () async {
      final cookies = await OhosCookieManager.instance().getCookies(
        url: WebUri('https://example.com'),
      );
      expect(cookies.length, 1);
      expect(cookies.first.name, 'session');
    });

    test('deleteCookie and deleteAllCookies should delegate to channel',
        () async {
      final manager = OhosCookieManager.instance();
      final url = WebUri('https://example.com');

      expect(
        await manager.deleteCookie(url: url, name: 'session'),
        isTrue,
      );
      expect(
        await manager.deleteCookies(url: url),
        isTrue,
      );
      expect(await manager.deleteAllCookies(), isTrue);
      expect(await manager.removeSessionCookies(), isTrue);
    });
  });

  group('OhosProxyController', () {
    const channel =
        MethodChannel('com.pichillilorenzo/flutter_inappwebview_proxycontroller');

    setUp(() {
      setMockMethodChannelHandler(channel, (call) async {
        switch (call.method) {
          case 'setProxyOverride':
          case 'clearProxyOverride':
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
          OhosProxyController.instance(),
          OhosProxyController.instance(),
        ),
        isTrue,
      );
    });

    test('setProxyOverride and clearProxyOverride should complete', () async {
      final controller = OhosProxyController.instance();
      await expectLater(
        controller.setProxyOverride(
          settings: ProxySettings(bypassRules: ['localhost']),
        ),
        completes,
      );
      await expectLater(controller.clearProxyOverride(), completes);
    });
  });

  group('OhosTracingController', () {
    const channel =
        MethodChannel('com.pichillilorenzo/flutter_inappwebview_tracingcontroller');

    setUp(() {
      setMockMethodChannelHandler(channel, (call) async {
        switch (call.method) {
          case 'start':
            return null;
          case 'stop':
            return true;
          case 'isTracing':
            return false;
        }
        return null;
      });
    });

    tearDown(() {
      setMockMethodChannelHandler(channel, null);
    });

    test('start, stop, and isTracing should delegate to channel', () async {
      final controller = OhosTracingController.instance();
      await controller.start(
        settings: TracingSettings(categories: ['blink']),
      );
      expect(await controller.isTracing(), isFalse);
      expect(await controller.stop(), isTrue);
    });
  });

  group('OhosPullToRefreshController', () {
    test('method channel methods should delegate after init', () async {
      var refreshed = false;
      final controller = OhosPullToRefreshController(
        OhosPullToRefreshControllerCreationParams(
          settings: PullToRefreshSettings(enabled: true),
          onRefresh: () {
            refreshed = true;
          },
        ),
      );
      controller.init(1);

      final channel = MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_pull_to_refresh_1',
      );
      setMockMethodChannelHandler(channel, (call) async {
        switch (call.method) {
          case 'setEnabled':
            return null;
          case 'isEnabled':
            return true;
          case 'setRefreshing':
            return null;
          case 'isRefreshing':
            return false;
          case 'setColor':
          case 'setBackgroundColor':
          case 'setDistanceToTriggerSync':
          case 'setSlingshotDistance':
          case 'setSize':
            return null;
          case 'getDefaultSlingshotDistance':
            return 64;
        }
        return null;
      });

      await controller.setEnabled(true);
      expect(await controller.isEnabled(), isTrue);
      await controller.beginRefreshing();
      expect(await controller.isRefreshing(), isFalse);
      await controller.endRefreshing();

      await controller.setColor(const Color(0xFF0000FF));
      await controller.setBackgroundColor(const Color(0xFFFFFFFF));
      await controller.setDistanceToTriggerSync(120);
      await controller.setSlingshotDistance(80);
      expect(await controller.getDefaultSlingshotDistance(), 64);
      await controller.setIndicatorSize(PullToRefreshSize.DEFAULT);

      await sendPlatformMethodCall(channel, const MethodCall('onRefresh'));
      expect(refreshed, isTrue);

      setMockMethodChannelHandler(channel, null);
    });
  });

  group('OhosFindInteractionController', () {
    test('onFindResultReceived should invoke callback', () async {
      PlatformFindInteractionController? callbackController;
      var activeMatchOrdinal = -1;

      final controller = OhosFindInteractionController(
        OhosFindInteractionControllerCreationParams(
          onFindResultReceived: (ctrl, ordinal, numberOfMatches, isDone) {
            callbackController = ctrl;
            activeMatchOrdinal = ordinal;
          },
        ),
      );
      controller.init(7);

      final channel = MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_find_interaction_7',
      );
      setMockMethodChannelHandler(channel, (call) async {
        switch (call.method) {
          case 'setSearchText':
          case 'getSearchText':
            return 'test';
          case 'findAll':
          case 'findNext':
          case 'clearMatches':
            return null;
          case 'getActiveFindSession':
            return {
              'highlightedResultIndex': 1,
              'resultCount': 3,
              'searchResultDisplayStyle':
                  SearchResultDisplayStyle.TOTAL.toNativeValue(),
            };
        }
        return null;
      });

      await controller.setSearchText('test');
      expect(await controller.getSearchText(), 'test');
      await controller.findAll(find: 'test');
      await controller.findNext(forward: true);
      await controller.clearMatches();
      final session = await controller.getActiveFindSession();
      expect(session?.resultCount, 3);
      expect(session?.highlightedResultIndex, 1);

      await sendPlatformMethodCall(
        channel,
        MethodCall('onFindResultReceived', {
          'activeMatchOrdinal': 2,
          'numberOfMatches': 5,
          'isDoneCounting': true,
        }),
      );

      expect(callbackController, isNotNull);
      expect(activeMatchOrdinal, 2);

      setMockMethodChannelHandler(channel, null);
    });
  });

  group('OhosPrintJobController', () {
    test('cancel, restart, getInfo, and dispose should delegate to channel',
        () async {
      final controller = OhosPrintJobController(
        const PlatformPrintJobControllerCreationParams(id: 'job-42'),
      );

      final channel = MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_printjobcontroller_job-42',
      );
      setMockMethodChannelHandler(channel, (call) async {
        switch (call.method) {
          case 'cancel':
          case 'restart':
          case 'dispose':
            return null;
          case 'getInfo':
            return {'state': PrintJobState.COMPLETED.toNativeValue()};
        }
        return null;
      });

      await expectLater(controller.cancel(), completes);
      await expectLater(controller.restart(), completes);
      final info = await controller.getInfo();
      expect(info?.state, PrintJobState.COMPLETED);
      await expectLater(controller.dispose(), completes);

      setMockMethodChannelHandler(channel, null);
    });
  });
}
