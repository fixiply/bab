// Internal package
import 'package:bab/helpers/color_helper.dart';
import 'package:bab/helpers/formula_helper.dart';
import 'package:bab/models/fermentable_model.dart' as fm;
import 'package:bab/models/hop_model.dart' as hm;
import 'package:bab/models/image_model.dart';
import 'package:bab/models/misc_model.dart' as mm;
import 'package:bab/models/model.dart';
import 'package:bab/models/style_model.dart';
import 'package:bab/models/yeast_model.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/utils/fermentation.dart';
import 'package:bab/utils/localized_text.dart';
import 'package:bab/utils/mash.dart';
import 'package:bab/utils/quantity.dart';
import 'package:bab/utils/rating.dart';
import 'package:flutter/foundation.dart';

enum Method with Enums { all_grain,  extract, partial;
  List<Enum> get enums => [ all_grain,  extract, partial ];
}

const String XML_ELEMENT_NAME = 'NAME';
const String XML_ELEMENT_BATCH_SIZE = 'BATCH_SIZE';
const String XML_ELEMENT_BOIL_TIME = 'BOIL_TIME';
const String XML_ELEMENT_EFFICIENCY = 'EFFICIENCY';
const String XML_ELEMENT_NOTES = 'NOTES';
const String XML_ELEMENT_STYLE = 'STYLE';
const String XML_ELEMENT_TYPE = 'TYPE';

class RecipeModel<T> extends Model {
  Method? method;
  String? color;
  dynamic title;
  dynamic notes;
  bool? shared;
  StyleModel? style;
  /// The finale volume in liters.
  double? volume;
  /// The time in minutes.
  int? boil;
  double? efficiency;
  double? og;
  double? fg;
  double? abv;
  double? ibu;
  int? ebc;
  List<Quantity>? cacheFermentables;
  List<Quantity>? cacheHops;
  List<Quantity>? cacheMisc;
  List<Quantity>? cacheYeasts;
  List<Mash>? mash;
  List<Fermentation>? fermentation;
  ImageModel? image;
  List<Rating>? ratings;
  String? country;
  List<fm.FermentableModel>? _fermentables;
  List<hm.HopModel>? _hops;
  List<mm.MiscModel>? _misc;
  List<YeastModel>? _yeasts;

  RecipeModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    this.method = Method.all_grain,
    this.color,
    this.title,
    this.notes,
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
    this.fermentation,
    this.image,
    this.ratings,
    this.country,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator) {
    color ??= ColorHelper.random();
    cacheFermentables ??= [];
    cacheHops ??= [];
    cacheMisc ??= [];
    cacheYeasts ??= [];
    mash ??= [
      Mash(name: 'Mash In', type: Type.infusion, duration: 60, temperature: 65),
      Mash(name: 'Mash Out', type: Type.temperature, duration: 10, temperature: 75)
    ];
    fermentation ??= [];
    ratings ??= [];
  }

  @override
  Future fromMap(Map<String, dynamic> map) async {
    super.fromMap(map);
    if (map.containsKey('method')) this.method = Method.values.elementAt(map['method']);
    this.color = map['color'];
    this.title = LocalizedText.deserialize(map['title']);
    this.notes = LocalizedText.deserialize(map['notes']);
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
    this.cacheFermentables = Quantity.deserialize(map['fermentables']);
    this.cacheHops =  Quantity.deserialize(map['hops']);
    this.cacheMisc =  Quantity.deserialize(map['miscellaneous']);
    this.cacheYeasts =  Quantity.deserialize(map['yeasts']);
    this.mash = Mash.deserialize(map['mash']);
    if (map['fermentation'] != null) this.fermentation = Fermentation.deserialize(map['fermentation']);
    this.image = ImageModel.fromJson(map['image']);
    this.ratings = Rating.deserialize(map['ratings']);
    this.country = map['country'];
  }

  @override
  Map<String, dynamic> toMap({bool persist = false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'method': this.method!.index,
      'color': this.color,
      'title': LocalizedText.serialize(this.title),
      'notes': LocalizedText.serialize(this.notes),
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
      'fermentables': fm.FermentableModel.quantities(this._fermentables),
      'hops': hm.HopModel.quantities(this._hops),
      'miscellaneous': mm.MiscModel.quantities(this._misc),
      'yeasts': YeastModel.quantities(this._yeasts),
      'mash': Mash.serialize(this.mash),
      'fermentation': Fermentation.serialize(this.fermentation),
      'image': ImageModel.serialize(this.image),
      'ratings': Rating.serialize(this.ratings),
      'country': this.country
    });
    return map;
  }

  RecipeModel copy() {
    return RecipeModel(
      uuid: uuid,
      inserted_at: inserted_at,
      updated_at: updated_at,
      creator: creator,
      method: this.method,
      color: this.color,
      title: this.title,
      notes: this.notes,
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
      fermentation: this.fermentation,
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
    return (other is RecipeModel && other.uuid == uuid || other is String && other == uuid);
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
    for(fm.FermentableModel item in fermentables) {
      mass += (item.amount ?? 0);
    }
    return mass;
  }

  double get extract {
    double extract = 0;
    for(fm.FermentableModel item in fermentables) {
      extract += (item.efficiency ?? 0) / fermentables.length;
    }
    return extract;
  }

  int? get primaryDay {
    return fermentation!.first.duration!;
  }

  addFermentable(fm.FermentableModel model) {
    if (_fermentables == null) _fermentables = [];
   _fermentables!.add(model);
    cacheFermentables = fm.FermentableModel.quantities(this._fermentables);
  }

  set fermentables(List<fm.FermentableModel>data) {
    _fermentables = data;
    cacheFermentables = fm.FermentableModel.quantities(this._fermentables);
  }

  List<fm.FermentableModel> get fermentables => _fermentables ?? [];

  Future<List<fm.FermentableModel>> getFermentables({double? volume, bool forceResizing = false}) async {
    if (_fermentables == null || forceResizing) {
      _fermentables = await fm.FermentableModel.data(cacheFermentables!);
      resizeFermentales(volume);
    }
    return _fermentables ?? [];
  }

  addHop(hm.HopModel model) {
    if (_hops == null) _hops = [];
    _hops!.add(model);
    cacheHops = hm.HopModel.quantities(this._hops);
  }

  set hops(List<hm.HopModel>data) {
    _hops = data;
    cacheHops = hm.HopModel.quantities(data);
  }

  List<hm.HopModel> get hops => _hops ?? [];

  Future<List<hm.HopModel>> gethops({double? volume, hm.Use? use, bool forceResizing = false}) async {
    if (_hops == null || forceResizing) {
      _hops = await hm.HopModel.data(cacheHops!);
      resizeHops(volume);
      if (use != null) {
        return _hops!.where((element) => element.use == use).toList();
      }
    }
    return _hops ?? [];
  }

  addMisc(mm.MiscModel model) {
    if (_misc == null) _misc = [];
    _misc!.add(model);
    cacheMisc = mm.MiscModel.quantities(this._misc);
  }

  set miscellaneous(List<mm.MiscModel>data) {
    _misc = data;
    cacheMisc = mm.MiscModel.quantities(this._misc);
  }

  List<mm.MiscModel> get miscellaneous => _misc ?? [];

  Future<List<mm.MiscModel>> getMisc({double? volume, mm.Use? use, bool forceResizing = false}) async {
    if (_misc == null || forceResizing) {
      _misc = await mm.MiscModel.data(cacheMisc!);
      resizeMisc(volume);
      if (use != null) {
        return _misc!.where((element) => element.use == use).toList();
      }
    }
    return _misc ?? [];
  }

  addYeast(YeastModel model) {
    if (_yeasts == null) _yeasts = [];
    _yeasts!.add(model);
    cacheYeasts = YeastModel.quantities(this._yeasts);
  }

  set yeasts(List<YeastModel>data) {
    _yeasts = data;
    cacheYeasts = YeastModel.quantities(this._yeasts);
  }

  List<YeastModel> get yeasts => _yeasts ?? [];

  Future<List<YeastModel>> getYeasts({double? volume, bool forceResizing = false}) async {
    if (_yeasts == null) {
      _yeasts = await YeastModel.data(cacheYeasts!);
      resizeYeasts(volume);
    }
    return _yeasts ?? [];
  }

  @override
  String toString() {
    return 'Recipe: $title, UUID: $uuid';
  }

  /// Returns the bitterness index, based on the given conditions.
  ///
  /// The `amount` argument is relative to the amount of hops in grams.
  ///
  /// The `alpha` argument is relative to the hops alpha acid.
  ///
  /// The `og` argument is relative to the original gravity.
  ///
  /// The `duration` argument is relative to the boil duration in minute.
  ///
  /// The `volume` argument is relative to the final volume.
  resizeFermentales(double? volume) {
    if (volume == null || volume == this.volume) {
      return;
    }
    for(fm.FermentableModel item in fermentables) {
      if (item.amount != null) {
        item.amount = (item.amount! * (volume / this.volume!)).abs();
      }
    }
    calculate(volume: volume);
  }

  resizeHops(double? volume) {
    if (volume == null || volume == this.volume) {
      return;
    }
    for(hm.HopModel item in hops) {
      if (item.amount != null) {
        item.amount = (item.amount! * (volume / this.volume!)).abs();
      }
    }
    calculate(volume: volume);
  }

  resizeYeasts(double? volume) {
    if (volume == null || volume == this.volume) {
      return;
    }
    for(YeastModel item in yeasts) {
      if ((item.measurement == Measurement.milliliter || item.measurement == Measurement.liter || item.measurement == Measurement.gram || item.measurement == Measurement.kilo) && item.amount != null) {
        item.amount = (item.amount! * (volume / this.volume!)).abs();
      }
    }

    calculate(volume: volume);
  }

  resizeMisc(double? volume) {
    if (volume == null || volume == this.volume) {
      return;
    }
    for(mm.MiscModel item in miscellaneous) {
      if (item.amount != null) {
        item.amount = (item.amount! * (volume / this.volume!)).abs();
      }
    }

    calculate(volume: volume);
  }

  calculate({double? volume}) async {
    og = null;
    fg = null;
    ibu = null;
    abv = null;
    double mcu = 0.0;
    double extract = 0.0;
    for(fm.FermentableModel item in await getFermentables()) {
      if (item.use == fm.Method.mashed) {
        // double volume = EquipmentModel.preBoilVolume(null, widget.model.volume);
        extract += (item.extract(efficiency) ?? 0);
        mcu += ColorHelper.mcu(item.ebc, item.amount, volume ?? this.volume);
      }
    }
    if (extract != 0) {
      og = FormulaHelper.og(extract, volume ?? this.volume);
    }

    int? primaryday;
    for(YeastModel item in await getYeasts()) {
      if (fermentation!.isEmpty) {
        double primarytemp = (((item.tempmin ?? 0) + (item.tempmax ?? 0)) / 2).roundToDouble();
        double? secondarytemp;
        int? secondaryday;
        switch (item.type ?? Style.hight) {
          case Style.hight:
            primaryday = primaryday ?? 21;
            break;
          case Style.low:
            primaryday = primaryday ?? 14;
            secondaryday = secondaryday ?? 21;
            secondarytemp = secondarytemp ?? 5;
            break;
          case Style.spontaneous:
            break;
        }
        if (primaryday != null) {
          fermentation!.add(Fermentation(name: 'Primary', duration: primaryday, temperature: primarytemp));
        }
        if (secondaryday != null && secondarytemp != null) {
          fermentation!.add(Fermentation(name: 'Secondary', duration: secondaryday, temperature: secondarytemp));
        }
      }
      double? density =  item.density(og);
      if (density != null) {
        fg = (fg ?? 0) + density;
      }
    }

    for(hm.HopModel item in await gethops()) {
      if (item.use == hm.Use.boil) {
        if (item.duration != null && boil != null && item.duration! > boil!) {
          item.duration = boil;
        }
        double? bitterness = item.ibu(og, boil, volume ?? this.volume);
        if (bitterness != null) {
          ibu = (ibu ?? 0) + bitterness;
        }
      } else if (item.use == hm.Use.dry_hop) {
        if (item.duration != null && primaryday != null && item.duration! > primaryday) {
          item.duration = primaryday;
        }
      }
    }

    for(mm.MiscModel item in await getMisc()) {
      if (item.use == mm.Use.boil) {
        if (item.duration != null && boil != null && item.duration! > boil!) {
          item.duration = boil;
        }
      }
    }

    if (og != 0 && fg != 0) abv = FormulaHelper.abv(og, fg);
    if (mcu != 0) ebc = ColorHelper.ratingEBC(mcu).toInt();
  }

  static Method? getTypeByName(String? name) {
    if (name == null) return null;
    switch (name) {
      case 'All Grain':
        return Method.all_grain;
      case 'Extract':
        return Method.extract;
      case 'Partial Mash':
        return Method.partial;
    }
    return null;
  }
}
