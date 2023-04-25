import 'package:flutter/material.dart';

// Internal package
import 'package:bb/models/fermentable_model.dart';
import 'package:bb/models/hop_model.dart';
import 'package:bb/models/image_model.dart';
import 'package:bb/models/misc_model.dart';
import 'package:bb/models/model.dart';
import 'package:bb/models/style_model.dart';
import 'package:bb/models/yeast_model.dart';
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
  List<dynamic>? cacheFermentables;
  List<dynamic>? cacheHops;
  List<dynamic>? cacheMisc;
  List<dynamic>? cacheYeasts;
  List<Mash>? mash;
  int? primaryday;
  double? primarytemp;
  int? secondaryday;
  double? secondarytemp;
  int? tertiaryday;
  double? tertiarytemp;
  dynamic? notes;
  ImageModel? image;

  List<FermentableModel>? _fermentables;
  List<HopModel>? _hops;
  List<MiscModel>? _misc;
  List<YeastModel>? _yeasts;

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
    this.cacheFermentables,
    this.cacheHops,
    this.cacheMisc,
    this.cacheYeasts,
    this.mash,
    this.primaryday,
    this.primarytemp,
    this.secondaryday,
    this.secondarytemp,
    this.tertiaryday,
    this.tertiarytemp,
    this.notes,
    this.image,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator) {
    if (cacheFermentables == null) { cacheFermentables = []; }
    if (cacheHops == null) { cacheHops = []; }
    if (cacheMisc == null) { cacheMisc = []; }
    if (cacheYeasts == null) { cacheYeasts = []; }
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
    this.cacheFermentables = map['fermentables'];
    this.cacheHops = map['hops'];
    this.cacheMisc = map['miscellaneous'];
    this.cacheYeasts = map['yeasts'];
    this.mash = Mash.deserialize(map['mash']);
    this.primaryday = map['primaryday'];
    if (map['primarytemp'] != null) this.primarytemp = map['primarytemp'].toDouble();
    this.secondaryday = map['secondaryday'];
    if (map['secondarytemp'] != null) this.secondarytemp = map['secondarytemp'].toDouble();
    this.tertiaryday = map['tertiaryday'];
    if (map['tertiarytemp'] != null) this.tertiarytemp = map['tertiarytemp'].toDouble();
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
      'fermentables': FermentableModel.quantities(this._fermentables),
      'hops': HopModel.quantities(this._hops),
      'miscellaneous': MiscModel.quantities(this._misc),
      'yeasts': YeastModel.quantities(this._yeasts),
      'mash': Mash.serialize(this.mash),
      'primaryday': this.primaryday,
      'primarytemp': this.primarytemp,
      'secondaryday': this.secondaryday,
      'secondarytemp': this.secondarytemp,
      'tertiaryday': this.tertiaryday,
      'tertiarytemp': this.tertiarytemp,
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
      cacheFermentables: this.cacheFermentables,
      cacheHops: this.cacheHops,
      cacheMisc: this.cacheMisc,
      cacheYeasts: this.cacheYeasts,
      mash: this.mash,
      primaryday: this.primaryday,
      primarytemp: this.primarytemp,
      secondaryday: this.secondaryday,
      secondarytemp: this.secondarytemp,
      tertiaryday: this.tertiaryday,
      tertiarytemp: this.tertiarytemp,
      notes: this.notes,
      image: this.image,
    )
      .._fermentables = _fermentables
      .._hops = _hops
      .._misc = _misc
      .._yeasts = _yeasts;
  }

  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is ReceiptModel && other.uuid == uuid);
  }

  set fermentables(List<FermentableModel>data) => _fermentables = data;

  List<FermentableModel> get fermentables => _fermentables ?? [];

  Future<List<FermentableModel>> get fermentablesAsync async {
    if (_fermentables == null) {
      _fermentables = await FermentableModel.data(cacheFermentables);
    }
    return _fermentables ?? [];
  }

  set hops(List<HopModel>data) => _hops = data;

  List<HopModel> get hops => _hops ?? [];

  Future<List<HopModel>> get hopsAsync async {
    if (_hops == null) {
      _hops = await HopModel.data(cacheHops);
    }
    return _hops ?? [];
  }

  set miscellaneous(List<MiscModel>data) => _misc = data;

  List<MiscModel> get miscellaneous => _misc ?? [];

  Future<List<MiscModel>> get miscellaneousAsync async {
    if (_misc == null) {
      _misc = await MiscModel.data(cacheMisc);
    }
    return _misc ?? [];
  }

  set yeasts(List<YeastModel>data) => _yeasts = data;

  List<YeastModel> get yeasts => _yeasts ?? [];

  Future<List<YeastModel>> get yeastsAsync async {
    if (_yeasts == null) {
      _yeasts = await YeastModel.data(cacheYeasts);
    }
    return _yeasts ?? [];
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
