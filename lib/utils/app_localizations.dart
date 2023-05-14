import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

// Internal package
import 'package:bb/helpers/formula_helper.dart';
import 'package:bb/helpers/color_helper.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/localized_text.dart';

// External package
import 'package:intl/intl.dart';

class AppLocalizations {
  final Locale locale;
  Measure measure;
  Gravity gravity;
  static Map<dynamic, dynamic>? _localisedValues;

  AppLocalizations(this.locale, this.measure, this.gravity) {
    _localisedValues = null;
  }

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Future<AppLocalizations> load(Locale locale) async {
    Measure measure = Measure.metric;
    Gravity gravity = Gravity.sg;
    if (locale.countryCode == 'US') {
      measure = Measure.imperial;
    }
    AppLocalizations appTranslations = AppLocalizations(locale, measure, gravity);
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

  String localizedText(dynamic? value, {Locale? locale}) {
    return LocalizedText.text(locale ?? this.locale, value);
  }

  String get colon {
    if (currentLanguage == 'fr') {
      return ' :';
    }
    return ':';
  }

  String get liquid {
    if (measure == Measure.imperial) {
      return text('gallons');
    }
    return text('liters');
  }

  String get colorUnit {
    if (measure == Measure.imperial) {
      return 'SRM';
    }
    return 'EBC';
  }

  String get tempMeasure {
    if (measure == Measure.imperial) {
      return '°F';
    }
    return '°C';
  }

  int get maxColor {
    if (measure == Measure.imperial) {
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
  double? decimal(number) {
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
  String? numberFormat(number, {String pattern = "#0.#", String? symbol}) {
    if (number == null) {
      return null;
    }
    return NumberFormat(pattern, currentLanguage).format(number) + (symbol ?? '');
  }

  /// Returns the formatted currency.
  String? currencyFormat(number) {
    if (number == null) {
      return null;
    }
    return NumberFormat.simpleCurrency(locale: currentLanguage).format(number);
  }

  /// Returns the formatted temperature.
  String? tempFormat(number) {
    if (number == null) {
      return null;
    }
    if (measure == Measure.imperial) {
      return NumberFormat("#0.#°F", currentLanguage).format(number);
    }
    return NumberFormat("#0.#°C", currentLanguage).format(number);
  }

  /// Returns the formatted percent.
  String? percentFormat(number) {
    if (number == null) {
      return null;
    }
    return this.numberFormat(number, symbol: '%');
  }

  /// Returns the formatted duration, based on the given conditions.
  ///
  /// The `number` argument is relative to the number in minutes.
  String? durationFormat(number) {
    if (number == null) {
      return null;
    }
    if (number >= 2880) {
      return '${number/1440} ${text('days')}';
    } else if (number >= 1440) {
      return '${number/1440} ${text('day')}';
    }
    return '$number min';
  }

  /// Returns the formatted weight, based on the given conditions.
  ///
  /// The `number` argument is relative to the number in kilogram.
  String? kiloWeightFormat(number, {bool? symbol = true}) {
    return weightFormat(number * 1000, symbol: symbol);
  }

  /// Returns the formatted weight, based on the given conditions.
  ///
  /// The `number` argument is relative to the number in grams.
  String? weightFormat(number, {bool? symbol = true}) {
    if (number == null) {
      return null;
    }
    if (measure == Measure.imperial) {
      number = FormulaHelper.convertGramToOunce(number);
      var suffix = ' oz';
      if (symbol == true && number >= 10) {
        number = FormulaHelper.convertOunceToLivre(number);
        suffix = ' lb';
      }
      return this.numberFormat(number, symbol: (symbol == true ? suffix : null));
    }

    var suffix = ' g';
    if (symbol == true && number >= 1000) {
      number = number / 1000;
      suffix = ' kg';
    }
    return this.numberFormat(number, symbol: (symbol == true ? suffix : null));
  }

  /// Returns the suffix weight, based on the given conditions.
  ///
  /// The `weight` argument is relative to the number in grams.
  String? weightSuffix({Weight? weight = Weight.gram}) {
    if (measure == Measure.imperial) {
      if (weight == Weight.gram) {
        return 'oz';
      }
      return 'lb';
    }

    if (weight == Weight.gram) {
      return 'g';
    }
    return 'kg';
  }

  /// Returns the localized weight, based on the given conditions.
  ///
  /// The `number` argument is relative to the number in grams.
  double? weight(number, {Weight? weight = Weight.gram}) {
    if (number == null) {
      return null;
    }
    if (measure == Measure.imperial) {
      number = FormulaHelper.convertGramToOunce(number);
      if (weight == Weight.kilo) {
        number = FormulaHelper.convertOunceToLivre(number);
      }

      return number;
    }

    if (weight == Weight.kilo) {
      number = number / 1000;
    }
    return number;
  }


  /// Returns the localized weight to gram, based on the given conditions.
  double? gram(number, {Weight? weight = Weight.gram}) {
    if (number == null) {
      return null;
    }
    if (measure == Measure.imperial) {
      if (weight == Weight.kilo) {
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
  String? litterVolumeFormat(number, {bool? symbol = true}) {
    if (number == null) {
      return null;
    }
    return volumeFormat(number * 1000, symbol: symbol);
  }

  /// Returns the formatted volume, based on the given conditions.
  ///
  /// The `number` argument is relative to the number in millimeter.
  String? volumeFormat(number, {bool? symbol = true}) {
    if (number == null) {
      return null;
    }
    if (measure == Measure.imperial) {
      number = FormulaHelper.convertLiterToGallon(number);
      var suffix = ' oz';
      if (symbol == true && number >= 1280) {
        number = number / 128;
        suffix = ' gal';
      }
      return this.numberFormat(number, symbol: (symbol == true ? suffix : null));
    }

    var suffix = ' ml';
    if (symbol == true && number >= 1000) {
      number = number / 1000;
      suffix = ' l';
    }
    return this.numberFormat(number, symbol: (symbol == true ? suffix : null));
  }

  /// Returns the localized volume to litter, based on the given conditions.
  double? volume(number) {
    if (number == null) {
      return null;
    }
    if (measure == Measure.imperial) {
      return FormulaHelper.convertGallonToLiter(number);
    }
    return number;
  }

  /// Returns the formatted color, based on the given conditions.
  ///
  /// The `number` argument is relative to the number in ebc color.
  String? colorFormat(number) {
    if (number == null) {
      return null;
    }
    if (measure == Measure.imperial) {
      return this.numberFormat(ColorHelper.toSRM(number));
    }
    return this.numberFormat(number);
  }

  /// Returns the localized volume to litter, based on the given conditions.
  int? color(number) {
    if (number == null) {
      return null;
    }
    if (measure == Measure.imperial) {
      number = ColorHelper.toSRM(number);
    }
    return number > maxColor ? maxColor : number;
  }

  int? fromSRM(number) {
    if (number != null && measure == Measure.imperial) {
      return ColorHelper.toEBC(number);
    }
    return number;
  }

  /// Returns the formatted gravity.
  String? gravityFormat(number) {
    switch(gravity) {
      case Gravity.sg:
        if (number == null || number <= 1 || number >= 2) {
          return '1.xxx';
        }
        return NumberFormat('0.000', 'en').format(number);
      case Gravity.plato:
        if (number == null) {
          return null;
        }
        return this.numberFormat(FormulaHelper.convertSGToPlato(number), symbol: '°P');
      case Gravity.brix:
        if (number == null) {
          return null;
        }
        return this.numberFormat(FormulaHelper.convertSGToBrix(number), symbol: '°Bx');
    }
  }
}

class TranslationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  final Locale? newLocale;

  const TranslationsDelegate({this.newLocale});

  @override
  bool isSupported(Locale locale) {
    return ["en", "es", "fr"].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(newLocale ?? locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    return true;
  }
}
