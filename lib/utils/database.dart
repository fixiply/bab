import 'package:flutter/widgets.dart';

// Internal package
import 'package:bb/helpers/class_helper.dart';
import 'package:bb/models/basket_model.dart';
import 'package:bb/models/company_model.dart';
import 'package:bb/models/equipment_model.dart';
import 'package:bb/models/event_model.dart';
import 'package:bb/models/fermentable_model.dart';
import 'package:bb/models/hop_model.dart';
import 'package:bb/models/inventory_model.dart';
import 'package:bb/models/miscellaneous_model.dart';
import 'package:bb/models/model.dart';
import 'package:bb/models/product_model.dart';
import 'package:bb/models/purchase_model.dart';
import 'package:bb/models/rating_model.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/models/style_model.dart';
import 'package:bb/models/user_model.dart';
import 'package:bb/models/yeast_model.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/quantity.dart';

// External package
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Database {
  static final firestore = FirebaseFirestore.instance;

  final baskets = firestore.collection("baskets");
  final companies = firestore.collection("companies");
  final equipment = firestore.collection("equipment");
  final events = firestore.collection("events");
  final fermentables = firestore.collection("fermentables");
  final hops = firestore.collection("hops");
  final inventory = firestore.collection("inventory");
  final miscellaneous = firestore.collection("miscellaneous");
  final products = firestore.collection("products");
  final purchases = firestore.collection("purchases");
  final ratings = firestore.collection("ratings");
  final receipts = firestore.collection("receipts");
  final styles = firestore.collection("styles");
  final users = firestore.collection("users");
  final yeasts = firestore.collection("yeasts");

  // Authentification
  final _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>? getTableName(dynamic o) {
    if (o is BasketModel) {
      return baskets;
    } else if (o is CompanyModel) {
      return companies;
    } else if (o is EquipmentModel) {
      return equipment;
    } else if (o is EventModel) {
      return events;
    } else if (o is FermentableModel) {
      return fermentables;
    } else if (o is HopModel) {
      return hops;
    } else if (o is InventoryModel) {
      return inventory;
    } else if (o is MiscellaneousModel) {
      return miscellaneous;
    } else if (o is ProductModel) {
      return products;
    } else if (o is PurchaseModel) {
      return purchases;
    } else if (o is RatingModel) {
      return ratings;
    } else if (o is ReceiptModel) {
      return receipts;
    } else if (o is StyleModel) {
      return styles;
    } else if (o is UserModel) {
      return users;
    } else if (o is YeastModel) {
      return yeasts;
    }
    return null;
  }

  Future<void> copy(String from, String to) async {
    await firestore.collection(from).get().then((result) async {
      result.docs.forEach((doc) async {
        await firestore.collection(to).add(doc.data());
      });
    });
  }

  Future<String> add(dynamic d, {bool? ignoreAuth = false}) async {
    try {
      if (ignoreAuth == false && d is Model && _auth.currentUser != null) {
        d.creator = _auth.currentUser!.uid;
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

  Future<bool> set(String id, dynamic d, {bool? ignoreAuth = false}) async {
    try {
      if (ignoreAuth == false && d is Model && _auth.currentUser != null) {
        d.creator = _auth.currentUser!.uid;
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
          d.creator = _auth.currentUser!.uid;
        }
      }
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
          canBeUpdated = creator == null || _auth.currentUser!.uid == map['creator'];
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

  Future<ReceiptModel?> getReceipt(String uuid) async {
    DocumentSnapshot snapshot = await receipts.doc(uuid).get();
    if (snapshot.exists) {
      ReceiptModel model = ReceiptModel();
      model.uuid = snapshot.id;
      model.fromMap(snapshot.data() as Map<String, dynamic>);
      return model;
    }
    return null;
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
      list.sort((a, b) => a.title!.toString().toLowerCase().compareTo(b.title!.toString().toLowerCase()));
    }
    return list;
  }

  Future<CompanyModel?> getCompany(String uuid) async {
    DocumentSnapshot snapshot = await companies.doc(uuid).get();
    if (snapshot.exists) {
      CompanyModel model = CompanyModel();
      model.uuid = snapshot.id;
      model.fromMap(snapshot.data() as Map<String, dynamic>);
      return model;
    }
    return null;
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

  Future<StyleModel?> getStyle(String uuid) async {
    DocumentSnapshot snapshot = await styles.doc(uuid).get();
    if (snapshot.exists) {
      StyleModel model = StyleModel();
      model.uuid = snapshot.id;
      model.fromMap(snapshot.data() as Map<String, dynamic>);
      return model;
    }
    return null;
  }

  Future<List<StyleModel>> getStyles({List<Fermentation>? fermentations, bool ordered = false}) async {
    List<StyleModel> list = [];
    Query query = styles;
    query = query.orderBy('updated_at', descending: true);
    await query.get().then((result) {
      result.docs.forEach((doc) {
        bool canBeAdded = true;
        if (fermentations != null && fermentations.length > 0) {
          Fermentation fermentation = Fermentation.values.elementAt(doc['fermentation']);
          canBeAdded = fermentations.contains(fermentation);
        }
        if (canBeAdded) {
          StyleModel model = StyleModel();
          model.uuid = doc.id;
          model.fromMap(doc.data() as Map<String, dynamic>);
          list.add(model);
        }
      });
    });
    if (ordered == true) {
      list.sort((a, b) => a.name!.compareTo(b.name!));
    }
    return list;
  }

  Future<ProductModel?> getProduct(String uuid) async {
    DocumentSnapshot snapshot = await products.doc(uuid).get();
    if (snapshot.exists) {
      ProductModel model = ProductModel();
      model.uuid = snapshot.id;
      model.fromMap(snapshot.data() as Map<String, dynamic>);
      return model;
    }
    return null;
  }

  Future<List<ProductModel>> getProducts({Product? product, String? company, String? receipt, bool ordered = false}) async {
    List<ProductModel> list = [];
    Query query = products;
    if (product != null) {
      query = query.where('product', isEqualTo: product.index);
    }
    if (company != null) {
      query = query.where('company', isEqualTo: company);
    }
    if (receipt != null) {
      query = query.where('receipt', isEqualTo: receipt);
    }
    query = query.orderBy('updated_at', descending: true);
    await query.get().then((result) {
      result.docs.forEach((doc) {
        ProductModel model = ProductModel();
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

  Future<List<RatingModel>> getRatings({String? beer, bool ordered = false}) async {
    List<RatingModel> list = [];
    Query query = ratings;
    if (beer != null) {
      query = query.where('beer', isEqualTo: beer);
    }
    query = query.orderBy('updated_at', descending: true);
    await query.get().then((result) {
      result.docs.forEach((doc) {
        RatingModel model = RatingModel();
        model.uuid = doc.id;
        model.fromMap(doc.data() as Map<String, dynamic>);
        list.add(model);
      });
    });
    return list;
  }

  Future<List<PurchaseModel>> getPurchases({String? user, bool ordered = false}) async {
    List<PurchaseModel> list = [];
    Query query = purchases;
    if (user != null) {
      query = query.where('creator', isEqualTo: user);
    }
    query = query.orderBy('updated_at', descending: true);
    await query.get().then((result) {
      result.docs.forEach((doc) {
        PurchaseModel model = PurchaseModel();
        model.uuid = doc.id;
        model.fromMap(doc.data() as Map<String, dynamic>);
        list.add(model);
      });
    });
    return list;
  }

  Future<FermentableModel?> getFermentable(String uuid) async {
    DocumentSnapshot snapshot = await fermentables.doc(uuid).get();
    if (snapshot.exists) {
      FermentableModel model = FermentableModel();
      model.uuid = snapshot.id;
      model.fromMap(snapshot.data() as Map<String, dynamic>);
      return model;
    }
    return null;
  }

  Future<List<FermentableModel>> getFermentables({List<Quantity>? quantities, String? name, String? searchText, bool ordered = false}) async {
    List<FermentableModel> list = [];
    Query query = fermentables;
    if (name != null) {
      query = query.where('name', isEqualTo: name);
    }
    query = query.orderBy('updated_at', descending: true);
    await query.get().then((result) {
      result.docs.forEach((doc) {
        bool canBeAdded = true;
        if (quantities != null) {
          canBeAdded = quantities.contains(doc.id);
        }
        if (searchText != null && searchText.length > 0) {
          canBeAdded = false;
          String name = doc['name'].toString();
          if (name.toLowerCase().contains(searchText.toLowerCase())) {
            canBeAdded = true;
          }
        }
        if (canBeAdded) {
          FermentableModel model = FermentableModel();
          model.uuid = doc.id;
          model.fromMap(doc.data() as Map<String, dynamic>);
          model.merge(quantities);
          list.add(model);
        }
      });
    });
    if (ordered == true) {
      list.sort((a, b) => a.name!.toString().toLowerCase().compareTo(b.name!.toString().toLowerCase()));
    }
    return list;
  }

  Future<HopModel?> getHop(String uuid) async {
    DocumentSnapshot snapshot = await hops.doc(uuid).get();
    if (snapshot.exists) {
      HopModel model = HopModel();
      model.uuid = snapshot.id;
      model.fromMap(snapshot.data() as Map<String, dynamic>);
      return model;
    }
    return null;
  }

  Future<List<HopModel>> getHops({List<Quantity>? quantities, String? name, String? searchText, bool ordered = false}) async {
    List<HopModel> list = [];
    Query query = hops;
    if (name != null) {
      query = query.where('name', isEqualTo: name);
    }
    query = query.orderBy('updated_at', descending: true);
    await query.get().then((result) {
      result.docs.forEach((doc) {
        bool canBeAdded = true;
        if (quantities != null) {
          canBeAdded = quantities.contains(doc.id);
        }
        if (searchText != null && searchText.length > 0) {
          canBeAdded = false;
          String name = doc['name'].toString();
          if (name.toLowerCase().contains(searchText.toLowerCase())) {
            canBeAdded = true;
          }
        }
        if (canBeAdded) {
          HopModel model = HopModel();
          model.uuid = doc.id;
          model.fromMap(doc.data() as Map<String, dynamic>);
          model.merge(quantities);
          list.add(model);
        }
      });
    });
    if (ordered == true) {
      list.sort((a, b) => a.name!.toString().toLowerCase().compareTo(b.name!.toString().toLowerCase()));
    }
    return list;
  }

  Future<MiscellaneousModel?> getMisc(String uuid) async {
    DocumentSnapshot snapshot = await miscellaneous.doc(uuid).get();
    if (snapshot.exists) {
      MiscellaneousModel model = MiscellaneousModel();
      model.uuid = snapshot.id;
      model.fromMap(snapshot.data() as Map<String, dynamic>);
      return model;
    }
    return null;
  }

  Future<List<MiscellaneousModel>> getMiscellaneous({List<Quantity>? quantities, String? name, String? searchText, bool ordered = false}) async {
    List<MiscellaneousModel> list = [];
    Query query = miscellaneous;
    if (name != null) {
      query = query.where('name', isEqualTo: name);
    }
    query = query.orderBy('updated_at', descending: true);
    await query.get().then((result) {
      result.docs.forEach((doc) {
        bool canBeAdded = true;
        if (quantities != null) {
          canBeAdded = quantities.contains(doc.id);
        }
        if (searchText != null && searchText.length > 0) {
          canBeAdded = false;
          String name = doc['name'].toString();
          if (name.toLowerCase().contains(searchText.toLowerCase())) {
            canBeAdded = true;
          }
        }
        if (canBeAdded) {
          MiscellaneousModel model = MiscellaneousModel();
          model.uuid = doc.id;
          model.fromMap(doc.data() as Map<String, dynamic>);
          model.merge(quantities);
          list.add(model);
        }
      });
    });
    if (ordered == true) {
      list.sort((a, b) => a.name!.toString().toLowerCase().compareTo(b.name!.toString().toLowerCase()));
    }
    return list;
  }

  Future<YeastModel?> getYeast(String uuid) async {
    DocumentSnapshot snapshot = await yeasts.doc(uuid).get();
    if (snapshot.exists) {
      YeastModel model = YeastModel();
      model.uuid = snapshot.id;
      model.fromMap(snapshot.data() as Map<String, dynamic>);
      return model;
    }
    return null;
  }

  Future<List<YeastModel>> getYeasts({List<Quantity>? quantities, String? name, String? searchText, bool ordered = false}) async {
    List<YeastModel> list = [];
    Query query = yeasts;
    if (name != null) {
      query = query.where('name', isEqualTo: name);
    }
    query = query.orderBy('updated_at', descending: true);
    await query.get().then((result) {
      result.docs.forEach((doc) {
        bool canBeAdded = true;
        if (quantities != null) {
          canBeAdded = quantities.contains(doc.id);
        }
        if (searchText != null && searchText.length > 0) {
          canBeAdded = false;
          String name = doc['name'].toString();
          if (name.toLowerCase().contains(searchText.toLowerCase())) {
            canBeAdded = true;
          }
        }
        if (canBeAdded) {
          YeastModel model = YeastModel();
          model.uuid = doc.id;
          model.fromMap(doc.data() as Map<String, dynamic>);
          model.merge(quantities);
          list.add(model);
        }
      });
    });
    if (ordered == true) {
      list.sort((a, b) => a.name!.toString().toLowerCase().compareTo(b.name!.toString().toLowerCase()));
    }
    return list;
  }

  Future<InventoryModel?> getInventory(String uuid) async {
    DocumentSnapshot snapshot = await inventory.doc(uuid).get();
    if (snapshot.exists) {
      InventoryModel model = InventoryModel();
      model.uuid = snapshot.id;
      model.fromMap(snapshot.data() as Map<String, dynamic>);
      return model;
    }
    return null;
  }

  Future<List<InventoryModel>> getInventories({Ingredient? ingredient, bool ordered = false}) async {
    List<InventoryModel> list = [];
    Query query = inventory;
    if (ingredient != null) {
      query = query.where('ingredient', isEqualTo: ingredient.index);
    }
    query = query.orderBy('updated_at', descending: true);
    await query.get().then((result) {
      result.docs.forEach((doc) {
        InventoryModel model = InventoryModel();
        model.uuid = doc.id;
        model.fromMap(doc.data() as Map<String, dynamic>);
        list.add(model);
      });
    });
    if (ordered == true) {
      // list.sort((a, b) => a.name!.toString().toLowerCase().compareTo(b.name!.toString().toLowerCase()));
    }
    return list;
  }

  Future<EquipmentModel?> getEquipment(String uuid) async {
    DocumentSnapshot snapshot = await equipment.doc(uuid).get();
    if (snapshot.exists) {
      EquipmentModel model = EquipmentModel();
      model.uuid = snapshot.id;
      model.fromMap(snapshot.data() as Map<String, dynamic>);
      return model;
    }
    return null;
  }

  Future<List<EquipmentModel>> getEquipments({bool ordered = false}) async {
    List<EquipmentModel> list = [];
    Query query = equipment;
    query = query.orderBy('updated_at', descending: true);
    await query.get().then((result) {
      result.docs.forEach((doc) {
        EquipmentModel model = EquipmentModel();
        model.uuid = doc.id;
        model.fromMap(doc.data() as Map<String, dynamic>);
        list.add(model);
      });
    });
    if (ordered == true) {
      // list.sort((a, b) => a.name!.toString().toLowerCase().compareTo(b.name!.toString().toLowerCase()));
    }
    return list;
  }
}
