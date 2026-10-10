/// Demo 首页导航
///
/// 21 个 flutter_inappwebview OHOS 接口演示入口页。
/// 点击卡片进入对应的 Demo 页面。

import 'package:flutter/material.dart';

import '001_webview_create_load/webview_create_load_page.dart';
import '002_url_intercept_error/url_intercept_error_page.dart';
import '003_js_interaction/js_interaction_page.dart';
import '004_webview_settings/webview_settings_page.dart';
import '005_dark_mode_multiwindow/dark_mode_multiwindow_page.dart';
import '006_page_info_nav/page_info_nav_page.dart';
import '007_scroll_content_size/scroll_content_size_page.dart';
import '008_zoom_control/zoom_control_page.dart';
import '009_cookie_manage/cookie_manage_page.dart';
import '010_webstorage_local/webstorage_local_page.dart';
import '011_webstorage_manager/webstorage_manager_page.dart';
import '012_find_content/find_content_page.dart';
import '013_proxy_config/proxy_config_page.dart';
import '014_pull_refresh/pull_refresh_page.dart';
import '015_resource_intercept/resource_intercept_page.dart';
import '016_content_blocker/content_blocker_page.dart';
import '017_print_job/print_job_page.dart';
import '018_http_auth/http_auth_page.dart';
import '019_weburi_parse/weburi_parse_page.dart';
import '020_inapp_browser/inapp_browser_page.dart';
import '021_keepalive_instance/keepalive_instance_page.dart';
import '022_headless_webview/headless_webview_page.dart';
import '023_content_extract/content_extract_page.dart';
import '024_cache_state/cache_state_page.dart';
import '025_context_menu_nav/context_menu_nav_page.dart';
import '026_callback_events/callback_events_page.dart';
import '027_advanced_settings/advanced_settings_page.dart';
import '028_refresh_find_asset/refresh_find_asset_page.dart';
import '029_webview_js_prompt/webview_js_prompt_page.dart';
import '030_webview_lifecycle_crash/webview_lifecycle_crash_page.dart';

/// DemoHomePage - Demo 导航首页
///
/// 以列表卡片形式展示 21 个 Demo，点击进入对应页面。
class DemoHomePage extends StatelessWidget {
  const DemoHomePage({super.key});

  static const _demoList = <_DemoEntry>[
    _DemoEntry('001', 'WebView 创建与加载',
        'InAppWebView 创建、initialUrlRequest/initialFile/initialData、onWebViewCreated/onLoadStart/onLoadStop/onProgressChanged'),
    _DemoEntry('002', 'URL 拦截与错误处理',
        'shouldOverrideUrlLoading、onReceivedError/onReceivedHttpError、onConsoleMessage、onPermissionRequest'),
    _DemoEntry('003', 'JS 交互',
        'evaluateJavascript、addJavaScriptHandler/removeJavaScriptHandler/hasJavaScriptHandler、onJsAlert/onJsConfirm/onJsPrompt'),
    _DemoEntry('004', 'WebView 设置',
        'InAppWebViewSettings、setSettings/getSettings'),
    _DemoEntry('005', '暗色模式与多窗口',
        'forceDark/ForceDark、contentBlockers、allowFileAccess/domStorageEnabled/supportMultipleWindows'),
    _DemoEntry('006', '页面信息与导航',
        'getUrl/getTitle/getProgress、canGoBack/canGoForward/goBack/reload/loadUrl'),
    _DemoEntry('007', '滚动与内容尺寸',
        'getScrollX/getScrollY/scrollTo/scrollBy、getContentHeight/getContentWidth、pause/resume'),
    _DemoEntry('008', '缩放控制',
        'onZoomScaleChanged、textZoom via setSettings'),
    _DemoEntry('009', 'Cookie 管理',
        'CookieManager setCookie/getCookies/deleteCookie/deleteAllCookies'),
    _DemoEntry('010', 'WebStorage 本地存储',
        'localStorage/sessionStorage setItem/getItem/removeItem/clear/length'),
    _DemoEntry('011', 'WebStorageManager',
        'getOrigins/deleteAllData/deleteOrigin/getQuotaForOrigin/getUsageForOrigin'),
    _DemoEntry('012', '页面内容查找',
        'FindInteractionController findAll/findNext/clearMatches、onFindResultReceived'),
    _DemoEntry('013', '网络代理配置',
        'ProxyController setProxyOverride/clearProxyOverride'),
    _DemoEntry('014', '下拉刷新控制',
        'PullToRefreshController setEnabled/beginRefreshing/endRefreshing/isRefreshing'),
    _DemoEntry('015', '资源加载拦截',
        'shouldInterceptRequest/shouldInterceptAjaxRequest、WebViewAssetLoader PathHandler'),
    _DemoEntry('016', '内容拦截规则',
        'ContentBlocker/ContentBlockerTrigger/ContentBlockerAction'),
    _DemoEntry('017', '打印任务控制',
        'PrintJobController cancel/restart/dismiss/getInfo/dispose/onComplete'),
    _DemoEntry('018', 'HTTP 认证凭据',
        'HttpAuthCredentialDatabase CRUD、URLProtectionSpace/URLCredential'),
    _DemoEntry('019', 'WebUri URI 解析',
        'WebUri 属性与方法 replace/resolve/removeFragment/normalizePath'),
    _DemoEntry('020', '独立浏览器窗口',
        'InAppBrowser openUrlRequest/show/hide/close/isOpened/isHidden'),
    _DemoEntry('021', 'KeepAlive 实例',
        'InAppWebViewKeepAlive 构造与 API 限制说明'),
    _DemoEntry('022', '无头 WebView',
        'HeadlessInAppWebView run/isRunning/getSize/setSize/dispose、后台内容抓取'),
    _DemoEntry('023', '页面内容提取',
        'getHtml/getMetaTags/getMetaThemeColor/getFavicons/getSelectedText/getHitTestResult/getCertificate/takeScreenshot'),
    _DemoEntry('024', '缓存与状态管理',
        'clearAllCache/clearCache/clearFocus/clearHistory/clearSslPreferences/getDefaultUserAgent/isLoading/stopLoading/pauseTimers/resumeTimers/saveWebArchive/isSecureContext'),
    _DemoEntry('025', '上下文菜单与高级导航',
        'setContextMenu/ContextMenuItem、goForward/goBackOrForward/goTo/canGoBackOrForward/getCopyBackForwardList、callAsyncJavaScript'),
    _DemoEntry('026', '回调事件合集',
        'onLoadResource/onDownloadStartRequest/onCloseWindow/onFormResubmission/onOverScrolled/onEnterFullscreen/onExitFullscreen/onPrintRequest/onGeolocationPermissionsShowPrompt/onRenderProcessGone'),
    _DemoEntry('027', '高级设置项',
        'blockNetworkImage/blockNetworkLoads/minimumFontSize/databaseEnabled/initialScale/mixedContentMode/layoutAlgorithm/preferredContentMode 等'),
    _DemoEntry('028', '刷新外观/查找会话/AssetLoader',
        'PullToRefreshController setColor/setBackgroundColor/setDistanceToTriggerSync/setSlingshotDistance/setIndicatorSize、getActiveFindSession、AssetsPathHandler/ResourcesPathHandler/InternalStoragePathHandler'),
    _DemoEntry('029', 'JS Prompt 回调丢失/销毁兜底',
        'onJsPrompt 回调在 WebView 销毁时的兜底机制；50 次 prompt 连发 + 立即 dispose 压力测试'),
    _DemoEntry('030', '生命周期竞态崩溃回归',
        'onAreaChange 生命周期竞态、controller 解绑窗口、prompt 在途 JsResult、孤儿弹框治理；尺寸抖动 + create/dispose 循环 + prompt 连发组合场景'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('flutter_inappwebview OHOS Demo'),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _demoList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final entry = _demoList[index];
          return _DemoCard(entry: entry, index: index);
        },
      ),
    );
  }
}

/// Demo 条目数据
class _DemoEntry {
  final String id;
  final String title;
  final String description;

  const _DemoEntry(this.id, this.title, this.description);
}

/// Demo 卡片
class _DemoCard extends StatelessWidget {
  const _DemoCard({required this.entry, required this.index});

  final _DemoEntry entry;
  final int index;

  Widget _buildPage() {
    switch (entry.id) {
      case '001':
        return const WebViewCreateLoadPage();
      case '002':
        return const UrlInterceptErrorPage();
      case '003':
        return const JsInteractionPage();
      case '004':
        return const WebviewSettingsPage();
      case '005':
        return const DarkModeMultiwindowPage();
      case '006':
        return const PageInfoNavPage();
      case '007':
        return const ScrollContentSizePage();
      case '008':
        return const ZoomControlPage();
      case '009':
        return const CookieManagePage();
      case '010':
        return const WebstorageLocalPage();
      case '011':
        return const WebstorageManagerPage();
      case '012':
        return const FindContentPage();
      case '013':
        return const ProxyConfigPage();
      case '014':
        return const PullRefreshPage();
      case '015':
        return const ResourceInterceptPage();
      case '016':
        return const ContentBlockerPage();
      case '017':
        return const PrintJobPage();
      case '018':
        return const HttpAuthPage();
      case '019':
        return const WeburiParsePage();
      case '020':
        return const InappBrowserPage();
      case '021':
        return const KeepaliveInstancePage();
      case '022':
        return const HeadlessWebViewPage();
      case '023':
        return const ContentExtractPage();
      case '024':
        return const CacheStatePage();
      case '025':
        return const ContextMenuNavPage();
      case '026':
        return const CallbackEventsPage();
      case '027':
        return const AdvancedSettingsPage();
      case '028':
        return const RefreshFindAssetPage();
      case '029':
        return const WebviewJsPromptPage();
      case '030':
        return const WebviewLifecycleCrashPage();
      default:
        return Scaffold(
          appBar: AppBar(title: const Text('未知')),
          body: const Center(child: Text('未找到对应 Demo')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => _buildPage()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 序号圆角标
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    entry.id,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 标题与描述
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
