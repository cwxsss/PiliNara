import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WebUri', () {
    test('parses valid https URL and exposes components', () {
      final uri = WebUri('https://example.com:8443/path?q=1#frag');
      expect(uri.isValidUri, isTrue);
      expect(uri.scheme, 'https');
      expect(uri.host, 'example.com');
      expect(uri.port, 8443);
      expect(uri.path, '/path');
      expect(uri.query, 'q=1');
      expect(uri.fragment, 'frag');
      expect(uri.toString(), contains('example.com'));
    });

    test('WebUri.uri preserves source Uri', () {
      final source = Uri.parse('https://flutter.dev/docs');
      final uri = WebUri.uri(source);
      expect(uri.host, 'flutter.dev');
      expect(uri.path, '/docs');
    });
  });

  group('Util and DebugLoggingSettings', () {
    test('Util platform flags are booleans', () {
      expect(Util.isAndroid, isA<bool>());
      expect(Util.isIOS, isA<bool>());
      expect(Util.isOhos, isA<bool>());
      expect(Util.isMacOS, isA<bool>());
      expect(Util.isWindows, isA<bool>());
      expect(Util.isLinux, isA<bool>());
      expect(Util.isWeb, isA<bool>());
      expect(Util.isFuchsia, isA<bool>());
    });

    test('DebugLoggingSettings exposes defaults and mutability', () {
      final settings = DebugLoggingSettings();
      expect(settings.enabled, isA<bool>());
      settings.enabled = true;
      expect(settings.enabled, isTrue);
    });
  });

  group('ContentBlocker', () {
    test('trigger action and serialization', () {
      final blocker = ContentBlocker(
        trigger: ContentBlockerTrigger(urlFilter: '.*ads.*'),
        action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK),
      );
      expect(blocker.trigger.urlFilter, '.*ads.*');
      expect(blocker.action.type, ContentBlockerActionType.BLOCK);
      expect(blocker.toMap()['trigger'], isNotNull);
      expect(ContentBlockerActionType.BLOCK.toValue(), isNotNull);
      expect(
        ContentBlockerTrigger(urlFilter: '.*').toMap()['url-filter'],
        '.*',
      );
    });
  });

  group('ContentWorld and Sandbox', () {
    test('ContentWorld factories', () {
      expect(ContentWorld.PAGE.name, isNotEmpty);
      expect(ContentWorld.DEFAULT_CLIENT.name, isNotEmpty);
      final custom = ContentWorld.world(name: 'custom');
      expect(custom.name, 'custom');
    });

    test('Sandbox values expose toValue', () {
      expect(Sandbox.ALLOW_SCRIPTS.toValue(), 'allow-scripts');
      expect(Sandbox.ALLOW_FORMS.toNativeValue(), 'allow-forms');
    });
  });

  group('ContextMenu', () {
    test('ContextMenu ContextMenuItem ContextMenuSettings', () {
      final item = ContextMenuItem(id: 1, title: 'Copy');
      final settings =
          ContextMenuSettings(hideDefaultSystemContextMenuItems: true);
      final menu = ContextMenu(menuItems: [item], settings: settings);

      expect(menu.menuItems.first.title, 'Copy');
      expect(menu.toMap()['menuItems'], isNotEmpty);
      expect(item.toMap()['id'], 1);
      expect(settings.toMap()['hideDefaultSystemContextMenuItems'], isTrue);
      expect(settings.copy().hideDefaultSystemContextMenuItems, isTrue);
      expect(ContextMenu.fromMap(null), isNull);
      expect(ContextMenuItem.fromMap(null), isNull);
      expect(ContextMenuSettings.fromMap(null), isNull);
    });
  });

  group('Settings models', () {
    test('InAppWebViewSettings PullToRefreshSettings PrintJobSettings', () {
      final webSettings = InAppWebViewSettings(javaScriptEnabled: true);
      expect(webSettings.toMap()['javaScriptEnabled'], isTrue);
      expect(InAppWebViewSettings.fromMap(null), isNull);

      final pull = PullToRefreshSettings(enabled: true);
      expect(pull.toMap()['enabled'], isTrue);
      expect(PullToRefreshSettings.fromMap(null), isNull);

      final printSettings = PrintJobSettings();
      expect(printSettings.toMap(), isA<Map>());
      expect(PrintJobSettings.fromMap(null), isNull);
    });

    test('ProxySettings TracingSettings ProcessGlobalConfigSettings', () {
      final proxy = ProxySettings();
      expect(proxy.toMap(), isA<Map>());
      expect(ProxySettings.fromMap(null), isNull);

      final tracing = TracingSettings(categories: ['blink']);
      expect(tracing.toMap(), isA<Map>());
      expect(TracingSettings.fromMap(null), isNull);

      final process = ProcessGlobalConfigSettings(
        dataDirectorySuffix: 'suffix',
      );
      expect(process.toMap()['dataDirectorySuffix'], 'suffix');
      expect(ProcessGlobalConfigSettings.fromMap(null), isNull);
    });

    test('WebViewEnvironmentSettings WebAuthenticationSessionSettings', () {
      final env = WebViewEnvironmentSettings();
      expect(env.toMap(), isA<Map>());
      expect(WebViewEnvironmentSettings.fromMap(null), isNull);

      final auth = WebAuthenticationSessionSettings();
      expect(auth.toMap(), isA<Map>());
      expect(WebAuthenticationSessionSettings.fromMap(null), isNull);
    });
  });

  group('WebMessage WebViewFeature WebStorageItem', () {
    test('WebMessage type helpers', () {
      final message = WebMessage(data: 'hello');
      expect(message.data, 'hello');
      expect(WebMessageType.STRING.toValue(), isNotNull);
      expect(WebMessageType.ARRAY_BUFFER.toValue(), isNotNull);
    });

    test('WebViewFeature constants are non-empty', () {
      expect(WebViewFeature.CREATE_WEB_MESSAGE_CHANNEL.toValue(), isNotEmpty);
      expect(WebViewFeature.fromNativeValue(
        WebViewFeature.CREATE_WEB_MESSAGE_CHANNEL.toNativeValue(),
      ), isNotNull);
    });

    test('WebStorageItem already covered helpers stay available', () {
      final item = WebStorageItem(key: 'k', value: 'v');
      expect(item.key, 'k');
      expect(item.value, 'v');
    });
  });
}
