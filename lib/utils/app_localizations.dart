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
  Unit unit;
  static Map<dynamic, dynamic>? _localisedValues;

  AppLocalizations(this.locale, this.unit) {
    _localisedValues = null;
  }

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Future<AppLocalizations> load(Locale locale) async {
    Unit unit = Unit.metric;
    if (locale.countryCode == 'US') {
      unit = Unit.imperial;
    }
    AppLocalizations appTranslations = AppLocalizations(locale, unit);
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

  String get liquidUnit {
    if (unit == Unit.imperial) {
      return text('gallons');
    }
    return text('liters');
  }

  String get colorUnit {
    if (unit == Unit.imperial) {
      return 'SRM';
    }
    return 'EBC';
  }

  String get tempUnit {
    if (unit == Unit.imperial) {
      return '°F';
    }
    return '°C';
  }

  int get maxColor {
    if (unit == Unit.imperial) {
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
  String? numberFormat(number, {String newPattern = "#0.#", String? symbol}) {
    if (number == null) {
      return null;
    }
    return NumberFormat(newPattern, currentLanguage).format(number) + (symbol ?? '');
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
    if (unit == Unit.imperial) {
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
  /// The `number` argument is relative to the number in grams.
  String? weightFormat(number) {
    if (number == null) {
      return null;
    }
    if (unit == Unit.imperial) {
      number = FormulaHelper.convertGramToOunce(number);
      var suffix = ' oz';
      if (number >= 10) {
        number = FormulaHelper.convertOunceToLivre(number);
        suffix = ' lb';
      }
      return this.numberFormat(number, symbol: suffix);
    }

    var suffix = ' g';
    if (number >= 1000) {
      number = number / 1000;
      suffix = ' kg';
    }
    return this.numberFormat(number, symbol: suffix);
  }

  /// Returns the suffix weight, based on the given conditions.
  ///
  /// The `weight` argument is relative to the number in grams.
  String? weightSuffix({Weight? weight = Weight.gram}) {
    if (unit == Unit.imperial) {
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
    if (unit == Unit.imperial) {
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
    if (unit == Unit.imperial) {
      if (weight == Weight.kilo) {
        number = FormulaHelper.convertLivreToOunce(number);
      }
      number =  FormulaHelper.convertOunceToGram(number);
    }
    if (weight == Weight.kilo) {
      number = number / 1000;
    }
    return number;
  }


  /// Returns the formatted volume, based on the given conditions.
  ///
  /// The `number` argument is relative to the number in litters.
  String? volumeFormat(number, {bool? symbol = true}) {
    if (number == null) {
      return null;
    }
    if (unit == Unit.imperial) {
      return this.numberFormat(FormulaHelper.convertLiterToGallon(number), symbol: (symbol == true ? ' gal' : null));
    }
    return this.numberFormat(number, symbol: (symbol == true ? ' L' : null));
  }

  /// Returns the localized volume to litter, based on the given conditions.
  double? volume(number) {
    if (number == null) {
      return null;
    }
    if (unit == Unit.imperial) {
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
    if (unit == Unit.imperial) {
      return this.numberFormat(ColorHelper.toSRM(number));
    }
    return this.numberFormat(number);
  }

  /// Returns the localized volume to litter, based on the given conditions.
  int? color(number) {
    if (number == null) {
      return null;
    }
    if (unit == Unit.imperial) {
      number = ColorHelper.toSRM(number);
    }
    return number > maxColor ? maxColor : number;
  }

  int? fromSRM(number) {
    if (number != null && unit == Unit.imperial) {
      return ColorHelper.toEBC(number);
    }
    return number;
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
