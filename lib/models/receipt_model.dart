import 'package:bb/models/model.dart';
import 'package:bb/utils/constants.dart';

class ReceiptModel<T> extends Model {
  Status? status;
  String? title;
  String? subtitle;

  ReceiptModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    this.status = Status.pending,
    this.title,
    this.subtitle,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator);

  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.title = map['title'];
    this.subtitle = map['subtitle'];
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'title': this.title,
      'subtitle': this.subtitle,
    });
    return map;
  }

  ReceiptModel copy() {
    return ReceiptModel(
      uuid: this.uuid,
      inserted_at: this.inserted_at,
      updated_at: this.updated_at,
      creator: this.creator,
      status: this.status,
      title: this.title,
      subtitle: this.subtitle,
    );
  }

  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is ReceiptModel && other.uuid == uuid);
  }

  @override
  String toString() {
    return 'Receipt: $title, UUID: $uuid';
  }
}
