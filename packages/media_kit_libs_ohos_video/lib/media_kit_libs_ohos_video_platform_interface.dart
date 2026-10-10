import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'media_kit_libs_ohos_video_method_channel.dart';

abstract class MediaKitLibsOhosVideoPlatform extends PlatformInterface {
  /// Constructs a MediaKitLibsOhosVideoPlatform.
  MediaKitLibsOhosVideoPlatform() : super(token: _token);

  static final Object _token = Object();

  static MediaKitLibsOhosVideoPlatform _instance = MethodChannelMediaKitLibsOhosVideo();

  /// The default instance of [MediaKitLibsOhosVideoPlatform] to use.
  ///
  /// Defaults to [MethodChannelMediaKitLibsOhosVideo].
  static MediaKitLibsOhosVideoPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MediaKitLibsOhosVideoPlatform] when
  /// they register themselves.
  static set instance(MediaKitLibsOhosVideoPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
