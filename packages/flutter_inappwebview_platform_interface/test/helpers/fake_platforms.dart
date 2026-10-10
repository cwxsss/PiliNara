import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'fake_controller.dart';

/// In-memory fake for [PlatformStorage] operations used by unit tests.
class FakePlatformStorageBackend {
  FakePlatformStorageBackend({required this.webStorageType});

  final WebStorageType webStorageType;
  final Map<String, dynamic> items = {};
  bool disposed = false;

  Future<int?> length() async => items.length;

  Future<void> setItem({required String key, required dynamic value}) async {
    items[key] = value;
  }

  Future<dynamic> getItem({required String key}) async => items[key];

  Future<void> removeItem({required String key}) async {
    items.remove(key);
  }

  Future<List<WebStorageItem>> getItems() async =>
      items.entries.map((e) => WebStorageItem(key: e.key, value: e.value)).toList();

  Future<void> clear() async => items.clear();

  Future<String> key({required int index}) async => items.keys.elementAt(index);

  void dispose() {
    disposed = true;
    items.clear();
  }
}

class FakePlatformLocalStorage extends PlatformLocalStorage
    with MockPlatformInterfaceMixin {
  FakePlatformLocalStorage({PlatformInAppWebViewController? controller})
      : backend = FakePlatformStorageBackend(
            webStorageType: WebStorageType.LOCAL_STORAGE),
        super.implementation(
          PlatformLocalStorageCreationParams(
            PlatformStorageCreationParams(
              controller: controller,
              webStorageType: WebStorageType.LOCAL_STORAGE,
            ),
          ),
        );

  final FakePlatformStorageBackend backend;

  @override
  PlatformInAppWebViewController? get controller => params.controller;

  @override
  Future<int?> length() => backend.length();

  @override
  Future<void> setItem({required String key, required dynamic value}) =>
      backend.setItem(key: key, value: value);

  @override
  Future<dynamic> getItem({required String key}) => backend.getItem(key: key);

  @override
  Future<void> removeItem({required String key}) =>
      backend.removeItem(key: key);

  @override
  Future<List<WebStorageItem>> getItems() => backend.getItems();

  @override
  Future<void> clear() => backend.clear();

  @override
  Future<String> key({required int index}) => backend.key(index: index);

  @override
  void dispose() => backend.dispose();
}

class FakePlatformSessionStorage extends PlatformSessionStorage
    with MockPlatformInterfaceMixin {
  FakePlatformSessionStorage({PlatformInAppWebViewController? controller})
      : backend = FakePlatformStorageBackend(
            webStorageType: WebStorageType.SESSION_STORAGE),
        super.implementation(
          PlatformSessionStorageCreationParams(
            PlatformStorageCreationParams(
              controller: controller,
              webStorageType: WebStorageType.SESSION_STORAGE,
            ),
          ),
        );

  final FakePlatformStorageBackend backend;

  @override
  PlatformInAppWebViewController? get controller => params.controller;

  @override
  Future<int?> length() => backend.length();

  @override
  Future<void> setItem({required String key, required dynamic value}) =>
      backend.setItem(key: key, value: value);

  @override
  Future<dynamic> getItem({required String key}) => backend.getItem(key: key);

  @override
  Future<void> removeItem({required String key}) =>
      backend.removeItem(key: key);

  @override
  Future<List<WebStorageItem>> getItems() => backend.getItems();

  @override
  Future<void> clear() => backend.clear();

  @override
  Future<String> key({required int index}) => backend.key(index: index);

  @override
  void dispose() => backend.dispose();
}

class FakePlatformWebStorage extends PlatformWebStorage
    with MockPlatformInterfaceMixin {
  FakePlatformWebStorage({
    required this.localStorage,
    required this.sessionStorage,
  }) : super.implementation(
          PlatformWebStorageCreationParams(
            localStorage: localStorage,
            sessionStorage: sessionStorage,
          ),
        );

  @override
  final PlatformLocalStorage localStorage;

  @override
  final PlatformSessionStorage sessionStorage;

  bool disposed = false;

  @override
  void dispose() {
    disposed = true;
    localStorage.dispose();
    sessionStorage.dispose();
  }
}

class FakePlatformWebStorageManager extends PlatformWebStorageManager
    with MockPlatformInterfaceMixin {
  FakePlatformWebStorageManager()
      : super.implementation(const PlatformWebStorageManagerCreationParams());

  final List<WebStorageOrigin> origins = [
    WebStorageOrigin(origin: 'https://example.com', quota: 1000, usage: 100),
  ];

  bool deleteAllCalled = false;
  String? deletedOrigin;

  @override
  Future<List<WebStorageOrigin>> getOrigins() async => origins;

  @override
  Future<void> deleteAllData() async {
    deleteAllCalled = true;
  }

  @override
  Future<void> deleteOrigin({required String origin}) async {
    deletedOrigin = origin;
  }

  @override
  Future<int> getQuotaForOrigin({required String origin}) async => 1000;

  @override
  Future<int> getUsageForOrigin({required String origin}) async => 100;

  @override
  Future<List<WebsiteDataRecord>> fetchDataRecords(
          {required Set<WebsiteDataType> dataTypes}) async =>
      [WebsiteDataRecord(displayName: 'example.com', dataTypes: dataTypes)];

  @override
  Future<void> removeDataFor(
          {required Set<WebsiteDataType> dataTypes,
          required List<WebsiteDataRecord> dataRecords}) async {}

  @override
  Future<void> removeDataModifiedSince(
          {required Set<WebsiteDataType> dataTypes,
          required DateTime date}) async {}
}

class FakePlatformCookieManager extends PlatformCookieManager
    with MockPlatformInterfaceMixin {
  FakePlatformCookieManager()
      : super.implementation(const PlatformCookieManagerCreationParams());

  final List<Cookie> allCookies = [];

  @override
  Future<bool> setCookie(
          {required WebUri url,
          required String name,
          required String value,
          String path = "/",
          String? domain,
          int? expiresDate,
          int? maxAge,
          bool? isSecure,
          bool? isHttpOnly,
          HTTPCookieSameSitePolicy? sameSite,
          PlatformInAppWebViewController? iosBelow11WebViewController,
          PlatformInAppWebViewController? webViewController}) async =>
      true;

  @override
  Future<List<Cookie>> getCookies(
          {required WebUri url,
          PlatformInAppWebViewController? iosBelow11WebViewController,
          PlatformInAppWebViewController? webViewController}) async =>
      allCookies;

  @override
  Future<Cookie?> getCookie(
          {required WebUri url,
          required String name,
          PlatformInAppWebViewController? iosBelow11WebViewController,
          PlatformInAppWebViewController? webViewController}) async {
    for (final cookie in allCookies) {
      if (cookie.name == name) return cookie;
    }
    return null;
  }

  @override
  Future<bool> deleteCookie(
          {required WebUri url,
          required String name,
          String path = "/",
          String? domain,
          PlatformInAppWebViewController? iosBelow11WebViewController,
          PlatformInAppWebViewController? webViewController}) async =>
      true;

  @override
  Future<bool> deleteCookies(
          {required WebUri url,
          String path = "/",
          String? domain,
          PlatformInAppWebViewController? iosBelow11WebViewController,
          PlatformInAppWebViewController? webViewController}) async =>
      true;

  @override
  Future<bool> deleteAllCookies() async => true;

  @override
  Future<List<Cookie>> getAllCookies() async => allCookies;

  @override
  Future<bool> removeSessionCookies() async => true;
}

class FakePlatformPrintJobController extends PlatformPrintJobController
    with MockPlatformInterfaceMixin {
  FakePlatformPrintJobController({String id = 'job-1', this.onComplete})
      : super.implementation(
          PlatformPrintJobControllerCreationParams(
            id: id,
            onComplete: onComplete,
          ),
        );

  @override
  PrintJobCompletionHandler? onComplete;

  bool cancelCalled = false;
  bool restartCalled = false;
  bool dismissCalled = false;
  bool disposed = false;

  @override
  Future<void> cancel() async {
    cancelCalled = true;
  }

  @override
  Future<void> restart() async {
    restartCalled = true;
  }

  @override
  Future<void> dismiss({bool animated = true}) async {
    dismissCalled = true;
  }

  @override
  Future<PrintJobInfo?> getInfo() async =>
      PrintJobInfo(state: PrintJobState.COMPLETED);

  @override
  void dispose() {
    disposed = true;
  }
}

class FakePlatformProxyController extends PlatformProxyController
    with MockPlatformInterfaceMixin {
  FakePlatformProxyController()
      : super.implementation(const PlatformProxyControllerCreationParams());

  bool clearCalled = false;
  bool setProxyCalled = false;

  @override
  Future<void> clearProxyOverride({bool reload = true}) async {
    clearCalled = true;
  }

  @override
  Future<void> setProxyOverride({required ProxySettings settings}) async {
    setProxyCalled = true;
  }
}

class FakePlatformTracingController extends PlatformTracingController
    with MockPlatformInterfaceMixin {
  FakePlatformTracingController()
      : super.implementation(const PlatformTracingControllerCreationParams());

  bool tracing = false;

  @override
  Future<bool> isTracing() async => tracing;

  @override
  Future<void> start({TracingSettings? settings}) async {
    tracing = true;
  }

  @override
  Future<bool> stop({String? filePath}) async {
    tracing = false;
    return true;
  }
}

class FakePlatformWebMessagePort extends PlatformWebMessagePort
    with MockPlatformInterfaceMixin {
  FakePlatformWebMessagePort({int index = 0})
      : super.implementation(
          PlatformWebMessagePortCreationParams(index: index));

  bool closed = false;

  @override
  Future<void> close() async {
    closed = true;
  }

  @override
  Future<void> setWebMessageCallback(WebMessageCallback? onMessage) async {}

  @override
  Future<void> postMessage(WebMessage message) async {}

  @override
  Map<String, dynamic> toMap() => {'index': params.index};

  @override
  Map<String, dynamic> toJson() => toMap();
}

class FakePlatformWebMessageChannel extends PlatformWebMessageChannel
    with MockPlatformInterfaceMixin {
  FakePlatformWebMessageChannel._({
    required PlatformWebMessageChannelCreationParams params,
  }) : super.implementation(params);

  factory FakePlatformWebMessageChannel({String id = 'channel-1'}) {
    final port1 = FakePlatformWebMessagePort(index: 0);
    final port2 = FakePlatformWebMessagePort(index: 1);
    return FakePlatformWebMessageChannel._(
      params: PlatformWebMessageChannelCreationParams(
        id: id,
        port1: port1,
        port2: port2,
      ),
    );
  }

  bool disposed = false;

  @override
  void dispose() {
    disposed = true;
  }
}

class FakePlatformWebMessageListener extends PlatformWebMessageListener
    with MockPlatformInterfaceMixin {
  FakePlatformWebMessageListener({
    String jsObjectName = 'testObj',
    Set<String>? allowedOriginRules,
    OnPostMessageCallback? onPostMessage,
  }) : super.implementation(
          PlatformWebMessageListenerCreationParams(
            jsObjectName: jsObjectName,
            allowedOriginRules: allowedOriginRules,
            onPostMessage: onPostMessage,
          ),
        );

  bool disposed = false;

  @override
  Map<String, dynamic> toMap() => {
        'jsObjectName': params.jsObjectName,
        'allowedOriginRules': params.allowedOriginRules?.toList(),
      };

  @override
  Map<String, dynamic> toJson() => toMap();

  @override
  void dispose() {
    disposed = true;
  }
}

class FakePlatformWebMessageChannelStatic extends PlatformWebMessageChannel
    with MockPlatformInterfaceMixin {
  FakePlatformWebMessageChannelStatic()
      : super.implementation(
          PlatformWebMessageChannelCreationParams(
            id: 'static',
            port1: FakePlatformWebMessagePort(index: 0),
            port2: FakePlatformWebMessagePort(index: 1),
          ),
        );

  @override
  PlatformWebMessageChannel? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return FakePlatformWebMessageChannel(
      id: map['id'] as String? ?? 'mapped-channel',
    );
  }

  @override
  void dispose() {}
}

class FakePlatformWebAuthenticationSession
    extends PlatformWebAuthenticationSession with MockPlatformInterfaceMixin {
  FakePlatformWebAuthenticationSession({
    PlatformWebAuthenticationSessionCreationParams params =
        const PlatformWebAuthenticationSessionCreationParams(),
    this.sessionId = 'fake-auth-session',
    WebUri? url,
    this.callbackURLSchemeValue,
    this.initialSettingsValue,
    this.onCompleteHandler,
  })  : sessionUrl = url ?? WebUri('https://example.com/oauth'),
        super.implementation(params);

  final String sessionId;
  final WebUri sessionUrl;
  final String? callbackURLSchemeValue;
  final WebAuthenticationSessionSettings? initialSettingsValue;
  final WebAuthenticationSessionCompletionHandler? onCompleteHandler;

  bool canceled = false;
  bool disposed = false;
  bool started = false;

  @override
  String get id => sessionId;

  @override
  WebUri get url => sessionUrl;

  @override
  String? get callbackURLScheme => callbackURLSchemeValue;

  @override
  WebAuthenticationSessionSettings? get initialSettings =>
      initialSettingsValue;

  @override
  WebAuthenticationSessionCompletionHandler get onComplete =>
      onCompleteHandler ?? (_, __) async {};

  @override
  Future<bool> canStart() async => !canceled && !disposed;

  @override
  Future<bool> start() async {
    started = true;
    return true;
  }

  @override
  Future<void> cancel() async {
    canceled = true;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

class FakePlatformJavaScriptReplyProxy extends PlatformJavaScriptReplyProxy
    with MockPlatformInterfaceMixin {
  FakePlatformJavaScriptReplyProxy(PlatformWebMessageListener webMessageListener)
      : super.implementation(
          PlatformJavaScriptReplyProxyCreationParams(
            webMessageListener: webMessageListener,
          ),
        );

  @override
  Future<void> postMessage(WebMessage message) async {}
}

class FakePlatformWebAuthenticationSessionStatic
    extends PlatformWebAuthenticationSession with MockPlatformInterfaceMixin {
  FakePlatformWebAuthenticationSessionStatic()
      : super.implementation(
          const PlatformWebAuthenticationSessionCreationParams(),
        );

  @override
  Future<PlatformWebAuthenticationSession> create({
    required WebUri url,
    String? callbackURLScheme,
    WebAuthenticationSessionCompletionHandler? onComplete,
    WebAuthenticationSessionSettings? initialSettings,
  }) async {
    return FakePlatformWebAuthenticationSession(
      url: url,
      callbackURLSchemeValue: callbackURLScheme,
      initialSettingsValue: initialSettings,
      onCompleteHandler: onComplete,
    );
  }

  @override
  Future<bool> isAvailable() async => true;
}

class FakePlatformInAppLocalhostServer extends PlatformInAppLocalhostServer
    with MockPlatformInterfaceMixin {
  FakePlatformInAppLocalhostServer(
      [PlatformInAppLocalhostServerCreationParams? params])
      : super.implementation(
          params ??
              const PlatformInAppLocalhostServerCreationParams(
                port: 9090,
                directoryIndex: 'main.html',
                documentRoot: '/assets',
                shared: true,
              ),
        );

  bool running = false;
  bool startCalled = false;
  bool closeCalled = false;

  @override
  Future<void> start() async {
    startCalled = true;
    running = true;
  }

  @override
  Future<void> close() async {
    closeCalled = true;
    running = false;
  }

  @override
  bool isRunning() => running;
}

class FakePlatformInAppBrowser extends PlatformInAppBrowser
    with MockPlatformInterfaceMixin {
  FakePlatformInAppBrowser([
    PlatformInAppBrowserCreationParams params =
        const PlatformInAppBrowserCreationParams(),
  ]) : super.implementation(params);

  @override
  String get id => 'fake-browser-id';

  bool opened = false;
  bool hidden = false;
  bool setSettingsCalled = false;
  bool getSettingsCalled = false;
  InAppBrowserClassSettings? storedSettings;
  String? openedAssetPath;
  String? openedData;
  FakePlatformInAppWebViewController? _webViewController;

  final List<InAppBrowserMenuItem> menuItems = [];

  @override
  PlatformInAppWebViewController? get webViewController => _webViewController;

  @override
  Future<void> openUrlRequest(
          {required URLRequest urlRequest,
          InAppBrowserClassOptions? options,
          InAppBrowserClassSettings? settings}) async {
    opened = true;
    _webViewController = FakePlatformInAppWebViewController(id: 'browser-wv');
  }

  @override
  Future<void> openFile(
          {required String assetFilePath,
          InAppBrowserClassOptions? options,
          InAppBrowserClassSettings? settings}) async {
    opened = true;
    openedAssetPath = assetFilePath;
    _webViewController = FakePlatformInAppWebViewController(id: 'browser-wv');
  }

  @override
  Future<void> openData(
          {required String data,
          String mimeType = 'text/html',
          String encoding = 'utf8',
          WebUri? baseUrl,
          Uri? androidHistoryUrl,
          WebUri? historyUrl,
          InAppBrowserClassOptions? options,
          InAppBrowserClassSettings? settings}) async {
    opened = true;
    openedData = data;
    _webViewController = FakePlatformInAppWebViewController(id: 'browser-wv');
  }

  @override
  Future<void> openWithSystemBrowser({required WebUri url}) async {}

  @override
  void addMenuItem(InAppBrowserMenuItem menuItem) {
    menuItems.add(menuItem);
  }

  @override
  void addMenuItems(List<InAppBrowserMenuItem> menuItems) {
    this.menuItems.addAll(menuItems);
  }

  @override
  bool removeMenuItem(InAppBrowserMenuItem menuItem) =>
      menuItems.remove(menuItem);

  @override
  void removeMenuItems(List<InAppBrowserMenuItem> menuItems) {
    this.menuItems.removeWhere(menuItems.contains);
  }

  @override
  void removeAllMenuItem() => menuItems.clear();

  @override
  bool hasMenuItem(InAppBrowserMenuItem menuItem) =>
      menuItems.contains(menuItem);

  @override
  Future<void> show() async {
    hidden = false;
  }

  @override
  Future<void> hide() async {
    hidden = true;
  }

  @override
  Future<void> close() async {
    opened = false;
    _webViewController = null;
  }

  @override
  Future<bool> isHidden() async => hidden;

  @override
  Future<void> setSettings(
      {required InAppBrowserClassSettings settings}) async {
    setSettingsCalled = true;
    storedSettings = settings;
  }

  @override
  Future<InAppBrowserClassSettings?> getSettings() async {
    getSettingsCalled = true;
    return storedSettings;
  }

  @override
  bool isOpened() => opened;

  @override
  void dispose() {
    opened = false;
    _webViewController = null;
  }
}

class FakePlatformInAppWebViewWidget extends PlatformInAppWebViewWidget
    with MockPlatformInterfaceMixin {
  FakePlatformInAppWebViewWidget(
      PlatformInAppWebViewWidgetCreationParams params)
      : super.implementation(params);

  bool disposed = false;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  @override
  T controllerFromPlatform<T>(PlatformInAppWebViewController controller) {
    final wrapper = params.controllerFromPlatform;
    if (wrapper != null) {
      return wrapper(controller) as T;
    }
    return controller as T;
  }

  @override
  void dispose() {
    disposed = true;
  }
}

class FakePlatformHeadlessInAppWebView extends PlatformHeadlessInAppWebView
    with MockPlatformInterfaceMixin {
  FakePlatformHeadlessInAppWebView(
      PlatformHeadlessInAppWebViewCreationParams params)
      : super.implementation(params);

  @override
  String get id => 'fake-headless-id';

  bool running = false;
  Size? currentSize;
  FakePlatformInAppWebViewController? _webViewController;

  @override
  PlatformInAppWebViewController? get webViewController => _webViewController;

  @override
  Future<void> run() async {
    if (running) {
      return;
    }
    running = true;
    _webViewController = FakePlatformInAppWebViewController(id: 'headless-wv');
    params.onWebViewCreated?.call(
      params.controllerFromPlatform != null
          ? params.controllerFromPlatform!(_webViewController!)
          : _webViewController!,
    );
  }

  @override
  bool isRunning() => running;

  @override
  Future<void> setSize(Size size) async {
    currentSize = size;
  }

  @override
  Future<Size?> getSize() async => currentSize;

  @override
  Future<void> dispose() async {
    running = false;
    _webViewController = null;
  }
}

class FakePathHandler implements PlatformPathHandler {
  FakePathHandler({required this.path, required this.handlerType});

  final String handlerType;

  @override
  String get type => handlerType;

  @override
  final String path;

  @override
  late PlatformPathHandlerEvents? eventHandler;

  @override
  Map<String, dynamic> toMap() => {'type': type, 'path': path};

  @override
  Map<String, dynamic> toJson() => toMap();
}

class FakePlatformWebViewEnvironment extends PlatformWebViewEnvironment
    with MockPlatformInterfaceMixin {
  FakePlatformWebViewEnvironment({this.environmentId = 'test-env'})
      : super.implementation(const PlatformWebViewEnvironmentCreationParams());

  final String environmentId;
  bool disposed = false;
  bool createCalled = false;
  String? lastAvailableVersionFolder;
  String? lastCompareVersion1;
  String? lastCompareVersion2;

  @override
  String get id => environmentId;

  @override
  Future<PlatformWebViewEnvironment> create(
      {WebViewEnvironmentSettings? settings}) async {
    createCalled = true;
    return FakePlatformWebViewEnvironment(environmentId: 'created-env');
  }

  @override
  Future<String?> getAvailableVersion({String? browserExecutableFolder}) async {
    lastAvailableVersionFolder = browserExecutableFolder;
    return '1.0.0.0';
  }

  @override
  Future<int?> compareBrowserVersions(
      {required String version1, required String version2}) async {
    lastCompareVersion1 = version1;
    lastCompareVersion2 = version2;
    return version1.compareTo(version2);
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

class FakePlatformServiceWorkerController
    extends PlatformServiceWorkerController with MockPlatformInterfaceMixin {
  FakePlatformServiceWorkerController(
      [PlatformServiceWorkerControllerCreationParams? params])
      : super.implementation(
            params ?? const PlatformServiceWorkerControllerCreationParams());

  ServiceWorkerClient? _client;
  bool allowContentAccess = true;
  bool allowFileAccess = true;
  bool blockNetworkLoads = false;
  CacheMode? cacheMode = CacheMode.LOAD_DEFAULT;

  @override
  ServiceWorkerClient? get serviceWorkerClient => _client;

  @override
  Future<void> setServiceWorkerClient(ServiceWorkerClient? value) async {
    _client = value;
  }

  @override
  Future<bool> getAllowContentAccess() async => allowContentAccess;

  @override
  Future<bool> getAllowFileAccess() async => allowFileAccess;

  @override
  Future<bool> getBlockNetworkLoads() async => blockNetworkLoads;

  @override
  Future<CacheMode?> getCacheMode() async => cacheMode;

  @override
  Future<void> setAllowContentAccess(bool allow) async {
    allowContentAccess = allow;
  }

  @override
  Future<void> setAllowFileAccess(bool allow) async {
    allowFileAccess = allow;
  }

  @override
  Future<void> setBlockNetworkLoads(bool flag) async {
    blockNetworkLoads = flag;
  }

  @override
  Future<void> setCacheMode(CacheMode mode) async {
    cacheMode = mode;
  }
}

class FakePlatformProcessGlobalConfig extends PlatformProcessGlobalConfig
    with MockPlatformInterfaceMixin {
  FakePlatformProcessGlobalConfig(
      [PlatformProcessGlobalConfigCreationParams? params])
      : super.implementation(
            params ?? const PlatformProcessGlobalConfigCreationParams());

  ProcessGlobalConfigSettings? lastSettings;
  bool applyCalled = false;

  @override
  Future<void> apply({required ProcessGlobalConfigSettings settings}) async {
    applyCalled = true;
    lastSettings = settings;
  }
}

/// Test platform used to instantiate app-facing APIs without native plugins.
class FakeInAppWebViewPlatform extends InAppWebViewPlatform {
  FakePlatformInAppWebViewWidget? lastWebViewWidget;
  FakePlatformInAppBrowser? lastBrowser;
  FakePlatformHeadlessInAppWebView? lastHeadless;
  FakePlatformInAppLocalhostServer? lastLocalhostServer;
  final FakePlatformServiceWorkerController sharedServiceWorkerController =
      FakePlatformServiceWorkerController();
  final FakePlatformWebViewEnvironment sharedWebViewEnvironmentStatic =
      FakePlatformWebViewEnvironment();
  final FakePlatformProcessGlobalConfig sharedProcessGlobalConfig =
      FakePlatformProcessGlobalConfig();

  @override
  PlatformInAppWebViewWidget createPlatformInAppWebViewWidget(
    PlatformInAppWebViewWidgetCreationParams params,
  ) {
    lastWebViewWidget = FakePlatformInAppWebViewWidget(params);
    return lastWebViewWidget!;
  }

  @override
  PlatformInAppBrowser createPlatformInAppBrowser(
    PlatformInAppBrowserCreationParams params,
  ) {
    lastBrowser = FakePlatformInAppBrowser(params);
    return lastBrowser!;
  }

  @override
  PlatformInAppBrowser createPlatformInAppBrowserStatic() {
    return FakePlatformInAppBrowser();
  }

  @override
  PlatformHeadlessInAppWebView createPlatformHeadlessInAppWebView(
    PlatformHeadlessInAppWebViewCreationParams params,
  ) {
    lastHeadless = FakePlatformHeadlessInAppWebView(params);
    return lastHeadless!;
  }

  @override
  PlatformInAppLocalhostServer createPlatformInAppLocalhostServer(
    PlatformInAppLocalhostServerCreationParams params,
  ) {
    lastLocalhostServer = FakePlatformInAppLocalhostServer(params);
    return lastLocalhostServer!;
  }

  @override
  PlatformInAppWebViewController createPlatformInAppWebViewController(
    PlatformInAppWebViewControllerCreationParams params,
  ) {
    return FakePlatformInAppWebViewController(id: params.id);
  }

  @override
  PlatformInAppWebViewController createPlatformInAppWebViewControllerStatic() {
    return FakePlatformInAppWebViewControllerStatic();
  }

  @override
  PlatformAssetsPathHandler createPlatformAssetsPathHandler(
    PlatformAssetsPathHandlerCreationParams params,
  ) {
    return FakePlatformAssetsPathHandler(params);
  }

  @override
  PlatformFindInteractionController createPlatformFindInteractionController(
    PlatformFindInteractionControllerCreationParams params,
  ) {
    return FakePlatformFindInteractionController(params);
  }

  @override
  PlatformPullToRefreshController createPlatformPullToRefreshController(
    PlatformPullToRefreshControllerCreationParams params,
  ) {
    return FakePlatformPullToRefreshController(params);
  }

  @override
  PlatformHttpAuthCredentialDatabase createPlatformHttpAuthCredentialDatabase(
    PlatformHttpAuthCredentialDatabaseCreationParams params,
  ) {
    return FakePlatformHttpAuthCredentialDatabase(params);
  }

  @override
  PlatformChromeSafariBrowser createPlatformChromeSafariBrowser(
    PlatformChromeSafariBrowserCreationParams params,
  ) {
    return FakePlatformChromeSafariBrowser(params);
  }

  @override
  PlatformChromeSafariBrowser createPlatformChromeSafariBrowserStatic() {
    return FakePlatformChromeSafariBrowserStatic();
  }

  @override
  PlatformPrintJobController createPlatformPrintJobController(
    PlatformPrintJobControllerCreationParams params,
  ) {
    return FakePlatformPrintJobController(
      id: params.id,
      onComplete: params.onComplete,
    );
  }

  @override
  PlatformWebStorage createPlatformWebStorage(
    PlatformWebStorageCreationParams params,
  ) {
    return FakePlatformWebStorage(
      localStorage: params.localStorage,
      sessionStorage: params.sessionStorage,
    );
  }

  @override
  PlatformLocalStorage createPlatformLocalStorage(
    PlatformLocalStorageCreationParams params,
  ) {
    return FakePlatformLocalStorage(controller: params.controller);
  }

  @override
  PlatformSessionStorage createPlatformSessionStorage(
    PlatformSessionStorageCreationParams params,
  ) {
    return FakePlatformSessionStorage(controller: params.controller);
  }

  @override
  PlatformCookieManager createPlatformCookieManager(
    PlatformCookieManagerCreationParams params,
  ) {
    return FakePlatformCookieManager();
  }

  @override
  PlatformProxyController createPlatformProxyController(
    PlatformProxyControllerCreationParams params,
  ) {
    return FakePlatformProxyController();
  }

  @override
  PlatformTracingController createPlatformTracingController(
    PlatformTracingControllerCreationParams params,
  ) {
    return FakePlatformTracingController();
  }

  @override
  PlatformWebStorageManager createPlatformWebStorageManager(
    PlatformWebStorageManagerCreationParams params,
  ) {
    return FakePlatformWebStorageManager();
  }

  @override
  PlatformResourcesPathHandler createPlatformResourcesPathHandler(
    PlatformResourcesPathHandlerCreationParams params,
  ) {
    return FakePlatformResourcesPathHandler(params);
  }

  @override
  PlatformInternalStoragePathHandler createPlatformInternalStoragePathHandler(
    PlatformInternalStoragePathHandlerCreationParams params,
  ) {
    return FakePlatformInternalStoragePathHandler(params);
  }

  @override
  PlatformCustomPathHandler createPlatformCustomPathHandler(
    PlatformCustomPathHandlerCreationParams params,
  ) {
    return FakePlatformCustomPathHandler(params);
  }

  @override
  PlatformWebAuthenticationSession createPlatformWebAuthenticationSession(
    PlatformWebAuthenticationSessionCreationParams params,
  ) {
    return FakePlatformWebAuthenticationSession(params: params);
  }

  @override
  PlatformWebAuthenticationSession createPlatformWebAuthenticationSessionStatic() {
    return FakePlatformWebAuthenticationSessionStatic();
  }

  @override
  PlatformWebMessageListener createPlatformWebMessageListener(
    PlatformWebMessageListenerCreationParams params,
  ) {
    return FakePlatformWebMessageListener(
      jsObjectName: params.jsObjectName,
      allowedOriginRules: params.allowedOriginRules,
      onPostMessage: params.onPostMessage,
    );
  }

  @override
  PlatformJavaScriptReplyProxy createPlatformJavaScriptReplyProxy(
    PlatformJavaScriptReplyProxyCreationParams params,
  ) {
    return FakePlatformJavaScriptReplyProxy(params.webMessageListener);
  }

  @override
  PlatformWebMessagePort createPlatformWebMessagePort(
    PlatformWebMessagePortCreationParams params,
  ) {
    return FakePlatformWebMessagePort(index: params.index);
  }

  @override
  PlatformWebMessageChannel createPlatformWebMessageChannel(
    PlatformWebMessageChannelCreationParams params,
  ) {
    return FakePlatformWebMessageChannel._(params: params);
  }

  @override
  PlatformWebMessageChannel createPlatformWebMessageChannelStatic() {
    return FakePlatformWebMessageChannelStatic();
  }

  @override
  PlatformWebViewEnvironment createPlatformWebViewEnvironment(
    PlatformWebViewEnvironmentCreationParams params,
  ) {
    return FakePlatformWebViewEnvironment();
  }

  @override
  PlatformWebViewEnvironment createPlatformWebViewEnvironmentStatic() {
    return sharedWebViewEnvironmentStatic;
  }

  @override
  PlatformServiceWorkerController createPlatformServiceWorkerController(
    PlatformServiceWorkerControllerCreationParams params,
  ) {
    return FakePlatformServiceWorkerController(params);
  }

  @override
  PlatformServiceWorkerController createPlatformServiceWorkerControllerStatic() {
    return sharedServiceWorkerController;
  }

  @override
  PlatformProcessGlobalConfig createPlatformProcessGlobalConfig(
    PlatformProcessGlobalConfigCreationParams params,
  ) {
    return sharedProcessGlobalConfig;
  }
}
