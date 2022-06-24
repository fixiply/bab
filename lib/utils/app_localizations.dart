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

  String currency(double value) {
    final formatter = NumberFormat.simpleCurrency(locale: locale.languageCode);
    return formatter.format(value);
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
