// Internal package
import 'package:bab/helpers/date_helper.dart';

class PaymentModel<T> {
  String? uuid;
  DateTime? inserted_at;
  DateTime? updated_at;
  String? name;
  int? number;
  String? date;
  int? security;
  String? address;
  int? zip;
  String? city;

  PaymentModel({
    this.uuid,
    this.inserted_at,
    this.updated_at,
    this.name,
    this.number,
    this.date,
    this.security,
    this.address,
    this.zip,
    this.city,
  }) {
    inserted_at ??= DateTime.now();
  }

  void fromMap(Map<String, dynamic> map) {
    if (map.containsKey('uuid')) this.uuid = map['uuid'];
    this.inserted_at = DateHelper.parse(map['inserted_at']);
    this.updated_at = DateHelper.parse(map['updated_at']);
    this.name = map['name'];
    this.number = map['number'];
    this.date = map['date'];
    this.security = map['code'];
    this.address = map['address'];
    this.zip = map['zip'];
    this.city = map['city'];
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = {
      'inserted_at': this.inserted_at,
      'updated_at': DateTime.now(),
      'name': this.name,
      'number': this.number,
      'date': this.date,
      'code': this.security,
      'address': this.address,
      'zip': this.zip,
      'city': this.city,
    };
    if (persist == true) {
      map.addAll({'uuid': this.uuid});
    }
    return map;
  }

  PaymentModel copy() {
    return PaymentModel(
      uuid: this.uuid,
      inserted_at: this.inserted_at,
      updated_at: this.updated_at,
      name: this.name,
      number: this.number,
      date: this.date,
      security: this.security,
      address: this.address,
      zip: this.zip,
      city: this.city,
    );
  }

  // ignore: hash_and_equals
  @override
  bool operator ==(other) {
    return (other is PaymentModel && other.uuid == uuid);
  }

  @override
  int get hashCode => uuid.hashCode;

  @override
  String toString() {
    return 'Payment: $name, UUID: $uuid';
  }

  static dynamic serialize(dynamic data) {
    if (data != null) {
      if (data is PaymentModel) {
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

  static List<PaymentModel> deserialize(dynamic data) {
    List<PaymentModel> values = [];
    if (data != null) {
      if (data is List) {
        for(final value in data) {
          values.addAll(deserialize(value));
        }
      } else {
        PaymentModel model = PaymentModel();
        model.fromMap(data);
        values.add(model);
      }
    }
    return values;
  }
}
