import 'package:bb/helpers/formula_helper.dart';
import 'package:bb/models/fermentable_model.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/helpers/color_helper.dart';
import 'package:bb/helpers/date_helper.dart';
import 'package:bb/models/equipment_model.dart';
import 'package:bb/models/model.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/localized_text.dart';

enum Status with Enums { pending, started, finished, stoped;
  List<Enum> get enums => [ pending, started, finished, stoped ];
}

extension DoubleParsing on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

class BrewModel<T> extends Model {
  String? color;
  Status? status;
  DateTime? started_at;
  String? reference;
  ReceiptModel? receipt;
  EquipmentModel? tank;
  EquipmentModel? fermenter;
  double? volume;
  double? mash_ph;
  double? mash_water;
  double? sparge_ph;
  double? sparge_water;
  double? og;
  double? fg;
  int? primaryday;
  int? secondaryday;
  int? tertiaryday;
  dynamic? notes;

  BrewModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    this.color,
    this.status = Status.pending,
    this.started_at,
    this.reference,
    this.receipt,
    this.tank,
    this.fermenter,
    this.volume,
    this.mash_ph = 5.4,
    this.mash_water,
    this.sparge_ph = 5.2,
    this.sparge_water,
    this.og,
    this.fg,
    this.primaryday,
    this.secondaryday,
    this.tertiaryday,
    this.notes
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator) {
    if (color == null) { color = ColorHelper.random(); }
  }

  Future fromMap(Map<String, dynamic> map) async {
    super.fromMap(map);
    this.color = map['color'];
    this.status = Status.values.elementAt(map['status']);
    this.started_at = DateHelper.parse(map['started_at']);
    this.reference = map['reference'];
    if (map['receipt'] != null) this.receipt = await Database().getReceipt(map['receipt']);
    if (map['tank'] != null) this.tank = await Database().getEquipment(map['tank']);
    if (map['fermenter'] != null) this.fermenter = await Database().getEquipment(map['fermenter']);
    if (map['volume'] != null) this.volume = map['volume'].toDouble();
    if (map['mash_ph'] != null) this.mash_ph = map['mash_ph'].toDouble();
    if (map['mash_water'] != null) this.mash_water = map['mash_water'].toDouble();
    if (map['sparge_ph'] != null) this.sparge_ph = map['sparge_ph'].toDouble();
    if (map['sparge_water'] != null) this.sparge_water = map['sparge_water'].toDouble();
    if (map['og'] != null) this.og = map['og'].toDouble();
    if (map['fg'] != null) this.fg = map['fg'].toDouble();
    this.primaryday = map['primaryday'];
    this.secondaryday = map['secondaryday'];
    this.tertiaryday = map['tertiaryday'];
    this.notes = LocalizedText.deserialize(map['notes']);
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'color': this.color,
      'status': this.status!.index,
      'started_at': started_at != null ? this.started_at!.toIso8601String() : null,
      'reference': this.reference,
      'receipt': this.receipt != null ? this.receipt!.uuid : null,
      'tank': this.tank != null ? this.tank!.uuid : null,
      'fermenter': this.fermenter != null ? this.fermenter!.uuid : null,
      'volume': this.volume,
      'mash_ph': this.mash_ph,
      'mash_water': this.mash_water,
      'sparge_ph': this.sparge_ph,
      'sparge_water': this.sparge_water,
      'og': this.og,
      'fg': this.fg,
      'primaryday': this.primaryday,
      'secondaryday': this.secondaryday,
      'tertiaryday': this.tertiaryday,
      'notes': LocalizedText.serialize(this.notes),
    });
    return map;
  }

  BrewModel copy() {
    return BrewModel(
      uuid: this.uuid,
      inserted_at: this.inserted_at,
      updated_at: this.updated_at,
      creator: this.creator,
      color: this.color,
      status: this.status,
      started_at: this.started_at,
      reference: this.reference,
      receipt: this.receipt?.copy(),
      tank: this.tank,
      fermenter: this.fermenter,
      volume: this.volume,
      mash_ph: this.mash_ph,
      mash_water: this.mash_water,
      sparge_ph: this.sparge_ph,
      sparge_water: this.sparge_water,
      og: this.og,
      fg: this.fg,
      primaryday: this.primaryday,
      secondaryday: this.secondaryday,
      tertiaryday: this.tertiaryday,
      notes: this.notes
    );
  }

  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is BrewModel && other.uuid == uuid);
  }

  @override
  String toString() {
    return 'Breaw: $reference, UUID: $uuid';
  }

  DateTime started() {
    return started_at ?? inserted_at!;
  }

  DateTime? secondaryDate() {
    int? primary = primaryday ?? receipt?.primaryday;
    if (primary != null) {
      return DateHelper.toDate(inserted_at!.add(Duration(days: primary)));
    }
    return null;
  }

  DateTime? tertiaryDate() {
    int? secondary = secondaryday ?? receipt?.secondaryday;
    if (secondary != null) {
      int? primary = primaryday ?? receipt?.primaryday;
      int days = (primary ?? 0) + secondary;
      return DateHelper.toDate(inserted_at!.add(Duration(days: days)));
    }
    return null;
  }

  DateTime? finish() {
    int? primary = primaryday ?? receipt?.primaryday;
    int? secondary = secondaryday ?? receipt?.secondaryday;
    int? tertiary = tertiaryday ?? receipt?.tertiaryday;
    if (primary != null || secondary != null || tertiary != null) {
      int days = (primary ?? 0) + (secondary ?? 0) + (tertiary ?? 0);
      return DateHelper.toDate(inserted_at!.add(Duration(days: days)));
    }
    return null;
  }

  calculate() async {
    if (receipt != null && tank != null) {
      double weight = 0;
      for(FermentableModel item in await receipt!.getFermentables()) {
        if (item.use == Method.mashed) {
          weight +=  (item.amount! * (volume! / receipt!.volume!)).abs();
        }
      }
      mash_water = tank!.mash(weight);
      debugPrint('mash_water $mash_water');
      sparge_water = tank!.sparge(volume!, weight, duration: receipt!.boil!);
      debugPrint('sparge_water $sparge_water');

    } else {
      mash_water = null;
      sparge_water = null;
    }
  }
}
