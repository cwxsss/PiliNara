import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _FakePlatform extends InAppWebViewPlatform {
  @override
  PlatformCookieManager createPlatformCookieManager(
    PlatformCookieManagerCreationParams params,
  ) =>
      _FakeCookieManager();

  @override
  PlatformProxyController createPlatformProxyController(
    PlatformProxyControllerCreationParams params,
  ) =>
      _FakeProxyController();

  @override
  PlatformTracingController createPlatformTracingController(
    PlatformTracingControllerCreationParams params,
  ) =>
      _FakeTracingController();

  @override
  PlatformProcessGlobalConfig createPlatformProcessGlobalConfig(
    PlatformProcessGlobalConfigCreationParams params,
  ) =>
      _FakeProcessGlobalConfig();

  @override
  PlatformServiceWorkerController createPlatformServiceWorkerController(
    PlatformServiceWorkerControllerCreationParams params,
  ) =>
      _FakeServiceWorkerController();

  @override
  PlatformServiceWorkerController
      createPlatformServiceWorkerControllerStatic() =>
          _FakeServiceWorkerController();

  @override
  PlatformWebViewFeature createPlatformWebViewFeature(
    PlatformWebViewFeatureCreationParams params,
  ) =>
      _FakeWebViewFeature();

  @override
  PlatformWebViewFeature createPlatformWebViewFeatureStatic() =>
      _FakeWebViewFeature();

  @override
  PlatformWebViewEnvironment createPlatformWebViewEnvironment(
    PlatformWebViewEnvironmentCreationParams params,
  ) =>
      _FakeWebViewEnvironment();

  @override
  PlatformWebViewEnvironment createPlatformWebViewEnvironmentStatic() =>
      _FakeWebViewEnvironment();

  @override
  PlatformHttpAuthCredentialDatabase createPlatformHttpAuthCredentialDatabase(
    PlatformHttpAuthCredentialDatabaseCreationParams params,
  ) =>
      _FakeHttpAuthDb();

  @override
  PlatformWebStorageManager createPlatformWebStorageManager(
    PlatformWebStorageManagerCreationParams params,
  ) =>
      _FakeWebStorageManager();

  @override
  PlatformFindInteractionController createPlatformFindInteractionController(
    PlatformFindInteractionControllerCreationParams params,
  ) =>
      _FakeFindInteractionController(params);

  @override
  PlatformPullToRefreshController createPlatformPullToRefreshController(
    PlatformPullToRefreshControllerCreationParams params,
  ) =>
      _FakePullToRefreshController(params);

  @override
  PlatformPrintJobController createPlatformPrintJobController(
    PlatformPrintJobControllerCreationParams params,
  ) =>
      _FakePrintJobController(params);

  @override
  PlatformInAppLocalhostServer createPlatformInAppLocalhostServer(
    PlatformInAppLocalhostServerCreationParams params,
  ) =>
      _FakeLocalhostServer(params);
}

class _FakeCookieManager extends PlatformCookieManager
    with MockPlatformInterfaceMixin {
  _FakeCookieManager()
      : super.implementation(const PlatformCookieManagerCreationParams());

  @override
  Future<bool> setCookie({
    required WebUri url,
    required String name,
    required String value,
    String path = '/',
    String? domain,
    int? expiresDate,
    int? maxAge,
    bool? isSecure,
    bool? isHttpOnly,
    HTTPCookieSameSitePolicy? sameSite,
    PlatformInAppWebViewController? iosBelow11WebViewController,
    PlatformInAppWebViewController? webViewController,
  }) async =>
      true;

  @override
  Future<List<Cookie>> getCookies({
    required WebUri url,
    PlatformInAppWebViewController? iosBelow11WebViewController,
    PlatformInAppWebViewController? webViewController,
  }) async =>
      [];

  @override
  Future<Cookie?> getCookie({
    required WebUri url,
    required String name,
    PlatformInAppWebViewController? iosBelow11WebViewController,
    PlatformInAppWebViewController? webViewController,
  }) async =>
      null;

  @override
  Future<bool> deleteCookie({
    required WebUri url,
    required String name,
    String path = '/',
    String? domain,
    PlatformInAppWebViewController? iosBelow11WebViewController,
    PlatformInAppWebViewController? webViewController,
  }) async =>
      true;

  @override
  Future<bool> deleteCookies({
    required WebUri url,
    String path = '/',
    String? domain,
    PlatformInAppWebViewController? iosBelow11WebViewController,
    PlatformInAppWebViewController? webViewController,
  }) async =>
      true;

  @override
  Future<bool> deleteAllCookies() async => true;

  @override
  Future<List<Cookie>> getAllCookies() async => [];

  @override
  Future<bool> removeSessionCookies() async => true;
}

class _FakeProxyController extends PlatformProxyController
    with MockPlatformInterfaceMixin {
  _FakeProxyController()
      : super.implementation(const PlatformProxyControllerCreationParams());

  @override
  Future<void> clearProxyOverride({bool reload = true}) async {}

  @override
  Future<void> setProxyOverride({required ProxySettings settings}) async {}
}

class _FakeTracingController extends PlatformTracingController
    with MockPlatformInterfaceMixin {
  _FakeTracingController()
      : super.implementation(const PlatformTracingControllerCreationParams());

  @override
  Future<bool> isTracing() async => false;

  @override
  Future<void> start({required TracingSettings settings}) async {}

  @override
  Future<bool> stop({String? filePath}) async => true;
}

class _FakeProcessGlobalConfig extends PlatformProcessGlobalConfig
    with MockPlatformInterfaceMixin {
  _FakeProcessGlobalConfig()
      : super.implementation(const PlatformProcessGlobalConfigCreationParams());

  @override
  Future<void> apply({required ProcessGlobalConfigSettings settings}) async {}
}

class _FakeServiceWorkerController extends PlatformServiceWorkerController
    with MockPlatformInterfaceMixin {
  _FakeServiceWorkerController()
      : super.implementation(
            const PlatformServiceWorkerControllerCreationParams());

  ServiceWorkerClient? _client;

  @override
  ServiceWorkerClient? get serviceWorkerClient => _client;

  @override
  Future<void> setServiceWorkerClient(ServiceWorkerClient? value) async {
    _client = value;
  }

  @override
  Future<bool> getAllowContentAccess() async => true;

  @override
  Future<bool> getAllowFileAccess() async => true;

  @override
  Future<bool> getBlockNetworkLoads() async => false;

  @override
  Future<CacheMode?> getCacheMode() async => CacheMode.LOAD_DEFAULT;

  @override
  Future<void> setAllowContentAccess(bool allow) async {}

  @override
  Future<void> setAllowFileAccess(bool allow) async {}

  @override
  Future<void> setBlockNetworkLoads(bool flag) async {}

  @override
  Future<void> setCacheMode(CacheMode mode) async {}
}

class _FakeWebViewFeature extends PlatformWebViewFeature
    with MockPlatformInterfaceMixin {
  _FakeWebViewFeature()
      : super.implementation(const PlatformWebViewFeatureCreationParams());

  @override
  Future<bool> isFeatureSupported(WebViewFeature feature) async => true;

  @override
  Future<bool> isStartupFeatureSupported(WebViewFeature feature) async => true;
}

class _FakeWebViewEnvironment extends PlatformWebViewEnvironment
    with MockPlatformInterfaceMixin {
  _FakeWebViewEnvironment()
      : super.implementation(const PlatformWebViewEnvironmentCreationParams());

  @override
  String get id => 'env';

  @override
  Future<PlatformWebViewEnvironment> create(
      {WebViewEnvironmentSettings? settings}) async =>
      this;

  @override
  Future<String?> getAvailableVersion({String? browserExecutableFolder}) async =>
      '1.0.0';

  @override
  Future<int?> compareBrowserVersions(
          {required String version1, required String version2}) async =>
      0;

  @override
  Future<void> dispose() async {}
}

class _FakeHttpAuthDb extends PlatformHttpAuthCredentialDatabase
    with MockPlatformInterfaceMixin {
  _FakeHttpAuthDb()
      : super.implementation(
            const PlatformHttpAuthCredentialDatabaseCreationParams());

  @override
  Future<List<URLProtectionSpaceHttpAuthCredentials>>
      getAllAuthCredentials() async => [];

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
  Future<void> clearAllAuthCredentials() async {}
}

class _FakeWebStorageManager extends PlatformWebStorageManager
    with MockPlatformInterfaceMixin {
  _FakeWebStorageManager()
      : super.implementation(const PlatformWebStorageManagerCreationParams());

  @override
  Future<void> deleteOrigin({required String origin}) async {}

  @override
  Future<List<WebStorageOrigin>> getOrigins() async => [];

  @override
  Future<int> getQuotaForOrigin({required String origin}) async => 0;

  @override
  Future<int> getUsageForOrigin({required String origin}) async => 0;

  @override
  Future<List<WebsiteDataRecord>> fetchDataRecords(
          {required Set<WebsiteDataType> dataTypes}) async =>
      [];

  @override
  Future<void> removeDataFor(
      {required Set<WebsiteDataType> dataTypes,
      required List<WebsiteDataRecord> dataRecords}) async {}

  @override
  Future<void> removeDataModifiedSince(
      {required Set<WebsiteDataType> dataTypes, required DateTime date}) async {}
}

class _FakeFindInteractionController extends PlatformFindInteractionController
    with MockPlatformInterfaceMixin {
  _FakeFindInteractionController(
      PlatformFindInteractionControllerCreationParams params)
      : super.implementation(params);

  @override
  Future<void> findAll({String? find}) async {}

  @override
  Future<void> findNext({bool forward = true}) async {}

  @override
  Future<void> clearMatches() async {}

  @override
  Future<void> setSearchText(String? searchText) async {}

  @override
  Future<String?> getSearchText() async => null;

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
  void dispose({bool isKeepAlive = false}) {}
}

class _FakePullToRefreshController extends PlatformPullToRefreshController
    with MockPlatformInterfaceMixin {
  _FakePullToRefreshController(
      PlatformPullToRefreshControllerCreationParams params)
      : super.implementation(params);

  @override
  Future<void> setEnabled(bool enabled) async {}

  @override
  Future<bool> isEnabled() async => true;

  @override
  Future<void> beginRefreshing() async {}

  @override
  Future<void> endRefreshing() async {}

  @override
  Future<bool> isRefreshing() async => false;

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
  Future<void> setSize(AndroidPullToRefreshSize size) async {}

  @override
  Future<void> setIndicatorSize(PullToRefreshSize size) async {}

  @override
  Future<void> setStyledTitle(AttributedString attributedTitle) async {}

  @override
  Future<void> setAttributedTitle(IOSNSAttributedString attributedTitle) async {}

  @override
  void dispose({bool isKeepAlive = false}) {}
}

class _FakePrintJobController extends PlatformPrintJobController
    with MockPlatformInterfaceMixin {
  _FakePrintJobController(PlatformPrintJobControllerCreationParams params)
      : super.implementation(params);

  @override
  Future<void> cancel() async {}

  @override
  Future<void> restart() async {}

  @override
  Future<void> dismiss({bool animated = true}) async {}

  @override
  Future<PrintJobInfo?> getInfo() async =>
      PrintJobInfo(state: PrintJobState.COMPLETED);

  @override
  void dispose() {}
}

class _FakeLocalhostServer extends PlatformInAppLocalhostServer
    with MockPlatformInterfaceMixin {
  _FakeLocalhostServer(PlatformInAppLocalhostServerCreationParams params)
      : super.implementation(params);

  @override
  Future<void> start() async {}

  @override
  bool isRunning() => true;

  @override
  Future<void> close() async {}
}

void main() {
  late InAppWebViewPlatform? previous;

  setUp(() {
    previous = InAppWebViewPlatform.instance;
    InAppWebViewPlatform.instance = _FakePlatform();
  });

  tearDown(() {
    // PlatformInterface forbids resetting instance to null.
  });

  group('Platform interface factories', () {
    test('CookieManager Proxy Tracing ProcessGlobal ServiceWorker Feature',
        () async {
      final cookies = PlatformCookieManager(
        const PlatformCookieManagerCreationParams(),
      );
      expect(
        await cookies.setCookie(
          url: WebUri('https://example.com'),
          name: 'a',
          value: '1',
        ),
        isTrue,
      );

      final proxy = PlatformProxyController(
        const PlatformProxyControllerCreationParams(),
      );
      await proxy.setProxyOverride(settings: ProxySettings());
      await proxy.clearProxyOverride();

      final tracing = PlatformTracingController(
        const PlatformTracingControllerCreationParams(),
      );
      await tracing.start(settings: TracingSettings(categories: ['blink']));
      expect(await tracing.isTracing(), isFalse);
      expect(await tracing.stop(), isTrue);

      final process = PlatformProcessGlobalConfig(
        const PlatformProcessGlobalConfigCreationParams(),
      );
      await process.apply(settings: ProcessGlobalConfigSettings());

      final sw = PlatformServiceWorkerController(
        const PlatformServiceWorkerControllerCreationParams(),
      );
      await sw.setServiceWorkerClient(null);
      expect(await PlatformServiceWorkerController.static().getAllowContentAccess(),
          isTrue);

      expect(
        await PlatformWebViewFeature.static()
            .isFeatureSupported(WebViewFeature.CREATE_WEB_MESSAGE_CHANNEL),
        isTrue,
      );
    });

    test('WebViewEnvironment HttpAuth WebStorageManager controllers', () async {
      final env = await PlatformWebViewEnvironment.static().create();
      expect(env.id, 'env');
      expect(await PlatformWebViewEnvironment.static().getAvailableVersion(),
          '1.0.0');
      expect(
        await PlatformWebViewEnvironment.static().compareBrowserVersions(
          version1: '1',
          version2: '1',
        ),
        0,
      );
      await env.dispose();

      final db = PlatformHttpAuthCredentialDatabase(
        const PlatformHttpAuthCredentialDatabaseCreationParams(),
      );
      expect(await db.getAllAuthCredentials(), isEmpty);

      final storage = PlatformWebStorageManager(
        const PlatformWebStorageManagerCreationParams(),
      );
      expect(await storage.getOrigins(), isEmpty);
    });

    test('Find PullToRefresh PrintJob Localhost controllers', () async {
      final find = PlatformFindInteractionController(
        const PlatformFindInteractionControllerCreationParams(),
      );
      await find.findAll(find: 'a');
      find.dispose();

      final pull = PlatformPullToRefreshController(
        PlatformPullToRefreshControllerCreationParams(
          onRefresh: null,
        ),
      );
      await pull.setEnabled(true);
      pull.dispose();

      final printJob = PlatformPrintJobController(
        PlatformPrintJobControllerCreationParams(id: 'job-1'),
      );
      expect((await printJob.getInfo())?.state, PrintJobState.COMPLETED);
      printJob.dispose();

      final server = PlatformInAppLocalhostServer(
        const PlatformInAppLocalhostServerCreationParams(),
      );
      await server.start();
      expect(await server.isRunning(), isTrue);
      await server.close();
    });

    test('creation params objects are constructible', () {
      expect(const PlatformCookieManagerCreationParams(), isNotNull);
      expect(const PlatformProxyControllerCreationParams(), isNotNull);
      expect(const PlatformTracingControllerCreationParams(), isNotNull);
      expect(const PlatformProcessGlobalConfigCreationParams(), isNotNull);
      expect(const PlatformServiceWorkerControllerCreationParams(), isNotNull);
      expect(const PlatformWebViewFeatureCreationParams(), isNotNull);
      expect(const PlatformWebViewEnvironmentCreationParams(), isNotNull);
      expect(const PlatformHttpAuthCredentialDatabaseCreationParams(), isNotNull);
      expect(const PlatformWebStorageManagerCreationParams(), isNotNull);
      expect(const PlatformFindInteractionControllerCreationParams(), isNotNull);
      expect(const PlatformInAppLocalhostServerCreationParams(), isNotNull);
      expect(PlatformPrintJobControllerCreationParams(id: 'x'), isNotNull);
      expect(
        PlatformPullToRefreshControllerCreationParams(onRefresh: null),
        isNotNull,
      );
    });
  });
}
