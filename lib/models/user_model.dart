// Internal package
import 'package:bab/utils/adress.dart';
import 'package:bab/models/subscription_model.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/helpers/date_helper.dart';
import 'package:bab/utils/device.dart';

// External package
import 'package:firebase_auth/firebase_auth.dart';

class UserModel<T> {
  String? uuid;
  DateTime? inserted_at;
  DateTime? updated_at;
  Role? role;
  String? company;
  String? language;
  List<Adress>? addresses;
  List<SubscriptionModel>? subscriptions;
  List<Device>? devices;
  String? openAI_api_key;

  UserModel({
    this.uuid,
    this.inserted_at,
    this.updated_at,
    this.role = Role.editor,
    this.company,
    this.language,
    this.addresses,
    this.subscriptions,
    this.devices,
    this.openAI_api_key
  }) {
    inserted_at ??= DateTime.now();
    addresses ??= [];
    subscriptions ??= [];
    devices ??= [];
  }

  bool isAdmin() {
    return role != null && role == Role.admin;
  }

  bool isEditor() {
    return role != null && role == Role.editor;
  }

  bool hasRole() {
    return role != null && (role == Role.editor || role == Role.admin);
  }

  void fromMap(Map<String, dynamic> map) {
    if (map.containsKey('uuid')) this.uuid = map['uuid'];
    this.inserted_at = DateHelper.parse(map['inserted_at']);
    this.updated_at = DateHelper.parse(map['updated_at']);
    this.role = Role.values.elementAt(map['role']);
    this.company = map['company'];
    this.language = map['language'];
    this.addresses = Adress.deserialize(map['addresses']);
    this.subscriptions = SubscriptionModel.deserialize(map['subscriptions']);
    this.devices = Device.deserialize(map['devices']);
    this.openAI_api_key = map['openAI_api_key'];
  }

  Map<String, dynamic> toMap({bool persist = false}) {
    Map<String, dynamic> map = {
      'inserted_at': this.inserted_at,
      'updated_at': DateTime.now(),
      'role': this.role!.index,
      'company': company,
      'language': language,
      'addresses': Adress.serialize(this.addresses),
      'subscriptions': SubscriptionModel.serialize(this.subscriptions),
      'devices': Device.serialize(this.devices),
      'openAI_api_key': this.openAI_api_key,
    };
    if (persist == true) {
      map.addAll({'uuid': this.uuid});
    }
    return map;
  }

  UserModel copy() {
    return UserModel(
      uuid: this.uuid,
      inserted_at: this.inserted_at,
      updated_at: this.updated_at,
      role: this.role,
      company: this.company,
      language: this.language,
      addresses: this.addresses,
      subscriptions: this.subscriptions,
      devices: this.devices,
      openAI_api_key: this.openAI_api_key,
    );
  }

  // ignore: hash_and_equals
  @override
  bool operator ==(other) {
    return (other is UserModel && other.uuid == uuid);
  }

  @override
  int get hashCode => uuid.hashCode;

  @override
  String toString() {
    return 'User: $role, UUID: $uuid';
  }

  bool isSubscribed() {
    final now = DateTime.now();
    for(SubscriptionModel subscription in subscriptions!) {
      if (subscription.isValid(now)) {
        return true;
      }
    }
    return false;
  }
}
