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

class _TestPathHandlerEvents extends PlatformPathHandlerEvents {
  var handledPath = '';

  @override
  Future<WebResourceResponse?> handle(String path) async {
    handledPath = path;
    return WebResourceResponse(
      contentType: 'text/plain',
      data: Uint8List.fromList([1, 2, 3]),
    );
  }
}

void main() {
  ensureTestBindings();

  setUp(() {
    OhosInAppWebViewPlatform.registerWith();
  });

  group('Ohos path handlers', () {
    late OhosInAppWebViewPlatform platform;

    setUp(() {
      platform = OhosInAppWebViewPlatform();
    });

    test('AssetsPathHandler should expose path and type', () {
      final handler = platform.createPlatformAssetsPathHandler(
        PlatformAssetsPathHandlerCreationParams(
          PlatformPathHandlerCreationParams(path: '/assets/'),
        ),
      );
      expect(handler.path, '/assets/');
      expect(handler.type, 'AssetsPathHandler');
      expect(handler.toMap()['type'], 'AssetsPathHandler');
    });

    test('ResourcesPathHandler should expose path and type', () {
      final handler = platform.createPlatformResourcesPathHandler(
        PlatformResourcesPathHandlerCreationParams(
          PlatformPathHandlerCreationParams(path: '/res/'),
        ),
      );
      expect(handler.path, '/res/');
      expect(handler.type, 'ResourcesPathHandler');
    });

    test('InternalStoragePathHandler should expose path, type, and directory',
        () {
      final handler = platform.createPlatformInternalStoragePathHandler(
        PlatformInternalStoragePathHandlerCreationParams(
          PlatformPathHandlerCreationParams(path: '/internal/'),
          directory: 'files',
        ),
      );
      expect(handler.path, '/internal/');
      expect(handler.type, 'InternalStoragePathHandler');
      expect(handler.directory, 'files');
    });

    test('CustomPathHandler should expose path and type', () {
      final handler = platform.createPlatformCustomPathHandler(
        PlatformCustomPathHandlerCreationParams(
          PlatformPathHandlerCreationParams(path: '/custom/'),
        ),
      );
      expect(handler.path, '/custom/');
      expect(handler.type, 'CustomPathHandler');
    });

    test('CustomPathHandler handle should invoke eventHandler', () async {
      final events = _TestPathHandlerEvents();
      final handler = platform.createPlatformCustomPathHandler(
        PlatformCustomPathHandlerCreationParams(
          PlatformPathHandlerCreationParams(path: '/custom/'),
        ),
      ) as OhosCustomPathHandler;

      handler.eventHandler = events;
      final handlerId = handler.toMap()['id'] as String;
      final channel = MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_custompathhandler_$handlerId',
      );

      await sendPlatformMethodCall(
        channel,
        MethodCall('handle', {'path': '/custom/index.html'}),
      );
      expect(events.handledPath, '/custom/index.html');
    });

    test('AssetsPathHandler dispose should clear channel handler', () {
      final handler = platform.createPlatformAssetsPathHandler(
        PlatformAssetsPathHandlerCreationParams(
          PlatformPathHandlerCreationParams(path: '/assets/'),
        ),
      ) as OhosAssetsPathHandler;

      final handlerId = handler.toMap()['id'] as String;
      final channel = MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_custompathhandler_$handlerId',
      );
      setMockMethodChannelHandler(channel, (_) async => null);

      handler.dispose();
      setMockMethodChannelHandler(channel, null);
    });
  });
}
