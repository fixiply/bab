import 'dart:ui';

import 'package:flutter/foundation.dart';

class LocaleNotifier with ChangeNotifier {
  Locale? _locale;
  Locale? get locale => _locale;

  void set(Locale l) {
    _locale = l;
    notifyListeners();
  }
}
