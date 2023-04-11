import 'package:flutter/material.dart';

// Internal package
import 'package:bb/models/model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/localized_text.dart';
import 'package:bb/utils/quantity.dart';

// External package
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

enum Misc with Enums { spice, fining, water_agent, herb, flavor, other;
  List<Enum> get enums => [ spice, fining, water_agent, herb, flavor, other ];
}

enum Use with Enums { boil, mash, primary, secondary, bottling, sparge;
  List<Enum> get enums => [ boil, mash, primary, secondary, bottling, sparge ];
}

extension Ex on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

class MiscModel<T> extends Model {
  Status? status;
  dynamic? name;
  Misc? type;
  Use? use;
  int? time;
  double? amount;
  dynamic? notes;

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
    this.time,
    this.amount,
    this.notes,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator, isEdited: isEdited, isSelected: isSelected);

  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.name = LocalizedText.deserialize(map['name']);
    this.type = Misc.values.elementAt(map['type']);
    // if (map['use'] != null) this.use = MiscUse.values.elementAt(map['use']);
    // this.time = map['time'];
    this.notes = LocalizedText.deserialize(map['notes']);
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'name': LocalizedText.serialize(this.name),
      'type': this.type!.index,
      // 'use': this.use!.index,
      // 'time': this.time,
      // 'amount': this.amount,
      'notes': LocalizedText.serialize(this.notes),
    });
    return map;
  }

  MiscModel copy() {
    return MiscModel(
      uuid: this.uuid,
      inserted_at: this.inserted_at,
      updated_at: this.updated_at,
      creator: this.creator,
      status: this.status,
      name: this.name,
      type: this.type,
      use: this.use,
      time: this.time,
      amount: this.amount,
      notes: this.notes,
    );
  }

  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is MiscModel && other.uuid == uuid);
  }

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
    }
    return null;
  }

  static List<MiscModel> merge(List<Quantity>? quantities, List<MiscModel> miscellaneous) {
    List<MiscModel> list = [];
    if (quantities != null && miscellaneous != null) {
      for (Quantity quantity in quantities) {
        for (MiscModel misc in miscellaneous) {
          if (quantity.uuid == misc.uuid) {
            MiscModel model = misc.copy();
            model.amount = quantity.amount;
            model.time = quantity.duration;
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
        MiscModel model = new MiscModel();
        model.fromMap(data);
        values.add(model);
      }
    }
    return values;
  }
}