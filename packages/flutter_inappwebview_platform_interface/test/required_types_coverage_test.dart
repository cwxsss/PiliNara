import 'dart:typed_data';

import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Required-arg ExchangeableObject coverage', () {
    test('Cookie toMap/fromMap round-trip', () {
      final cookie = Cookie(name: 'sid', value: 'abc', path: '/');
      expect(cookie.toMap()['name'], 'sid');
      expect(Cookie.fromMap(null), isNull);
      final restored = Cookie.fromMap({
        'name': 'sid',
        'value': 'abc',
        'path': '/',
      });
      expect(restored?.name, 'sid');
    });

    test('UserScript toMap/fromMap round-trip', () {
      final script = UserScript(
        source: '1+1',
        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
      );
      expect(script.toMap()['source'], '1+1');
      expect(UserScript.fromMap(null), isNull);
    });

    test('WebResourceRequest and WebResourceError expose fields', () {
      final request = WebResourceRequest(url: WebUri('https://example.com'));
      expect(request.url.rawValue, 'https://example.com');
      expect(request.toMap()['url'], isNotNull);
      expect(WebResourceRequest.fromMap(null), isNull);

      final error = WebResourceError(
        description: 'failed',
        type: WebResourceErrorType.HOST_LOOKUP,
      );
      expect(error.description, 'failed');
      expect(error.toMap()['description'], 'failed');
      expect(WebResourceError.fromMap(null), isNull);
    });

    test('NavigationAction requires request and isForMainFrame', () {
      final action = NavigationAction(
        request: URLRequest(url: WebUri('https://example.com')),
        isForMainFrame: true,
      );
      expect(action.isForMainFrame, isTrue);
      expect(action.toMap()['isForMainFrame'], isTrue);
      expect(NavigationAction.fromMap(null), isNull);
    });

    test('ClientCertResponse Cookie helpers and related models', () {
      final response = ClientCertResponse(
        certificatePath: '/tmp/cert.p12',
        action: ClientCertResponseAction.PROCEED,
      );
      expect(response.toMap()['certificatePath'], '/tmp/cert.p12');
      expect(ClientCertResponse.fromMap(null), isNull);
    });

    test('Favicon DownloadStartRequest LoginRequest models', () {
      final favicon = Favicon(url: WebUri('https://example.com/favicon.ico'));
      expect(favicon.toMap()['url'], isNotNull);
      expect(Favicon.fromMap(null), isNull);

      final download = DownloadStartRequest(
        url: WebUri('https://example.com/a.bin'),
        contentLength: 10,
        mimeType: 'application/octet-stream',
        contentDisposition: 'attachment',
        userAgent: 'ua',
      );
      expect(download.toMap()['contentLength'], 10);
      expect(DownloadStartRequest.fromMap(null), isNull);

      final login = LoginRequest(
        realm: 'realm',
        account: 'user',
        args: 'args',
      );
      expect(login.toMap()['realm'], 'realm');
      expect(LoginRequest.fromMap(null), isNull);
    });

    test('PermissionRequest FindSession FrameInfo models', () {
      final permission = PermissionRequest(
        origin: WebUri('https://example.com'),
        resources: [PermissionResourceType.CAMERA],
      );
      expect(permission.toMap()['resources'], isNotEmpty);
      expect(PermissionRequest.fromMap(null), isNull);

      final session = FindSession(
        resultCount: 3,
        highlightedResultIndex: 1,
        searchResultDisplayStyle: SearchResultDisplayStyle.NONE,
      );
      expect(session.toMap()['resultCount'], 3);
      expect(FindSession.fromMap(null), isNull);

      final frame = FrameInfo(isMainFrame: true);
      expect(frame.toMap()['isMainFrame'], isTrue);
      expect(FrameInfo.fromMap(null), isNull);
    });

    test('URLResponse SecurityOrigin ProxyRule models', () {
      final response = URLResponse(
        url: WebUri('https://example.com'),
        mimeType: 'text/html',
        expectedContentLength: 1,
        textEncodingName: 'utf-8',
      );
      expect(response.toMap()['mimeType'], 'text/html');
      expect(URLResponse.fromMap(null), isNull);

      final origin = SecurityOrigin(
        host: 'example.com',
        port: 443,
        protocol: 'https',
      );
      expect(origin.toMap()['host'], 'example.com');
      expect(SecurityOrigin.fromMap(null), isNull);

      final rule = ProxyRule(
        url: 'proxy.example.com',
        schemeFilter: ProxySchemeFilter.MATCH_HTTPS,
      );
      expect(rule.toMap()['url'], 'proxy.example.com');
      expect(ProxyRule.fromMap(null), isNull);
    });

    test('InAppWebViewInitialData InAppWebViewRect models', () {
      final data = InAppWebViewInitialData(data: '<html></html>');
      expect(data.toMap()['data'], '<html></html>');
      expect(InAppWebViewInitialData.fromMap(null), isNull);

      final rect = InAppWebViewRect(x: 1, y: 2, width: 3, height: 4);
      expect(rect.toMap()['width'], 3);
      expect(InAppWebViewRect.fromMap(null), isNull);
    });

    test('GeolocationPermissionShowPromptResponse PrewarmingToken models', () {
      final geo = GeolocationPermissionShowPromptResponse(
        origin: 'https://example.com',
        allow: true,
        retain: false,
      );
      expect(geo.toMap()['allow'], isTrue);
      expect(GeolocationPermissionShowPromptResponse.fromMap(null), isNull);

      final token = PrewarmingToken(id: 'token-1');
      expect(token.toMap()['id'], 'token-1');
      expect(PrewarmingToken.fromMap(null), isNull);
    });

    test('CustomSchemeResponse CustomSchemeRegistration models', () {
      final scheme = CustomSchemeResponse(
        data: Uint8List.fromList([1, 2]),
        contentType: 'text/plain',
      );
      expect(scheme.toMap()['contentType'], 'text/plain');
      expect(CustomSchemeResponse.fromMap(null), isNull);

      final registration = CustomSchemeRegistration(scheme: 'my-scheme');
      expect(registration.toMap()['scheme'], 'my-scheme');
      expect(CustomSchemeRegistration.fromMap(null), isNull);
    });

    test('RenderProcessGoneDetail RendererPriorityPolicy models', () {
      final gone = RenderProcessGoneDetail(didCrash: true);
      expect(gone.toMap()['didCrash'], isTrue);
      expect(RenderProcessGoneDetail.fromMap(null), isNull);

      final policy = RendererPriorityPolicy(
        rendererRequestedPriority: RendererPriority.RENDERER_PRIORITY_IMPORTANT,
        waivedWhenNotVisible: true,
      );
      expect(policy.toMap()['waivedWhenNotVisible'], isTrue);
      expect(RendererPriorityPolicy.fromMap(null), isNull);
    });

    test('PrintJobResolution AndroidResource ActivityButton models', () {
      final resolution = PrintJobResolution(
        id: 'res',
        label: 'Label',
        verticalDpi: 300,
        horizontalDpi: 300,
      );
      expect(resolution.toMap()['verticalDpi'], 300);
      expect(PrintJobResolution.fromMap(null), isNull);

      final resource = AndroidResource(name: 'icon');
      expect(resource.toMap()['name'], 'icon');
      expect(AndroidResource.fromMap(null), isNull);

      final button = ActivityButton(
        templateImage: UIImage(name: 'share'),
        extensionIdentifier: 'com.example.share',
      );
      expect(button.toMap()['templateImage'], isNotNull);
      expect(ActivityButton.fromMap(null), isNull);
    });

    test('UIEventAttribution URLAuthenticationChallenge AjaxRequestHeaders', () {
      final attribution = UIEventAttribution(
        sourceIdentifier: 1,
        destinationURL: WebUri('https://example.com'),
        sourceDescription: 'desc',
        purchaser: 'buyer',
      );
      expect(attribution.toMap()['sourceIdentifier'], 1);
      expect(UIEventAttribution.fromMap(null), isNull);

      final challenge = URLAuthenticationChallenge(
        protectionSpace: URLProtectionSpace(
          host: 'example.com',
          protocol: 'https',
          realm: null,
          port: 443,
        ),
      );
      expect(challenge.toMap()['protectionSpace'], isNotNull);
      expect(URLAuthenticationChallenge.fromMap(null), isNull);

      final headers = AjaxRequestHeaders({'A': '1'});
      expect(headers.getHeaders()['A'], '1');
      headers.setRequestHeader('B', '2');
      expect(headers.toMap()['B'], '2');
      expect(AjaxRequestHeaders.fromMap(null), isNull);
    });

    test('NavigationResponse models', () {
      final response = NavigationResponse(
        response: URLResponse(
          url: WebUri('https://example.com'),
          mimeType: 'text/html',
          expectedContentLength: 1,
          textEncodingName: 'utf-8',
        ),
        isForMainFrame: true,
        canShowMIMEType: true,
      );
      expect(response.toMap()['isForMainFrame'], isTrue);
      expect(NavigationResponse.fromMap(null), isNull);
    });
  });
}
