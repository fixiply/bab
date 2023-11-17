// Internal package
import 'package:bab/helpers/date_helper.dart';
import 'package:bab/helpers/formula_helper.dart';
import 'package:bab/models/equipment_model.dart';
import 'package:bab/models/fermentable_model.dart';
import 'package:bab/models/hop_model.dart';
import 'package:bab/models/model.dart';
import 'package:bab/models/recipe_model.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/utils/localized_text.dart';
import 'package:bab/utils/mash.dart';
import 'package:bab/utils/quantity.dart';

extension DoubleParsing on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

class BrewModel<T> extends Model {
  DateTime? started_at;
  DateTime? fermented_at;
  String? reference;
  RecipeModel? receipt;
  EquipmentModel? tank;
  EquipmentModel? fermenter;
  double? volume;
  double? mash_ph;
  double? mash_water;
  double? sparge_ph;
  double? sparge_water;
  double? efficiency;
  double? abv;
  double? og;
  double? fg;
  int? primaryday;
  int? secondaryday;
  int? tertiaryday;
  int? last_step;
  dynamic notes;

  BrewModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    this.started_at,
    this.fermented_at,
    this.reference,
    this.receipt,
    this.tank,
    this.fermenter,
    this.volume,
    this.mash_ph = 5.4,
    this.mash_water,
    this.sparge_ph = 5.2,
    this.sparge_water,
    this.efficiency,
    this.abv,
    this.og,
    this.fg,
    this.primaryday,
    this.secondaryday,
    this.tertiaryday,
    this.last_step,
    this.notes
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator);

  @override
  Future fromMap(Map<String, dynamic> map) async {
    super.fromMap(map);
    this.started_at = DateHelper.parse(map['started_at']);
    this.fermented_at = DateHelper.parse(map['fermented_at']);
    this.reference = map['reference'];
    if (map['receipt'] != null) this.receipt = await Database().getReceipt(map['receipt']);
    if (map['tank'] != null) this.tank = await Database().getEquipment(map['tank']);
    if (map['fermenter'] != null) this.fermenter = await Database().getEquipment(map['fermenter']);
    if (map['volume'] != null) this.volume = map['volume'].toDouble();
    if (map['mash_ph'] != null) this.mash_ph = map['mash_ph'].toDouble();
    if (map['mash_water'] != null) this.mash_water = map['mash_water'].toDouble();
    if (map['sparge_ph'] != null) this.sparge_ph = map['sparge_ph'].toDouble();
    if (map['sparge_water'] != null) this.sparge_water = map['sparge_water'].toDouble();
    if (map['efficiency'] != null) this.efficiency = map['efficiency'].toDouble();
    if (map['abv'] != null) this.abv = map['abv'].toDouble();
    if (map['og'] != null) this.og = map['og'].toDouble();
    if (map['fg'] != null) this.fg = map['fg'].toDouble();
    this.primaryday = map['primaryday'];
    this.secondaryday = map['secondaryday'];
    this.tertiaryday = map['tertiaryday'];
    this.last_step = map['last_step'];
    this.notes = LocalizedText.deserialize(map['notes']);
  }

  @override
  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'started_at': started_at,
      'fermented_at': fermented_at,
      'reference': this.reference,
      'receipt': this.receipt != null ? this.receipt!.uuid : null,
      'tank': this.tank != null ? this.tank!.uuid : null,
      'fermenter': this.fermenter != null ? this.fermenter!.uuid : null,
      'volume': this.volume,
      'mash_ph': this.mash_ph,
      'mash_water': this.mash_water,
      'sparge_ph': this.sparge_ph,
      'sparge_water': this.sparge_water,
      'efficiency': this.efficiency,
      'abv': this.abv,
      'og': this.og,
      'fg': this.fg,
      'primaryday': this.primaryday,
      'secondaryday': this.secondaryday,
      'tertiaryday': this.tertiaryday,
      'last_step': this.last_step,
      'notes': LocalizedText.serialize(this.notes),
    });
    return map;
  }

  BrewModel copy() {
    return BrewModel(
      uuid: uuid,
      inserted_at: inserted_at,
      updated_at: updated_at,
      creator: creator,
      started_at: this.started_at,
      fermented_at: this.fermented_at,
      reference: this.reference,
      receipt: this.receipt?.copy(),
      tank: this.tank,
      fermenter: this.fermenter,
      volume: this.volume,
      mash_ph: this.mash_ph,
      mash_water: this.mash_water,
      sparge_ph: this.sparge_ph,
      sparge_water: this.sparge_water,
      efficiency: this.efficiency,
      abv: this.abv,
      og: this.og,
      fg: this.fg,
      primaryday: this.primaryday,
      secondaryday: this.secondaryday,
      tertiaryday: this.tertiaryday,
      last_step: this.last_step,
      notes: this.notes
    );
  }

  // ignore: hash_and_equals
  @override
  bool operator ==(other) {
    return (other is BrewModel && other.uuid == uuid);
  }

  @override
  int get hashCode => uuid.hashCode;

  @override
  String toString() {
    return 'Breaw: $reference, UUID: $uuid';
  }

  /// Returns the initial brew temperature
  ///
  /// The `tgi` argument is relative to the celcius initial grain temperature.
  ///
  /// The `weight` argument is relative to the grain weight in kilo.
  Future<double> initialBrewTemp(double? tgi) async {
    double? tmf = null;
    for(Mash item in receipt!.mash!) {
      if (tmf == null) {
        tmf = item.temperature;
        continue;
      }
    }
    double weight = await totalWeight;
    return Future.value(FormulaHelper.initialBrewTemp(FormulaHelper.ratio(volume, weight), tmf, tgi) ?? 0);
  }

  DateTime? get start_fermentation => fermented_at ?? started_at;

  int? primaryDay() {
    return primaryday ?? receipt?.primaryday;
  }

  DateTime? endDatePrimary() {
    int? primary = primaryday ?? receipt?.primaryday;
    if (primary != null) {
      return DateHelper.toDate(start_fermentation!.add(Duration(days: primary)));
    }
    return null;
  }

  int? secondaryDay() {
    return secondaryday ?? receipt?.secondaryday;
  }

  DateTime? endDateSecondary() {
    int? secondary = secondaryday ?? receipt?.secondaryday;
    if (secondary != null) {
      int? primary = primaryday ?? receipt?.primaryday;
      int days = (primary ?? 0) + secondary;
      return DateHelper.toDate(start_fermentation!.add(Duration(days: days)));
    }
    return null;
  }

  int? tertiaryDay() {
    return tertiaryday ?? receipt?.tertiaryday;
  }

  DateTime? endDateTertiary() {
    int? secondary = secondaryday ?? receipt?.secondaryday;
    int? tertiary = tertiaryday ?? receipt?.tertiaryday;
    if (secondary != null && tertiary != null) {
      int? primary = primaryday ?? receipt?.primaryday;
      int days = (primary ?? 0) + (secondary ?? 0) + (tertiary ?? 0);
      return DateHelper.toDate(start_fermentation!.add(Duration(days: days)));
    }
    return null;
  }

  List<DateTime> dryHop() {
    List<DateTime> values = [];
    if (receipt != null) {
      int? primary = primaryday ?? receipt?.primaryday;
      for(Quantity item in receipt!.cacheHops!) {
        if (item.use == Use.dry_hop.index) {
          int days = (primary ?? 0) - (item.duration ?? 0);
          values.add(DateHelper.toDate(start_fermentation!.add(Duration(days: days))));
        }
      }
    }
    return values;
  }

  DateTime? finish() {
    int? primary = primaryday ?? receipt?.primaryday;
    int? secondary = secondaryday ?? receipt?.secondaryday;
    int? tertiary = tertiaryday ?? receipt?.tertiaryday;
    if (primary != null || secondary != null || tertiary != null) {
      int days = (primary ?? 0) + (secondary ?? 0) + (tertiary ?? 0);
      return DateHelper.toDate(start_fermentation!.add(Duration(days: days)));
    }
    return null;
  }

  Future<double> get totalWeight async {
    double weight = 0;
    for(FermentableModel item in await receipt!.getFermentables()) {
      if (item.use == Method.mashed) {
        weight +=  (item.amount! * (volume! / receipt!.volume!)).abs();
      }
    }
    return weight;
  }

  calculate() async {
    abv = null;
    efficiency = null;
    if (receipt != null && tank != null) {
      double weight = await totalWeight;
      mash_water = tank!.mash(weight);
      sparge_water = tank!.sparge(volume!, weight, duration: receipt!.boil!);
      efficiency = FormulaHelper.efficiency(volume, og, receipt!.mass, receipt!.extract);
    } else {
      mash_water = null;
      sparge_water = null;
    }
    if (og != 0 && fg != 0) abv = FormulaHelper.abv(og, fg);
  }
}
