import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_ohos/flutter_inappwebview_ohos.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import 'test_bindings.dart';

const ohosManagerChannel = MethodChannel(
  'com.pichillilorenzo/flutter_inappwebview_manager',
);

MethodChannel ohosControllerChannel(int id) {
  return MethodChannel('com.pichillilorenzo/flutter_inappwebview_$id');
}

OhosInAppWebViewController createMockOhosController({
  required int id,
  Future<dynamic> Function(MethodCall call)? handler,
  PlatformInAppWebViewWidgetCreationParams? webviewParams,
}) {
  setMockMethodChannelHandler(
    ohosControllerChannel(id),
    handler ?? defaultOhosControllerHandler,
  );
  return OhosInAppWebViewController(
    OhosInAppWebViewControllerCreationParams(
      id: id,
      webviewParams: webviewParams,
    ),
  );
}

void mockOhosStaticChannel({
  Future<dynamic> Function(MethodCall call)? handler,
}) {
  setMockMethodChannelHandler(
    ohosManagerChannel,
    handler ?? defaultOhosStaticHandler,
  );
}

Future<dynamic> defaultOhosControllerHandler(MethodCall call) async {
  switch (call.method) {
    case 'getUrl':
      return 'https://example.com';
    case 'getTitle':
      return 'Example';
    case 'getProgress':
      return 100;
    case 'getOriginalUrl':
      return 'https://example.com/original';
    case 'canGoBack':
      return true;
    case 'canGoForward':
      return false;
    case 'canGoBackOrForward':
      return true;
    case 'isLoading':
      return false;
    case 'getSettings':
      return {'javaScriptEnabled': true};
    case 'getCopyBackForwardList':
      return {
        'currentIndex': 0,
        'list': [
          {
            'url': 'https://example.com',
            'title': 'Example',
            'originalUrl': 'https://example.com',
          },
        ],
      };
    case 'getContentHeight':
      return 500;
    case 'getContentWidth':
      return 320;
    case 'getZoomScale':
      return 1.5;
    case 'getSelectedText':
      return 'selection';
    case 'getHitTestResult':
      return {'type': 0, 'extra': 'https://example.com/link'};
    case 'getScrollX':
      return 10;
    case 'getScrollY':
      return 20;
    case 'getCertificate':
      return null;
    case 'printCurrentPage':
      return 'print-job-1';
    case 'createWebMessageChannel':
      return {'id': 'wm-test'};
    case 'callAsyncJavaScript':
      return jsonEncode({'value': 'ok', 'error': null});
    case 'saveWebArchive':
      return '/data/archive.mht';
    case 'isSecureContext':
      return true;
    case 'canScrollVertically':
      return true;
    case 'canScrollHorizontally':
      return false;
    case 'startSafeBrowsing':
      return true;
    case 'pageDown':
    case 'pageUp':
    case 'zoomIn':
    case 'zoomOut':
      return true;
    case 'isInFullscreen':
      return false;
    case 'requestFocusNodeHref':
      return {
        'url': 'https://example.com/focus',
        'title': 'Focus',
        'src': 'src',
      };
    case 'requestImageRef':
      return {'url': 'https://example.com/img.png'};
    case 'getMetaThemeColor':
      return '#ffffff';
    case 'takeScreenshot':
      return Uint8List.fromList([1, 2, 3]);
    case 'evaluateJavascript':
      return evaluateJavascriptMock(call.arguments['source'] as String);
  }
  return null;
}

String? evaluateJavascriptMock(String source) {
  if (source.contains('metaTagNodes')) {
    return '[{"name":"theme-color","content":"#000000","attrs":[]}]';
  }
  if (source.contains('linkNodes')) {
    return '[]';
  }
  if (source.contains('scrollHeight')) {
    return '800';
  }
  if (source.contains('scrollWidth')) {
    return '400';
  }
  if (source.contains('outerHTML')) {
    return '"<html></html>"';
  }
  if (source.contains('webStorageItems')) {
    return '[{"key":"k1","value":"v1"}]';
  }
  if (source.contains('.getItem(')) {
    return '"value"';
  }
  return '"js-result"';
}

Future<dynamic> defaultOhosStaticHandler(MethodCall call) async {
  switch (call.method) {
    case 'getDefaultUserAgent':
      return 'Mozilla/test';
    case 'getSafeBrowsingPrivacyPolicyUrl':
      return 'https://example.com/policy';
    case 'setSafeBrowsingAllowlist':
      return true;
    case 'getCurrentWebViewPackage':
      return {'packageName': 'com.test.webview', 'versionName': '1.0'};
    case 'getVariationsHeader':
      return 'variation-header';
    case 'isMultiProcessEnabled':
      return true;
  }
  return null;
}

Future<dynamic> mockEvaluateJavascriptHandler(MethodCall call) async {
  if (call.method != 'evaluateJavascript') {
    return null;
  }
  return evaluateJavascriptMock(call.arguments['source'] as String);
}
