import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:PiliPlus/utils/platform_utils.dart';

void main() {
  test('mobile lifecycle applies on HarmonyOS', () {
    if (Platform.operatingSystem == 'ohos') {
      expect(PlatformUtils.isHarmonyOS, isTrue);
      expect(PlatformUtils.isMobile, isTrue);
      expect(PlatformUtils.isDesktop, isFalse);
    } else {
      expect(PlatformUtils.isHarmonyOS, isFalse);
    }
  });
  test('desktop lifecycle remains exclusive of mobile lifecycle', () {
    if (PlatformUtils.isDesktop) {
      expect(PlatformUtils.isMobile, isFalse);
    }
  });
}
