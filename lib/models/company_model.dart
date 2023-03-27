// Internal package
import 'package:bb/models/image_model.dart';
import 'package:bb/models/model.dart';
import 'package:bb/helpers/date_helper.dart';
import 'package:bb/utils/constants.dart';
import 'package:flutter/material.dart';

class CompanyModel<T> extends Model {
  Status? status;
  String? name;
  String? text;
  ImageModel? image;

  CompanyModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    this.status = Status.publied,
    this.name,
    this.text,
    this.image,
  });

  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.inserted_at = DateHelper.parse(map['inserted_at']);
    this.updated_at = DateHelper.parse(map['updated_at']);
    this.name = map['name'];
    this.text = map['text'];
    this.image = ImageModel.fromJson(map['image']);
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'name': this.name,
      'text': this.text,
      'image': ImageModel.serialize(this.image),
    });
    return map;
  }

  CompanyModel copy() {
    return CompanyModel(
      uuid: this.uuid,
      inserted_at: this.inserted_at,
      updated_at: this.updated_at,
      creator: this.creator,
      status: this.status,
      name: this.name,
      text: this.text,
      image: this.image
    );
  }

  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is CompanyModel && other.uuid == uuid);
  }

  @override
  String toString() {
    return 'Company: $name, UUID: $uuid';
  }
}
