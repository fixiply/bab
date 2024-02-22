// Internal package
import 'package:bab/helpers/date_helper.dart';
import 'package:bab/models/model.dart';
import 'package:bab/utils/constants.dart';

class PurchaseModel<T> extends Model {
  String? name;
  String? transaction;

  PurchaseModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    this.name,
    this.transaction,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator);

  @override
  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.name = map['name'];
    this.transaction = map['transaction'];
  }

  @override
  Map<String, dynamic> toMap({bool persist = false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'name': this.name,
      'transaction': this.transaction,
    });
    return map;
  }

  PurchaseModel copy() {
    return PurchaseModel(
      uuid: uuid,
      inserted_at: inserted_at,
      updated_at: updated_at,
      creator: creator,
      name: this.name,
      transaction: this.transaction,
    );
  }

  // ignore: hash_and_equals
  @override
  bool operator ==(other) {
    return (other is PurchaseModel && other.uuid == uuid);
  }

  @override
  int get hashCode => uuid.hashCode;

  @override
  String toString() {
    return 'Purchase: $name, UUID: $uuid';
  }
}
