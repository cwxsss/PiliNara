import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'fake_platforms.dart';

/// Full stub [PlatformInAppWebViewController] for app-facing API unit tests.
class FakePlatformInAppWebViewController extends PlatformInAppWebViewController
    with MockPlatformInterfaceMixin {
  FakePlatformInAppWebViewController({dynamic id = 'test-id'})
      : _webStorage = FakePlatformWebStorage(
          localStorage: FakePlatformLocalStorage(),
          sessionStorage: FakePlatformSessionStorage(),
        ),
        super.implementation(
          PlatformInAppWebViewControllerCreationParams(id: id),
        );

  final FakePlatformWebStorage _webStorage;
  final List<UserScript> userScripts = [];
  final Map<String, JavaScriptHandlerCallback> jsHandlers = {};
  final Set<String> removedGroupNames = {};
  final Set<PlatformWebMessageListener> listeners = {};

  bool canScrollVerticallyValue = true;
  bool canScrollHorizontallyValue = false;
  bool disposed = false;

  @override
  PlatformWebStorage get webStorage => _webStorage;

  @override
  dynamic getViewId() => params.id;

  @override
  Future<WebUri?> getUrl() async => WebUri('https://example.com');

  @override
  Future<String?> getTitle() async => 'Example';

  @override
  Future<int?> getProgress() async => 100;

  @override
  Future<String?> getHtml() async => '<html></html>';

  @override
  Future<List<Favicon>> getFavicons() async =>
      [Favicon(url: WebUri('https://example.com/favicon.ico'))];

  @override
  Future<void> loadUrl(
          {required URLRequest urlRequest,
          Uri? iosAllowingReadAccessTo,
          WebUri? allowingReadAccessTo}) async {}

  @override
  Future<void> postUrl(
          {required WebUri url, required Uint8List postData}) async {}

  @override
  Future<void> loadData(
          {required String data,
          String mimeType = 'text/html',
          String encoding = 'utf8',
          WebUri? baseUrl,
          Uri? androidHistoryUrl,
          WebUri? historyUrl,
          Uri? iosAllowingReadAccessTo,
          WebUri? allowingReadAccessTo}) async {}

  @override
  Future<void> loadFile({required String assetFilePath}) async {}

  @override
  Future<void> reload() async {}

  @override
  Future<void> goBack() async {}

  @override
  Future<bool> canGoBack() async => true;

  @override
  Future<void> goForward() async {}

  @override
  Future<bool> canGoForward() async => false;

  @override
  Future<void> goBackOrForward({required int steps}) async {}

  @override
  Future<bool> canGoBackOrForward({required int steps}) async => true;

  @override
  Future<void> goTo({required WebHistoryItem historyItem}) async {}

  @override
  Future<bool> isLoading() async => false;

  @override
  Future<void> stopLoading() async {}

  @override
  Future<dynamic> evaluateJavascript(
          {required String source, ContentWorld? contentWorld}) async =>
      'ok';

  @override
  Future<void> injectJavascriptFileFromUrl(
          {required WebUri urlFile,
          ScriptHtmlTagAttributes? scriptHtmlTagAttributes}) async {}

  @override
  Future<dynamic> injectJavascriptFileFromAsset(
          {required String assetFilePath}) async =>
      'ok';

  @override
  Future<void> injectCSSCode({required String source}) async {}

  @override
  Future<void> injectCSSFileFromUrl(
          {required WebUri urlFile,
          CSSLinkHtmlTagAttributes? cssLinkHtmlTagAttributes}) async {}

  @override
  Future<void> injectCSSFileFromAsset({required String assetFilePath}) async {}

  @override
  void addJavaScriptHandler(
          {required String handlerName,
          required JavaScriptHandlerCallback callback}) {
    jsHandlers[handlerName] = callback;
  }

  @override
  JavaScriptHandlerCallback? removeJavaScriptHandler(
          {required String handlerName}) =>
      jsHandlers.remove(handlerName);

  @override
  bool hasJavaScriptHandler({required String handlerName}) =>
      jsHandlers.containsKey(handlerName);

  @override
  Future<Uint8List?> takeScreenshot(
          {ScreenshotConfiguration? screenshotConfiguration}) async =>
      Uint8List.fromList([1, 2, 3]);

  @override
  Future<void> setSettings({required InAppWebViewSettings settings}) async {}

  @override
  Future<InAppWebViewSettings?> getSettings() async =>
      InAppWebViewSettings(javaScriptEnabled: true);

  @override
  Future<WebHistory?> getCopyBackForwardList() async => WebHistory(
        currentIndex: 0,
        list: [
          WebHistoryItem(
            url: WebUri('https://example.com'),
            title: 'Example',
          ),
        ],
      );

  @override
  Future<void> clearCache() async {}

  @override
  Future<void> scrollTo(
          {required int x, required int y, bool animated = false}) async {}

  @override
  Future<void> scrollBy(
          {required int x, required int y, bool animated = false}) async {}

  @override
  Future<void> pauseTimers() async {}

  @override
  Future<void> resumeTimers() async {}

  @override
  Future<PlatformPrintJobController?> printCurrentPage(
          {PrintJobSettings? settings}) async =>
      FakePlatformPrintJobController();

  @override
  Future<int?> getContentHeight() async => 800;

  @override
  Future<int?> getContentWidth() async => 400;

  @override
  Future<void> zoomBy(
          {required double zoomFactor,
          bool? iosAnimated,
          bool animated = false}) async {}

  @override
  Future<WebUri?> getOriginalUrl() async => WebUri('https://example.com');

  @override
  Future<double?> getZoomScale() async => 1.0;

  @override
  Future<String?> getSelectedText() async => 'selected';

  @override
  Future<InAppWebViewHitTestResult?> getHitTestResult() async =>
      InAppWebViewHitTestResult(type: InAppWebViewHitTestResultType.SRC_ANCHOR_TYPE);

  @override
  Future<void> clearFocus() async {}

  @override
  Future<void> setContextMenu(ContextMenu? contextMenu) async {}

  @override
  Future<RequestFocusNodeHrefResult?> requestFocusNodeHref() async =>
      RequestFocusNodeHrefResult(
        url: WebUri('https://example.com'),
        title: 'Link',
      );

  @override
  Future<RequestImageRefResult?> requestImageRef() async =>
      RequestImageRefResult(url: WebUri('https://example.com/img.png'));

  @override
  Future<List<MetaTag>> getMetaTags() async => [];

  @override
  Future<Color?> getMetaThemeColor() async => const Color(0xFFFFFFFF);

  @override
  Future<int?> getScrollX() async => 0;

  @override
  Future<int?> getScrollY() async => 0;

  @override
  Future<SslCertificate?> getCertificate() async => null;

  @override
  Future<void> addUserScript({required UserScript userScript}) async {
    userScripts.add(userScript);
  }

  @override
  Future<void> addUserScripts({required List<UserScript> userScripts}) async {
    this.userScripts.addAll(userScripts);
  }

  @override
  Future<bool> removeUserScript({required UserScript userScript}) async {
    return userScripts.remove(userScript);
  }

  @override
  Future<void> removeUserScriptsByGroupName({required String groupName}) async {
    removedGroupNames.add(groupName);
    userScripts.removeWhere((script) => script.groupName == groupName);
  }

  @override
  Future<void> removeUserScripts({required List<UserScript> userScripts}) async {
    this.userScripts.removeWhere(userScripts.contains);
  }

  @override
  Future<void> removeAllUserScripts() async => userScripts.clear();

  @override
  bool hasUserScript({required UserScript userScript}) =>
      userScripts.contains(userScript);

  @override
  Future<CallAsyncJavaScriptResult?> callAsyncJavaScript(
          {required String functionBody,
          Map<String, dynamic> arguments = const {},
          ContentWorld? contentWorld}) async =>
      CallAsyncJavaScriptResult(value: 'ok');

  @override
  Future<String?> saveWebArchive(
          {required String filePath, bool autoname = false}) async =>
      filePath;

  @override
  Future<bool> isSecureContext() async => true;

  @override
  Future<PlatformWebMessageChannel?> createWebMessageChannel() async =>
      FakePlatformWebMessageChannel();

  @override
  Future<void> postWebMessage(
          {required WebMessage message, WebUri? targetOrigin}) async {}

  @override
  Future<void> addWebMessageListener(
          PlatformWebMessageListener webMessageListener) async {
    listeners.add(webMessageListener);
  }

  @override
  bool hasWebMessageListener(PlatformWebMessageListener webMessageListener) =>
      listeners.contains(webMessageListener);

  @override
  Future<bool> canScrollVertically() async => canScrollVerticallyValue;

  @override
  Future<bool> canScrollHorizontally() async => canScrollHorizontallyValue;

  @override
  Future<bool> startSafeBrowsing() async => true;

  @override
  Future<void> clearSslPreferences() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<bool> pageDown({required bool bottom}) async => true;

  @override
  Future<bool> pageUp({required bool top}) async => true;

  @override
  Future<bool> zoomIn() async => true;

  @override
  Future<bool> zoomOut() async => true;

  @override
  Future<void> clearHistory() async {}

  @override
  Future<void> reloadFromOrigin() async {}

  @override
  Future<Uint8List?> createPdf(
          {IOSWKPDFConfiguration? iosWKPdfConfiguration,
          PDFConfiguration? pdfConfiguration}) async =>
      Uint8List.fromList([1]);

  @override
  Future<Uint8List?> createWebArchiveData() async => Uint8List.fromList([1]);

  @override
  Future<bool> hasOnlySecureContent() async => true;

  @override
  Future<void> pauseAllMediaPlayback() async {}

  @override
  Future<void> setAllMediaPlaybackSuspended({required bool suspended}) async {}

  @override
  Future<void> closeAllMediaPresentations() async {}

  @override
  Future<MediaPlaybackState?> requestMediaPlaybackState() async =>
      MediaPlaybackState.NONE;

  @override
  Future<bool> isInFullscreen() async => false;

  @override
  Future<void> clearFormData() async {}

  @override
  Future<MediaCaptureState?> getCameraCaptureState() async =>
      MediaCaptureState.NONE;

  @override
  Future<void> setCameraCaptureState({required MediaCaptureState state}) async {}

  @override
  Future<MediaCaptureState?> getMicrophoneCaptureState() async =>
      MediaCaptureState.NONE;

  @override
  Future<void> setMicrophoneCaptureState(
          {required MediaCaptureState state}) async {}

  @override
  Future<void> loadSimulatedRequest(
          {required URLRequest urlRequest,
          required Uint8List data,
          URLResponse? urlResponse}) async {}

  @override
  Future<void> openDevTools() async {}

  @override
  Future<dynamic> callDevToolsProtocolMethod(
          {required String methodName,
          Map<String, dynamic>? parameters}) async =>
      null;

  @override
  Future<void> addDevToolsProtocolEventListener(
          {required String eventName,
          required Function(dynamic data) callback}) async {}

  @override
  Future<void> removeDevToolsProtocolEventListener(
          {required String eventName}) async {}

  @override
  Future<String?> getIFrameId() async => 'frame-1';

  @override
  void dispose({bool isKeepAlive = false}) {
    disposed = true;
  }
}

/// Static controller stub for [InAppWebViewController] class methods.
class FakePlatformInAppWebViewControllerStatic
    extends FakePlatformInAppWebViewController {
  FakePlatformInAppWebViewControllerStatic()
      : super(id: 'static-controller');

  @override
  Future<String> getDefaultUserAgent() async => 'Mozilla/test';

  @override
  Future<void> clearAllCache({bool includeDiskFiles = true}) async {}

  @override
  Future<void> clearClientCertPreferences() async {}

  @override
  Future<WebUri?> getSafeBrowsingPrivacyPolicyUrl() async =>
      WebUri('https://example.com/policy');

  @override
  Future<bool> setSafeBrowsingAllowlist({required List<String> hosts}) async =>
      true;

  @override
  Future<WebViewPackageInfo?> getCurrentWebViewPackage() async =>
      WebViewPackageInfo(packageName: 'com.test.webview', versionName: '1.0');

  @override
  Future<void> setWebContentsDebuggingEnabled(bool debuggingEnabled) async {}

  @override
  Future<String?> getVariationsHeader() async => 'variations';

  @override
  Future<bool> isMultiProcessEnabled() async => true;

  @override
  Future<void> disableWebView() async {}

  @override
  Future<bool> handlesURLScheme(String urlScheme) async => urlScheme == 'https';

  @override
  Future<void> disposeKeepAlive(InAppWebViewKeepAlive keepAlive) async {}

  @override
  Future<String> get tRexRunnerHtml async => '<html>t-rex</html>';

  @override
  Future<String> get tRexRunnerCss async => 'body{}';
}

class FakePlatformResourcesPathHandler extends PlatformResourcesPathHandler
    with MockPlatformInterfaceMixin {
  FakePlatformResourcesPathHandler(
      PlatformResourcesPathHandlerCreationParams params)
      : super.implementation(params);

  @override
  late PlatformPathHandlerEvents? eventHandler;

  @override
  Map<String, dynamic> toMap() => {'type': type, 'path': path};

  @override
  Map<String, dynamic> toJson() => toMap();
}

class FakePlatformInternalStoragePathHandler
    extends PlatformInternalStoragePathHandler with MockPlatformInterfaceMixin {
  FakePlatformInternalStoragePathHandler(
      PlatformInternalStoragePathHandlerCreationParams params)
      : super.implementation(params);

  @override
  late PlatformPathHandlerEvents? eventHandler;

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'path': path,
        'directory': directory,
      };

  @override
  Map<String, dynamic> toJson() => toMap();
}

class FakePlatformCustomPathHandler extends PlatformCustomPathHandler
    with MockPlatformInterfaceMixin {
  FakePlatformCustomPathHandler(
      PlatformCustomPathHandlerCreationParams params)
      : super.implementation(params);

  @override
  late PlatformPathHandlerEvents? eventHandler;

  @override
  Map<String, dynamic> toMap() => {'type': type, 'path': path};

  @override
  Map<String, dynamic> toJson() => toMap();
}

class FakePlatformAssetsPathHandler extends PlatformAssetsPathHandler
    with MockPlatformInterfaceMixin {
  FakePlatformAssetsPathHandler(
      PlatformAssetsPathHandlerCreationParams params)
      : super.implementation(params);

  @override
  late PlatformPathHandlerEvents? eventHandler;

  @override
  Map<String, dynamic> toMap() => {'type': type, 'path': path};

  @override
  Map<String, dynamic> toJson() => toMap();
}

class FakePlatformFindInteractionController
    extends PlatformFindInteractionController with MockPlatformInterfaceMixin {
  FakePlatformFindInteractionController(
      PlatformFindInteractionControllerCreationParams params)
      : super.implementation(params);

  String? searchText;
  bool disposed = false;

  @override
  void Function(PlatformFindInteractionController controller,
          int activeMatchOrdinal, int numberOfMatches, bool isDoneCounting)?
      get onFindResultReceived => params.onFindResultReceived;

  @override
  Future<void> findAll({String? find}) async {}

  @override
  Future<void> findNext({bool forward = true}) async {}

  @override
  Future<void> clearMatches() async {}

  @override
  Future<void> setSearchText(String? searchText) async {
    this.searchText = searchText;
  }

  @override
  Future<String?> getSearchText() async => searchText;

  @override
  Future<bool?> isFindNavigatorVisible() async => false;

  @override
  Future<void> updateResultCount() async {}

  @override
  Future<void> presentFindNavigator() async {}

  @override
  Future<void> dismissFindNavigator() async {}

  @override
  Future<FindSession?> getActiveFindSession() async => null;

  @override
  void dispose({bool isKeepAlive = false}) {
    disposed = true;
  }
}

class FakePlatformPullToRefreshController extends PlatformPullToRefreshController
    with MockPlatformInterfaceMixin {
  FakePlatformPullToRefreshController(
      PlatformPullToRefreshControllerCreationParams params)
      : super.implementation(params);

  bool enabled = true;
  bool refreshing = false;
  bool disposed = false;

  @override
  PullToRefreshSettings get settings =>
      params.settings ?? PullToRefreshSettings();

  @override
  void Function()? get onRefresh => params.onRefresh;

  @override
  Future<void> setEnabled(bool enabled) async {
    this.enabled = enabled;
  }

  @override
  Future<bool> isEnabled() async => enabled;

  @override
  Future<void> beginRefreshing() async {
    refreshing = true;
  }

  @override
  Future<void> endRefreshing() async {
    refreshing = false;
  }

  @override
  Future<bool> isRefreshing() async => refreshing;

  @override
  Future<void> setColor(Color color) async {}

  @override
  Future<void> setBackgroundColor(Color color) async {}

  @override
  Future<void> setDistanceToTriggerSync(int distanceToTriggerSync) async {}

  @override
  Future<void> setSlingshotDistance(int slingshotDistance) async {}

  @override
  Future<int> getDefaultSlingshotDistance() async => 64;

  @override
  Future<void> setIndicatorSize(PullToRefreshSize size) async {}

  @override
  Future<void> setStyledTitle(AttributedString attributedTitle) async {}

  @override
  void dispose({bool isKeepAlive = false}) {
    disposed = true;
  }
}

class FakePlatformHttpAuthCredentialDatabase
    extends PlatformHttpAuthCredentialDatabase
    with MockPlatformInterfaceMixin {
  FakePlatformHttpAuthCredentialDatabase(
      PlatformHttpAuthCredentialDatabaseCreationParams params)
      : super.implementation(params);

  final List<URLProtectionSpaceHttpAuthCredentials> allCredentials = [];
  bool disposed = false;

  @override
  Future<List<URLProtectionSpaceHttpAuthCredentials>>
      getAllAuthCredentials() async => allCredentials;

  @override
  Future<List<URLCredential>> getHttpAuthCredentials(
          {required URLProtectionSpace protectionSpace}) async =>
      [];

  @override
  Future<void> setHttpAuthCredential(
          {required URLProtectionSpace protectionSpace,
          required URLCredential credential}) async {}

  @override
  Future<void> removeHttpAuthCredential(
          {required URLProtectionSpace protectionSpace,
          required URLCredential credential}) async {}

  @override
  Future<void> removeHttpAuthCredentials(
          {required URLProtectionSpace protectionSpace}) async {}

  @override
  Future<void> clearAllAuthCredentials() async {
    allCredentials.clear();
  }

  @override
  void dispose() {
    disposed = true;
    allCredentials.clear();
  }
}

class FakePlatformChromeSafariBrowser extends PlatformChromeSafariBrowser
    with MockPlatformInterfaceMixin {
  FakePlatformChromeSafariBrowser(
      [PlatformChromeSafariBrowserCreationParams params =
          const PlatformChromeSafariBrowserCreationParams()])
      : super.implementation(params);

  @override
  String get id => 'fake-chrome-browser';

  bool opened = false;
  bool disposed = false;

  @override
  Future<void> open(
          {WebUri? url,
          Map<String, String>? headers,
          List<WebUri>? otherLikelyURLs,
          WebUri? referrer,
          ChromeSafariBrowserClassOptions? options,
          ChromeSafariBrowserSettings? settings}) async {
    opened = true;
  }

  @override
  Future<void> launchUrl(
          {required WebUri url,
          Map<String, String>? headers,
          List<WebUri>? otherLikelyURLs,
          WebUri? referrer}) async {
    opened = true;
  }

  @override
  Future<bool> mayLaunchUrl(
          {WebUri? url, List<WebUri>? otherLikelyURLs}) async =>
      true;

  @override
  Future<bool> validateRelationship(
          {required CustomTabsRelationType relation,
          required WebUri origin}) async =>
      true;

  @override
  Future<void> close() async {
    opened = false;
  }

  @override
  bool isOpened() => opened;

  @override
  void setActionButton(ChromeSafariBrowserActionButton actionButton) {}

  @override
  Future<void> updateActionButton(
          {required Uint8List icon, required String description}) async {}

  @override
  void setSecondaryToolbar(
          ChromeSafariBrowserSecondaryToolbar secondaryToolbar) {}

  @override
  Future<void> updateSecondaryToolbar(
          ChromeSafariBrowserSecondaryToolbar secondaryToolbar) async {}

  @override
  void addMenuItem(ChromeSafariBrowserMenuItem menuItem) {}

  @override
  void addMenuItems(List<ChromeSafariBrowserMenuItem> menuItems) {}

  @override
  Future<bool> requestPostMessageChannel(
          {required WebUri sourceOrigin, WebUri? targetOrigin}) async =>
      true;

  @override
  Future<CustomTabsPostMessageResultType> postMessage(String message) async =>
      CustomTabsPostMessageResultType.SUCCESS;

  @override
  Future<bool> isEngagementSignalsApiAvailable() async => false;

  @override
  void dispose() {
    disposed = true;
  }
}

class FakePlatformChromeSafariBrowserStatic extends FakePlatformChromeSafariBrowser {
  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<int> getMaxToolbarItems() async => 5;

  @override
  Future<String?> getPackageName(
          {List<String>? packages, bool ignoreDefault = false}) async =>
      'com.android.chrome';

  @override
  Future<void> clearWebsiteData() async {}

  @override
  Future<PrewarmingToken?> prewarmConnections(List<WebUri> URLs) async =>
      PrewarmingToken(id: 'prewarm-token');

  @override
  Future<void> invalidatePrewarmingToken(
          PrewarmingToken prewarmingToken) async {}
}
