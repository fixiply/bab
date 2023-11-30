// Internal package
import 'package:bab/utils/constants.dart';
import 'package:flutter/material.dart';

class Quantity<T> {
  String? uuid;
  double? amount;
  Measurement? measurement;
  int? duration;
  int? use;

  Quantity({
    this.uuid,
    this.amount,
    this.measurement = Measurement.units,
    this.duration,
    this.use,
  });

  void fromMap(Map<String, dynamic> map) {
    this.uuid = map['uuid'];
    if (map['amount'] != null) this.amount = map['amount'].toDouble();
    if (map.containsKey('measurement')) this.measurement = Measurement.values.elementAt(map['measurement']);
    else if (map.containsKey('unit')) this.measurement = Measurement.values.elementAt(map['unit']);
    this.duration = map['duration'];
    if (map.containsKey('use')) this.use = map['use'];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'uuid': this.uuid,
      'amount': this.amount,
      'measurement': this.measurement!.index,
      'duration': this.duration,
      'use': this.use,
    };
    return map;
  }

  Quantity copy() {
    return Quantity(
      uuid: this.uuid,
      amount: this.amount,
      measurement: this.measurement,
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
