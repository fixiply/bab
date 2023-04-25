// Internal package
import 'package:bb/helpers/formula_helper.dart';
import 'package:bb/models/model.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/localized_text.dart';
import 'package:bb/utils/quantity.dart';

enum Type with Enums { grain, sugar, extract,  dry_extract, adjunct, fruit, juice, honey;
  List<Enum> get enums => [ grain, sugar, extract,  dry_extract, adjunct, fruit, juice, honey ];
}

enum Method with Enums { mashed,  steeped;
  List<Enum> get enums => [ mashed,  steeped ];
}

extension Ex on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

class FermentableModel<T> extends Model {
  Status? status;
  dynamic? name;
  Type? type;
  String? origin;
  double? amount;
  Method? use;
  double? efficiency;
  int? ebc;
  dynamic? notes;

  FermentableModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    bool? isEdited,
    bool? isSelected,
    this.status = Status.publied,
    this.name,
    this.type = Type.grain,
    this.origin,
    this.amount,
    this.use = Method.mashed,
    this.efficiency,
    this.ebc,
    this.notes,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator, isEdited: isEdited, isSelected: isSelected);

  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.name = LocalizedText.deserialize(map['name']);
    this.type = Type.values.elementAt(map['type']);
    this.origin = map['origin'];
    // if (map['amount'] != null) this.amount = map['amount'].toDouble();
    // this.method = Method.values.elementAt(map['method']);
    if (map['efficiency'] != null) this.efficiency = map['efficiency'].toDouble();
    this.ebc = map['ebc'];
    this.notes = LocalizedText.deserialize(map['notes']);
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'name': LocalizedText.serialize(this.name),
      'type': this.type!.index,
      'origin': this.origin,
      // 'amount': this.amount,
      // 'method': this.method!.index,
      'efficiency': this.efficiency,
      'ebc': this.ebc,
      'notes': LocalizedText.serialize(this.notes),
    });
    return map;
  }

  FermentableModel copy() {
    return FermentableModel(
      uuid: this.uuid,
      inserted_at: this.inserted_at,
      updated_at: this.updated_at,
      creator: this.creator,
      status: this.status,
      name: this.name,
      type: this.type,
      origin: this.origin,
      amount: this.amount,
      use: this.use,
      efficiency: this.efficiency,
      ebc: this.ebc,
      notes: this.notes,
    );
  }

  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is FermentableModel && other.uuid == uuid);
  }

  @override
  String toString() {
    return 'FermentableModel: $name, UUID: $uuid';
  }

  /// Returns the dry extract, based on the given conditions.
  ///
  /// The `efficiency` argument is relative to the theoretical efficiency of the equipment.
  double extract(double? efficiency) {
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

  static dynamic serialize(dynamic data) {
    if (data != null) {
      if (data is FermentableModel) {
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

  static List<FermentableModel> deserialize(dynamic data) {
    List<FermentableModel> values = [];
    if (data != null) {
      if (data is List) {
        for(final value in data) {
          values.addAll(deserialize(value));
        }
      } else {
        FermentableModel model = new FermentableModel();
        model.fromMap(data);
        values.add(model);
      }
    }
    return values;
  }

  static Future<List<FermentableModel>> data(data) async {
    List<FermentableModel>? values = [];
    for(Quantity item in Quantity.deserialize(data)) {
      FermentableModel? model = await Database().getFermentable(item.uuid!);
      if (model != null) {
        model.amount = item.amount;
        model.use = item.use != null ? Method.values.elementAt(item.use!) : Method.mashed;
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
          Quantity model = new Quantity();
          model.uuid = item.uuid;
          model.amount = item.amount;
          model.use = item.use?.index;
          values.add(Quantity.serialize(model));
        }
        return values;
      }
    }
    return null;
  }
}
