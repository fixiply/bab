// Internal package
import 'package:bb/models/model.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/localized_text.dart';
import 'package:flutter/material.dart';

class StyleModel<T> extends Model {
  Status? status;
  Fermentation? fermentation;
  dynamic? name;
  String? number;
  dynamic? category;
  dynamic? overallimpression;
  dynamic? aroma;
  dynamic? appareance;
  dynamic? flavor;
  dynamic? mouthfeel;
  dynamic? comments;
  double? ogmin;
  double? ogmax;
  double? fgmin;
  double? fgmax;
  double? abvmin;
  double? abvmax;
  double? ibumin;
  double? ibumax;
  int? ebcmin;
  int? ebcmax;

  StyleModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    this.status = Status.publied,
    this.fermentation = Fermentation.hight,
    this.name,
    this.number,
    this.category,
    this.overallimpression,
    this.aroma,
    this.appareance,
    this.flavor,
    this.mouthfeel,
    this.comments,
    this.ogmin,
    this.ogmax,
    this.fgmin,
    this.fgmax,
    this.abvmin,
    this.abvmax,
    this.ibumin,
    this.ibumax,
    this.ebcmin,
    this.ebcmax
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator);

  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.fermentation = Fermentation.values.elementAt(map['fermentation']);
    this.name = LocalizedText.deserialize(map['name']);
    this.number = map['number'];
    this.category = LocalizedText.deserialize(map['category']);
    this.overallimpression = LocalizedText.deserialize(map['overallimpression']);
    this.aroma = LocalizedText.deserialize(map['aroma']);
    this.appareance = LocalizedText.deserialize(map['appareance']);
    this.flavor = LocalizedText.deserialize(map['flavor']);
    this.mouthfeel = LocalizedText.deserialize(map['mouthfeel']);
    this.comments = LocalizedText.deserialize(map['comments']);
    if (map['ogmin'] != null) this.ogmin = map['ogmin'].toDouble();
    if (map['ogmax'] != null) this.ogmax = map['ogmax'].toDouble();
    if (map['fgmin'] != null) this.fgmin = map['fgmin'].toDouble();
    if (map['fgmax'] != null) this.fgmax = map['fgmax'].toDouble();
    if (map['abvmin'] != null) this.abvmin = map['abvmin'].toDouble();
    if (map['abvmax'] != null) this.abvmax = map['abvmax'].toDouble();
    if (map['ibumin'] != null) this.ibumin = map['ibumin'].toDouble();
    if (map['ibumax'] != null) this.ibumax = map['ibumax'].toDouble();
    this.ebcmin = map['ebcmin'];
    this.ebcmax = map['ebcmax'];
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'fermentation': this.fermentation!.index,
      'name': LocalizedText.serialize(this.name),
      'number': this.number,
      'category': LocalizedText.serialize(this.category),
      'overallimpression': LocalizedText.serialize(this.overallimpression),
      'aroma': LocalizedText.serialize(this.aroma),
      'appareance': LocalizedText.serialize(this.appareance),
      'flavor': LocalizedText.serialize(this.flavor),
      'mouthfeel': LocalizedText.serialize(this.mouthfeel),
      'comments': LocalizedText.serialize(this.comments),
      'ogmin': this.ogmin,
      'ogmax': this.ogmax,
      'fgmin': this.fgmin,
      'fgmax': this.fgmax,
      'abvmin': this.abvmin,
      'abvmax': this.abvmax,
      'ibumin': this.ibumin,
      'ibumax': this.ibumax,
      'ebcmin': this.ebcmin,
      'ebcmax': this.ebcmax,
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
      number: this.number,
      category: this.category,
      overallimpression: this.overallimpression,
      aroma: this.aroma,
      appareance: this.appareance,
      flavor: this.flavor,
      mouthfeel: this.mouthfeel,
      comments: this.comments,
      ogmin: this.ogmin,
      ogmax: this.ogmax,
      fgmin: this.fgmin,
      fgmax: this.fgmax,
      abvmin: this.abvmin,
      abvmax: this.abvmax,
      ibumin: this.ibumin,
      ibumax: this.ibumax,
      ebcmin: this.ebcmin,
      ebcmax: this.ebcmax,
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
}
