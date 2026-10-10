// OHOS texture protocol based on CPF-Flutter/fluttertpc_flutter_media_kit.
// Its MIT license and the original native plugin sources are retained.
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit/ffi/ffi.dart';

import '../platform_video_controller.dart';

/// OHOS backend for PiliNara's customized NativePlayer API.
class OhosVideoController extends PlatformVideoController {
  static bool get supported => Platform.operatingSystem == 'ohos';
  static final Map<int, OhosVideoController> _controllers = {};
  static final MethodChannel _channel = const MethodChannel(
    'com.alexmercerind/media_kit_video',
  )..setMethodCallHandler(_onMethodCall);

  final int _handle;
  bool _disposed = false;
  bool _hasVideoParameters = false;
  int _width = 1;
  int _height = 1;
  String? _surface;
  int _surfaceWidth = 0;
  int _surfaceHeight = 0;
  StreamSubscription<VideoParams>? _subscription;

  OhosVideoController._(super.player, super.configuration)
    : _handle = player.handle;

  void _setProperty(String name, String value) {
    final property = name.toNativeUtf8();
    final data = value.toNativeUtf8();
    try {
      final result = NativePlayer.mpv.mpv_set_property_string(
        player.ctx,
        property,
        data,
      );
      if (result < 0) {
        throw StateError('OHOS player property $name failed: $result');
      }
    } finally {
      calloc.free(property);
      calloc.free(data);
    }
  }

  static Future<PlatformVideoController> create(
    Player player,
    VideoControllerConfiguration configuration,
  ) async {
    final handle = player.handle;
    final existing = _controllers[handle];
    if (existing != null) return existing;
    final controller = OhosVideoController._(player, configuration);
    _controllers[handle] = controller;
    try {
      // Keep video output disabled until the native surface has been attached.
      final properties = <String, String>{
        'vo': 'null',
        'hwdec':
            configuration.hwdec ??
            (configuration.enableHardwareAcceleration ? 'auto-safe' : 'no'),
        'gpu-context': 'openharmony',
        'opengl-es': 'yes',
        'force-window': 'yes',
        'vid': 'auto',
        'sub-font-provider': 'none',
      };
      for (final property in properties.entries) {
        controller._setProperty(property.key, property.value);
      }
      controller._subscription = player.stream.videoParams.listen((params) {
        final rotated = params.rotate != 0 && params.rotate != 180;
        final width = (rotated ? params.dh : params.dw) ?? 0;
        final height = (rotated ? params.dw : params.dh) ?? 0;
        if (controller._disposed || width <= 0 || height <= 0) return;
        controller._hasVideoParameters = true;
        if (width != controller._width || height != controller._height) {
          unawaited(
            controller.setSize(width: width, height: height).catchError((
              Object error,
              StackTrace stack,
            ) {
              FlutterError.reportError(
                FlutterErrorDetails(
                  exception: error,
                  stack: stack,
                  library: 'OHOS media_kit_video',
                ),
              );
            }),
          );
        }
        controller._completeReady();
      });
      await _channel.invokeMethod<void>('VideoOutputManager.Create', {
        'handle': handle.toString(),
      });
      player.release.add(controller._dispose);
      return controller;
    } catch (_) {
      await controller._dispose();
      rethrow;
    }
  }

  void _completeReady() {
    // This plugin has no frame-presented signal. Wait for decoded video
    // dimensions AND a registered texture; actual rendering needs device QA.
    if (_hasVideoParameters &&
        id.value != null &&
        _surfaceWidth > 1 && _surfaceHeight > 1 &&
        !waitUntilFirstFrameRenderedCompleter.isCompleted) {
      waitUntilFirstFrameRenderedCompleter.complete();
    }
  }

  @override
  Future<void> setSize({int? width, int? height}) async {
    if (_disposed) return;
    final nextWidth = width ?? _width;
    final nextHeight = height ?? _height;
    if (nextWidth <= 0 || nextHeight <= 0) {
      throw ArgumentError('Video output dimensions must be positive');
    }
    if (nextWidth == _width && nextHeight == _height) return;
    // Reserve requested dimensions before awaiting native acknowledgement.
    _width = nextWidth;
    _height = nextHeight;
    await _channel.invokeMethod<void>('VideoOutputManager.SetSurfaceSize', {
      'handle': _handle.toString(),
      'width': nextWidth.toString(),
      'height': nextHeight.toString(),
    });
    if (_disposed) return;
    _width = nextWidth;
    _height = nextHeight;
  }

  static Future<void> _onMethodCall(MethodCall call) async {
    if (call.method != 'VideoOutput.Resize') return;
    final args = Map<Object?, Object?>.from(call.arguments as Map);
    final handle = int.parse(args['handle'].toString());
    final controller = _controllers[handle];
    if (controller == null || controller._disposed) return;
    final surface = args['wid'].toString();
    final bounds = Map<Object?, Object?>.from(args['rect'] as Map);
    final width = (bounds['width'] as num).toInt();
    final height = (bounds['height'] as num).toInt();
    final surfaceChanged = surface != controller._surface;
    final dimensionsChanged = width != controller._surfaceWidth ||
        height != controller._surfaceHeight;
    if (surface == '0') {
      controller._setProperty('vo', 'null');
      controller._setProperty('wid', '0');
      controller._surface = surface;
      return;
    }
    if (width > 1 && height > 1) {
      if (surfaceChanged || dimensionsChanged) {
        // mpv's OHOS EGL context reads the geometry when the output initializes.
        // Source video dimensions avoid a video-out-params resize feedback loop.
        controller._setProperty('vo', 'null');
        controller._setProperty('openharmony-surface-size', '${width}x$height');
        controller._setProperty('wid', surface);
        controller._setProperty('vo', controller.configuration.vo ?? 'gpu');
        controller._surface = surface;
        controller._surfaceWidth = width;
        controller._surfaceHeight = height;
      }
      controller.rect.value = Rect.fromLTWH(
        0,
        0,
        width.toDouble(),
        height.toDouble(),
      );
      controller.id.value = (args['id'] as num).toInt();
      controller._completeReady();
    }
    // Surface resizing must not seek: preserve current playback position.
  }

  Future<void> _dispose() async {
    if (_disposed) return;
    _disposed = true;
    _controllers.remove(_handle);
    await _subscription?.cancel();
    try {
      _setProperty('vo', 'null');
      _setProperty('wid', '0');
      await _channel.invokeMethod<void>('VideoOutputManager.Dispose', {
        'handle': _handle.toString(),
      });
    } finally {
      id.dispose();
      rect.dispose();
    }
  }
}
