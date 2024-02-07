// Internal package
import 'package:bab/helpers/date_helper.dart';

class Adress<T> {
  String? uuid;
  DateTime? inserted_at;
  DateTime? updated_at;
  String? name;
  String? address;
  int? zip;
  String? city;
  String? information;
  String? phone;

  Adress({
    this.uuid,
    this.inserted_at,
    this.updated_at,
    this.name,
    this.address,
    this.zip,
    this.city,
    this.information,
    this.phone,
  }) {
    inserted_at ??= DateTime.now();
  }

  void fromMap(Map<String, dynamic> map) {
    if (map.containsKey('uuid')) this.uuid = map['uuid'];
    this.inserted_at = DateHelper.parse(map['inserted_at']);
    this.updated_at = DateHelper.parse(map['updated_at']);
    this.name = map['name'];
    this.address = map['street'];
    this.zip = map['zip'];
    this.city = map['city'];
    this.information = map['information'];
    this.phone = map['phone'];
  }

  Map<String, dynamic> toMap({bool persist = false}) {
    Map<String, dynamic> map = {
      'inserted_at': this.inserted_at,
      'updated_at': DateTime.now(),
      'name': this.name,
      'street': this.address,
      'zip': this.zip,
      'city': this.city,
      'information': this.information,
      'phone': this.phone,
    };
    if (persist == true) {
      map.addAll({'uuid': this.uuid});
    }
    return map;
  }

  Adress copy() {
    return Adress(
      uuid: this.uuid,
      inserted_at: this.inserted_at,
      updated_at: this.updated_at,
      name: this.name,
      address: this.address,
      zip: this.zip,
      city: this.city,
      information: this.information,
      phone: this.phone,
    );
  }

  // ignore: hash_and_equals
  @override
  bool operator ==(other) {
    return (other is Adress && other.uuid == uuid);
  }

  @override
  int get hashCode => uuid.hashCode;

  @override
  String toString() {
    return 'Adress: $name, UUID: $uuid';
  }

  static dynamic serialize(dynamic data) {
    if (data != null) {
      if (data is Adress) {
        return data.toMap(persist: true);
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

  static List<Adress> deserialize(dynamic data) {
    List<Adress> values = [];
    if (data != null) {
      if (data is List) {
        for(final value in data) {
          values.addAll(deserialize(value));
        }
      } else {
        Adress model = Adress();
        model.fromMap(data);
        values.add(model);
      }
    }
    return values;
  }
}
