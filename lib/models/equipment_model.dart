// Internal package
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/helpers/formula_helper.dart';
import 'package:bab/models/image_model.dart';
import 'package:bab/models/model.dart';
import 'package:bab/utils/bluetooth.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/localized_text.dart';

// External package

enum Equipment with Enums { tank, fermenter;
  List<Enum> get enums => [ tank, fermenter ];
}

class EquipmentModel<T> extends Model {
  String? reference;
  String? name;
  Equipment? type;
  /// The pre-boil volume in liters.
  double? volume;
  /// The finale volume in liters.
  double? mash_volume;
  double? efficiency;
  double? absorption;
  double? lost_volume;
  double? mash_ratio;
  double? boil_loss;
  double? shrinkage;
  double? head_loss;
  bool? bluetooth = false;
  Bluetooth? controller;
  dynamic notes;
  ImageModel? image;
  bool selected = false;

  EquipmentModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    bool? isEdited,
    bool? isSelected,
    this.reference,
    this.name,
    this.type,
    this.volume,
    this.mash_volume,
    this.efficiency = DEFAULT_YIELD,
    this.absorption,
    this.lost_volume,
    this.mash_ratio,
    this.boil_loss = DEFAULT_BOIL_LOSS,
    this.shrinkage = DEFAULT_WORT_SHRINKAGE,
    this.head_loss,
    this.bluetooth,
    this.controller,
    this.notes,
    this.image,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator, isEdited: isEdited, isSelected: isSelected);

  @override
  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.reference = map['reference'];
    this.name = map['name'];
    this.type = Equipment.values.elementAt(map['type']);
    if (map['volume'] != null) this.volume = map['volume'].toDouble();
    if (map['mash_volume'] != null) this.mash_volume = map['mash_volume'].toDouble();
    if (map['efficiency'] != null) this.efficiency = map['efficiency'].toDouble();
    if (map['absorption'] != null) this.absorption = map['absorption'].toDouble();
    if (map['lost_volume'] != null) this.lost_volume = map['lost_volume'].toDouble();
    if (map['mash_ratio'] != null) this.mash_ratio = map['mash_ratio'].toDouble();
    if (map['boil_loss'] != null) this.boil_loss = map['boil_loss'].toDouble();
    if (map['shrinkage'] != null) this.shrinkage = map['shrinkage'].toDouble();
    if (map['head_loss'] != null) this.head_loss = map['head_loss'].toDouble();
    if (map['bluetooth'] != null) this.bluetooth = map['bluetooth'];
    if (map['controller'] != null) this.controller = Bluetooth.deserialize(map['controller']);
    this.notes = LocalizedText.deserialize(map['notes']);
    this.image = ImageModel.fromJson(map['image']);
  }

  @override
  Map<String, dynamic> toMap({bool persist = false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'reference': this.reference,
      'name': this.name,
      'type': this.type!.index,
      'volume': this.volume,
      'mash_volume': this.mash_volume,
      'efficiency': this.efficiency,
      'absorption': this.absorption,
      'lost_volume': this.lost_volume,
      'mash_ratio': this.mash_ratio,
      'boil_loss': this.boil_loss,
      'shrinkage': this.shrinkage,
      'head_loss': this.head_loss,
      'bluetooth': this.bluetooth,
      'controller': Bluetooth.serialize(this.controller),
      'notes': LocalizedText.serialize(this.notes),
      'image': ImageModel.serialize(this.image),
    });
    return map;
  }

  EquipmentModel copy() {
    return EquipmentModel(
      uuid: uuid,
      inserted_at: inserted_at,
      updated_at: updated_at,
      creator: creator,
      reference: this.reference,
      name: this.name,
      type: this.type,
      volume: this.volume,
      mash_volume: this.mash_volume,
      efficiency: this.efficiency,
      absorption: this.absorption,
      lost_volume: this.lost_volume,
      mash_ratio: this.mash_ratio,
      boil_loss: this.boil_loss,
      shrinkage: this.shrinkage,
      head_loss: this.head_loss,
      bluetooth: this.bluetooth,
      controller: this.controller,
      notes: this.notes,
      image: this.image,
    );
  }

  // ignore: hash_and_equals
  @override
  bool operator ==(other) {
    return (other is EquipmentModel && other.uuid == uuid);
  }

  @override
  int get hashCode => uuid.hashCode;

  @override
  String toString() {
    return 'Equipment: $name, UUID: $uuid';
  }

  /// Returns the pre-boil volume, based on the given conditions.
  ///
  /// The `volume` argument is relative to the final volume.
  ///
  /// The `duration` argument is relative to the boil duration in minute.
  double preboilVolume(double? volume, {int duration = 60}) {
    if (volume == null) {
      return 0;
    }
    double boil_losses = boil_loss ?? DEFAULT_BOIL_LOSS;
    double boil_off_rate = head_loss ?? DEFAULT_WORT_SHRINKAGE;
    return FormulaHelper.preboilVolume(volume, boil_losses, boil_off_rate, duration: duration);
  }

  /// Returns the mash water, based on the given conditions.
  ///
  /// The `weight` argument is relative to the weight in kilo.
  double mash(double weight) {
    return FormulaHelper.mashWater(weight, mash_ratio, lost_volume);
  }

  /// Returns the sparge water, based on the given conditions.
  ///
  /// The `volume` argument is relative to the final volume.
  ///
  /// The `weight` argument is relative to the weight in kilo.
  ///
  /// The `duration` argument is relative to the boil duration in minute.
  double sparge(double volume, double weight, {int duration = 60}) {
    var preboil = preboilVolume(volume, duration: duration);
    return FormulaHelper.spargeWater(weight, preboil, mash(weight), absorption: absorption);
  }

  bool hasBluetooth() {
    return this.bluetooth == true && (DeviceHelper.isAndroid ||  DeviceHelper.isIOS);
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
        EquipmentModel model = EquipmentModel();
        model.fromMap(data);
        values.add(model);
      }
    }
    return values;
  }
}
