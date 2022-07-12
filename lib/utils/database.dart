import 'package:flutter/widgets.dart';

// Internal package
import 'package:bb/models/beer_model.dart';
import 'package:bb/models/company_model.dart';
import 'package:bb/models/event_model.dart';
import 'package:bb/models/model.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/models/style_model.dart';
import 'package:bb/models/user_model.dart';
import 'package:bb/helpers/class_helper.dart';
import 'package:bb/utils/constants.dart';

// External package
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Database {
  static final firestore = FirebaseFirestore.instance;

  final beers = firestore.collection("beers");
  final companies = firestore.collection("companies");
  final events = firestore.collection("events");
  final receipts = firestore.collection("receipts");
  final styles = firestore.collection("styles");
  final users = firestore.collection("users");

  // Authentification
  final _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>? getTableName(dynamic o) {
    if (o is BeerModel) {
      return beers;
    } else if (o is CompanyModel) {
      return companies;
    } else if (o is EventModel) {
      return events;
    } else if (o is ReceiptModel) {
      return receipts;
    } else if (o is StyleModel) {
      return styles;
    } else if (o is UserModel) {
      return users;
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

  Future<bool> set(String id, dynamic d) async {
    try {
      if (d is Model && _auth.currentUser != null) {
        d.creator = _auth.currentUser!.email;
      }
      await getTableName(d)!.doc(id).set(d.toMap())
      .then((value) {
        return true;
      })
      .catchError((error) {
        return true;
      });
    }
    catch (e, s) {
      debugPrint(s.toString());
      throw e;
    }
    return false;
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
      debugPrint('update ${d.toMap()}');
      await getTableName(d)!.doc(d.uuid).update(d.toMap());
    }
    catch (e, s) {
      debugPrint(s.toString());
      throw e;
    }
  }

  Future<void> publishAll() async {
    await publish(events);
    await publish(receipts);
    await publish(styles);
  }

  Future<void> publish(CollectionReference collection, {bool push = false}) async {
    Query query = collection.where('status', isEqualTo: Status.pending.index);
    await query.get().then((result) async {
      result.docs.forEach((doc) {
        bool canBeUpdated = true;
        Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
        if (_auth.currentUser != null) {
          String? creator = map['creator'];
          canBeUpdated = creator == null || _auth.currentUser!.email == map['creator'];
        }
        if (canBeUpdated) {
          collection.doc(doc.id).update({'status': Status.publied.index});
        }
      });
    });
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

  Future<List<EventModel>> getEvents({String? searchText, bool archived = false, bool all = false, bool ordered = true}) async {
    List<EventModel> list = [];
    Query query = events;
    if (all == false) {
      if (archived == true) {
        query = query.where('status', isEqualTo: Status.disabled.index);
      } else {
        query = query.where('status', isLessThanOrEqualTo: Status.publied.index);
      }
    }
    await query.get().then((result) {
      result.docs.forEach((doc) {
        bool canBeAdded = true;
        if (searchText != null && searchText.length > 0) {
          canBeAdded = false;
          String title = doc['title'].toString();
          String text = doc['text'].toString();
          if (title.toLowerCase().contains(searchText.toLowerCase()) ||
              text.toLowerCase().contains(searchText.toLowerCase())) {
            canBeAdded = true;
          }
        }
        if (canBeAdded) {
          EventModel model = EventModel();
          model.uuid = doc.id;
          model.fromMap(doc.data() as Map<String, dynamic>);
          list.add(model);
        }
      });
    });
    if (ordered == true) {
      list.sort((a, b) => a.title!.toLowerCase().compareTo(b.title!.toLowerCase()));
    }
    return list;
  }

  Future<List<ReceiptModel>> getReceipts({String? searchText, bool archived = false, bool all = false, bool ordered = true}) async {
    List<ReceiptModel> list = [];
    Query query = receipts;
    if (all == false) {
      if (archived == true) {
        query = query.where('status', isEqualTo: Status.disabled.index);
      } else {
        query = query.where('status', isLessThanOrEqualTo: Status.publied.index);
      }
    }
    await query.get().then((result) {
      result.docs.forEach((doc) {
        bool canBeAdded = true;
        if (searchText != null && searchText.length > 0) {
          canBeAdded = false;
          String title = doc['title'].toString();
          String text = doc['text'].toString();
          if (title.toLowerCase().contains(searchText.toLowerCase()) ||
              text.toLowerCase().contains(searchText.toLowerCase())) {
            canBeAdded = true;
          }
        }
        if (canBeAdded) {
          ReceiptModel model = ReceiptModel();
          model.uuid = doc.id;
          model.fromMap(doc.data() as Map<String, dynamic>);
          list.add(model);
        }
      });
    });
    if (ordered == true) {
      list.sort((a, b) => a.title!.toLowerCase().compareTo(b.title!.toLowerCase()));
    }
    return list;
  }


  Future<List<CompanyModel>> getCompanies({bool ordered = false}) async {
    List<CompanyModel> list = [];
    Query query = companies;
    query = query.orderBy('updated_at', descending: true);
    await query.get().then((result) {
      result.docs.forEach((doc) {
        CompanyModel model = CompanyModel();
        model.uuid = doc.id;
        model.fromMap(doc.data() as Map<String, dynamic>);
        list.add(model);
      });
    });
    if (ordered == true) {
      list.sort((a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()));
    }
    return list;
  }

  Future<List<StyleModel>> getStyles({bool ordered = false}) async {
    List<StyleModel> list = [];
    Query query = styles;
    query = query.orderBy('updated_at', descending: true);
    await query.get().then((result) {
      result.docs.forEach((doc) {
        StyleModel model = StyleModel();
        model.uuid = doc.id;
        model.fromMap(doc.data() as Map<String, dynamic>);
        list.add(model);
      });
    });
    if (ordered == true) {
      list.sort((a, b) => a.title!.toLowerCase().compareTo(b.title!.toLowerCase()));
    }
    return list;
  }

  Future<List<BeerModel>> getBeers({String? company, bool ordered = false}) async {
    List<BeerModel> list = [];
    Query query = beers;
    if (company != null) {
      query = query.where('company', isEqualTo: company);
    }
    query = query.orderBy('updated_at', descending: true);
    await query.get().then((result) {
      result.docs.forEach((doc) {
        BeerModel model = BeerModel();
        model.uuid = doc.id;
        model.fromMap(doc.data() as Map<String, dynamic>);
        list.add(model);
      });
    });
    if (ordered == true) {
      list.sort((a, b) => a.title!.toLowerCase().compareTo(b.title!.toLowerCase()));
    }
    return list;
  }
}
