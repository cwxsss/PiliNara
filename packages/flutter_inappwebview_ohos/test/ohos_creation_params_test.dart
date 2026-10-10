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

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_inappwebview_ohos/src/in_app_webview/in_app_webview.dart';
import 'package:flutter_inappwebview_ohos/src/find_interaction/find_interaction_controller.dart';
import 'package:flutter_inappwebview_ohos/src/pull_to_refresh/pull_to_refresh_controller.dart';

void main() {
  group('OhosInAppWebViewWidgetCreationParams', () {
    test('should accept findInteractionController and pullToRefreshController',
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

      final params = OhosInAppWebViewWidgetCreationParams(
        findInteractionController: findController,
        pullToRefreshController: pullController,
      );

      expect(params.findInteractionController, same(findController));
      expect(params.pullToRefreshController, same(pullController));
    });

    test('should construct with default optional controllers', () {
      final params = OhosInAppWebViewWidgetCreationParams();
      expect(params.findInteractionController, isNull);
      expect(params.pullToRefreshController, isNull);
    });

    test('fromPlatformInAppWebViewWidgetCreationParams should copy controllers',
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

      final params =
          OhosInAppWebViewWidgetCreationParams.fromPlatformInAppWebViewWidgetCreationParams(
        PlatformInAppWebViewWidgetCreationParams(
          findInteractionController: findController,
          pullToRefreshController: pullController,
        ),
      );

      expect(params.findInteractionController, same(findController));
      expect(params.pullToRefreshController, same(pullController));
    });
  });
}
