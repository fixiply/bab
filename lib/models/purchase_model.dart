// Internal package
import 'package:bb/models/model.dart';
import 'package:bb/utils/constants.dart';

class PurchaseModel<T> extends Model {
  Status? status;
  String? name;

  PurchaseModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    this.status = Status.pending,
    this.name,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator);

  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.name = map['name'];
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'name': this.name,
    });
    return map;
  }

  PurchaseModel copy() {
    return PurchaseModel(
      uuid: this.uuid,
      inserted_at: this.inserted_at,
      updated_at: this.updated_at,
      creator: this.creator,
      status: this.status,
      name: this.name,
    );
  }

  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is PurchaseModel && other.uuid == uuid);
  }

  @override
  String toString() {
    return 'Purchase: $name, UUID: $uuid';
  }
}
