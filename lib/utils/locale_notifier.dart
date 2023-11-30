import 'dart:ui';

import 'package:flutter/foundation.dart';

// Internal package
import 'package:bab/utils/constants.dart';

class LocaleNotifier with ChangeNotifier {
  Locale? _locale;
  Locale? get locale => _locale;

  Unit? _unit;
  Unit? get unit => _unit;

  Gravity? _gravity;
  Gravity? get gravity => _gravity;

  void setLocale(Locale l) {
    _locale = l;
    notifyListeners();
  }

  void setUnit(Unit value){
    _unit = value;
    notifyListeners();
  }

  void setGravity(Gravity value){
    _gravity = value;
    notifyListeners();
  }
}
