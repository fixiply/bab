import 'package:flutter/material.dart';

class DeviceHelper {
  static bool mobileLayout(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide < 600;
  }

  static bool tabletteLayout(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }

  static bool landscapeOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static bool portraitOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }
}
