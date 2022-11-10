// Internal package
import 'package:bb/models/model.dart';
import 'package:bb/utils/constants.dart';

class IngredientModel<T> extends Model {
  Status? status;
  Ingredient? ingredient;
  String? name;
  double? amount;
  Unit? unit;
  String? comment;

  IngredientModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    this.status = Status.pending,
    this.ingredient,
    this.unit,
    this.name,
    this.amount,
    this.comment,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator);

  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.ingredient = Ingredient.values.elementAt(map['ingredient']);
    this.unit = Unit.values.elementAt(map['unit']);
    if (map['amount'] != null) this.amount = map['amount'].toDouble();
    this.name = map['name'];
    this.comment = map['comment'];
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'ingredient': this.ingredient!.index,
      'unit': this.unit!.index,
      'name': this.name,
      'amount': this.amount,
      'comment': this.comment,
    });
    return map;
  }

  IngredientModel copy() {
    return IngredientModel(
      uuid: this.uuid,
      inserted_at: this.inserted_at,
      updated_at: this.updated_at,
      creator: this.creator,
      status: this.status,
      ingredient: this.ingredient,
      unit: this.unit,
      name: this.name,
      amount: this.amount,
      comment: this.comment,
    );
  }

  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is IngredientModel && other.uuid == uuid);
  }

  @override
  String toString() {
    return 'Ingredient: $name, UUID: $uuid';
  }

  static dynamic serialize(dynamic data) {
    if (data != null) {
      if (data is IngredientModel) {
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

  static List<IngredientModel> deserialize(dynamic data) {
    List<IngredientModel> values = [];
    if (data != null) {
      if (data is List) {
        for(final value in data) {
          values.addAll(deserialize(value));
        }
      } else {
        IngredientModel model = new IngredientModel();
        model.fromMap(data);
        values.add(model);
      }
    }
    return values;
  }
}
