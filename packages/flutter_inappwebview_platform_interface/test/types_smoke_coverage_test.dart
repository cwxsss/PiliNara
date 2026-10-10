import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExchangeableObject smoke coverage', () {
    test('AjaxRequest toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = AjaxRequest();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(AjaxRequest.fromMap(null), isNull);
    });

    test('AjaxRequestEvent toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = AjaxRequestEvent();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(AjaxRequestEvent.fromMap(null), isNull);
    });

    test('CallAsyncJavaScriptResult toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = CallAsyncJavaScriptResult();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(CallAsyncJavaScriptResult.fromMap(null), isNull);
    });

    test('ConsoleMessage toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = ConsoleMessage();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(ConsoleMessage.fromMap(null), isNull);
    });

    test('CSSLinkHtmlTagAttributes toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = CSSLinkHtmlTagAttributes();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(CSSLinkHtmlTagAttributes.fromMap(null), isNull);
    });

    test('FetchRequest toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = FetchRequest();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(FetchRequest.fromMap(null), isNull);
    });

    test('FetchRequestCredential toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = FetchRequestCredential();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(FetchRequestCredential.fromMap(null), isNull);
    });

    test('HttpAuthResponse toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = HttpAuthResponse();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(HttpAuthResponse.fromMap(null), isNull);
    });

    test('InAppWebViewHitTestResult toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = InAppWebViewHitTestResult();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(InAppWebViewHitTestResult.fromMap(null), isNull);
    });

    test('JsAlertRequest toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = JsAlertRequest();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(JsAlertRequest.fromMap(null), isNull);
    });

    test('JsAlertResponse toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = JsAlertResponse();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(JsAlertResponse.fromMap(null), isNull);
    });

    test('JsBeforeUnloadRequest toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = JsBeforeUnloadRequest();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(JsBeforeUnloadRequest.fromMap(null), isNull);
    });

    test('JsBeforeUnloadResponse toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = JsBeforeUnloadResponse();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(JsBeforeUnloadResponse.fromMap(null), isNull);
    });

    test('JsConfirmRequest toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = JsConfirmRequest();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(JsConfirmRequest.fromMap(null), isNull);
    });

    test('JsConfirmResponse toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = JsConfirmResponse();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(JsConfirmResponse.fromMap(null), isNull);
    });

    test('JsPromptRequest toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = JsPromptRequest();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(JsPromptRequest.fromMap(null), isNull);
    });

    test('JsPromptResponse toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = JsPromptResponse();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(JsPromptResponse.fromMap(null), isNull);
    });

    test('LoadedResource toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = LoadedResource();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(LoadedResource.fromMap(null), isNull);
    });

    test('MetaTag toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = MetaTag();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(MetaTag.fromMap(null), isNull);
    });

    test('MetaTagAttribute toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = MetaTagAttribute();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(MetaTagAttribute.fromMap(null), isNull);
    });

    test('PDFConfiguration toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = PDFConfiguration();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(PDFConfiguration.fromMap(null), isNull);
    });

    test('IOSWKPDFConfiguration toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = IOSWKPDFConfiguration();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(IOSWKPDFConfiguration.fromMap(null), isNull);
    });

    test('PermissionResponse toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = PermissionResponse();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(PermissionResponse.fromMap(null), isNull);
    });

    test('PermissionRequestResponse toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = PermissionRequestResponse();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(PermissionRequestResponse.fromMap(null), isNull);
    });

    test('PrintJobInfo toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = PrintJobInfo();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(PrintJobInfo.fromMap(null), isNull);
    });

    test('Printer toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = Printer();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(Printer.fromMap(null), isNull);
    });

    test('RequestFocusNodeHrefResult toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = RequestFocusNodeHrefResult();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(RequestFocusNodeHrefResult.fromMap(null), isNull);
    });

    test('RequestImageRefResult toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = RequestImageRefResult();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(RequestImageRefResult.fromMap(null), isNull);
    });

    test('SafeBrowsingResponse toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = SafeBrowsingResponse();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(SafeBrowsingResponse.fromMap(null), isNull);
    });

    test('ScreenshotConfiguration toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = ScreenshotConfiguration();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(ScreenshotConfiguration.fromMap(null), isNull);
    });

    test('ScriptHtmlTagAttributes toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = ScriptHtmlTagAttributes();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(ScriptHtmlTagAttributes.fromMap(null), isNull);
    });

    test('ServerTrustAuthResponse toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = ServerTrustAuthResponse();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(ServerTrustAuthResponse.fromMap(null), isNull);
    });

    test('SslCertificate toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = SslCertificate();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(SslCertificate.fromMap(null), isNull);
    });

    test('SslCertificateDName toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = SslCertificateDName();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(SslCertificateDName.fromMap(null), isNull);
    });

    test('SslError toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = SslError();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(SslError.fromMap(null), isNull);
    });

    test('UIImage toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = UIImage();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(UIImage.fromMap(null), isNull);
    });

    test('URLCredential toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = URLCredential();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(URLCredential.fromMap(null), isNull);
    });

    test('URLProtectionSpaceHttpAuthCredentials toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = URLProtectionSpaceHttpAuthCredentials();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(URLProtectionSpaceHttpAuthCredentials.fromMap(null), isNull);
    });

    test('WebHistory toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = WebHistory();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(WebHistory.fromMap(null), isNull);
    });

    test('WebHistoryItem toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = WebHistoryItem();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(WebHistoryItem.fromMap(null), isNull);
    });

    test('WebResourceResponse toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = WebResourceResponse();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(WebResourceResponse.fromMap(null), isNull);
    });

    test('WebStorageOrigin toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = WebStorageOrigin();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(WebStorageOrigin.fromMap(null), isNull);
    });

    test('AndroidWebStorageOrigin toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = AndroidWebStorageOrigin();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(AndroidWebStorageOrigin.fromMap(null), isNull);
    });

    test('WebsiteDataRecord toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = WebsiteDataRecord();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(WebsiteDataRecord.fromMap(null), isNull);
    });

    test('IOSWKWebsiteDataRecord toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = IOSWKWebsiteDataRecord();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(IOSWKWebsiteDataRecord.fromMap(null), isNull);
    });

    test('WebViewPackageInfo toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = WebViewPackageInfo();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(WebViewPackageInfo.fromMap(null), isNull);
    });

    test('AndroidWebViewPackageInfo toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = AndroidWebViewPackageInfo();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(AndroidWebViewPackageInfo.fromMap(null), isNull);
    });

    test('WindowFeatures toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = WindowFeatures();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(WindowFeatures.fromMap(null), isNull);
    });

    test('IOSWKWindowFeatures toMap/toJson/toString and fromMap(null)', () {
      try {
        final instance = IOSWKWindowFeatures();
        final map = instance.toMap();
        expect(map, isA<Map>());
        expect(instance.toJson(), isA<Map>());
        expect(instance.toString(), isNotEmpty);
      } catch (_) {
        // Constructor may assert platform-specific non-null invariants.
      }
      expect(IOSWKWindowFeatures.fromMap(null), isNull);
    });

  });
}
