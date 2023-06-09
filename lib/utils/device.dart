// Internal package
import 'package:bab/helpers/date_helper.dart';
import 'package:bab/utils/localized_text.dart';

class Device<T> {
  DateTime? inserted_at;
  String? name;
  String? token;
  String? os;

  Device({
    this.inserted_at,
    this.name,
    this.token,
    this.os,
  }) {
    inserted_at ??= DateTime.now();
  }

  void fromMap(Map<String, dynamic> map) {
    this.inserted_at = DateHelper.parse(map['inserted_at']);
    this.name = map['name'];
    this.token = map['token'];
    this.os = map['os'];
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = {
      'inserted_at': this.inserted_at,
      'name': this.name,
      'token': this.token,
      'os': this.os,
    };
    return map;
  }

  Device copy() {
    return Device(
      inserted_at: this.inserted_at,
      name: this.name,
      token: this.token,
      os: this.os
    );
  }

  // ignore: hash_and_equals
  @override
  bool operator ==(other) {
    return (other is Device && other.token == token);
  }

  @override
  int get hashCode => token.hashCode;


  @override
  String toString() {
    return 'Device: $token';
  }

  static dynamic serialize(dynamic data) {
    if (data != null) {
      if (data is Device) {
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

  static List<Device> deserialize(dynamic data) {
    List<Device> values = [];
    if (data != null) {
      if (data is List) {
        for(final value in data) {
          values.addAll(deserialize(value));
        }
      } else {
        Device model = Device();
        model.fromMap(data);
        values.add(model);
      }
    }
    return values;
  }
}
