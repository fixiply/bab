import 'dart:ui';

import 'package:flutter/foundation.dart';

// Internal package
import 'package:bab/models/model.dart';

enum Changes { added, modified, deleted }

class ChangesNotifier with ChangeNotifier {
  Model? _model;
  Changes? _changes;
  Model get model => _model!;
  Changes get changes => _changes!;

  void set(Model model, Changes changes) {
    _model = model;
    _changes = changes;
    notifyListeners();
  }
}
