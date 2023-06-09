// Internal package
import 'package:bab/utils/constants.dart';

class Quantity<T> {
  String? uuid;
  double? amount;
  Unit? unit;
  int? duration;
  int? use;

  Quantity({
    this.uuid,
    this.amount,
    this.unit = Unit.units,
    this.duration,
    this.use,
  });

  void fromMap(Map<String, dynamic> map) {
    this.uuid = map['uuid'];
    if (map['amount'] != null) this.amount = map['amount'].toDouble();
    if (map.containsKey('unit')) this.unit = Unit.values.elementAt(map['unit']);
    this.duration = map['duration'];
    this.use = map['use'];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'uuid': this.uuid,
      'amount': this.amount,
      'unit': this.unit!.index,
      'duration': this.duration,
      'use': this.use,
    };
    return map;
  }

  Quantity copy() {
    return Quantity(
      uuid: this.uuid,
      amount: this.amount,
      unit: this.unit,
      duration: this.duration,
      use: this.use,
    );
  }

  // ignore: hash_and_equals
  @override
  bool operator ==(other) {
    return (other is Quantity && other.uuid == uuid || other is String && other == uuid);
  }

  int get hashCode => uuid.hashCode;

  @override
  String toString() {
    return 'Quantity: $uuid';
  }

  static dynamic serialize(dynamic data) {
    if (data != null) {
      if (data is Quantity) {
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

  static List<Quantity> deserialize(dynamic data) {
    List<Quantity> values = [];
    if (data != null) {
      if (data is List) {
        for(final value in data) {
          values.addAll(deserialize(value));
        }
      } else {
        Quantity model = Quantity();
        model.fromMap(data);
        values.add(model);
      }
    }
    return values;
  }
}
