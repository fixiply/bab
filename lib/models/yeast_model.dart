// Internal package
import 'package:bb/helpers/formula_helper.dart';
import 'package:bb/models/model.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/localized_text.dart';
import 'package:bb/utils/quantity.dart';

enum Yeast with Enums { liquid, dry, slant, culture;
  List<Enum> get enums => [ liquid, dry, slant, culture ];
}

extension DoubleParsing on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

class YeastModel<T> extends Model {
  Status? status;
  dynamic? name;
  String? reference;
  String? laboratory;
  Fermentation? type;
  Yeast? form;
  double? amount;
  double? cells;
  double? tempmin;
  double? tempmax;
  double? attmin;
  double? attmax;
  dynamic? notes;

  YeastModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    bool? isEdited,
    bool? isSelected,
    this.status = Status.publied,
    this.name,
    this.reference,
    this.laboratory,
    this.type = Fermentation.hight,
    this.form = Yeast.dry,
    this.amount,
    this.cells,
    this.tempmin,
    this.tempmax,
    this.attmin,
    this.attmax,
    this.notes,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator, isEdited: isEdited, isSelected: isSelected);

  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.name = LocalizedText.deserialize(map['name']);
    this.name = LocalizedText.deserialize(map['name']);
    this.reference = map['product'];
    this.laboratory = map['laboratory'];
    this.type = Fermentation.values.elementAt(map['type']);
    this.form = Yeast.values.elementAt(map['form']);
    // if (map['amount'] != null) this.amount = map['amount'].toDouble();
    if (map['cells'] != null) this.cells = map['cells'].toDouble();
    if (map['min_temp'] != null) this.tempmin = map['min_temp'].toDouble();
    if (map['max_temp'] != null) this.tempmin = map['max_temp'].toDouble();
    if (map['min_attenuation'] != null) this.attmin = map['min_attenuation'].toDouble();
    if (map['max_attenuation'] != null) this.attmax = map['max_attenuation'].toDouble();
    this.notes = LocalizedText.deserialize(map['notes']);
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'name': LocalizedText.serialize(this.name),
      'product': this.reference,
      'laboratory': this.laboratory,
      'type': this.type!.index,
      'form': this.form!.index,
      // 'amount': this.amount,
      'cells': this.cells,
      'min_temp': this.tempmin,
      'max_temp': this.tempmax,
      'min_attenuation': this.attmin,
      'max_attenuation': this.attmax,
      'notes': LocalizedText.serialize(this.notes),
    });
    return map;
  }

  YeastModel copy() {
    return YeastModel(
      uuid: this.uuid,
      inserted_at: this.inserted_at,
      updated_at: this.updated_at,
      creator: this.creator,
      status: this.status,
      name: this.name,
      reference: this.reference,
      laboratory: this.laboratory,
      type: this.type,
      form: this.form,
      amount: this.amount,
      cells: this.cells,
      tempmin: this.tempmin,
      tempmax: this.tempmax,
      attmin: this.attmin,
      attmax: this.attmax,
      notes: this.notes,
    );
  }

  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is YeastModel && other.uuid == uuid);
  }

  @override
  String toString() {
    return 'YeastModel: $name, UUID: $uuid';
  }

  double? get attenuation {
    if (this.attmin != null && this.attmax != null) {
      return (this.attmin! + this.attmax!) / 2;
    }
    return null;
  }

  /// Returns the pitching rate, based on the given conditions.
  ///
  /// The `og` argument is relative to the original gravity 1.xxx.
  double pitchingRate(double? og) {
    if (og != null) {
      if (type == Fermentation.low) {
        if (og < 1.060) {
          return 1.50;
        } else return 2.0;
      } else if (type == Fermentation.hight) {
        if (og < 1.060) {
          return 0.75;
        } else return 1.0;
      }
    }
    return 0.35;
  }

  /// Returns the final density, based on the given conditions.
  ///
  /// The `og` argument is relative to the original gravity 1.xxx.
  double density(double? og) {
    return FormulaHelper.fg(og, attenuation);
  }

  @override
  bool isNumericType(String columnName) {
    return columnName == 'amount' || columnName == 'attenuation';
  }

  @override
  bool isTextType(String columnName) {
    return columnName == 'name' || columnName == 'notes';
  }

  @override
  List<Enums>? isEnumType(String columnName) {
    if (columnName == 'type') {
      return Fermentation.values;
    } else if (columnName == 'form') {
      return Yeast.values;
    }
    return null;
  }

  static List<YeastModel> merge(List<Quantity>? quantities, List<YeastModel> yeasts) {
    List<YeastModel> list = [];
    if (quantities != null && yeasts != null) {
      for (Quantity quantity in quantities) {
        for (YeastModel yeast in yeasts) {
          if (quantity.uuid == yeast.uuid) {
            YeastModel model = yeast.copy();
            model.amount = quantity.amount;
            list.add(model);
            break;
          }
        }
      }
    }
    return list;
  }

  static dynamic serialize(dynamic data) {
    if (data != null) {
      if (data is YeastModel) {
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

  static List<YeastModel> deserialize(dynamic data) {
    List<YeastModel> values = [];
    if (data != null) {
      if (data is List) {
        for(final value in data) {
          values.addAll(deserialize(value));
        }
      } else {
        YeastModel model = new YeastModel();
        model.fromMap(data);
        values.add(model);
      }
    }
    return values;
  }
}
