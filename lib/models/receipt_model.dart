// Internal package
import 'package:bb/helpers/color_helper.dart';
import 'package:bb/helpers/formula_helper.dart';
import 'package:bb/models/fermentable_model.dart';
import 'package:bb/models/hop_model.dart' as hop;
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
import 'package:bb/utils/rating.dart';

class ReceiptModel<T> extends Model {
  Status? status;
  dynamic title;
  dynamic text;
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
  dynamic notes;
  ImageModel? image;
  List<Rating>? ratings;
  String? country;

  List<FermentableModel>? _fermentables;
  List<hop.HopModel>? _hops;
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
    this.ratings,
    this.country,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator) {
    cacheFermentables ??= [];
    cacheHops ??= [];
    cacheMisc ??= [];
    cacheYeasts ??= [];
    mash ??= [];
    ratings ??= [];
  }

  @override
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
    this.ratings = Rating.deserialize(map['ratings']);
    this.country = map['country'];
  }

  @override
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
      'hops': hop.HopModel.quantities(this._hops),
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
      'ratings': Rating.serialize(this.ratings),
      'country': this.country
    });
    return map;
  }

  ReceiptModel copy() {
    return ReceiptModel(
      uuid: uuid,
      inserted_at: inserted_at,
      updated_at: updated_at,
      creator: creator,
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
      ratings: this.ratings,
      country: this.country
    )
      .._fermentables = _fermentables
      .._hops = _hops
      .._misc = _misc
      .._yeasts = _yeasts;
  }

  // ignore: hash_and_equals
  @override
  bool operator ==(other) {
    return (other is ReceiptModel && other.uuid == uuid || other is String && other == uuid);
  }

  @override
  int get hashCode => uuid.hashCode;

  int get notice {
    return this.ratings != null ? this.ratings!.length : 0;
  }

  double get rating {
    double rating = 0;
    if (ratings != null && ratings!.isNotEmpty) {
      for(Rating model in ratings!) {
        rating += model.rating!;
      }
      rating = rating / ratings!.length;
    }
    return rating;
  }


  double get mass {
    double mass = 0;
    for(FermentableModel item in fermentables) {
      mass += (item.amount ?? 0);
    }
    return mass;
  }

  double get extract {
    double extract = 0;
    for(FermentableModel item in fermentables) {
      extract += (item.efficiency ?? 0) / fermentables.length;
    }
    return extract;
  }

  set fermentables(List<FermentableModel>data) => _fermentables = data;

  List<FermentableModel> get fermentables => _fermentables ?? [];

  Future<List<FermentableModel>> getFermentables({double? volume}) async {
    if (_fermentables == null) {
      _fermentables = await FermentableModel.data(cacheFermentables);
      resizeFermentales(volume);
    }
    return _fermentables ?? [];
  }

  set hops(List<hop.HopModel>data) => _hops = data;

  List<hop.HopModel> get hops => _hops ?? [];

  Future<List<hop.HopModel>> gethops({double? volume}) async {
    if (_hops == null) {
      _hops = await hop.HopModel.data(cacheHops);
      resizeHops(volume);
    }
    return _hops ?? [];
  }

  set miscellaneous(List<MiscModel>data) => _misc = data;

  List<MiscModel> get miscellaneous => _misc ?? [];

  Future<List<MiscModel>> getMisc({double? volume}) async {
    if (_misc == null) {
      _misc = await MiscModel.data(cacheMisc);
      resizeMisc(volume);
    }
    return _misc ?? [];
  }

  set yeasts(List<YeastModel>data) => _yeasts = data;

  List<YeastModel> get yeasts => _yeasts ?? [];

  Future<List<YeastModel>> getYeasts({double? volume}) async {
    if (_yeasts == null) {
      _yeasts = await YeastModel.data(cacheYeasts);
      resizeYeasts(volume);
    }
    return _yeasts ?? [];
  }

  @override
  String toString() {
    return 'Receipt: $title, UUID: $uuid';
  }

  resizeFermentales(double? volume) {
    if (volume == null || volume == this.volume) {
      return;
    }
    for(FermentableModel item in fermentables) {
      item.amount = (item.amount! * (volume / this.volume!)).abs();
    }
    calculate(volume: volume);
  }

  resizeHops(double? volume) {
    if (volume == null || volume == this.volume) {
      return;
    }
    for(HopModel item in hops) {
      item.amount = (item.amount! * (volume / this.volume!)).abs();
    }
    calculate(volume: volume);
  }

  resizeYeasts(double? volume) {
    if (volume == null || volume == this.volume) {
      return;
    }
    var percent = (volume - this.volume!) / this.volume!;

    calculate(volume: volume);
  }

  resizeMisc(double? volume) {
    if (volume == null || volume == this.volume) {
      return;
    }
    var percent = (volume - this.volume!) / this.volume!;

    calculate(volume: volume);
  }

  calculate({double? volume}) async {
    og = null;
    fg = null;
    ibu = null;
    abv = null;
    double mcu = 0.0;
    double extract = 0.0;
    primaryday = null;
    primarytemp = null;
    secondaryday = null;
    secondarytemp = null;
    for(FermentableModel item in await getFermentables()) {
      if (item.use == Method.mashed) {
        // double volume = EquipmentModel.preBoilVolume(null, widget.model.volume);
        extract += (item.extract(efficiency) ?? 0);
        mcu += ColorHelper.mcu(item.ebc, item.amount, volume ?? this.volume);
      }
    }
    if (extract != 0) {
      og = FormulaHelper.og(extract, volume ?? this.volume);
    }

    for(YeastModel item in await getYeasts()) {
      primarytemp = (((item.tempmin ?? 0) + (item.tempmax ?? 0)) / 2).roundToDouble();
      switch(item.type ?? Fermentation.hight) {
        case Fermentation.hight:
          primaryday = 21;
          break;
        case Fermentation.low:
          primaryday = 14;
          secondaryday = 21;
          secondarytemp = 5;
          break;
        case Fermentation.spontaneous:
          break;
      }
      double? density =  item.density(og);
      if (density != null) {
        fg = (fg ?? 0) + density;
      }
    }

    for(hop.HopModel item in await gethops()) {
      if (item.use == hop.Use.boil) {
        double? bitterness = item.ibu(og, boil, volume ?? this.volume);
        if (bitterness != null) {
          ibu = (ibu ?? 0) + bitterness;
        }
      }
    }

    if (og != 0 && fg != 0) abv = FormulaHelper.abv(og, fg);
    if (mcu != 0) ebc = ColorHelper.ratingEBC(mcu).toInt();
  }
}
