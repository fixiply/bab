import 'package:firebase_auth/firebase_auth.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/date_helper.dart';

class UserModel<T> {
  String? uuid;
  DateTime? inserted_at;
  DateTime? updated_at;
  User? user;
  Roles? role;

  UserModel({
    this.uuid,
    this.inserted_at,
    this.updated_at,
    this.user,
    this.role = Roles.editor,
  }) {
    if(inserted_at == null) { inserted_at = DateTime.now(); }
  }

  bool isAdmin() {
    return role != null && role == Roles.admin;
  }

  bool isEditor() {
    return role != null && (role == Roles.editor || role == Roles.admin);
  }

  void fromMap(Map<String, dynamic> map) {
    if (map.containsKey('uuid')) this.uuid = map['uuid'];
    this.inserted_at = DateHelper.parse(map['inserted_at']);
    this.updated_at = DateHelper.parse(map['updated_at']);
    this.role = Roles.values.elementAt(map['role']);
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = {
      'inserted_at': this.inserted_at!.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'role': this.role!.index,
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
      user: this.user,
      role: this.role,
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
