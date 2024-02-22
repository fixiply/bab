// Internal package
import 'package:bab/helpers/date_helper.dart';

class SubscriptionModel<T> {
  String? uuid;
  DateTime? inserted_at;
  DateTime? updated_at;
  String? transaction;
  DateTime? started_at;
  DateTime? ended_at;

  SubscriptionModel({
    this.uuid,
    this.inserted_at,
    this.updated_at,
    this.transaction,
    this.started_at,
    this.ended_at,
  }) {
    inserted_at ??= DateTime.now();
  }

  void fromMap(Map<String, dynamic> map) {
    if (map.containsKey('uuid')) this.uuid = map['uuid'];
    this.inserted_at = DateHelper.parse(map['inserted_at']);
    this.updated_at = DateHelper.parse(map['updated_at']);
    this.transaction = map['transaction'];
    this.started_at = DateHelper.parse(map['inserted_at']);
    this.ended_at = DateHelper.parse(map['ended_at']);
  }

  Map<String, dynamic> toMap({bool persist = false}) {
    Map<String, dynamic> map = {
      'inserted_at': this.inserted_at,
      'updated_at': DateTime.now(),
      'transaction': this.transaction,
      'started_at': this.started_at,
      'ended_at': this.ended_at,
    };
    if (persist == true) {
      map.addAll({'uuid': this.uuid});
    }
    return map;
  }

  SubscriptionModel copy() {
    return SubscriptionModel(
      uuid: this.uuid,
      inserted_at: this.inserted_at,
      updated_at: this.updated_at,
      transaction: this.transaction,
      started_at: this.started_at,
      ended_at: this.ended_at,
    );
  }

  // ignore: hash_and_equals
  @override
  bool operator ==(other) {
    return (other is SubscriptionModel && other.uuid == uuid);
  }

  @override
  int get hashCode => uuid.hashCode;

  @override
  String toString() {
    return 'Subscription: $transaction, UUID: $uuid';
  }

  bool isValid(DateTime date) {
    return DateHelper.isBetween(started_at, ended_at ?? date);
  }

  static dynamic serialize(dynamic data) {
    if (data != null) {
      if (data is SubscriptionModel) {
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

  static List<SubscriptionModel> deserialize(dynamic data) {
    List<SubscriptionModel> values = [];
    if (data != null) {
      if (data is List) {
        for(final value in data) {
          values.addAll(deserialize(value));
        }
      } else {
        SubscriptionModel model = SubscriptionModel();
        model.fromMap(data);
        values.add(model);
      }
    }
    return values;
  }
}
