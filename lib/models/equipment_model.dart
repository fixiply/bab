import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/tables/edit_data_source.dart';
import 'package:bb/models/model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/localized_text.dart';
import 'package:bb/utils/quantity.dart';

// External package

class EquipmentModel<T> extends Model {
  Status? status;
  dynamic? name;
  double? loss_boil;
  double? head_loss;
  dynamic? desc;

  EquipmentModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    bool? isEdited,
    bool? isSelected,
    this.status = Status.publied,
    this.name,
    this.loss_boil = DEFAULT_LOSS_BOIL,
    this.head_loss = DEFAULT_HEAD_LOSS,
    this.desc,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator, isEdited: isEdited, isSelected: isSelected);

  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.name = LocalizedText.deserialize(map['name']);
    if (map['loss_boil'] != null) this.loss_boil = map['loss_boil'].toDouble();
    if (map['head_loss'] != null) this.head_loss = map['head_loss'].toDouble();
    this.desc = LocalizedText.deserialize(map['desc']);
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'name': LocalizedText.serialize(this.name),
      'loss_boil': this.loss_boil,
      'head_loss': this.head_loss,
      'desc': LocalizedText.serialize(this.desc),
    });
    return map;
  }

  EquipmentModel copy() {
    return EquipmentModel(
      uuid: this.uuid,
      inserted_at: this.inserted_at,
      updated_at: this.updated_at,
      creator: this.creator,
      status: this.status,
      name: this.name,
      loss_boil: this.loss_boil,
      head_loss: this.head_loss,
      desc: this.desc,
    );
  }

  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is EquipmentModel && other.uuid == uuid);
  }

  @override
  String toString() {
    return 'Equipment: $name, UUID: $uuid';
  }

  String? localizedName(Locale? locale) {
    if (this.name is LocalizedText) {
      return this.name.get(locale);
    }
    return this.name;
  }

  String? localizedDesc(Locale? locale) {
    if (this.desc is LocalizedText) {
      return this.desc.get(locale);
    }
    return this.desc;
  }

  /// Returns the pre-boil volume, based on the given conditions.
  ///
  /// The `volume` argument is relative to the final volume.
  static double preBoilVolume(EquipmentModel? equipment, double? volume) {
    if (volume == null) {
      return 0;
    }
    double loss_boil = DEFAULT_LOSS_BOIL;
    double head_loss = DEFAULT_HEAD_LOSS;
    if (equipment != null) {
      loss_boil = equipment.loss_boil!;
      head_loss = equipment.head_loss!;
    }
    return (volume + loss_boil + head_loss) * 1.04;
  }

  static dynamic serialize(dynamic data) {
    if (data != null) {
      if (data is EquipmentModel) {
        return data.toMap();
      }
      if (data is List) {
        List<dynamic> values = [];
        for(final value in data) {
          values.add(serialize(value));
        }
        return values;
      }
    }
    return null;
  }

  static List<EquipmentModel> deserialize(dynamic data) {
    List<EquipmentModel> values = [];
    if (data != null) {
      if (data is List) {
        for(final value in data) {
          values.addAll(deserialize(value));
        }
      } else {
        EquipmentModel model = new EquipmentModel();
        model.fromMap(data);
        values.add(model);
      }
    }
    return values;
  }
}
