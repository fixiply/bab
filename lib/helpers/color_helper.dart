import 'dart:math';

import 'package:flutter/material.dart';

// Internal package
import 'package:bab/extensions/color_extensions.dart';
import 'package:bab/extensions/string_extensions.dart';

const List<Color> SRM_COLORS = [
  Color(0xFFFFE699),
  Color(0xFFFFD878),
  Color(0xFFFFCA5A),
  Color(0xFFFFBF42),
  Color(0xFFFBB123),
  Color(0xFFF8A600),
  Color(0xFFF39C00),
  Color(0xFFEA8F00),
  Color(0xFFE58500),
  Color(0xFFDE7C00),
  Color(0xFFD77200),
  Color(0xFFCF6900),
  Color(0xFFCB6200),
  Color(0xFFC35900),
  Color(0xFFBB5100),
  Color(0xFFB54C00),
  Color(0xFFB04500),
  Color(0xFFA63E00),
  Color(0xFFA13700),
  Color(0xFF9B3200),
  Color(0xFF952D00),
  Color(0xFF8E2900),
  Color(0xFF882300),
  Color(0xFF821E00),
  Color(0xFF7B1A00),
  Color(0xFF771900),
  Color(0xFF701400),
  Color(0xFF6A0E00),
  Color(0xFF660D00),
  Color(0xFF5E0B00),
  Color(0xFF5A0A02),
  Color(0xFF600903),
  Color(0xFF520907),
  Color(0xFF4C0505),
  Color(0xFF470606),
  Color(0xFF440607),
  Color(0xFF3F0708),
  Color(0xFF3B0607),
  Color(0xFF3A070B),
  Color(0xFF36080A),
];

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
    return Color(Random().nextInt(0xffffffff)).withOpacity(1.0).toHex();
  }

  static Color? fromHex(String? value) {
    if (value == null) {
      return null;
    }
    return value.toColor();
  }

  static String? toHex(Color? color) {
    if (color == null) {
      return null;
    }
    return color.toHex();
  }
}