import 'package:flutter/material.dart';

// Internal package
import 'package:bb/utils/app_localizations.dart';

// External package
import 'package:intl/intl.dart';

class DateHelper {
  static DateTime? parse(String? value) {
    return value != null ? DateTime.parse(value) : null;
  }

  static bool isToday(DateTime date) {
    return toDate(date).difference(toDate(DateTime.now())).inDays == 0;
  }

  static bool isTomorrow(DateTime date) {
    return toDate(date).difference(toDate(DateTime.now())).inDays == 1;
  }

  static bool isShortly(DateTime date) {
    return toDate(date).difference(toDate(DateTime.now())).inDays > 1;
  }

  static Duration difference(DateTime date) {
    return toDate(date).difference(toDate(DateTime.now()));
  }

  static bool isBetween(DateTime? start, DateTime? end) {
    if (start != null && isAfterNow(start)) {
      return false;
    }
    if (end != null && isBeforeNow(end)) {
      return false;
    }
    return true;
  }

  static bool isAfterNow(DateTime date) {
    return toDate(date).isAfter(toDate(DateTime.now()));
  }

  static bool isSameOrAfterNow(DateTime date) {
    return toDate(DateTime.now()) == toDate(date) || isAfterNow(date);
  }

  static bool isBeforeNow(DateTime date) {
    return toDate(date).isBefore(toDate(DateTime.now()));
  }

  static bool isSameOrBeforeNow(DateTime date) {
    return toDate(toDate(DateTime.now())) == toDate(date) || isBeforeNow(date);
  }

  static DateTime toDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day, 0, 0, 0);
  }

  static String formatCompactDate(BuildContext context, DateTime? date) {
    if (date != null) {
      return MaterialLocalizations.of(context).formatCompactDate(date);
    }
    return '';
  }

  static String formatMediumDate(BuildContext context, DateTime? date) {
    if (date != null) {
      return MaterialLocalizations.of(context).formatMediumDate(date);
    }
    return '';
  }

  static String formatDateTime(BuildContext context, DateTime? date) {
    if (date != null) {
      Locale locale = AppLocalizations.of(context)!.locale;
      return DateFormat.yMd(locale.languageCode).add_jm().format(date);
    }
    return '';
  }

  static DateTime? seTime(DateTime? date, int time) {
    if (date != null) {
      return DateTime(date.year, date.month, date.day, time);
    }
    return null;
  }
}
