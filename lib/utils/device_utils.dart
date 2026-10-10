import 'dart:io' show Platform;

import 'package:PiliPlus/utils/android/bindings.g.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:flutter/widgets.dart' show WidgetsBinding, Size;

abstract final class DeviceUtils {
  // sdkInt is an Android SDK level, never a HarmonyOS API version.
  static final int sdkInt = Platform.isAndroid ? AndroidHelper.sdkInt() : 0;

  static bool get isTablet {
    return size.shortestSide >= 600;
  }

  static Size get size {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    return view.physicalSize / view.devicePixelRatio;
  }

  static String get platformName => PlatformUtils.isDesktop
      ? 'desktop'
      : isTablet
      ? 'pad'
      : 'phone';
}
