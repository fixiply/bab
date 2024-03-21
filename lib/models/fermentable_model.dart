// Internal package
import 'package:bab/extensions/string_extensions.dart';
import 'package:bab/helpers/formula_helper.dart';
import 'package:bab/models/model.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/utils/localized_text.dart';
import 'package:bab/utils/quantity.dart';

// External package
import 'package:xml/xml.dart';

enum Type with Enums { grain, sugar, extract,  dry_extract, adjunct, fruit, juice, honey;
  List<Enum> get enums => [ grain, sugar, extract,  dry_extract, adjunct, fruit, juice, honey ];
}

enum Method with Enums { mashed,  steeped;
  List<Enum> get enums => [ mashed,  steeped ];
}

const String XML_ELEMENT_NAME = 'NAME';
const String XML_ELEMENT_TYPE = 'TYPE';
const String XML_ELEMENT_AMOUNT = 'AMOUNT';
const String XML_ELEMENT_YIELD = 'YIELD';
const String XML_ELEMENT_COLOR = 'COLOR';

class FermentableModel<T> extends Model {
  dynamic name;
  Type? type;
  String? origin;
  /// Weight in Kilograms.
  double? amount;
  Measurement? measurement;
  Method? use;
  double? efficiency;
  int? ebc;
  dynamic notes;

  FermentableModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    bool? isEdited,
    bool? isSelected,
    this.name,
    this.type = Type.grain,
    this.origin,
    this.amount,
    this.measurement = Measurement.kilo,
    this.use = Method.mashed,
    this.efficiency,
    this.ebc,
    this.notes,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator, isEdited: isEdited, isSelected: isSelected);

  @override
  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.name = LocalizedText.deserialize(map['name']);
    this.type = Type.values.elementAt(map['type']);
    this.origin = map['origin'];
    if (map['efficiency'] != null) this.efficiency = map['efficiency'].toDouble();
    this.ebc = map['ebc'];
    this.notes = LocalizedText.deserialize(map['notes']);
  }

  @override
  Map<String, dynamic> toMap({bool persist = false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'name': LocalizedText.serialize(this.name),
      'type': this.type!.index,
      'origin': this.origin,
      'efficiency': this.efficiency,
      'ebc': this.ebc,
      'notes': LocalizedText.serialize(this.notes),
    });
    return map;
  }

  FermentableModel copy() {
    return FermentableModel(
      uuid: uuid,
      inserted_at: inserted_at,
      updated_at: updated_at,
      creator: creator,
      name: this.name,
      type: this.type,
      origin: this.origin,
      amount: this.amount,
      use: this.use,
      measurement: this.measurement,
      efficiency: this.efficiency,
      ebc: this.ebc,
      notes: this.notes,
    );
  }

  // ignore: hash_and_equals
  @override
  bool operator ==(other) {
    return (other is FermentableModel && other.uuid == uuid);
  }

  @override
  int get hashCode => uuid.hashCode;

  @override
  String toString() {
    return 'FermentableModel: $name, UUID: $uuid';
  }

  /// Returns the dry extract, based on the given conditions.
  ///
  /// The `efficiency` argument is relative to the theoretical efficiency of the equipment.
  double? extract(double? efficiency) {
    return FormulaHelper.extract(this.amount, this.efficiency, efficiency);
  }

  @override
  bool isNumericType(String columnName) {
    return columnName == 'amount' || columnName == 'efficiency';
  }

  @override
  bool isTextType(String columnName) {
    return columnName == 'name' || columnName == 'notes';
  }

  @override
  List<Enums>? isEnumType(String columnName) {
    if (columnName == 'type') {
      return Type.values;
    } else if (columnName == 'method') {
      return Method.values;
    }
    return null;
  }

  bool hasName(String? text, List<String> excludes) {
    if (text == null) return false;
    if (name is LocalizedText) {
      for(String value in name.map!.values) {
        if (value.containsWord(text, excludes)) {
          return true;
        }
      }
    } else if ((name as String).containsWord(text, excludes)) {
      return true;
    }
    return false;
  }

  static dynamic serialize(dynamic data) {
    if (data != null) {
      if (data is FermentableModel) {
        return data.toMap();
      }
      if (data is List) {
        List<FermentableModel> values = [];
        for(final value in data) {
          values.add(serialize(value));
        }
        return values;
      }
    }
    return null;
  }

  static List<FermentableModel> deserialize(dynamic data) {
    List<FermentableModel> values = [];
    if (data != null) {
      if (data is List) {
        for(final value in data) {
          values.addAll(deserialize(value));
        }
      } else {
        FermentableModel model = FermentableModel();
        model.fromMap(data);
        values.add(model);
      }
    }
    return values;
  }

  static FermentableModel fromXML(XmlElement child, {FermentableModel? old}) {
    FermentableModel model = old != null ? old.copy() : FermentableModel();
    if (old == null) {
      model.name = child.getElement(XML_ELEMENT_NAME)!.innerText;
      model.type = FermentableModel.getTypeByName( child.getElement(XML_ELEMENT_TYPE)!.innerText);
      model.efficiency = double.parse(child.getElement(XML_ELEMENT_YIELD)!.innerText);
      model.ebc = int.parse(child.getElement(XML_ELEMENT_COLOR)!.innerText);
    }
    model.amount = double.parse(child.getElement(XML_ELEMENT_AMOUNT)!.innerText);
    model.measurement = Measurement.kilo;
    return model;
  }

  static Future<List<FermentableModel>> data(List<Quantity> data) async {
    List<FermentableModel>? values = [];
    for(Quantity item in data) {
      FermentableModel? model = await Database().getFermentable(item.uuid!);
      if (model != null) {
        model.amount = item.amount;
        model.use = item.use != null ? Method.values.elementAt(item.use!) : Method.mashed;
        model.measurement = Measurement.kilo;
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
        List<Quantity> values = [];
        for(final item in data) {
          Quantity model = Quantity();
          model.uuid = item.uuid;
          model.amount = item.amount;
          model.use = item.use?.index;
          if (item.measurement != null) model.measurement = item.measurement;
          values.add(model);
        }
        return values;
      }
    }
    return null;
  }

  static Type? getTypeByName(String? name) {
    if (name == null) return null;
    switch (name) {
      case 'Grain':
        return Type.grain;
      case 'Sugar':
        return Type.sugar;
      case 'Extract':
        return Type.extract;
      case 'Dry Extract':
        return Type.dry_extract;
      case 'Adjunct':
        return Type.adjunct;
      case 'Fruit':
        return  Type.fruit;
      case 'Juice':
        return Type.juice;
      case 'Honey':
        return Type.honey;
    }
    return null;
  }
}
