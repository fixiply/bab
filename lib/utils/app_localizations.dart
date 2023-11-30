import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

// Internal package
import 'package:bab/helpers/formula_helper.dart';
import 'package:bab/helpers/color_helper.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/localized_text.dart';

// External package
import 'package:intl/intl.dart';

class AppLocalizations {
  final Locale locale;
  Unit unit = Unit.metric;
  Gravity gravity = Gravity.sg;
  static Map<dynamic, dynamic>? _localisedValues;

  AppLocalizations(this.locale, this.unit, this.gravity) {
    _localisedValues = null;
  }

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Future<AppLocalizations> load(Locale locale, Unit? unit, Gravity? gravity) async {
    AppLocalizations appTranslations = AppLocalizations(locale, unit ?? Unit.metric, gravity ?? Gravity.sg);
    String jsonContent = await rootBundle.loadString("assets/locales/${locale.languageCode}.json");
    _localisedValues = json.decode(jsonContent);
    return appTranslations;
  }

  get currentLanguage => locale.languageCode;

  String text(String key) {
    if (_localisedValues == null) {
      return '';
    }
    return _localisedValues![key] ?? "$key not found";
  }

  String localizedText(dynamic value, {Locale? locale}) {
    return LocalizedText.text(locale ?? this.locale, value);
  }

  String get colon {
    if (currentLanguage == 'fr') {
      return ' :';
    }
    return ':';
  }

  String? symbol(Enum e) {
    switch (e) {
      case Time.minutes:
        return 'min';
      case Time.hours:
        return 'h';
      case Time.days:
        return 'd';
      case Time.weeks:
        return 'week';
      case Time.month:
        return 'm';
      case Measurement.gram:
        return 'g';
      case Measurement.kilo:
        return 'kg';
      case Measurement.milliliter:
        return 'ml';
      case Measurement.liter:
        return 'l';
      case Measurement.packages:
        return 'pkt';
      case Measurement.units:
        return 'u';
    }
    return null;
  }

  String get liquid {
    if (unit == Unit.us) {
      return text('gallons');
    }
    return text('liters');
  }

  String get colorUnit {
    if (unit == Unit.us) {
      return 'SRM';
    }
    return 'EBC';
  }

  String get tempMeasure {
    if (unit == Unit.us) {
      return '°F';
    }
    return '°C';
  }

  int get maxColor {
    if (unit == Unit.us) {
      return 40;
    }
    return 80;
  }

  /// Returns the formatted datetime.
  String? datetimeFormat(datetime) {
    if (datetime == null) {
      return null;
    }
    return DateFormat.yMd(currentLanguage).add_jm().format(datetime);
  }

  String? dateFormat(datetime) {
    if (datetime == null) {
      return null;
    }
    return DateFormat.yMd(currentLanguage).format(datetime);
  }

  /// Returns the number format.
  double? decimal(String? number) {
    if (number == null || number.isEmpty) {
      return null;
    }
    try {
      return NumberFormat.decimalPattern(locale.toString()).parse(number) as double;
    }
    catch(e) {
      return double.tryParse(number);
    }
  }

  /// Returns the formatted decimal.
  String? numberFormat(num? number, {String pattern = "#0.#", String? symbol}) {
    if (number == null) {
      return null;
    }
    return NumberFormat(pattern, currentLanguage).format(number) + (symbol ?? '');
  }

  String? measurementFormat(num? number, Measurement? measurement) {
    if (number == null || measurement == null) {
      return null;
    }
    switch (measurement) {
      case Measurement.gram:
        return weightFormat(number);
      case Measurement.kilo:
        return weightFormat(number);
      case Measurement.milliliter:
        return litterVolumeFormat(number);
      case Measurement.liter:
        return litterVolumeFormat(number);
      case Measurement.packages:
        return numberFormat(number, symbol: ' pkt');
      case Measurement.units:
        return numberFormat(number);
    }
  }

  /// Returns the formatted currency.
  String? currencyFormat(num? number) {
    if (number == null) {
      return null;
    }
    return NumberFormat.simpleCurrency(locale: currentLanguage).format(number);
  }

  /// Returns the formatted temperature.
  String? tempFormat(num? number, {Unit? unit, bool? symbol = true}) {
    if (number == null) {
      return null;
    }
    unit = unit ?? this.unit;
    if (unit == Unit.us) {
      number = FormulaHelper.convertCelciusToFarenheit(number);
      return NumberFormat(symbol == true ? "#0.#°F" : "#0.#", currentLanguage).format(number);
    }
    return NumberFormat(symbol == true ? "#0.#°C" : "#0.#", currentLanguage).format(number);
  }

  /// Returns the formatted percent.
  String? percentFormat(num? number) {
    if (number == null) {
      return null;
    }
    return numberFormat(number, symbol: '%');
  }

  /// Returns the formatted duration, based on the given conditions.
  ///
  /// The `number` argument is relative to the number in minutes.
  String? durationFormat(num? number) {
    if (number == null) {
      return null;
    }
    if (number >= 2880) {
      return '${(number/1440).toInt()} ${text('days')}';
    } else if (number >= 1440) {
      return '${(number/1440).toInt()} ${text('day')}';
    }
    return '$number min';
  }

  /// Returns the formatted weight, based on the given conditions.
  ///
  /// The `number` argument is relative to the number in kilogram.
  String? kiloWeightFormat(double? number, {bool? symbol = true}) {
    if (number == null) {
      return null;
    }
    return weightFormat(number * 1000, symbol: symbol);
  }

  /// Returns the formatted weight, based on the given conditions.
  ///
  /// The `number` argument is relative to the number in grams.
  String? weightFormat(num? number, {bool? symbol = true}) {
    if (number == null) {
      return null;
    }
    String pattern = '#0.#';
    if (unit == Unit.us) {
      number = FormulaHelper.convertGramToOunce(number);
      var suffix = ' oz';
      if (symbol == true && number >= 10) {
        number = FormulaHelper.convertOunceToLivre(number);
        suffix = ' lb';
        pattern = '#0.##';
      }
      return numberFormat(number, symbol: (symbol == true ? suffix : null));
    }

    var suffix = ' g';
    if (symbol == true && number >= 1000) {
      number = number / 1000;
      suffix = ' kg';
      pattern = '#0.##';
    }
    return numberFormat(number, pattern: pattern, symbol: (symbol == true ? suffix : null));
  }

  /// Returns the suffix weight, based on the given conditions.
  ///
  /// The `weight` argument is relative to the number in grams.
  String? weightSuffix({Measurement? measurement = Measurement.gram}) {
    if (unit == Unit.us) {
      if (measurement == Measurement.gram) {
        return 'oz';
      }
      return 'lb';
    }

    if (measurement == Measurement.gram) {
      return 'g';
    }
    return 'kg';
  }

  /// Returns the localized weight, based on the given conditions.
  ///
  /// The `number` argument is relative to the number in grams.
  double? weight(double? number, {Measurement? measurement = Measurement.gram}) {
    if (number == null) {
      return null;
    }
    if (unit == Unit.us) {
      number = FormulaHelper.convertGramToOunce(number);
      if (measurement == Measurement.kilo) {
        number = FormulaHelper.convertOunceToLivre(number);
      }

      return number;
    }

    if (measurement == Measurement.kilo) {
      number = number / 1000;
    }
    return number;
  }


  /// Returns the localized weight to gram, based on the given conditions.
  double? gram(double? number, {Measurement? measurement = Measurement.gram}) {
    if (number == null) {
      return null;
    }
    if (unit == Unit.us) {
      if (measurement == Measurement.kilo) {
        number = FormulaHelper.convertLivreToOunce(number);
        number = number / 1000;
      }
      number =  FormulaHelper.convertOunceToGram(number);
    }
    // if (weight == Weight.kilo) {
    //   number = number * 1000;
    // }
    return number;
  }

  /// Returns the formatted volume, based on the given conditions.
  ///
  /// The `number` argument is relative to the number in litter.
  String? litterVolumeFormat(num? number, {bool? symbol = true}) {
    if (number == null) {
      return null;
    }
    return volumeFormat(number * 1000, symbol: symbol);
  }

  /// Returns the formatted volume, based on the given conditions.
  ///
  /// The `number` argument is relative to the number in millimeter.
  String? volumeFormat(double? number, {Unit? unit, bool? symbol = true}) {
    if (number == null) {
      return null;
    }
    unit = unit ?? this.unit;
    if (unit == Unit.us) {
      number = FormulaHelper.convertMillimeterToOnce(number);
      var suffix = ' oz';

      if (symbol == true && number >= 128) {
        number = number / 128;
        suffix = ' gal';
      }
      return numberFormat(number, symbol: (symbol == true ? suffix : null));
    }

    var suffix = ' ml';
    if (symbol == true && number >= 1000) {
      number = number / 1000;
      suffix = ' l';
    }
    return numberFormat(number, symbol: (symbol == true ? suffix : null));
  }

  /// Returns the localized volume to litter, based on the given conditions.
  double? volume(double? number) {
    if (number == null) {
      return null;
    }
    if (unit == Unit.us) {
      return FormulaHelper.convertGallonToLiter(number);
    }
    return number;
  }

  /// Returns the formatted color, based on the given conditions.
  ///
  /// The `number` argument is relative to the number in ebc color.
  String? colorFormat(num? number) {
    if (number == null) {
      return null;
    }
    if (unit == Unit.us) {
      return numberFormat(ColorHelper.toSRM(number));
    }
    return numberFormat(number);
  }

  /// Returns the localized volume to litter, based on the given conditions.
  int? color(int? number) {
    if (number == null) {
      return null;
    }
    if (unit == Unit.us) {
      number = ColorHelper.toSRM(number);
    }
    return number > maxColor ? maxColor : number;
  }

  int? fromSRM(num? number) {
    if (number != null) {
      if (unit == Unit.us) {
        return ColorHelper.toEBC(number);
      }
      return number.toInt();
    }
    return null;
  }

  /// Returns the formatted gravity.
  ///
  /// The `number` argument is relative to the number in specific gravity.
  String? gravityFormat(double? number, {Gravity? gravity, bool? symbol = true}) {
    switch(gravity ?? this.gravity) {
      case Gravity.sg:
        if (number == null || number <= 1 || number >= 2) {
          return '1.xxx';
        }
        return NumberFormat('0.000', 'en').format(number);
      case Gravity.plato:
        if (number == null) {
          return null;
        }
        return numberFormat(FormulaHelper.convertSGToPlato(number), symbol:  (symbol == true ? '°P' : null));
      case Gravity.brix:
        if (number == null) {
          return null;
        }
        return numberFormat(FormulaHelper.convertSGToBrix(number), symbol:  (symbol == true ? '°Bx' : null));
    }
  }
}

class TranslationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  final Locale? newLocale;
  final Unit? newMeasure;
  final Gravity? newGravity;

  const TranslationsDelegate({this.newLocale, this.newMeasure, this.newGravity});

  @override
  bool isSupported(Locale locale) {
    return ["en", "es", "fr"].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(newLocale ?? locale, newMeasure, newGravity);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    return true;
  }
}
