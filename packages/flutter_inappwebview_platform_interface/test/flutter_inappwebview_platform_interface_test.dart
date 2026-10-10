import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_inappwebview_platform_interface/src/in_app_webview/in_app_webview_keep_alive.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WebStorageItem', () {
    test('should hold key and value', () {
      final item = WebStorageItem(key: 'foo', value: 'bar');
      expect(item.key, 'foo');
      expect(item.value, 'bar');
    });
  });

  group('WebStorageOrigin', () {
    test('should expose origin quota and usage', () {
      final origin = WebStorageOrigin(
        origin: 'https://example.com',
        quota: 1000,
        usage: 100,
      );
      expect(origin.origin, 'https://example.com');
      expect(origin.quota, 1000);
      expect(origin.usage, 100);
    });
  });

  group('WebsiteDataRecord', () {
    test('should expose displayName and dataTypes', () {
      final record = WebsiteDataRecord(
        displayName: 'example.com',
        dataTypes: {WebsiteDataType.WKWebsiteDataTypeLocalStorage},
      );
      expect(record.displayName, 'example.com');
      expect(record.dataTypes, isNotEmpty);
    });
  });

  group('PrintJobInfo', () {
    test('should expose print job state', () {
      final info = PrintJobInfo(state: PrintJobState.COMPLETED);
      expect(info.state, PrintJobState.COMPLETED);
    });
  });

  group('InAppWebViewKeepAlive', () {
    test('should expose id', () {
      final keepAlive = InAppWebViewKeepAlive();
      expect(keepAlive.id, isNotEmpty);
    });
  });
}
