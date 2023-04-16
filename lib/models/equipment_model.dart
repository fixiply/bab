// Internal package
import 'package:bb/models/image_model.dart';
import 'package:bb/models/model.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/localized_text.dart';

// External package

enum Equipment with Enums { tank, fermenter;
  List<Enum> get enums => [ tank, fermenter ];
}

extension Ex on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

class EquipmentModel<T> extends Model {
  Status? status;
  String? name;
  Equipment? type;
  double? volume;
  double? mash_volume;
  double? efficiency;
  double? absorption;
  double? lost_volume;
  double? boil_loss;
  double? shrinkage;
  dynamic? notes;
  ImageModel? image;

  EquipmentModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    bool? isEdited,
    bool? isSelected,
    this.status = Status.publied,
    this.name,
    this.type,
    this.volume,
    this.mash_volume,
    this.efficiency = DEFAULT_YIELD,
    this.absorption,
    this.lost_volume,
    this.boil_loss = DEFAULT_BOIL_LOSS,
    this.shrinkage = DEFAULT_WORT_SHRINKAGE,
    this.notes,
    this.image,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator, isEdited: isEdited, isSelected: isSelected);

  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.name = map['name'];
    this.type = Equipment.values.elementAt(map['type']);
    if (map['volume'] != null) this.volume = map['volume'].toDouble();
    if (map['mash_volume'] != null) this.mash_volume = map['mash_volume'].toDouble();
    if (map['efficiency'] != null) this.efficiency = map['efficiency'].toDouble();
    if (map['absorption'] != null) this.absorption = map['absorption'].toDouble();
    if (map['lost_volume'] != null) this.lost_volume = map['lost_volume'].toDouble();
    if (map['boil_loss'] != null) this.boil_loss = map['boil_loss'].toDouble();
    if (map['shrinkage'] != null) this.shrinkage = map['shrinkage'].toDouble();
    this.notes = LocalizedText.deserialize(map['notes']);
    this.image = ImageModel.fromJson(map['image']);
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'name': this.name,
      'type': this.type!.index,
      'volume': this.volume,
      'mash_volume': this.mash_volume,
      'efficiency': this.efficiency,
      'absorption': this.absorption,
      'lost_volume': this.lost_volume,
      'boil_loss': this.boil_loss,
      'shrinkage': this.shrinkage,
      'notes': LocalizedText.serialize(this.notes),
      'image': ImageModel.serialize(this.image),
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
      type: this.type,
      volume: this.volume,
      mash_volume: this.mash_volume,
      efficiency: this.efficiency,
      absorption: this.absorption,
      lost_volume: this.lost_volume,
      boil_loss: this.boil_loss,
      shrinkage: this.shrinkage,
      notes: this.notes,
      image: this.image,
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

  /// Returns the pre-boil volume, based on the given conditions.
  ///
  /// The `volume` argument is relative to the final volume.
  static double preBoilVolume(EquipmentModel? equipment, double? volume) {
    if (volume == null) {
      return 0;
    }
    double loss_boil = DEFAULT_BOIL_LOSS;
    double head_loss = DEFAULT_WORT_SHRINKAGE;
    if (equipment != null) {
      loss_boil = equipment.boil_loss!;
      head_loss = equipment.shrinkage!;
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
