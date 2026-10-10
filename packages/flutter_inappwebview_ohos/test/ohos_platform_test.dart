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

import 'package:flutter_inappwebview_ohos/flutter_inappwebview_ohos.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_bindings.dart';

void main() {
  ensureTestBindings();

  group('OhosInAppWebViewPlatform', () {
    late OhosInAppWebViewPlatform platform;

    setUp(() {
      platform = OhosInAppWebViewPlatform();
      InAppWebViewPlatform.instance = platform;
    });

    test('registerWith should set platform instance', () {
      OhosInAppWebViewPlatform.registerWith();
      expect(InAppWebViewPlatform.instance, isA<OhosInAppWebViewPlatform>());
    });

    test('factory methods should create OHOS platform implementations', () {
      expect(
        platform.createPlatformCookieManager(
          const PlatformCookieManagerCreationParams(),
        ),
        isA<OhosCookieManager>(),
      );
      expect(
        platform.createPlatformInAppWebViewController(
          const PlatformInAppWebViewControllerCreationParams(id: 1),
        ),
        isA<OhosInAppWebViewController>(),
      );
      expect(
        platform.createPlatformInAppWebViewControllerStatic(),
        isA<OhosInAppWebViewController>(),
      );
      expect(
        platform.createPlatformInAppWebViewWidget(
          OhosInAppWebViewWidgetCreationParams(),
        ),
        isA<OhosInAppWebViewWidget>(),
      );
      expect(
        platform.createPlatformFindInteractionController(
          const OhosFindInteractionControllerCreationParams(),
        ),
        isA<OhosFindInteractionController>(),
      );
      expect(
        platform.createPlatformPrintJobController(
          const PlatformPrintJobControllerCreationParams(id: 'job-1'),
        ),
        isA<OhosPrintJobController>(),
      );
      expect(
        platform.createPlatformPullToRefreshController(
          OhosPullToRefreshControllerCreationParams(
            settings: PullToRefreshSettings(enabled: true),
            onRefresh: () {},
          ),
        ),
        isA<OhosPullToRefreshController>(),
      );
      expect(
        platform.createPlatformWebMessageChannel(
          PlatformWebMessageChannelCreationParams(
            id: 'ch-1',
            port1: platform.createPlatformWebMessagePort(
              const PlatformWebMessagePortCreationParams(index: 0),
            ),
            port2: platform.createPlatformWebMessagePort(
              const PlatformWebMessagePortCreationParams(index: 1),
            ),
          ),
        ),
        isA<OhosWebMessageChannel>(),
      );
      expect(
        platform.createPlatformWebMessageChannelStatic(),
        isA<OhosWebMessageChannel>(),
      );
      expect(
        platform.createPlatformWebMessageListener(
          const PlatformWebMessageListenerCreationParams(
            jsObjectName: 'testObj',
          ),
        ),
        isA<OhosWebMessageListener>(),
      );
      expect(
        platform.createPlatformWebMessagePort(
          const PlatformWebMessagePortCreationParams(index: 0),
        ),
        isA<OhosWebMessagePort>(),
      );
      expect(
        platform.createPlatformWebStorage(
          PlatformWebStorageCreationParams(
            localStorage: platform.createPlatformLocalStorage(
              PlatformLocalStorageCreationParams(
                PlatformStorageCreationParams(
                  controller: platform.createPlatformInAppWebViewController(
                    const PlatformInAppWebViewControllerCreationParams(id: 2),
                  ),
                  webStorageType: WebStorageType.LOCAL_STORAGE,
                ),
              ),
            ),
            sessionStorage: platform.createPlatformSessionStorage(
              PlatformSessionStorageCreationParams(
                PlatformStorageCreationParams(
                  controller: platform.createPlatformInAppWebViewController(
                    const PlatformInAppWebViewControllerCreationParams(id: 3),
                  ),
                  webStorageType: WebStorageType.SESSION_STORAGE,
                ),
              ),
            ),
          ),
        ),
        isA<OhosWebStorage>(),
      );
      expect(
        platform.createPlatformHeadlessInAppWebView(
          PlatformHeadlessInAppWebViewCreationParams(
            initialSize: const Size(-1, -1),
          ),
        ),
        isA<OhosHeadlessInAppWebView>(),
      );
      expect(
        platform.createPlatformHttpAuthCredentialDatabase(
          const PlatformHttpAuthCredentialDatabaseCreationParams(),
        ),
        isA<OhosHttpAuthCredentialDatabase>(),
      );
      expect(
        platform.createPlatformInAppBrowser(
          const PlatformInAppBrowserCreationParams(),
        ),
        isA<OhosInAppBrowser>(),
      );
      expect(
        platform.createPlatformInAppBrowserStatic(),
        isA<OhosInAppBrowser>(),
      );
      expect(
        platform.createPlatformProcessGlobalConfig(
          const PlatformProcessGlobalConfigCreationParams(),
        ),
        isA<OhosProcessGlobalConfig>(),
      );
      expect(
        platform.createPlatformProxyController(
          const PlatformProxyControllerCreationParams(),
        ),
        isA<OhosProxyController>(),
      );
      expect(
        platform.createPlatformServiceWorkerController(
          const PlatformServiceWorkerControllerCreationParams(),
        ),
        isA<OhosServiceWorkerController>(),
      );
      expect(
        platform.createPlatformServiceWorkerControllerStatic(),
        isA<OhosServiceWorkerController>(),
      );
      expect(
        platform.createPlatformTracingController(
          const PlatformTracingControllerCreationParams(),
        ),
        isA<OhosTracingController>(),
      );
      expect(
        platform.createPlatformAssetsPathHandler(
          PlatformAssetsPathHandlerCreationParams(
            PlatformPathHandlerCreationParams(path: '/assets/'),
          ),
        ),
        isA<OhosAssetsPathHandler>(),
      );
      expect(
        platform.createPlatformResourcesPathHandler(
          PlatformResourcesPathHandlerCreationParams(
            PlatformPathHandlerCreationParams(path: '/res/'),
          ),
        ),
        isA<OhosResourcesPathHandler>(),
      );
      expect(
        platform.createPlatformInternalStoragePathHandler(
          PlatformInternalStoragePathHandlerCreationParams(
            PlatformPathHandlerCreationParams(path: '/internal/'),
            directory: 'files',
          ),
        ),
        isA<OhosInternalStoragePathHandler>(),
      );
      expect(
        platform.createPlatformCustomPathHandler(
          PlatformCustomPathHandlerCreationParams(
            PlatformPathHandlerCreationParams(path: '/custom/'),
          ),
        ),
        isA<OhosCustomPathHandler>(),
      );
      expect(
        platform.createPlatformWebViewFeature(
          const PlatformWebViewFeatureCreationParams(),
        ),
        isA<OhosWebViewFeature>(),
      );
      expect(
        platform.createPlatformWebViewFeatureStatic(),
        isA<OhosWebViewFeature>(),
      );
      expect(
        platform.createPlatformChromeSafariBrowser(
          const PlatformChromeSafariBrowserCreationParams(),
        ),
        isA<OhosChromeSafariBrowser>(),
      );
      expect(
        platform.createPlatformChromeSafariBrowserStatic(),
        isA<OhosChromeSafariBrowser>(),
      );
      expect(
        platform.createPlatformWebStorageManager(
          const PlatformWebStorageManagerCreationParams(),
        ),
        isA<OhosWebStorageManager>(),
      );
    });
  });
}
