import 'package:flutter/foundation.dart';

// Internal package
import 'package:bab/models/user_model.dart';

class UserNotifier with ChangeNotifier {
  UserModel? _user;
  UserModel? get user => _user;

  void set(UserModel? u) {
    _user = u;
    notifyListeners();
  }
}
