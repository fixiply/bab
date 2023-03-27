import 'dart:ui';

import 'package:flutter/foundation.dart';

class LocaleNotifier with ChangeNotifier {
  Locale? locale;
  Locale? get getlocale => locale;

  void set(Locale l) {
    locale = l;
    notifyListeners();
  }
}
