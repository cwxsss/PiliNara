import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit_libs_ohos_video/media_kit_libs_ohos_video.dart';
import 'package:media_kit_libs_ohos_video/media_kit_libs_ohos_video_platform_interface.dart';
import 'package:media_kit_libs_ohos_video/media_kit_libs_ohos_video_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMediaKitLibsOhosVideoPlatform
    with MockPlatformInterfaceMixin
    implements MediaKitLibsOhosVideoPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final MediaKitLibsOhosVideoPlatform initialPlatform = MediaKitLibsOhosVideoPlatform.instance;

  test('$MethodChannelMediaKitLibsOhosVideo is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMediaKitLibsOhosVideo>());
  });

  test('getPlatformVersion', () async {
    MediaKitLibsOhosVideo mediaKitLibsOhosVideoPlugin = MediaKitLibsOhosVideo();
    MockMediaKitLibsOhosVideoPlatform fakePlatform = MockMediaKitLibsOhosVideoPlatform();
    MediaKitLibsOhosVideoPlatform.instance = fakePlatform;

    expect(await mediaKitLibsOhosVideoPlugin.getPlatformVersion(), '42');
  });
}
