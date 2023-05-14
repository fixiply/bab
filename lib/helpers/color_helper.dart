import 'dart:math';

import 'package:flutter/material.dart';

const List<Color> SRM_COLORS = [
  const Color(0xFFFFE699),
  const Color(0xFFFFD878),
  const Color(0xFFFFCA5A),
  const Color(0xFFFFBF42),
  const Color(0xFFFBB123),
  const Color(0xFFF8A600),
  const Color(0xFFF39C00),
  const Color(0xFFEA8F00),
  const Color(0xFFE58500),
  const Color(0xFFDE7C00),
  const Color(0xFFD77200),
  const Color(0xFFCF6900),
  const Color(0xFFCB6200),
  const Color(0xFFC35900),
  const Color(0xFFBB5100),
  const Color(0xFFB54C00),
  const Color(0xFFB04500),
  const Color(0xFFA63E00),
  const Color(0xFFA13700),
  const Color(0xFF9B3200),
  const Color(0xFF952D00),
  const Color(0xFF8E2900),
  const Color(0xFF882300),
  const Color(0xFF821E00),
  const Color(0xFF7B1A00),
  const Color(0xFF771900),
  const Color(0xFF701400),
  const Color(0xFF6A0E00),
  const Color(0xFF660D00),
  const Color(0xFF5E0B00),
  const Color(0xFF5A0A02),
  const Color(0xFF600903),
  const Color(0xFF520907),
  const Color(0xFF4C0505),
  const Color(0xFF470606),
  const Color(0xFF440607),
  const Color(0xFF3F0708),
  const Color(0xFF3B0607),
  const Color(0xFF3A070B),
  const Color(0xFF36080A),
];

extension ColorExtension on String {
  toColor() {
    var hexColor = this.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }
}

extension HexColor on Color {
  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

class ColorHelper {
  double? start;
  double? end;

  clear() {
    start = null;
    end = null;
  }

  static int toSRM(ebc) {
    return ebc != null ? (ebc * 0.508).toInt() : 0;
  }

  static int toEBC(srm) {
    return srm != null ? (srm * 1.97).round() : 0;
  }

  /// Returns the malt color unit, based on the given conditions.
  ///
  /// The `ebc` argument is relative to the grain ebc.
  ///
  /// The `weight` argument is relative to the weight grain.
  ///
  /// The `volume` argument is relative to the final volume.
  static double mcu(int? ebc, double? weight, double? volume) {
    if (ebc == null || weight == null || volume == null) {
      return 0;
    }
    return (4.23 * ebc * weight) / volume;
  }

  /// Returns the EBC color rating, based on the given conditions.
  /// 
  /// The `mcu` argument is relative to the total mcu.
  static double ratingEBC(double? mcu) {
    if (mcu == null || mcu == 0) {
      return 0;
    }
    return 2.939 * pow(mcu, 0.659);
  }

  /// Returns the SRM color rating, based on the given conditions.
  /// 
  /// The `mcu` argument is relative to the total mcu.{
  static double ratingSRM(double? mcu) {
    if (mcu == null || mcu == 0) {
      return 0;
    }
    return 1.4922 * pow(mcu, 0.659);
  }

  static Color? color(int? ebc) {
    if (ebc != null) {
      int srm = ColorHelper.toSRM(ebc);
      if (srm <= 0) return null;
      if (srm < SRM_COLORS.length) return SRM_COLORS[srm-1];
      if (srm >= SRM_COLORS.length) return SRM_COLORS[SRM_COLORS.length-1];
    }
    return null;
  }

  static String random() {
    return Color(Random().nextInt(0xffffffff)).toHex();
  }

  static Color? fromHex(String value) {
    if (value == null) {
      return null;
    }
    return value.toColor();
  }

  static String? toHex(Color color) {
    if (color == null) {
      return null;
    }
    return color.toHex();
  }
}