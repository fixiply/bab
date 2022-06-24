import 'package:flutter/foundation.dart';

class EditionNotifier with ChangeNotifier {
  bool edition = false;
  bool editable = false;

  void setEdition(bool value){
    edition = value;
    notifyListeners();
  }

  void setEditable(bool value){
    editable = value;
    notifyListeners();
  }
}
