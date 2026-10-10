import '../../lib/utils/platform_utils.dart';

void main() {
  if (PlatformUtils.isHarmonyOS) {
    if (!PlatformUtils.isMobile || PlatformUtils.isDesktop) {
      throw StateError('HarmonyOS must be a mobile platform');
    }
  }
  if (PlatformUtils.isDesktop && PlatformUtils.isMobile) {
    throw StateError('Desktop and mobile classifications overlap');
  }
  print('Platform classification passed on this host');
}
