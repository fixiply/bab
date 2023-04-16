import 'package:flutter/material.dart';

// Internal package
import 'package:bb/models/image_model.dart';
import 'package:bb/models/model.dart';
import 'package:bb/models/style_model.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/localized_text.dart';
import 'package:bb/utils/mash.dart';
import 'package:bb/utils/quantity.dart';
import 'package:intl/intl.dart';

class ReceiptModel<T> extends Model {
  Status? status;
  dynamic? title;
  dynamic? text;
  bool? shared;
  StyleModel? style;
  double? volume;
  int? boil;
  double? efficiency;
  double? og;
  double? fg;
  double? abv;
  double? ibu;
  int? ebc;
  List<Quantity>? fermentables;
  List<Quantity>? hops;
  List<Quantity>? miscellaneous;
  List<Quantity>? yeasts;
  List<Mash>? mash;
  dynamic? notes;
  ImageModel? image;

  ReceiptModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    this.status = Status.disabled,
    this.title,
    this.text,
    this.shared = false,
    this.style,
    this.volume,
    this.boil = 60,
    this.efficiency = DEFAULT_YIELD,
    this.og,
    this.fg,
    this.abv,
    this.ibu,
    this.ebc,
    this.fermentables,
    this.hops,
    this.miscellaneous,
    this.yeasts,
    this.mash,
    this.notes,
    this.image,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator) {
    if (fermentables == null) { fermentables = []; }
    if (hops == null) { hops = []; }
    if (miscellaneous == null) { miscellaneous = []; }
    if (yeasts == null) { yeasts = []; }
    if (mash == null) { mash = []; }
  }

  Future fromMap(Map<String, dynamic> map) async {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.title = LocalizedText.deserialize(map['title']);
    this.text = LocalizedText.deserialize(map['text']);
    if (map.containsKey('shared')) this.shared = map['shared'];
    if (map['style'] != null) this.style = await Database().getStyle(map['style']);
    if (map['volume'] != null) this.volume = map['volume'].toDouble();
    if (map['boil'] != null) this.boil = map['boil'];
    if (map['efficiency'] != null) this.efficiency = map['efficiency'].toDouble();
    if (map['og'] != null) this.og = map['og'].toDouble();
    if (map['fg'] != null) this.fg = map['fg'].toDouble();
    if (map['abv'] != null) this.abv = map['abv'].toDouble();
    if (map['ibu'] != null) this.ibu = map['ibu'].toDouble();
    this.ebc = map['ebc'];
    this.fermentables = Quantity.deserialize(map['fermentables']);
    this.hops = Quantity.deserialize(map['hops']);
    this.miscellaneous = Quantity.deserialize(map['miscellaneous']);
    this.yeasts = Quantity.deserialize(map['yeasts']);
    this.mash = Mash.deserialize(map['mash']);
    this.notes = LocalizedText.deserialize(map['notes']);
    this.image = ImageModel.fromJson(map['image']);
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'title': LocalizedText.serialize(this.title),
      'text': LocalizedText.serialize(this.text),
      'shared': this.shared,
      'style': this.style != null ? this.style!.uuid : null,
      'volume': this.volume,
      'boil': this.boil,
      'efficiency': this.efficiency,
      'og': this.og,
      'fg': this.fg,
      'abv': this.abv,
      'ibu': this.ibu,
      'ebc': this.ebc,
      'fermentables': Quantity.serialize(this.fermentables),
      'hops': Quantity.serialize(this.hops),
      'miscellaneous': Quantity.serialize(this.miscellaneous),
      'yeasts': Quantity.serialize(this.yeasts),
      'mash': Mash.serialize(this.mash),
      'notes': LocalizedText.serialize(this.notes),
      'image': ImageModel.serialize(this.image),
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
      shared: this.shared,
      style: this.style,
      volume: this.volume,
      boil: this.boil,
      efficiency: this.efficiency,
      og: this.og,
      fg: this.fg,
      abv: this.abv,
      ibu: this.ibu,
      ebc: this.ebc,
      fermentables: this.fermentables,
      hops: this.hops,
      miscellaneous: this.miscellaneous,
      yeasts: this.yeasts,
      mash: this.mash,
      notes: this.notes,
      image: this.image,
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

  String? localizedOG(Locale? locale) {
    if (this.og != null) {
      return NumberFormat("0.000", locale.toString()).format(og);
    }
    return '';
  }

  String? localizedFG(Locale? locale) {
    if (this.fg != null) {
      return NumberFormat("0.000", locale.toString()).format(fg);
    }
    return '';
  }

  String? localizedABV(Locale? locale) {
    if (this.abv != null) {
      return NumberFormat("#0.#", locale.toString()).format(abv) + '%';
    }
    return '';
  }

  String? localizedIBU(Locale? locale) {
    if (this.ibu != null) {
      return NumberFormat("#0.#", locale.toString()).format(ibu);
    }
    return '';
  }
}
