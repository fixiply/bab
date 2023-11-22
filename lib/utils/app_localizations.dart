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
      case Unit.gram:
        return 'g';
      case Unit.kilo:
        return 'kg';
      case Unit.milliliter:
        return 'ml';
      case Unit.liter:
        return 'l';
      case Unit.packages:
        return 'pkt';
      case Unit.units:
        return 'u';
    }
    return null;
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

  /// Returns the formatted currency.
  String? currencyFormat(num? number) {
    if (number == null) {
      return null;
    }
    return NumberFormat.simpleCurrency(locale: currentLanguage).format(number);
  }

  /// Returns the formatted temperature.
  String? tempFormat(num? number) {
    if (number == null) {
      return null;
    }
    if (measure == Measure.imperial) {
      return NumberFormat("#0.#°F", currentLanguage).format(number);
    }
    return NumberFormat("#0.#°C", currentLanguage).format(number);
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
  String? weightFormat(double? number, {bool? symbol = true}) {
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
      return numberFormat(number, symbol: (symbol == true ? suffix : null));
    }

    var suffix = ' g';
    if (symbol == true && number >= 1000) {
      number = number / 1000;
      suffix = ' kg';
    }
    return numberFormat(number, symbol: (symbol == true ? suffix : null));
  }

  /// Returns the suffix weight, based on the given conditions.
  ///
  /// The `weight` argument is relative to the number in grams.
  String? weightSuffix({Unit? unit = Unit.gram}) {
    if (measure == Measure.imperial) {
      if (unit == Unit.gram) {
        return 'oz';
      }
      return 'lb';
    }

    if (unit == Unit.gram) {
      return 'g';
    }
    return 'kg';
  }

  /// Returns the localized weight, based on the given conditions.
  ///
  /// The `number` argument is relative to the number in grams.
  double? weight(double? number, {Unit? unit = Unit.gram}) {
    if (number == null) {
      return null;
    }
    if (measure == Measure.imperial) {
      number = FormulaHelper.convertGramToOunce(number);
      if (unit == Unit.kilo) {
        number = FormulaHelper.convertOunceToLivre(number);
      }

      return number;
    }

    if (unit == Unit.kilo) {
      number = number / 1000;
    }
    return number;
  }


  /// Returns the localized weight to gram, based on the given conditions.
  double? gram(double? number, {Unit? unit = Unit.gram}) {
    if (number == null) {
      return null;
    }
    if (measure == Measure.imperial) {
      if (unit == Unit.kilo) {
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
  String? volumeFormat(double? number, {bool? symbol = true}) {
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
    if (measure == Measure.imperial) {
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
    if (measure == Measure.imperial) {
      return numberFormat(ColorHelper.toSRM(number));
    }
    return numberFormat(number);
  }

  /// Returns the localized volume to litter, based on the given conditions.
  int? color(int? number) {
    if (number == null) {
      return null;
    }
    if (measure == Measure.imperial) {
      number = ColorHelper.toSRM(number);
    }
    return number > maxColor ? maxColor : number;
  }

  int? fromSRM(num? number) {
    if (number != null) {
      if (measure == Measure.imperial) {
        return ColorHelper.toEBC(number);
      }
      return number.toInt();
    }
    return null;
  }

  /// Returns the formatted gravity.
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
