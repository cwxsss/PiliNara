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

import 'package:flutter_inappwebview_ohos/src/find_interaction/find_interaction_controller.dart';
import 'package:flutter_inappwebview_ohos/src/in_app_webview/in_app_webview.dart';
import 'package:flutter_inappwebview_ohos/src/inappwebview_platform.dart';
import 'package:flutter_inappwebview_ohos/src/pull_to_refresh/pull_to_refresh_controller.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OhosInAppWebViewWidget ohosParams', () {
    test('should expose OhosInAppWebViewWidgetCreationParams as widget params',
        () {
      final findController = OhosFindInteractionController(
        const OhosFindInteractionControllerCreationParams(),
      );
      final pullController = OhosPullToRefreshController(
        OhosPullToRefreshControllerCreationParams(
          settings: PullToRefreshSettings(enabled: true),
          onRefresh: () {},
        ),
      );
      final ohosParams = OhosInAppWebViewWidgetCreationParams(
        findInteractionController: findController,
        pullToRefreshController: pullController,
        initialSettings: InAppWebViewSettings(javaScriptEnabled: true),
      );

      final widget = OhosInAppWebViewWidget(ohosParams);

      expect(widget.params, isA<OhosInAppWebViewWidgetCreationParams>());
      final exposedParams = widget.params as OhosInAppWebViewWidgetCreationParams;
      expect(exposedParams.findInteractionController, same(findController));
      expect(exposedParams.pullToRefreshController, same(pullController));
      expect(exposedParams.initialSettings?.javaScriptEnabled, isTrue);
    });

    test('should convert generic platform params into ohos params', () {
      final findController = OhosFindInteractionController(
        const OhosFindInteractionControllerCreationParams(),
      );
      final pullController = OhosPullToRefreshController(
        OhosPullToRefreshControllerCreationParams(
          settings: PullToRefreshSettings(enabled: false),
          onRefresh: () {},
        ),
      );

      final widget = OhosInAppWebViewWidget(
        PlatformInAppWebViewWidgetCreationParams(
          findInteractionController: findController,
          pullToRefreshController: pullController,
          initialUrlRequest: URLRequest(url: WebUri('https://example.com')),
        ),
      );

      expect(widget.params, isA<OhosInAppWebViewWidgetCreationParams>());
      final ohosParams = widget.params as OhosInAppWebViewWidgetCreationParams;
      expect(ohosParams.findInteractionController, same(findController));
      expect(ohosParams.pullToRefreshController, same(pullController));
      expect(
        ohosParams.initialUrlRequest?.url?.rawValue,
        'https://example.com',
      );
    });

    test('platform factory should create widget with ohos params', () {
      OhosInAppWebViewPlatform.registerWith();
      final platform = OhosInAppWebViewPlatform();
      final ohosParams = OhosInAppWebViewWidgetCreationParams(
        initialSettings: InAppWebViewSettings(useHybridComposition: false),
      );

      final widget = platform.createPlatformInAppWebViewWidget(ohosParams);

      expect(widget, isA<OhosInAppWebViewWidget>());
      expect(widget.params, isA<OhosInAppWebViewWidgetCreationParams>());
      expect(
        (widget.params as OhosInAppWebViewWidgetCreationParams)
            .initialSettings
            ?.useHybridComposition,
        isFalse,
      );
    });
  });
}
