import 'dart:io' show Platform;

abstract final class PlatformUtils {
  /// Use the OS name so Android/iOS SDKs can still compile this shared file.
  @pragma('vm:platform-const')
  static final bool isHarmonyOS = Platform.operatingSystem == 'ohos';
  @pragma("vm:platform-const")
  static final bool isMobile =
      Platform.isAndroid || Platform.isIOS || isHarmonyOS;

  @pragma("vm:platform-const")
  static final bool isDesktop =
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  @pragma("vm:platform-const")
  static final bool isDarwin = Platform.isIOS || Platform.isMacOS;
}
