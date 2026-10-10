import 'package:flutter/services.dart' show DeviceOrientation;
import 'package:flutter_test/flutter_test.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:native_device_orientation/src/native_device_orientation_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDeviceOrientationPlatform
    with MockPlatformInterfaceMixin
    implements NativeDeviceOrientationPlatform {
  @override
  Stream<OrientationParams> onOrientationChanged({
    int? angleDegrees,
    bool checkIsAutoRotate = true,
  }) async* {
    yield (orientation: DeviceOrientation.landscapeLeft, isAutoRotate: null);
    yield (orientation: DeviceOrientation.landscapeRight, isAutoRotate: null);
  }

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}
}

void main() {
  final NativeDeviceOrientationPlatform initialPlatform =
      NativeDeviceOrientationPlatform.instance;

  test('$MethodChannelNativeDeviceOrientation is the default instance', () {
    expect(
        initialPlatform, isInstanceOf<MethodChannelNativeDeviceOrientation>());
  });

  group('test', () {
    setUp(() {
      MockDeviceOrientationPlatform fakePlatform =
          MockDeviceOrientationPlatform();
      NativeDeviceOrientationPlatform.instance = fakePlatform;
    });

    test('pause', () async {
      await NativeDeviceOrientationPlatform.instance.pause();
    });

    test('resume', () async {
      await NativeDeviceOrientationPlatform.instance.resume();
    });

    test('onOrientationChanged', () async {
      final stream =
          NativeDeviceOrientationPlatform.instance.onOrientationChanged();

      var numEvents = 0;

      final sub = stream.listen((event) {
        numEvents += 1;
      });

      await sub.asFuture();
      expect(numEvents, 2);
    });
  });
}
