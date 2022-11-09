// Internal package
import 'package:bb/models/adress_model.dart';
import 'package:bb/models/payment_model.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/helpers/date_helper.dart';

// External package
import 'package:firebase_auth/firebase_auth.dart';

class UserModel<T> {
  String? uuid;
  DateTime? inserted_at;
  DateTime? updated_at;
  String? full_name;
  String? email;
  User? user;
  Roles? role;
  String? company;
  List<AdressModel>? addresses;
  List<PaymentModel>? payments;

  UserModel({
    this.uuid,
    this.inserted_at,
    this.updated_at,
    this.full_name,
    this.email,
    this.user,
    this.role = Roles.customer,
    this.company,
    this.addresses,
    this.payments
  }) {
    if(inserted_at == null) { inserted_at = DateTime.now(); }
    if (addresses == null) { addresses = []; }
    if (payments == null) { payments = []; }
  }

  bool isAdmin() {
    return role != null && role == Roles.admin;
  }

  bool isEditor() {
    return role != null && role == Roles.editor;
  }

  bool hasRole() {
    return role != null && (role == Roles.editor || role == Roles.admin);
  }

  void fromMap(Map<String, dynamic> map) {
    if (map.containsKey('uuid')) this.uuid = map['uuid'];
    this.inserted_at = DateHelper.parse(map['inserted_at']);
    this.updated_at = DateHelper.parse(map['updated_at']);
    this.full_name = map['full_name'];
    this.email = map['email'];
    this.role = Roles.values.elementAt(map['role']);
    this.company = map['company'];
    this.addresses = AdressModel.deserialize(map['addresses']);
    this.payments = PaymentModel.deserialize(map['payments']);
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = {
      'inserted_at': this.inserted_at!.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'full_name': this.full_name,
      'email': this.email,
      'role': this.role!.index,
      'company': company,
      'addresses': AdressModel.serialize(this.addresses),
      'payments': PaymentModel.serialize(this.payments),
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
      full_name: this.full_name,
      email: this.email,
      user: this.user,
      role: this.role,
      addresses: this.addresses,
      payments: this.payments,
    );
  }

  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is UserModel && other.uuid == uuid);
  }

  @override
  String toString() {
    return 'Role: $role, UUID: $uuid';
  }
}
