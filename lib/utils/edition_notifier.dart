import 'package:bb/utils/constants.dart';
import 'package:flutter/foundation.dart';

class ValuesNotifier with ChangeNotifier {
  Measure _measure = Measure.metric;
  Gravity _gravity = Gravity.sg;

  Measure get measure => _measure;
  Gravity get gravity => _gravity;

  void set measure(Measure value){
    _measure = value;
    notifyListeners();
  }

  void set gravity(Gravity value){
    _gravity = value;
    notifyListeners();
  }
}
