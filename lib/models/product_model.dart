// Internal package
import 'package:bb/models/image_model.dart';
import 'package:bb/models/model.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/term.dart';

class ProductModel<T> extends Model {
  Status? status;
  Product? product;
  String? company;
  String? receipt;
  String? title;
  String? subtitle;
  double? price;
  int? pack;
  int? max;
  int? min;
  List<dynamic>? weekdays;
  Term? term;
  String? text;
  ImageModel? image;

  ProductModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    this.status = Status.publied,
    this.product = Product.article,
    this.company,
    this.receipt,
    this.title,
    this.subtitle,
    this.price,
    this.pack,
    this.max,
    this.min,
    this.weekdays,
    this.term,
    this.text,
    this.image
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator) {
    if(weekdays == null) { weekdays = []; }
    if(term == null) { term = Term(); }
  }

  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.product = Product.values.elementAt(map['product']);
    this.company = map['company'];
    this.receipt = map['receipt'];
    this.title = map['title'];
    this.subtitle = map['subtitle'];
    if (map['price'] != null) this.price = map['price'].toDouble();
    if (map['pack'] != null) this.pack = map['pack'];
    if (map['max'] != null) this.max = map['max'];
    if (map['min'] != null) this.min = map['min'];
    if (map['weekdays'] != null) this.weekdays = map['weekdays'];
    if (map['term'] != null) this.term = Term.deserialize(map['term']);
    this.text = map['text'];
    this.image = ImageModel.fromJson(map['image']);
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'product': this.product!.index,
      'company': this.company,
      'receipt': this.receipt,
      'title': this.title,
      'subtitle': this.subtitle,
      'price': this.price,
      'pack': this.pack,
      'max': this.max,
      'min': this.min,
      'weekdays': this.weekdays,
      'term': Term.serialize(this.term),
      'text': this.text,
      'image': ImageModel.serialize(this.image)
    });
    return map;
  }

  ProductModel copy() {
    return ProductModel(
      uuid: this.uuid,
      inserted_at: this.inserted_at,
      updated_at: this.updated_at,
      creator: this.creator,
      status: this.status,
      product: this.product,
      company: this.company,
      receipt: this.receipt,
      title: this.title,
      subtitle: this.subtitle,
      price: this.price,
      pack: this.pack,
      max: this.max,
      min: this.min,
      weekdays: this.weekdays,
      term: this.term,
      text: this.text,
      image: this.image
    );
  }

  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is ProductModel && other.uuid == uuid);
  }

  @override
  String toString() {
    return 'Product: $title, UUID: $uuid';
  }
  //
  // int notice() {
  //   return this.ratings != null ? this.ratings!.length : 0;
  // }
  //
  // double rating() {
  //   double rating = 0;
  //   if (ratings != null && ratings!.length > 0) {
  //     for(RatingModel model in ratings!) {
  //       rating += model.rating!;
  //     }
  //     rating = rating / ratings!.length;
  //   }
  //   return rating;
  // }
}
