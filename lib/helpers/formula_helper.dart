import 'dart:math';

import 'package:flutter/material.dart';

class FormulaHelper {
  /// Returns the dry extract, based on the given conditions.
  ///
  /// The `mass` argument is relative to the grain mass in kilo.
  ///
  /// The `potential` argument is relative to the grain efficiency.
  ///
  /// The `efficiency` argument is relative to the theoretical efficiency of the equipment.
  static double extract(double? mass, double? potential, double? efficiency) {
    if (mass == null || potential == null || efficiency == null) {
      return 0;
    }
    return mass * (potential / 100) * (efficiency / 100);
  }

  /// Returns the original gravity, based on the given conditions.
  ///
  /// The `extract` argument is relative to the dry extract.
  ///
  /// The `volume` argument is relative to the pre-boil volume.
  static double og(double? extract, double? volume) {
    if (extract == null || volume == null) {
      return 0;
    }
    return 1 + ( 383 * extract / volume ) / 1000;
  }

  /// Returns the final gravity, based on the given conditions.
  ///
  /// The `og` argument is relative to the original gravity 1.xxx.
  ///
  /// The `attenuation` argument is relative to the theoretical yeast attenuation.
  static double fg(double? og, double? attenuation) {
    if (attenuation == null || og == null) {
      return 0;
    }
    og = (og - 1) * 1000;
    attenuation = attenuation / 100;
    var fg = og * (1 - attenuation) + 1000;
    return fg / 1000;
  }

  /// Returns the Alcohol level, based on the given conditions.
  ///
  /// The `og` argument is relative to the original gravity 1.xxx.
  ///
  /// The `fg` argument is relative to the final gravity.
  static double abv(double? og, double? fg) {
    if (og == null || fg == null) {
      return 0;
    }
    return ((og * 1000) - (fg * 1000) ) / 7.6;
  }

  /// Returns the bitterness index, based on the given conditions.
  ///
  /// The `amount` argument is relative to the amount of hops in grams.
  ///
  /// The `alpha` argument is relative to the hops alpha acid.
  ///
  /// The `og` argument is relative to the original gravity 1.xxx.
  ///
  /// The `duration` argument is relative to the boil duration in minute.
  ///
  /// The `volume` argument is relative to the final volume.
  static double ibu(double? amount, double? alpha, double? og, int? duration, double? volume, {double? maximum}) {
    if (amount == null || alpha == null || og == null || duration == null || volume == null) {
      return 0;
    }
    if (maximum == null) maximum = 4.15;
    return 1.65 * pow(0.000125, og) * ((1 - pow(e, -0.04 * duration)) / maximum) * ((alpha * amount * 1000) / volume) * 100;
  }

  /// Returns the plato degree, based on the given conditions.
  ///
  /// The `gravity` argument is relative to the gravity 1.xxx.
  static double plato(double? gravity) {
    if (gravity == null) {
      return 0;
    }
    return ((gravity - 1) * 1000) / 4;
  }

  /// Returns the yeast seeding rate, based on the given conditions.
  ///
  /// The `og` argument is relative to the original gravity 1.xxx.
  ///
  /// The `volume` argument is relative to the final volume.
  ///
  /// The `cells` argument is relative to the cells per gram.
  ///
  /// The `rate` argument is relative to the pitching rate.
  /// Minimum manufacturer's recommendation: 0.35 (ale only, fresh yeast only)
  /// Middle of the road Pro Brewer 0.75 (ale)
  /// Pro Brewer 1.00 (high gravity ale)
  /// Pro Brewer 1.50 (minimum for lager)
  /// Pro Brewer 2.0 (high gravity lager)
  static double yeast(double? og, double? volume, double cells, {double rate = 0.75}) {
    if (og == null || volume == null || cells == null) {
      return 0;
    }
    return rate * (volume * 1000) * plato(og) / (cells * 1000);
  }

  /// Returns the gallon to liter conversion
  ///
  /// The `volume` argument is relative to the volume in gallon.
  static double convertGallonToLiter(double? volume) {
    if (volume == null) {
      return 0;
    }
    return volume * 3.785;
  }

  /// Returns the liter to gallon conversion
  ///
  /// The `volume` argument is relative to the volume in liters.
  static double convertLiterToGallon(double? volume) {
    if (volume == null) {
      return 0;
    }
    return volume / 3.785;
  }

  /// Returns the gram to ounce conversion
  ///
  /// The `weight` argument is relative to the weight in grams.
  static double convertGramToOunce(double? weight) {
    if (weight == null) {
      return 0;
    }
    return weight / 28.35;
  }

  /// Returns the ounce to gram conversion
  ///
  /// The `weight` argument is relative to the weight in ounce.
  static double convertOunceToGram(double? weight) {
    if (weight == null) {
      return 0;
    }
    return weight * 28.35;
  }


  /// Returns the ounce to livre conversion
  ///
  /// The `weight` argument is relative to the weight in ounce.
  static double convertOunceToLivre(double? weight) {
    if (weight == null) {
      return 0;
    }
    return weight / 16;
  }

  /// Returns the livre to ounce conversion
  ///
  /// The `weight` argument is relative to the weight in livre.
  static double convertLivreToOunce(double? weight) {
    if (weight == null) {
      return 0;
    }
    return weight * 16;
  }
}

