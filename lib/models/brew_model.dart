// Internal package
import 'package:bb/models/equipment_model.dart';
import 'package:bb/models/model.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/localized_text.dart';
import 'package:flutter/material.dart';

enum Status with Enums { pending, started, finished, stoped;
  List<Enum> get enums => [ pending, started, finished, stoped ];
}

extension DoubleParsing on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

class BrewModel<T> extends Model {
  Status? status;
  String? identifier;
  ReceiptModel? receipt;
  EquipmentModel? tank;
  EquipmentModel? fermenter;
  double? volume;
  double? ph;
  dynamic? notes;

  BrewModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    this.status = Status.pending,
    this.identifier,
    this.receipt,
    this.tank,
    this.fermenter,
    this.volume,
    this.ph,
    this.notes
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator);

  Future fromMap(Map<String, dynamic> map) async {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.identifier = map['identifier'];
    if (map['receipt'] != null) this.receipt = await Database().getReceipt(map['receipt']);
    if (map['tank'] != null) this.tank = await Database().getEquipment(map['tank']);
    if (map['fermenter'] != null) this.fermenter = await Database().getEquipment(map['fermenter']);
    if (map['volume'] != null) this.volume = map['volume'].toDouble();
    if (map['ph'] != null) this.ph = map['ph'].toDouble();
    this.notes = LocalizedText.deserialize(map['notes']);
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'identifier': this.identifier,
      'receipt': this.receipt != null ? this.receipt!.uuid : null,
      'tank': this.tank != null ? this.tank!.uuid : null,
      'fermenter': this.fermenter != null ? this.fermenter!.uuid : null,
      'volume': this.volume,
      'ph': this.ph,
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
      status: this.status,
      identifier: this.identifier,
      receipt: this.receipt,
      tank: this.tank,
      fermenter: this.fermenter,
      volume: this.volume,
      ph: this.ph,
      notes: this.notes
    );
  }

  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is BrewModel && other.uuid == uuid);
  }

  @override
  String toString() {
    return 'Breaw: $identifier, UUID: $uuid';
  }
}
