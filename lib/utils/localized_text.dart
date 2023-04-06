import 'package:flutter/material.dart';
import 'dart:ui';

class LocalizedText<T> implements Comparable<LocalizedText> {
  Map<String, dynamic>? map;

  LocalizedText({
    this.map,
  }){
    if (map == null) map = {};
  }

  LocalizedText copy() {
    return LocalizedText(
      map: this.map
    );
  }

  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is LocalizedText && other.map == map);
  }

  int compareTo(other) {
    return toString().compareTo(other.toString());
  }

  @override
  String toString() {
    if (map!.containsKey(window.locale.languageCode)) {
      return map![window.locale.languageCode] ?? '';
    }
    return map!.values.first;
  }

  int size()  {
    return map!.length;
  }

  bool containsKey(String? key)  {
    return map!.containsKey(key);
  }

  bool contains(Locale locale)  {
    return containsKey(locale.languageCode);
  }

  void add(Locale? locale, String? value)  {
    if (locale != null) {
      if (value != null) {
        map![locale.languageCode] = value;
      }
      else map!.remove(locale);
    }
  }

  String? get(Locale? locale)  {
    if (locale == null) return null;
    if (contains(locale)) {
      return map![locale.languageCode];
    }
    return map!.values.first;
  }

  void remove(Locale locale)  {
    map!.remove(locale.languageCode);
  }

  static dynamic serialize(dynamic data) {
    if (data is LocalizedText) {
      return data.map;
    }
    return data;
  }

  static dynamic? deserialize(dynamic data) {
    if (data is Map<String, dynamic>) {
      return LocalizedText(map: data);
    } else {
      return data;
    }
  }

  static dynamic? init(Locale? locale, String? value) {

  }

  static String text(Locale? locale, dynamic? value) {
    if (value is LocalizedText) {
      return value.get(locale) ?? '';
    }
    return value ?? '';
  }

  static String emoji(String country) {
    int flagOffset = 0x1F1E6;
    int asciiOffset = 0x41;
    int firstChar = country.codeUnitAt(0) - asciiOffset + flagOffset;
    int secondChar = country.codeUnitAt(1) - asciiOffset + flagOffset;
    return String.fromCharCode(firstChar) + String.fromCharCode(secondChar);
  }

  static String? country(String value) {
    if (value != null && value.trim().length > 0) {
      if (value.toUpperCase().contains('U.S.'.toUpperCase()) || value.toUpperCase().contains('US - YCH Hops'.toUpperCase()))
        return 'US';
      if (value.toUpperCase().contains('United Kingdom'.toUpperCase()))
        return 'GB';
      if (value.toUpperCase().contains('South African'.toUpperCase()))
        return 'ZA';
      if (value.toUpperCase().contains('Czech Republic'.toUpperCase()))
        return 'CZ';
      if (value.toUpperCase().contains('Slovenia'.toUpperCase()))
        return 'SL';
      if (value.toUpperCase().contains('New Zealand'.toUpperCase()))
        return 'NZ';
      if (value.toUpperCase().contains('Poland'.toUpperCase()))
        return 'PL';
      if (value.toUpperCase().contains('Japan'.toUpperCase()))
        return 'JP';
      if (value.toUpperCase().contains('Russia'.toUpperCase()))
        return 'RU';
      if (value.toUpperCase().contains('China'.toUpperCase()))
        return 'ZH';
      if (value.toUpperCase().contains('Yugoslavia'.toUpperCase()))
        return 'YU';
      if (value.toUpperCase().contains('Germany'.toUpperCase()) || value.toUpperCase().contains('German'.toUpperCase()))
        return 'DE';
      if (value.toUpperCase().contains('France'.toUpperCase()))
        return 'FR';
      if (value.toUpperCase().contains('Switzerland'.toUpperCase()))
        return 'CH';
      if (value.toUpperCase().contains('Belgium'.toUpperCase()) || value.toUpperCase().contains('Belgian'.toUpperCase()))
        return 'BE';
      if (value.toUpperCase().contains('Italy'.toUpperCase()))
        return 'IT';
      if (value.toUpperCase().contains('Australia'.toUpperCase()))
        return 'AU';
      if (value.toUpperCase().contains('Scotland'.toUpperCase()))
        return 'GD';
      if (value.toUpperCase().contains('Canada'.toUpperCase()))
        return 'CA';
      return value.toUpperCase();
    }
  }
}
