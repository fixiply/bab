// Internal package
import 'package:bab/models/model.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/utils/localized_text.dart';
import 'package:bab/utils/quantity.dart';

enum Misc with Enums { spice, fining, water_agent, herb, flavor, other;
  List<Enum> get enums => [ spice, fining, water_agent, herb, flavor, other ];
}

enum Use with Enums { boil, mash, primary, secondary, bottling, sparge;
  List<Enum> get enums => [ boil, mash, primary, secondary, bottling, sparge ];
}

extension DoubleParsing on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

class MiscModel<T> extends Model {
  Status? status;
  dynamic name;
  Misc? type;
  Use? use;
  double? amount;
  Unit? unit;
  int? duration;
  dynamic notes;

  MiscModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    bool? isEdited,
    bool? isSelected,
    this.status = Status.publied,
    this.name,
    this.type = Misc.flavor,
    this.use = Use.mash,
    this.amount,
    this.unit,
    this.duration,
    this.notes,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator, isEdited: isEdited, isSelected: isSelected);

  @override
  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.name = LocalizedText.deserialize(map['name']);
    this.type = Misc.values.elementAt(map['type']);
    this.notes = LocalizedText.deserialize(map['notes']);
  }

  @override
  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'name': LocalizedText.serialize(this.name),
      'type': this.type!.index,
      'notes': LocalizedText.serialize(this.notes),
    });
    return map;
  }

  MiscModel copy() {
    return MiscModel(
      uuid: uuid,
      inserted_at: inserted_at,
      updated_at: updated_at,
      creator: creator,
      status: this.status,
      name: this.name,
      type: this.type,
      use: this.use,
      amount: this.amount,
      unit: this.unit,
      duration: this.duration,
      notes: this.notes,
    );
  }

  // ignore: hash_and_equals
  @override
  bool operator ==(other) {
    return (other is MiscModel && other.uuid == uuid);
  }

  @override
  int get hashCode => uuid.hashCode;

  @override
  String toString() {
    return 'MiscellaneousModel: $name, UUID: $uuid';
  }

  @override
  bool isNumericType(String columnName) {
    return columnName == 'amount' || columnName == 'time';
  }

  @override
  bool isTextType(String columnName) {
    return columnName == 'name' || columnName == 'notes';
  }

  @override
  List<Enums>? isEnumType(String columnName) {
    if (columnName == 'type') {
      return Misc.values;
    } else  if (columnName == 'use') {
      return Use.values;
    } else if (columnName == 'unit') {
      return [ Unit.gram, Unit.kilo, Unit.milliliter, Unit.liter, Unit.units ];
    }
    return null;
  }

  static dynamic serialize(dynamic data) {
    if (data != null) {
      if (data is MiscModel) {
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

  static List<MiscModel> deserialize(dynamic data) {
    List<MiscModel> values = [];
    if (data != null) {
      if (data is List) {
        for(final value in data) {
          values.addAll(deserialize(value));
        }
      } else {
        MiscModel model = MiscModel();
        model.fromMap(data);
        values.add(model);
      }
    }
    return values;
  }

  static Future<List<MiscModel>> data(List<Quantity> data) async {
    List<MiscModel>? values = [];
    for(Quantity item in data) {
      MiscModel? model = await Database().getMisc(item.uuid!);
      if (model != null) {
        model.amount = item.amount;
        model.unit = Unit.units;
        model.duration = item.duration;
        model.use = item.use != null ? Use.values.elementAt(item.use!) : Use.boil;
        values.add(model);
      }
    }
    return values;
  }

  static dynamic quantities(dynamic data) {
    if (data != null) {
      if (data is Quantity) {
        return data.toMap();
      }
      if (data is List) {
        List<dynamic> values = [];
        for(final item in data) {
          Quantity model = Quantity();
          model.uuid = item.uuid;
          model.amount = item.amount;
          if (item.unit != null) model.unit = item.unit;
          model.duration = item.duration;
          model.use = item.use?.index;
          values.add(Quantity.serialize(model));
        }
        return values;
      }
    }
    return null;
  }
}