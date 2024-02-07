// Internal package
import 'package:bab/helpers/formula_helper.dart';
import 'package:bab/models/model.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/utils/localized_text.dart';
import 'package:bab/utils/quantity.dart';

// External package
import 'package:xml/xml.dart';

enum Hop with Enums { leaf, pellet, plug, other;
  List<Enum> get enums => [ leaf, pellet, plug, other ];
}

enum Type with Enums { aroma, bittering, both;
  List<Enum> get enums => [ aroma, bittering, both ];
}
enum Use with Enums { mash, first_wort, boil, aroma, dry_hop;
  List<Enum> get enums => [ mash, first_wort, boil, aroma, dry_hop ];
}

const String XML_ELEMENT_NAME = 'NAME';
const String XML_ELEMENT_TIME = 'TIME';
const String XML_ELEMENT_AMOUNT = 'AMOUNT';
const String XML_ELEMENT_USE = 'USE';
const String XML_ELEMENT_FORM = 'FORM';
const String XML_ELEMENT_ALPHA = 'ALPHA';
const String XML_ELEMENT_BETA = 'BETA';

class HopModel<T> extends Model {
  dynamic name;
  String? origin;
  double? alpha;
  double? beta;
  /// Weight in Kilograms.
  double? amount;
  Hop? form;
  Type? type;
  Use? use;
  Measurement? measurement;
  /// The time in minutes.
  int? duration;
  dynamic notes;

  HopModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    bool? isEdited,
    bool? isSelected,
    this.name,
    this.origin,
    this.alpha,
    this.beta,
    this.amount,
    this.form = Hop.pellet,
    this.type = Type.both,
    this.use = Use.boil,
    this.measurement,
    this.duration,
    this.notes,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator, isEdited: isEdited, isSelected: isSelected);

  @override
  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.name = LocalizedText.deserialize(map['name']);
    this.origin = map['origin'];
    if (map['alpha'] != null) this.alpha = map['alpha'].toDouble();
    if (map['beta'] != null) this.beta = map['beta'].toDouble();
    this.form = Hop.values.elementAt(map['form']);
    this.type = Type.values.elementAt(map['type']);
    this.notes = LocalizedText.deserialize(map['notes']);
  }

  @override
  Map<String, dynamic> toMap({bool persist = false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'name': LocalizedText.serialize(this.name),
      'origin': this.origin,
      'alpha': this.alpha,
      'beta': this.beta,
      'form': this.form!.index,
      'type': this.type!.index,
      'notes': LocalizedText.serialize(this.notes),
    });
    return map;
  }

  HopModel copy() {
    return HopModel(
      uuid: uuid,
      inserted_at: inserted_at,
      updated_at: updated_at,
      creator: creator,
      name: this.name,
      origin: this.origin,
      alpha: this.alpha,
      beta: this.beta,
      amount: this.amount,
      measurement: this.measurement,
      form: this.form,
      type: this.type,
      use: this.use,
      duration: this.duration,
      notes: this.notes,
    );
  }

  // ignore: hash_and_equals
  @override
  bool operator ==(other) {
    return (other is HopModel && other.uuid == uuid);
  }

  @override
  int get hashCode => uuid.hashCode;

  @override
  String toString() {
    return 'HopModel: $name, UUID: $uuid';
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
  double? ibu(double? og, int? duration, double? volume, {double? maximum})  {
    return FormulaHelper.ibu((this.amount! * 1000), this.alpha, og, this.duration, volume, maximum: maximum);
  }

  @override
  bool isNumericType(String columnName) {
    return columnName == 'amount' || columnName == 'alpha' || columnName == 'duration';
  }

  @override
  bool isTextType(String columnName) {
    return columnName == 'name' || columnName == 'notes';
  }

  @override
  List<Enums>? isEnumType(String columnName) {
    if (columnName == 'form') {
      return Hop.values;
    } else if (columnName == 'type') {
      return Type.values;
    } else if (columnName == 'use') {
      return Use.values;
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
      if (data is HopModel) {
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

  static List<HopModel> deserialize(dynamic data) {
    List<HopModel> values = [];
    if (data != null) {
      if (data is List) {
        for(final value in data) {
          values.addAll(deserialize(value));
        }
      } else {
        HopModel model = HopModel();
        model.fromMap(data);
        values.add(model);
      }
    }
    return values;
  }

  static HopModel fromXML(XmlElement child, {HopModel? old}) {
    HopModel model = old != null ? old.copy() : HopModel();
    if (old == null) {
      model.name = child.getElement(XML_ELEMENT_NAME)!.innerText;
      model.form = HopModel.getFormByName(child.getElement(XML_ELEMENT_FORM)!.innerText);
      model.alpha = double.parse(child.getElement(XML_ELEMENT_ALPHA)!.innerText);
      final beta = child.getElement(XML_ELEMENT_BETA);
      if (beta != null) {
        model.beta = double.parse(beta.innerText);
      }
    }
    model.duration = int.parse(child.getElement(XML_ELEMENT_TIME)!.innerText);
    model.amount = double.parse(child.getElement(XML_ELEMENT_AMOUNT)!.innerText);
    model.measurement = Measurement.kilo;
    model.use = HopModel.getUseByName(child.getElement(XML_ELEMENT_USE)!.innerText);
    return model;
  }

  static Future<List<HopModel>> data(List<Quantity> data) async {
    List<HopModel>? values = [];
    for(Quantity item in data) {
      HopModel? model = await Database().getHop(item.uuid!);
      if (model != null) {
        model.amount = item.amount;
        model.duration = item.duration;
        model.use = item.use != null ? Use.values.elementAt(item.use!) : Use.boil;
        model.measurement = Measurement.gram;
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
          model.duration = item.duration;
          model.use = item.use?.index;
          if (item.measurement != null) model.measurement = item.measurement;
          values.add(Quantity.serialize(model));
        }
        return values;
      }
    }
    return null;
  }

  static Hop? getFormByName(String? name) {
    if (name == null) return null;
    switch (name) {
      case 'Leaf':
        return Hop.leaf;
      case 'Pellet':
        return Hop.pellet;
      case 'Plug':
        return Hop.plug;
      case 'Other':
        return Hop.other;
    }
    return null;
  }

  static Use? getUseByName(String? name) {
    if (name == null) return null;
    switch (name) {
      case 'Mash':
        return Use.mash;
      case 'First Wort':
        return Use.first_wort;
      case 'Boil':
        return Use.boil;
      case 'Aroma':
        return Use.aroma;
      case 'Dry Hop':
        return Use.dry_hop;
    }
    return null;
  }
}
