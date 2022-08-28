import 'package:flutter/foundation.dart';

// Internal package
import 'package:bb/models/product_model.dart';

class BasketNotifier with ChangeNotifier {
  List<ProductModel> _products = [];

  List<ProductModel> get products {
    return _products;
  }
}
