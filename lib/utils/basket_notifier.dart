import 'package:flutter/foundation.dart';

// Internal package
import 'package:bb/models/basket_model.dart';

class BasketNotifier with ChangeNotifier {
  List<BasketModel> _baskets = [];

  void add(BasketModel model) {
    bool found = false;
    for(BasketModel old in _baskets) {
      if (old.product == model.product) {
        old.quantity = old.quantity! + model.quantity!;
        found = true;
        break;
      }
    }
    if (!found) _baskets.add(model);
    notifyListeners();
  }

  void set(BasketModel model) {
    bool found = false;
    for(BasketModel old in _baskets) {
      if (old.product == model.product) {
        old.quantity = model.quantity!;
        found = true;
        break;
      }
    }
    if (!found) _baskets.add(model);
    notifyListeners();
  }

  void remove(BasketModel model) {
    _baskets.remove(model);
    notifyListeners();
  }

  List<BasketModel> get baskets {
    return _baskets;
  }

  int get size {
    return _baskets.length;
  }

  double get total {
    double total = 0;
    for(BasketModel model in _baskets) {
      total += (model.quantity! * model.price!).toDouble();
    }
    return total;
  }
}
