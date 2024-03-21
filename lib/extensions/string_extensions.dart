import 'package:flutter/material.dart';

extension StringExtension on String {
  toColor() {
    var hexColor = replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }

  bool containsWord(String? value, List<String> excludes) {
    if (value == null || value.isEmpty) return false;
    if (this.withoutDiacriticalMarks.toLowerCase() == value.withoutDiacriticalMarks.toLowerCase()) return true;
    for (final item in value.toLowerCase().split(' ')) {
      if (excludes.contains(RegExp(item.withoutDiacriticalMarks, caseSensitive: false))) continue;
      if (!this.withoutDiacriticalMarks.contains(RegExp(item.withoutDiacriticalMarks, caseSensitive: false))) return false;
    }
    return true;
  }

  bool containsOccurrence(List<String> values) {
    for (String item in values) {
      if (this.contains(RegExp(item.withoutDiacriticalMarks, caseSensitive: false))) return true;
    }
    return false;
  }

  String clean(List<String> values) {
    String value = this;
    for (final item in values) {
      value = value.replaceAll(RegExp(item.withoutDiacriticalMarks, caseSensitive: false), '');
    }
    value = value.replaceAll(new RegExp(r'[^\w\s]+'), '');
    // value = value.replaceAll(new RegExp(r'\p{Punctuation}'), '');
    // value = value.replaceAll(new RegExp(r'\p{Separator}'), '');
    // value = value.replaceAll(new RegExp(r'\p{General_Category=Math_Symbol}'), '');
    // value = value.replaceAll(new RegExp(r'\p{General_Category=Math_Symbol}'), '');
    value = value.trim();
    return value;
  }

  static const diacritics = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËĚèéêëěðČÇçčÐĎďÌÍÎÏìíîïĽľÙÚÛÜŮùúûüůŇÑñňŘřŠšŤťŸÝÿýŽž';
  static const nonDiacritics = 'AAAAAAaaaaaaOOOOOOOooooooEEEEEeeeeeeCCccDDdIIIIiiiiLlUUUUUuuuuuNNnnRrSsTtYYyyZz';

  String get withoutDiacriticalMarks => this.splitMapJoin('',
      onNonMatch: (char) => char.isNotEmpty && diacritics.contains(char)
          ? nonDiacritics[diacritics.indexOf(char)]
          : char);
}