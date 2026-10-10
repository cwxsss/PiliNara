import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Additional exported models', () {
    test('WebViewAssetLoader and path handler creation params', () {
      final assetsParams = PlatformAssetsPathHandlerCreationParams(
        PlatformPathHandlerCreationParams(path: '/assets/'),
      );
      expect(assetsParams.path, '/assets/');

      final resourcesParams = PlatformResourcesPathHandlerCreationParams(
        PlatformPathHandlerCreationParams(path: '/res/'),
      );
      expect(resourcesParams.path, '/res/');

      final internalParams = PlatformInternalStoragePathHandlerCreationParams(
        PlatformPathHandlerCreationParams(path: '/files/'),
        directory: 'documents',
      );
      expect(internalParams.directory, 'documents');

      final customParams = PlatformCustomPathHandlerCreationParams(
        PlatformPathHandlerCreationParams(path: '/custom/'),
      );
      expect(customParams.path, '/custom/');

      final loader = WebViewAssetLoader(
        domain: 'appassets.androidplatform.net',
        pathHandlers: const [],
      );
      expect(loader.toMap()['domain'], 'appassets.androidplatform.net');
      expect(WebViewAssetLoader.fromMap(null), isNull);
    });

    test('InAppBrowser and ChromeSafari settings serialize', () {
      final browserSettings = InAppBrowserSettings(hidden: true);
      expect(browserSettings.toMap()['hidden'], isTrue);
      expect(InAppBrowserSettings.fromMap(null), isNull);

      final chromeSettings = ChromeSafariBrowserSettings();
      expect(chromeSettings.toMap(), isA<Map>());
      expect(ChromeSafariBrowserSettings.fromMap(null), isNull);
    });

    test('NavigationType SslErrorType ContentBlockerActionType constants', () {
      expect(NavigationType.LINK_ACTIVATED.toValue(), isNotNull);
      expect(NavigationType.fromValue(NavigationType.LINK_ACTIVATED.toValue()),
          NavigationType.LINK_ACTIVATED);
      expect(SslErrorType.INVALID.toValue(), isNotNull);
      expect(ContentBlockerActionType.BLOCK.toValue(), isNotNull);
      expect(WindowStyleMask.TITLED.toValue(), isNotNull);
      expect(PermissionResourceType.CAMERA.toValue(), isNotNull);
    });

    test('InAppLocalhostServer creation params', () {
      const params = PlatformInAppLocalhostServerCreationParams();
      expect(params, isNotNull);
    });
  });
}
