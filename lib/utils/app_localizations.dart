import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

// External package
import 'package:intl/intl.dart';

class AppLocalizations {
  final Locale locale;
  static Map<dynamic, dynamic>? _localisedValues;

  AppLocalizations(this.locale) {
    _localisedValues = null;
  }

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations appTranslations = AppLocalizations(locale);
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

  String get colon {
    if (currentLanguage == 'fr') {
      return ' :';
    }
    return ':';
  }

  String? number(double? number, {String? symbol}) {
    if (number == null) {
      return null;
    }
    return NumberFormat("#0.#", currentLanguage).format(number) + symbol!;
  }

  String? currency(double? number) {
    if (number == null) {
      return null;
    }
    return NumberFormat.simpleCurrency(locale: currentLanguage).format(number);
  }

  String? temperature(double? number) {
    if (number == null) {
      return null;
    }
    return NumberFormat("#0.#°C", currentLanguage).format(number);
  }

  /// Returns the localized duration, based on the given conditions.
  ///
  /// The `number` argument is relative to the number in minutes.
  String? duration(int? number) {
    if (number == null) {
      return null;
    }
    return '$number min';
  }

  String? percent(double? number) {
    if (number == null) {
      return null;
    }
    return this.number(number, symbol: '%');
  }

  /// Returns the localized weight, based on the given conditions.
  ///
  /// The `number` argument is relative to the number in grams.
  String? weight(double? number) {
    if (number == null) {
      return null;
    }
    var suffix = ' g';
    if (number >= 100) {
      number = number / 100;
      suffix = ' kg';
    }
    return this.number(number, symbol: suffix);
  }

  String? volume(double? number) {
    if (number == null) {
      return null;
    }
    return this.number(number, symbol: ' L');
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
