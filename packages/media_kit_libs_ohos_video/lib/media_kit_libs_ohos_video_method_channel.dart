import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'media_kit_libs_ohos_video_platform_interface.dart';

/// An implementation of [MediaKitLibsOhosVideoPlatform] that uses method channels.
class MethodChannelMediaKitLibsOhosVideo extends MediaKitLibsOhosVideoPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('media_kit_libs_ohos_video');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
