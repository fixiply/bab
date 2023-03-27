// Internal package
import 'package:bb/models/model.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/localized_text.dart';
import 'package:flutter/material.dart';

class StyleModel<T> extends Model {
  Status? status;
  Fermentation? fermentation;
  dynamic? name;
  dynamic? text;
  dynamic? category;
  double? min_abv;
  double? max_abv;
  double? min_ibu;
  double? max_ibu;
  double? min_srm;
  double? max_srm;

  StyleModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    this.status = Status.publied,
    this.fermentation = Fermentation.hight,
    this.name,
    this.text,
    this.category,
    this.min_abv,
    this.max_abv,
    this.min_ibu,
    this.max_ibu,
    this.min_srm,
    this.max_srm
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator);

  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.fermentation = Fermentation.values.elementAt(map['fermentation']);
    this.name = LocalizedText.deserialize(map['name']);
    if (name == null) {
      this.name = LocalizedText.deserialize(map['title']);
    }
    this.text = LocalizedText.deserialize(map['text']);
    this.category = LocalizedText.deserialize(map['category']);
    if (map['min_abv'] != null) this.min_abv = map['min_abv'].toDouble();
    if (map['max_abv'] != null) this.max_abv = map['max_abv'].toDouble();
    if (map['min_ibu'] != null) this.min_ibu = map['min_ibu'].toDouble();
    if (map['max_ibu'] != null) this.max_ibu = map['max_ibu'].toDouble();
    if (map['min_srm'] != null) this.min_srm = map['min_srm'].toDouble();
    if (map['max_srm'] != null) this.max_srm = map['max_srm'].toDouble();
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'fermentation': this.fermentation!.index,
      'name': LocalizedText.serialize(this.name),
      'text': LocalizedText.serialize(this.text),
      'category': LocalizedText.serialize(this.category),
      'min_abv': this.min_abv,
      'max_abv': this.max_abv,
      'min_ibu': this.min_ibu,
      'max_ibu': this.max_ibu,
      'min_srm': this.min_srm,
      'max_srm': this.max_srm,
    });
    return map;
  }

  StyleModel copy() {
    return StyleModel(
      uuid: this.uuid,
      inserted_at: this.inserted_at,
      updated_at: this.updated_at,
      creator: this.creator,
      status: this.status,
      fermentation: this.fermentation,
      name: this.name,
      text: this.text,
      category: this.category,
      min_abv: this.min_abv,
      max_abv: this.max_abv,
      min_ibu: this.min_ibu,
      max_ibu: this.max_ibu,
      min_srm: this.min_srm,
      max_srm: this.max_srm,
    );
  }

  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is StyleModel && other.uuid == uuid || other is String && other == uuid);
  }

  @override
  String toString() {
    return 'Style: $name, UUID: $uuid';
  }

  String? localizedName(Locale? locale) {
    if (this.name is LocalizedText) {
      return this.name.get(locale);
    }
    return this.name;
  }

  String? localizedText(Locale? locale) {
    if (this.text is LocalizedText) {
      return this.text.get(locale);
    }
    return this.text;
  }

  String? localizedCategory(Locale? locale) {
    if (this.category is LocalizedText) {
      return this.category.get(locale);
    }
    return this.category;
  }
}
