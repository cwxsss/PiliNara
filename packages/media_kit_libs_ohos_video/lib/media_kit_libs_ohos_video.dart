
import 'media_kit_libs_ohos_video_platform_interface.dart';

class MediaKitLibsOhosVideo {
  Future<String?> getPlatformVersion() {
    return MediaKitLibsOhosVideoPlatform.instance.getPlatformVersion();
  }
}
