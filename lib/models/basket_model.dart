// Internal package
import 'package:bb/models/model.dart';
import 'package:bb/utils/constants.dart';

class BasketModel<T> extends Model {
  Status? status;
  String? product;
  double? price;
  int? quantity;

  BasketModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    this.status = Status.pending,
    this.product,
    this.price,
    this.quantity,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator);

  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.product = map['product'];
    if (map['price'] != null) this.price = map['price'].toDouble();
    this.quantity = map['quantity'];
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'product': this.product,
      'price': this.price,
      'quantity': this.quantity,
    });
    return map;
  }

  BasketModel copy() {
    return BasketModel(
      uuid: this.uuid,
      inserted_at: this.inserted_at,
      updated_at: this.updated_at,
      creator: this.creator,
      status: this.status,
      product: this.product,
      price: this.price,
      quantity: this.quantity,
    );
  }

  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is BasketModel && other.uuid == uuid);
  }

  @override
  String toString() {
    return 'Basket: $product, UUID: $uuid';
  }
}
