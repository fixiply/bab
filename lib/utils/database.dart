import 'package:bb/models/class_helper.dart';
import 'package:bb/models/model.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/utils/constants.dart';
import 'package:flutter/widgets.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bb/models/user_model.dart';

class Database {
  static final firestore = FirebaseFirestore.instance;

  final receipts = firestore.collection("receipts");
  final users = firestore.collection("users");

  // Authentification
  final _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>? getTableName(dynamic o) {
    if (o is ReceiptModel) {
      return receipts;
    }
    return null;
  }

  Future<String> add(dynamic d) async {
    try {
      if (d is Model && _auth.currentUser != null) {
        d.creator = _auth.currentUser!.email;
      }
      DocumentReference document = await getTableName(d)!.add(d.toMap());
      d.uuid = document.id;
    }
    catch (e, s) {
      debugPrint(s.toString());
      throw e;
    }

    return d.uuid;
  }

  //Returns document iD if the record is created, null is updated.
  Future<String?> update(dynamic d, {bool updateAll = true}) async {
    if (d.uuid == null) {
      return add(d);
    }
    try {
      if (updateAll == true) {
        if (ClassHelper.hasStatus(d) && d.status == Status.disabled) {
          d.status = Status.pending;
        }
        if (d is Model && _auth.currentUser != null) {
          d.creator = _auth.currentUser!.email;
        }
      }
      await getTableName(d)!.doc(d.uuid).update(d.toMap());
    }
    catch (e, s) {
      debugPrint(s.toString());
      throw e;
    }
  }

  Future<void> delete(dynamic d, {bool forced = false}) async {
    try {
      if (forced == true || (ClassHelper.hasStatus(d) && d.status == Status.disabled)) {
        return await getTableName(d)!.doc(d.uuid).delete();
      } else {
        if (ClassHelper.hasStatus(d)) {
          d.status = Status.disabled;
        }
        await getTableName(d)!.doc(d.uuid).update(d.toMap());
      }
    }
    catch (e, s) {
      debugPrint(s.toString());
      throw e;
    }
  }

  Future<UserModel?> getUser(String uuid) async {
    DocumentSnapshot snapshot = await users.doc(uuid).get();
    if (snapshot.exists) {
      UserModel model = UserModel();
      model.uuid = snapshot.id;
      model.fromMap(snapshot.data() as Map<String, dynamic>);
      return model;
    }
    return null;
  }

  Future<List<ReceiptModel>> getReceipts() async {
    List<ReceiptModel> list = [];
    return list;
  }
}
