// Internal package
import 'package:bab/helpers/formula_helper.dart';
import 'package:bab/models/model.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/utils/localized_text.dart';
import 'package:bab/utils/quantity.dart';
import 'package:flutter/foundation.dart';

// External package
import 'package:xml/xml.dart';

enum Yeast with Enums { liquid, dry, slant, culture;
  List<Enum> get enums => [ liquid, dry, slant, culture ];
}

const String XML_ELEMENT_NAME = 'NAME';
const String XML_ELEMENT_LABORATORY = 'LABORATORY';
const String XML_ELEMENT_PRODUCT_ID = 'PRODUCT_ID';
const String XML_ELEMENT_AMOUNT = 'AMOUNT';
const String XML_ELEMENT_FORM = 'FORM';
const String XML_ELEMENT_TYPE = 'TYPE';
const String XML_ELEMENT_MIN_TEMPERATURE = 'MIN_TEMPERATURE';
const String XML_ELEMENT_MAX_TEMPERATURE = 'MAX_TEMPERATURE';
const String XML_ELEMENT_ATTENUATION = 'ATTENUATION';

class YeastModel<T> extends Model {
  dynamic name;
  String? product;
  String? laboratory;
  Style? type;
  Yeast? form;
  /// Weight in Kilograms or volume in litters.
  double? amount;
  Measurement? measurement;
  double? cells;
  /// Degrees in Celsius
  double? tempmin;
  /// Degrees in Celsius
  double? tempmax;
  double? attmin;
  double? attmax;
  dynamic notes;

  YeastModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    bool? isEdited,
    bool? isSelected,
    this.name,
    this.product,
    this.laboratory,
    this.type = Style.hight,
    this.form = Yeast.dry,
    this.amount,
    this.measurement,
    this.cells,
    this.tempmin,
    this.tempmax,
    this.attmin,
    this.attmax,
    this.notes,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator, isEdited: isEdited, isSelected: isSelected);

  @override
  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.name = LocalizedText.deserialize(map['name']);
    this.product = map['product'];
    this.laboratory = map['laboratory'];
    this.type = Style.values.elementAt(map['type']);
    this.form = Yeast.values.elementAt(map['form']);
    if (map['cells'] != null) this.cells = map['cells'].toDouble();
    if (map['min_temp'] != null) this.tempmin = map['min_temp'].toDouble();
    if (map['max_temp'] != null) this.tempmax = map['max_temp'].toDouble();
    if (map['min_attenuation'] != null) this.attmin = map['min_attenuation'].toDouble();
    if (map['max_attenuation'] != null) this.attmax = map['max_attenuation'].toDouble();
    this.notes = LocalizedText.deserialize(map['notes']);
  }

  @override
  Map<String, dynamic> toMap({bool persist = false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'name': LocalizedText.serialize(this.name),
      'product': this.product,
      'laboratory': this.laboratory,
      'type': this.type!.index,
      'form': this.form!.index,
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
      uuid: uuid,
      inserted_at: inserted_at,
      updated_at: updated_at,
      creator: creator,
      name: this.name,
      product: this.product,
      laboratory: this.laboratory,
      type: this.type,
      form: this.form,
      amount: this.amount,
      measurement: this.measurement,
      cells: this.cells,
      tempmin: this.tempmin,
      tempmax: this.tempmax,
      attmin: this.attmin,
      attmax: this.attmax,
      notes: this.notes,
    );
  }

  // ignore: hash_and_equals
  @override
  bool operator ==(other) {
    return (other is YeastModel && other.uuid == uuid);
  }

  @override
  int get hashCode => uuid.hashCode;

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

  double? get temperature {
    if (this.tempmin != null && this.tempmax != null) {
      return (this.tempmin! + this.tempmax!) / 2;
    }
    return null;
  }

  /// Returns the pitching rate, based on the given conditions.
  ///
  /// The `og` argument is relative to the original gravity 1.xxx.
  double pitchingRate(double? og) {
    if (og != null) {
      if (type == Style.low) {
        if (og < 1.060) {
          return 1.50;
        } else return 2.0;
      } else if (type == Style.hight) {
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
  double? density(double? og) {
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
  List<Enums> isEnumType(String columnName) {
    if (columnName == 'type') {
      return Style.values;
    } else if (columnName == 'form') {
      return Yeast.values;
    } else if (columnName == 'measurement') {
      return [ Measurement.gram, Measurement.milliliter, Measurement.packages ].toList();
    }
    return [];
  }

  bool hasName(String? text, List<String> excludes) {
    if (text == null) return false;
    List<String> split = text.toLowerCase().split(' ');
    if (name is LocalizedText) {
      for(String value in name.map!.values) {
        if (value.containsWord(text, excludes)) {
          return true;
        }
        if (split.length == 2 && product != null) {
          String product = this.product!.replaceAll(new RegExp(r'[^\w\s]+'), '').toLowerCase();
          if (value.toLowerCase().contains(split.first.toLowerCase()) && product.contains(split.last.toLowerCase()))  {
            return true;
          }
        }
      }
    } else if (name is String) {
      if ((name as String).containsWord(text, excludes)) {
        return true;
      }
      if (split.length == 2 && product != null) {
        String product = this.product!.replaceAll(new RegExp(r'[^\w\s]+'), '').toLowerCase();
        if (name.toLowerCase().contains(split.first.toLowerCase()) && product.contains(split.last.toLowerCase()))  {
          return true;
        }
      }
    }
    return false;
  }

  static dynamic serialize(dynamic data) {
    if (data != null) {
      if (data is YeastModel) {
        return data.toMap();
      }
      if (data is List) {
        List<YeastModel> values = [];
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
        YeastModel model = YeastModel();
        model.fromMap(data);
        values.add(model);
      }
    }
    return values;
  }

  static YeastModel fromXML(XmlElement child, {YeastModel? old}) {
    YeastModel model = old != null ? old.copy() : YeastModel();
    if (old == null) {
      model.name = child.getElement(XML_ELEMENT_NAME)!.innerText;
      model.laboratory = child.getElement(XML_ELEMENT_LABORATORY)!.innerText;
      model.product = child.getElement(XML_ELEMENT_PRODUCT_ID)!.innerText;
      model.form = YeastModel.getFormByName(child.getElement(XML_ELEMENT_FORM)!.innerText);
      model.type = YeastModel.getTypeByName( child.getElement(XML_ELEMENT_TYPE)!.innerText);
      model.tempmin = double.parse(child.getElement(XML_ELEMENT_MIN_TEMPERATURE)!.innerText);
      model.tempmax = double.parse(child.getElement(XML_ELEMENT_MAX_TEMPERATURE)!.innerText);
      model.attmin = double.parse(child.getElement(XML_ELEMENT_ATTENUATION)!.innerText);
      model.attmax = double.parse(child.getElement(XML_ELEMENT_ATTENUATION)!.innerText);
    }
    model.amount = double.parse(child.getElement(XML_ELEMENT_AMOUNT)!.innerText);
    model.measurement = Measurement.packages;
    return model;
  }

  static Future<List<YeastModel>> data(List<Quantity> data) async {
    List<YeastModel>? values = [];
    for(Quantity item in data) {
      YeastModel? model = await Database().getYeast(item.uuid!);
      if (model != null) {
        model.amount = item.amount;
        model.measurement = item.measurement ?? (model.form == Yeast.liquid ? Measurement.liter : Measurement.kilo);
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
          if (item.measurement != null) model.measurement = item.measurement;
          values.add(Quantity.serialize(model));
        }
        return values;
      }
    }
    return null;
  }

  static Yeast? getFormByName(String? name) {
    if (name == null) return null;
    switch (name) {
      case 'Liquid':
        return Yeast.liquid;
      case 'Dry':
        return Yeast.dry;
      case 'Slant':
        return Yeast.slant;
      case 'Culture':
        return Yeast.culture;
    }
    return null;
  }

  static Style? getTypeByName(String? name) {
    if (name == null) return null;
    switch (name) {
      case 'Ale':
        return Style.hight;
      case 'Lager':
        return Style.low;
      case 'Spontaneous':
        return Style.spontaneous;
    }
    return null;
  }
}
