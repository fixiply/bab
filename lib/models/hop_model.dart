// Internal package
import 'package:bb/helpers/formula_helper.dart';
import 'package:bb/models/model.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/localized_text.dart';
import 'package:bb/utils/quantity.dart';

enum Hop with Enums { leaf, pellet, plug, other;
  List<Enum> get enums => [ leaf, pellet, plug, other ];
}

enum Type with Enums { aroma, bittering, both;
  List<Enum> get enums => [ aroma, bittering, both ];
}
enum Use with Enums { mash, first_wort, boil, aroma, dry_hop;
  List<Enum> get enums => [ mash, first_wort, boil, aroma, dry_hop ];
}

extension Ex on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

class HopModel<T> extends Model {
  Status? status;
  dynamic? name;
  String? origin;
  double? alpha;
  double? beta;
  double? amount;
  Hop? form;
  Type? type;
  Use? use;
  int? duration;
  dynamic? notes;

  HopModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    bool? isEdited,
    bool? isSelected,
    this.status = Status.publied,
    this.name,
    this.origin,
    this.alpha,
    this.beta,
    this.amount,
    this.form = Hop.pellet,
    this.type = Type.both,
    this.use = Use.boil,
    this.duration,
    this.notes,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator, isEdited: isEdited, isSelected: isSelected);

  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.name = LocalizedText.deserialize(map['name']);
    this.origin = map['origin'];
    if (map['alpha'] != null) this.alpha = map['alpha'].toDouble();
    if (map['beta'] != null) this.beta = map['beta'].toDouble();
    // if (map['amount'] != null) this.amount = map['amount'].toDouble();
    this.form = Hop.values.elementAt(map['form']);
    this.type = Type.values.elementAt(map['type']);
    // if (map['use'] != null) this.use = HopUse.values.elementAt(map['use']);
    // this.duration = map['duration'];
    this.notes = LocalizedText.deserialize(map['notes']);
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'name': LocalizedText.serialize(this.name),
      'origin': this.origin,
      'alpha': this.alpha,
      'beta': this.beta,
      // 'amount': this.amount,
      'form': this.form!.index,
      'type': this.type!.index,
      // 'use': this.use!.index,
      // 'duration': this.duration,
      'notes': LocalizedText.serialize(this.notes),
    });
    return map;
  }

  HopModel copy() {
    return HopModel(
      uuid: this.uuid,
      inserted_at: this.inserted_at,
      updated_at: this.updated_at,
      creator: this.creator,
      status: this.status,
      name: this.name,
      origin: this.origin,
      alpha: this.alpha,
      beta: this.beta,
      amount: this.amount,
      form: this.form,
      type: this.type,
      use: this.use,
      duration: this.duration,
      notes: this.notes,
    );
  }

  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is HopModel && other.uuid == uuid);
  }

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
  double ibu(double? og, int? duration, double? volume, {double? maximum})  {
    return FormulaHelper.ibu(this.amount, this.alpha, og, this.duration, volume, maximum: maximum);
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

  static List<HopModel> merge(List<Quantity>? quantities, List<HopModel> hops) {
    List<HopModel> list = [];
    if (quantities != null && hops != null) {
      for (Quantity quantity in quantities) {
        for (HopModel hop in hops) {
          if (quantity.uuid == hop.uuid) {
            HopModel model = hop.copy();
            model.amount = quantity.amount;
            model.duration = quantity.duration;
            model.use = quantity.use != null
                ? Use.values.elementAt(quantity.use!)
                : Use.boil;
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
        HopModel model = new HopModel();
        model.fromMap(data);
        values.add(model);
      }
    }
    return values;
  }
}
