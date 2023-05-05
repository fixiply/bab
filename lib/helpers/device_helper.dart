import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as Foundation;

class DeviceHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide < 600;
  }

  static bool isTablette(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }

  static bool isLargeScreen(BuildContext context) {
    if (isDesktop || isTablette(context)) {
      return true;
    }
    return false;
  }

  static bool get isDesktop {
    return Foundation.kIsWeb || Foundation.defaultTargetPlatform == TargetPlatform.linux || Foundation.defaultTargetPlatform == TargetPlatform.windows || Foundation.defaultTargetPlatform == TargetPlatform.macOS;
  }

  static bool get isIOS {
    return Foundation.defaultTargetPlatform == TargetPlatform.iOS;
  }

  static bool landscapeOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static bool portraitOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  static double? factor(BuildContext context) {
    if (isDesktop) {
      return 0.6;
    }
    if (!DeviceHelper.isMobile(context) && DeviceHelper.landscapeOrientation(context)) {
      return 0.6;
    }
    return null;
  }
}
