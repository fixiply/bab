import 'dart:math';

import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';

import 'package:bab/models/yeast_model.dart';
import 'package:bab/utils/constants.dart';

class FormulaHelper {
  /// Returns the dry extract, based on the given conditions.
  ///
  /// The `mass` argument is relative to the grain mass in kilo.
  ///
  /// The `potential` argument is relative to the grain efficiency.
  ///
  /// The `efficiency` argument is relative to the theoretical efficiency of the equipment.
  static double? extract(double? mass, double? potential, double? efficiency) {
    if (mass == null || potential == null || efficiency == null) {
      return null;
    }
    double result = mass * (potential / 100) * (efficiency / 100);
    if (foundation.kDebugMode) debugPrint('og $result=$mass * ($potential / 100) * ($efficiency / 100)');
    return result;
  }

  /// Returns the original gravity, based on the given conditions.
  ///
  /// The `extract` argument is relative to the dry extract.
  ///
  /// The `volume` argument is relativ-e to the pre-boil volume.
  static double? og(double? extract, double? volume) {
    if (extract == null || volume == null) {
      return null;
    }
    double result = 1 + ( 383 * extract / volume ) / 1000;
    if (foundation.kDebugMode) debugPrint('og $result=1 + ( 383 * $extract / $volume ) / 1000');
    return result;
  }

  /// Returns the final gravity, based on the given conditions.
  ///
  /// The `og` argument is relative to the original gravity 1.xxx.
  ///
  /// The `attenuation` argument is relative to the theoretical yeast attenuation.
  static double? fg(double? og, double? attenuation) {
    if (attenuation == null || og == null) {
      return null;
    }
    og = (og - 1) * 1000;
    attenuation = attenuation / 100;
    var result = og * (1 - attenuation) + 1000;
    if (foundation.kDebugMode) debugPrint('fg $result=($og * (1 - $attenuation) + 1000');
    return result / 1000;
  }

  /// Returns the Alcohol level, based on the given conditions.
  ///
  /// The `og` argument is relative to the original gravity 1.xxx.
  ///
  /// The `fg` argument is relative to the final gravity.
  static double? abv(double? og, double? fg) {
    if (og == null || fg == null) {
      return null;
    }
    double result = ((og * 1000) - (fg * 1000) ) / 7.6;
    if (foundation.kDebugMode) debugPrint('abv $result=((($og * 1000) - ($fg * 1000) ) / 7.6');
    return result;
  }

  /// Returns the mash efficiency, based on the given conditions.
  ///
  /// The `volume` argument is relative to the final volume.
  ///
  /// The `og` argument is relative to the original gravity 1.xxx.
  ///
  /// The `mass` argument is relative to the grain mass in kilo.
  ///
  /// The `extract` argument is relative to the dry extract.
  static double? efficiency(double? volume, double? og, double? mass, double? extract) {
    if (volume == null || og == null || mass == null || extract == null) {
      return null;
    }
    double result = (volume * og * convertSGToPlato(og)) / (mass * extract) * 100;
    if (foundation.kDebugMode) debugPrint('efficiency $result=($volume * $og * ${convertSGToPlato(og)}) / ($mass * $extract) * 100');
    return result;
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
  static double? ibu(double? amount, double? alpha, double? og, int? duration, double? volume, {double? maximum}) {
    if (amount == null || alpha == null || og == null || duration == null || volume == null) {
      return null;
    }
    maximum ??= 4.15;
    double result = 1.65 * pow(0.000125, og) * ((1 - pow(e, -0.04 * duration)) / maximum) * ((alpha * amount * 1000) / volume) * 100;
    if (foundation.kDebugMode) debugPrint('ibu $result=1.65 * pow(0.000125, $og) * ((1 - pow($e, -0.04 * $duration)) / $maximum) * (($alpha * $amount * 1000) / $volume) * 100');
    return result;
  }

  /// Returns the yeast seeding rate, based on the given conditions.
  ///
  /// The `og` argument is relative to the original gravity 1.xxx.
  ///
  /// The `volume` argument is relative to the final volume.
  ///
  /// The `cells` argument is relative to the viable billion cells per gram.
  ///
  /// The `rate` argument is relative to the pitching rate.
  /// Minimum manufacturer's recommendation: 0.35 (ale only, fresh yeast only)
  /// Middle of the road Pro Brewer 0.75 (ale)
  /// Pro Brewer 1.00 (high gravity ale)
  /// Pro Brewer 1.50 (minimum for lager)
  /// Pro Brewer 2.0 (high gravity lager)
  static double? yeast(double? og, double? volume, {Yeast form = Yeast.dry, double cells = 100, double rate = 0.75}) {
    if (og == null || volume == null) {
      return null;
    }
    var bc = billionCells(og, volume, rate: rate);
    if (form == Yeast.liquid) {
      return  (bc / cells);
    }
    return bc / (cells / 10);
  }

  /// Returns the billion cells, based on the given conditions.
  ///
  /// The `og` argument is relative to the original gravity 1.xxx.
  ///
  /// The `volume` argument is relative to the final volume.
  ///
  /// The `rate` argument is relative to the pitching rate.
  /// Minimum manufacturer's recommendation: 0.35 (ale only, fresh yeast only)
  /// Middle of the road Pro Brewer 0.75 (ale)
  /// Pro Brewer 1.00 (high gravity ale)
  /// Pro Brewer 1.50 (minimum for lager)
  /// Pro Brewer 2.0 (high gravity lager)
  static int billionCells(double? og, double? volume, {double rate = 0.75}) {
    if (og == null || volume == null) {
      return 0;
    }
    return ((rate * 1000000)  * (volume * 1000) * convertSGToBrix(og) / 1000000000).round();
  }

  /// Returns the mash water, based on the given conditions.
  ///
  /// The `volume` argument is relative to the final volume.
  ///
  /// The `boil_losses` argument is relative to the boil loss.
  ///
  /// The `boil_off_rate` argument is relative to the trub and chiller loss.
  ///
  /// The `duration` argument is relative to the boil duration in minute.
  static double preboilVolume(double? volume, double? boil_losses, double? boil_off_rate, {int duration = 60}) {
    if (volume == null || boil_losses == null || boil_off_rate == null) {
      return 0;
    }
    double result = volume + boil_losses + (boil_off_rate * (duration / 60));
    if (foundation.kDebugMode) debugPrint('preboilVolume $result=$volume + $boil_losses + ($boil_off_rate * ($duration / 60))');
    return result;
  }

  /// Returns the mash water, based on the given conditions.
  ///
  /// The `weight` argument is relative to the weight in kilo.
  ///
  /// The `ratio` argument is relative to the mash ratio.
  ///
  /// The `lost` argument is relative to the lost volume.
  static double mashWater(double? weight, double? ratio, double? lost) {
    if (weight == null || ratio == null || lost == null) {
      return 0;
    }
    double result = (weight * ratio) + lost;
    if (foundation.kDebugMode) debugPrint('mashWater $result=($weight * $ratio) + $lost');
    return result;
  }

  /// Returns the mash water, based on the given conditions.
  ///
  /// The `weight` argument is relative to the weight in kilo.
  ///
  /// The `volume` argument is relative to the pre-boil volume.
  ///
  /// The `mash` argument is relative to the mash water.
  ///
  /// The `absorption` argument is relative to the grain absorption rate.
  static double spargeWater(double? weight, double? volume, double? mash, {double? absorption = 0}) {
    if (weight == null || volume == null || mash == null || absorption == null) {
      return 0;
    }
    double result = volume - mash + (weight * absorption);
    if (foundation.kDebugMode) debugPrint('spargeWater $result=$volume - $mash + ($weight * $absorption');
    return result;
  }

  /// Returns the brix to specific gravity
  ///
  /// The `number` argument is relative to the brix.
  static double pH(double? current, double? target, double? volume, Acid? acid, double? concentration) {
    if (current == null || target == null || volume == null || acid == null || concentration == null) {
      return 0;
    }
    switch(acid) {
      case Acid.hydrochloric:
        return (0.02 * volume * (current - target)) / (concentration * 1.25);
      case Acid.phosphoric:
        return  (volume * (current - target)) / (10 * (concentration / 100));
      case Acid.lactic:
        return concentration * volume * (current - target) / 5.9;
      case Acid.sulfuric:
        return concentration * volume * (target - current) / 2;
    }
  }

  /// Returns the water/grain ratio.
  ///
  /// The `volume` argument is relative to the water volume.
  ///
  /// The `weight` argument is relative to the grain weight in kilo.
  static double? ratio(double? volume,  double? weight) {
    if (volume == null || weight == null) {
      return null;
    }
    double result = volume / weight;
    if (foundation.kDebugMode) debugPrint('ratio $result=($volume / $weight)');
    return result;
  }

  /// Returns the initial brew temperature
  ///
  /// The `ratio` argument is relative to the water/grain ratio.
  ///
  /// The `tmf` argument is relative to the celcius temperature of the next mash.
  ///
  /// The `tgi` argument is relative to the celcius initial grain temperature.
  static double? initialBrewTemp(double? ratio, double? tmf, double? tgi) {
    if (ratio == null || tmf == null || tgi == null) {
      return null;
    }
    double result = 0.41 / ratio * (tmf - tgi) + tmf;
    if (foundation.kDebugMode) debugPrint('initialBrewTemp $result=(0.41 / $ratio * ($tmf - $tgi) + $tmf)');
    return result;
  }

  /// Returns the water/grain ratio.
  ///
  /// The `volume` argument is relative to the water volume.
  ///
  /// The `co2` argument is relative to the grain weight in kilo.
  ///
  /// The `temperature` argument is relative to the grain weight in kilo.
  ///
  /// The `attenuation` argument is relative to the grain weight in kilo.
  static double? primingSugar(double? volume,  double? co2, {double? temperature = 18, double? attenuation = 0.5}) {
    if (volume == null || co2 == null || temperature == null || attenuation == null) {
      return null;
    }
    double residual = 1.7 - 0.059 * temperature + 0.00086 * sqrt(temperature);
    double result = (3.9 * volume * (co2 - residual)) / attenuation;
    if (foundation.kDebugMode) debugPrint('priming $result=(3.9 * $volume * ($co2 - $residual)) / $attenuation');
    // double result = (volume * co2 * (temperature + 17.8) * 10) / attenuation;
    // if (foundation.kDebugMode) debugPrint('priming $result=($volume * $co2 * ($temperature + 17.8)  * 10) / $attenuation');
    return result;
  }

  /// Returns the gallon to liter conversion
  ///
  /// The `number` argument is relative to the volume in gallon.
  static double convertGallonToLiter(num? number) {
    if (number == null) {
      return 0;
    }
    return number * 3.785;
  }

  /// Returns the liter to gallon conversion
  ///
  /// The `number` argument is relative to the volume in liters.
  static double convertLiterToGallon(num? number) {
    if (number == null) {
      return 0;
    }
    return number / 3.785;
  }

  /// Returns the millimeter to once conversion
  ///
  /// The `number` argument is relative to the number in millimeter.
  static double convertMillimeterToOnce(num? number) {
    if (number == null) {
      return 0;
    }
    return number / 29.574;
  }

  /// Returns the gram to ounce conversion
  ///
  /// The `number` argument is relative to the weight in grams.
  static double convertGramToOunce(num? number) {
    if (number == null) {
      return 0;
    }
    return number / 28.35;
  }

  /// Returns the kilo to livre conversion
  ///
  /// The `number` argument is relative to the weight in kilo.
  static double convertKiloToLivre(num? number) {
    if (number == null) {
      return 0;
    }
    return number * 2.205;
  }


  /// Returns the ounce to gram conversion
  ///
  /// The `number` argument is relative to the weight in ounce.
  static double convertOunceToGram(num? number) {
    if (number == null) {
      return 0;
    }
    return number * 28.35;
  }


  /// Returns the ounce to livre conversion
  ///
  /// The `number` argument is relative to the weight in ounce.
  static double convertOunceToLivre(num? number) {
    if (number == null) {
      return 0;
    }
    return number / 16;
  }

  /// Returns the livre to ounce conversion
  ///
  /// The `number` argument is relative to the weight in livre.
  static double convertLivreToOunce(num? number) {
    if (number == null) {
      return 0;
    }
    return number * 16;
  }

  /// Returns the farenheit to celcius conversion
  ///
  /// The `number` argument is relative to the farenheit.
  static double convertFarenheitToCelcius(num? number) {
    if (number == null) {
      return 0;
    }
    return (number - 32) * 5/9;
  }

  /// Returns the celcius to farenheit conversion
  ///
  /// The `number` argument is relative to the celcius.
  static double convertCelciusToFarenheit(num? number) {
    if (number == null) {
      return 0;
    }
    return (number * 9/5) + 32;
  }

  /// Returns the specific gravity to plato gravity
  ///
  /// The `number` argument is relative to the specific gravity.
  static double convertSGToPlato(num? number) {
    if (number == null) {
      return 0;
    }
    return (-1 * 616.868) + (1111.14 * number) - (630.272 * pow(number,2)) + (135.997 * pow(number,3));
  }

  /// Returns the plato gravity to specific gravity
  ///
  /// The `number` argument is relative to the plato gravity.
  static double convertPlatoToSG(num? number) {
    if (number == null) {
      return 0;
    }
    return 1 + (number / (258.6 - ( (number / 258.2) * 227.1)));
  }

  /// Returns the plato gravity to brix
  ///
  /// The `number` argument is relative to the plato gravity.
  static double convertPlatoToBrix(num? number) {
    if (number == null) {
      return 0;
    }
    return number * 1.04;
  }

  /// Returns the specific gravity to brix
  ///
  /// The `number` argument is relative to the specific gravity.
  static double convertSGToBrix(num? number) {
    if (number == null) {
      return 0;
    }
    return (((182.4601 * number -775.6821) * number + 1262.7794) * number - 669.5622);
  }

  /// Returns the brix to specific gravity
  ///
  /// The `number` argument is relative to the brix.
  static double convertBrixToSG(num? number) {
    if (number == null) {
      return 0;
    }
    return (number / (258.6 - ((number / 258.2) * 227.1))) + 1;
  }

  /// Returns the brix to plato gravity
  ///
  /// The `number` argument is relative to the brix.
  static double convertBrixToPlato(num? number) {
    if (number == null) {
      return 0;
    }
    return number / 1.04;
  }

  /// Returns the bar to psi pressure
  ///
  /// The `number` argument is relative to the bar.
  static double convertBarToPSI(num? number) {
    if (number == null) {
      return 0;
    }
    return number * 14.504;
    ;
  }

  /// Returns the bar to Pascal pressure
  ///
  /// The `number` argument is relative to the bar.
  static double convertBarToPascal(num? number) {
    if (number == null) {
      return 0;
    }
    return number * 100000;
  }

  /// Returns the psi to bar pressure
  ///
  /// The `number` argument is relative to the psi.
  static double convertPSIToBar(num? number) {
    if (number == null) {
      return 0;
    }
    return number / 14.504;
  }

  /// Returns the psi to Pascal pressure
  ///
  /// The `number` argument is relative to the psi.
  static double convertPSIToPascal(num? number) {
    if (number == null) {
      return 0;
    }
    return number * 6895;
  }

  /// Returns the Pascal to bar pressure
  ///
  /// The `number` argument is relative to the Pascal.
  static double convertPascalToBar(num? number) {
    if (number == null) {
      return 0;
    }
    return number / 100000;
  }

  /// Returns the Pascal to psi pressure
  ///
  /// The `number` argument is relative to the Pascal.
  static double convertPascalToPSI(num? number) {
    if (number == null) {
      return 0;
    }
    return number / 6895;
  }
}

