// Internal package
import 'package:bb/models/image_model.dart';
import 'package:bb/models/model.dart';
import 'package:bb/models/rating_model.dart';
import 'package:bb/utils/constants.dart';
import 'package:flutter/foundation.dart';

class ReceiptModel<T> extends Model {
  Status? status;
  String? title;
  String? text;
  ImageModel? image;
  String? style;
  double? alcohol;
  double? ibu;
  double? ebc;

  ReceiptModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    this.status = Status.pending,
    this.title,
    this.text,
    this.image,
    this.style,
    this.alcohol,
    this.ibu,
    this.ebc
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator);

  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.title = map['title'];
    this.text = map['text'];
    this.image = ImageModel.fromJson(map['image']);
    this.style = map['style'];
    if (map['alcohol'] != null) this.alcohol = map['alcohol'].toDouble();
    if (map['ibu'] != null) this.ibu = map['ibu'].toDouble();
    if (map['ebc'] != null) this.ebc = map['ebc'].toDouble();
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'title': this.title,
      'text': this.text,
      'image': ImageModel.serialize(this.image),
      'style': this.style,
      'alcohol': this.alcohol,
      'ibu': this.ibu,
      'ebc': this.ebc
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
      text: this.text,
      image: this.image,
      style: this.style,
      alcohol: this.alcohol,
      ibu: this.ibu,
      ebc: this.ebc
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

  int getSRM() {
    return (ebc! * 0.508).toInt();
  }
}
