// Internal package
import 'package:bb/utils/adress.dart';
import 'package:bb/models/payment_model.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/helpers/date_helper.dart';

// External package
import 'package:firebase_auth/firebase_auth.dart';

class UserModel<T> {
  String? uuid;
  DateTime? inserted_at;
  DateTime? updated_at;
  bool? verified;
  String? full_name;
  String? email;
  User? user;
  Role? role;
  String? company;
  List<Adress>? addresses;
  List<PaymentModel>? payments;

  UserModel({
    this.uuid,
    this.inserted_at,
    this.updated_at,
    this.verified = false,
    this.full_name,
    this.email,
    this.user,
    this.role = Role.editor,
    this.company,
    this.addresses,
    this.payments
  }) {
    if(inserted_at == null) { inserted_at = DateTime.now(); }
    if (addresses == null) { addresses = []; }
    if (payments == null) { payments = []; }
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
    this.verified = map['verified'];
    this.full_name = map['full_name'];
    this.email = map['email'];
    this.role = Role.values.elementAt(map['role']);
    this.company = map['company'];
    this.addresses = Adress.deserialize(map['addresses']);
    this.payments = PaymentModel.deserialize(map['payments']);
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = {
      'inserted_at': this.inserted_at!.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'verified': this.verified,
      'full_name': this.full_name,
      'email': this.email,
      'role': this.role!.index,
      'company': company,
      'addresses': Adress.serialize(this.addresses),
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
      verified: this.verified,
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
    return 'User: $role, UUID: $uuid';
  }
}
