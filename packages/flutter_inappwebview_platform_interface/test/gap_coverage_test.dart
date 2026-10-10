// ignore_for_file: deprecated_member_use

import 'dart:typed_data';
import 'dart:ui' show Color, Size;

import 'package:flutter/painting.dart' show EdgeInsets;
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class _DisposableStub implements Disposable {
  bool disposed = false;

  @override
  void dispose() {
    disposed = true;
  }
}

void main() {
  group('Previously uncovered models and helpers', () {
    test('IdGenerator Disposable ASN1IdentifierClass', () {
      final a = IdGenerator.generate();
      final b = IdGenerator.generate();
      expect(a, isNot(equals(b)));

      final disposable = _DisposableStub();
      disposable.dispose();
      expect(disposable.disposed, isTrue);

      expect(ASN1IdentifierClass.UNIVERSAL.toValue(), 0x00);
      expect(ASN1IdentifierClass.APPLICATION.toString(), 'APPLICATION');
      expect(ASN1IdentifierTagNumber.BOOLEAN.toValue(), 0x01);
    });

    test('AndroidWebViewFeature constants', () {
      expect(AndroidWebViewFeature.CREATE_WEB_MESSAGE_CHANNEL.toValue(),
          isNotEmpty);
      expect(
        AndroidWebViewFeature.fromNativeValue(
          AndroidWebViewFeature.CREATE_WEB_MESSAGE_CHANNEL.toNativeValue(),
        ),
        isNotNull,
      );
    });

    test('challenge and window action models', () {
      final space = URLProtectionSpace(
        host: 'example.com',
        protocol: 'https',
        realm: 'r',
        port: 443,
      );
      final client = ClientCertChallenge(protectionSpace: space);
      expect(client.protectionSpace.host, 'example.com');
      expect(ClientCertChallenge.fromMap(null), isNull);

      final http = HttpAuthenticationChallenge(
        protectionSpace: space,
        previousFailureCount: 1,
      );
      expect(http.previousFailureCount, 1);
      expect(HttpAuthenticationChallenge.fromMap(null), isNull);

      final trust = ServerTrustChallenge(protectionSpace: space);
      expect(trust.protectionSpace.port, 443);
      expect(ServerTrustChallenge.fromMap(null), isNull);

      final create = CreateWindowAction(
        windowId: 7,
        request: URLRequest(url: WebUri('https://example.com')),
        isForMainFrame: true,
      );
      expect(create.windowId, 7);
      expect(create.toMap()['windowId'], 7);
      expect(CreateWindowAction.fromMap(null), isNull);
    });

    test('FetchRequest credential variants', () {
      final def = FetchRequestCredentialDefault(value: 'token', type: 'token');
      expect(def.toMap()['value'], 'token');
      expect(FetchRequestCredentialDefault.fromMap(null), isNull);

      final federated = FetchRequestFederatedCredential(
        id: 'user@example.com',
        name: 'user',
        protocol: 'openid',
        provider: 'https://idp.example.com',
        iconURL: WebUri('https://idp.example.com/icon.png'),
      );
      expect(federated.toMap()['name'], 'user');
      expect(FetchRequestFederatedCredential.fromMap(null), isNull);

      final password = FetchRequestPasswordCredential(
        id: 'user',
        name: 'user',
        password: 'secret',
        iconURL: WebUri('https://example.com/icon.png'),
      );
      expect(password.toMap()['password'], 'secret');
      expect(FetchRequestPasswordCredential.fromMap(null), isNull);
    });

    test('PrintJobAttributes MediaSize ProcessGlobal directory paths', () {
      final attributes = PrintJobAttributes();
      expect(attributes.toMap(), isA<Map>());
      expect(PrintJobAttributes.fromMap(null), isNull);

      expect(PrintJobMediaSize.ISO_A4.id, 'ISO_A4');
      expect(PrintJobMediaSize.ISO_A4.toMap()['widthMils'], 8270);
      expect(PrintJobMediaSize.fromMap(null), isNull);

      final paths = ProcessGlobalConfigDirectoryBasePaths(
        cacheDirectoryBasePath: '/cache',
        dataDirectoryBasePath: '/data',
      );
      expect(paths.toMap()['cacheDirectoryBasePath'], '/cache');
      expect(ProcessGlobalConfigDirectoryBasePaths.fromMap(null), isNull);
    });

    test('TrustedWebActivity display modes and orientation', () {
      final def = TrustedWebActivityDefaultDisplayMode();
      expect(def.toMap(), isA<Map>());

      final immersive = TrustedWebActivityImmersiveDisplayMode(
        isSticky: true,
        displayCutoutMode: LayoutInDisplayCutoutMode.DEFAULT,
      );
      expect(immersive.toMap()['isSticky'], isTrue);
      expect(TrustedWebActivityImmersiveDisplayMode.fromMap(null), isNull);

      expect(
        TrustedWebActivityScreenOrientation.PORTRAIT.toValue(),
        isNotNull,
      );
      expect(
        TrustedWebActivityDefaultDisplayMode()
            is TrustedWebActivityDisplayMode,
        isTrue,
      );
    });

    test('ContextMenuOptions and InAppWebView options groups', () {
      final options =
          ContextMenuOptions(hideDefaultSystemContextMenuItems: true);
      expect(options.hideDefaultSystemContextMenuItems, isTrue);
      expect(options.toMap()['hideDefaultSystemContextMenuItems'], isTrue);

      final group = InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(javaScriptEnabled: true),
      );
      expect(group.crossPlatform?.javaScriptEnabled, isTrue);
      expect(
        InAppWebViewGroupOptions.fromMap(group.toMap()),
        isA<InAppWebViewGroupOptions>(),
      );

      final webOptions = InAppWebViewOptions(javaScriptEnabled: false);
      expect(webOptions.toMap()['javaScriptEnabled'], isFalse);
      expect(webOptions is WebViewOptions, isTrue);
    });

    test('iOS/Android alias models and website data type', () {
      final frame = IOSWKFrameInfo(isMainFrame: true);
      expect(frame.toMap()['isMainFrame'], isTrue);
      expect(IOSWKFrameInfo.fromMap(null), isNull);

      final response = IOSURLResponse(
        url: WebUri('https://example.com'),
        mimeType: 'text/html',
        expectedContentLength: 1,
        textEncodingName: 'utf-8',
      );
      expect(response.toMap()['mimeType'], 'text/html');
      expect(IOSURLResponse.fromMap(null), isNull);

      final nav = IOSWKNavigationResponse(
        response: response,
        isForMainFrame: true,
        canShowMIMEType: true,
      );
      expect(nav.toMap()['isForMainFrame'], isTrue);
      expect(IOSWKNavigationResponse.fromMap(null), isNull);

      final origin = IOSWKSecurityOrigin(
        host: 'example.com',
        port: 443,
        protocol: 'https',
      );
      expect(origin.toMap()['host'], 'example.com');
      expect(IOSWKSecurityOrigin.fromMap(null), isNull);

      expect(
        IOSWKWebsiteDataType.WKWebsiteDataTypeLocalStorage.toValue(),
        isNotNull,
      );
    });

    test('X509 extension subclasses', () {
      final oid = ASN1Object()..value = OID.subjectKeyIdentifier.toValue();
      final value =
          ASN1Object()..encoded = Uint8List.fromList([0x04, 0x01, 0xab]);
      final block = ASN1Object()..sub = [oid, value];

      expect(SubjectKeyIdentifierExtension(block: block).toMap(), isA<Map>());
      expect(AuthorityKeyIdentifierExtension(block: block).toMap(), isA<Map>());
      expect(AuthorityInfoAccessExtension(block: block).toMap(), isA<Map>());
      expect(CertificatePoliciesExtension(block: block).toMap(), isA<Map>());
      expect(CRLDistributionPointsExtension(block: block).toMap(), isA<Map>());
    });

    test('Platform event types and WebView creation params', () {
      const params = PlatformWebViewCreationParams();
      expect(params, isNotNull);
      // Ensure event contracts remain exported/importable.
      void useEvents(
        PlatformInAppBrowserEvents browserEvents,
        PlatformChromeSafariBrowserEvents chromeEvents,
      ) {}
      expect(useEvents, isA<Function>());
    });

    test('deprecated Options shells serialize defaults', () {
      expect(AndroidOptions(), isA<AndroidOptions>());
      expect(IosOptions(), isA<IosOptions>());
      expect(BrowserOptions().toMap(), isEmpty);
      expect(ChromeSafariBrowserOptions().toMap(), isEmpty);

      final androidWeb = AndroidInAppWebViewOptions(textZoom: 120);
      expect(androidWeb.toMap()['textZoom'], 120);
      expect(androidWeb, isA<AndroidOptions>());

      final iosWeb = IOSInAppWebViewOptions(disallowOverScroll: true);
      expect(iosWeb.toMap()['disallowOverScroll'], isTrue);
      expect(iosWeb, isA<IosOptions>());

      final browser = InAppBrowserOptions(hidden: true, hideUrlBar: true);
      expect(browser.toMap()['hidden'], isTrue);
      expect(InAppBrowserOptions.fromMap(browser.toMap()).hideUrlBar, isTrue);

      final androidBrowser =
          AndroidInAppBrowserOptions(hideTitleBar: true, toolbarTopFixedTitle: 'T');
      expect(androidBrowser.toMap()['hideTitleBar'], isTrue);
      expect(androidBrowser, isA<BrowserOptions>());

      final iosBrowser = IOSInAppBrowserOptions(hideToolbarBottom: true);
      expect(iosBrowser.toMap()['hideToolbarBottom'], isTrue);
      expect(iosBrowser, isA<IosOptions>());

      final androidTabs = AndroidChromeCustomTabsOptions(showTitle: false);
      expect(androidTabs.toMap()['showTitle'], isFalse);
      expect(androidTabs, isA<ChromeSafariBrowserOptions>());

      final iosSafari = IOSSafariOptions(entersReaderIfAvailable: true);
      expect(iosSafari.toMap()['entersReaderIfAvailable'], isTrue);
      expect(iosSafari, isA<ChromeSafariBrowserOptions>());

      final pull = PullToRefreshOptions(enabled: false, color: const Color(0xFF112233));
      expect(pull.toMap()['enabled'], isFalse);
      expect(pull.toMap()['color'], isNotNull);
    });

    test('ASN1 errors CertificatePolicy and SecondaryToolbarClickableID', () {
      expect(ASN1OutOfBufferError(), isA<Error>());
      expect(ASN1ParseError(), isA<Error>());
      expect(
        () => ASN1DERDecoder.decode(data: <int>[0x30, 0x05, 0x01]),
        throwsA(isA<ASN1OutOfBufferError>()),
      );

      final qualifier = CertificatePolicyQualifier(oid: '1.2.3', value: 'q');
      expect(qualifier.toMap()['oid'], '1.2.3');
      expect(qualifier.toJson()['value'], 'q');

      final policy = CertificatePolicy(
        oid: '2.5.29.32',
        qualifiers: [qualifier],
      );
      expect(policy.toMap()['oid'], '2.5.29.32');
      expect((policy.toMap()['qualifiers'] as List).first['oid'], '1.2.3');

      final clickable = ChromeSafariBrowserSecondaryToolbarClickableID(
        id: AndroidResource.id(name: 'action_button'),
      );
      expect(clickable.toMap()['id'], isA<Map>());
      expect(
        ChromeSafariBrowserSecondaryToolbarClickableID.fromMap(null),
        isNull,
      );
    });

    test('UtilColor HexColor MapSize MapEdgeInsets helpers', () {
      final color = UtilColor.fromHex('#FF112233');
      expect(color, isNotNull);
      expect(color!.toHex(leadingHashSign: true), contains('112233'));
      expect(UtilColor.fromStringRepresentation('red'), isNotNull);

      final size = const Size(10, 20);
      expect(size.toMap()['width'], 10);
      expect(MapSize.fromMap({'width': 3, 'height': 4})!.height, 4);
      expect(MapSize.fromMap(null), isNull);

      final insets = const EdgeInsets.fromLTRB(1, 2, 3, 4);
      expect(insets.toMap()['left'], 1);
      expect(
        MapEdgeInsets.fromMap(
          {'left': 1.0, 'top': 2.0, 'right': 3.0, 'bottom': 4.0},
        )!.top,
        2,
      );
      expect(MapEdgeInsets.fromMap(null), isNull);
    });
  });
}
