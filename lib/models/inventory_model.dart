import 'package:bb/utils/database.dart';
import 'package:bb/utils/localized_text.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/models/model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';

class InventoryModel<T> extends Model {
  Status? status;
  Ingredient? type;
  dynamic? ingredient;
  double? amount;

  InventoryModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    bool? isEdited,
    bool? isSelected,
    this.status = Status.publied,
    this.type,
    this.ingredient,
    this.amount,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator, isEdited: isEdited, isSelected: isSelected);

  void fromMap(Map<String, dynamic> map) async {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.type = Ingredient.values.elementAt(map['type']);
    if (this.type != null) {
      switch (this.type) {
        case Ingredient.fermentable :
          this.ingredient = await Database().getFermentable(map['ingredient']);
          break;
        case Ingredient.hops :
          this.ingredient = await Database().getHop(map['ingredient']);
          break;
        case Ingredient.yeast :
          this.ingredient = await Database().getYeast(map['ingredient']);
          break;
        case Ingredient.misc :
          this.ingredient = await Database().getMisc(map['ingredient']);
          break;
      }
    }
    if (map['amount'] != null) this.amount = map['amount'].toDouble();
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'type': this.type,
      'ingredient': this.ingredient != null ? this.ingredient!.uuid : null,
      'amount': this.amount,
    });
    return map;
  }

  InventoryModel copy() {
    return InventoryModel(
      uuid: this.uuid,
      inserted_at: this.inserted_at,
      updated_at: this.updated_at,
      creator: this.creator,
      status: this.status,
      type: this.type,
      ingredient: this.ingredient,
      amount: this.amount,
    );
  }

  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is InventoryModel && other.uuid == uuid);
  }

  @override
  String toString() {
    return 'InventoryModel: $ingredient, UUID: $uuid';
  }

  static dynamic serialize(dynamic data) {
    if (data != null) {
      if (data is InventoryModel) {
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

  static List<InventoryModel> deserialize(dynamic data) {
    List<InventoryModel> values = [];
    if (data != null) {
      if (data is List) {
        for(final value in data) {
          values.addAll(deserialize(value));
        }
      } else {
        InventoryModel model = new InventoryModel();
        model.fromMap(data);
        values.add(model);
      }
    }
    return values;
  }
}
