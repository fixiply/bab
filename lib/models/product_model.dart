// Internal package
import 'package:bb/models/image_model.dart';
import 'package:bb/models/model.dart';
import 'package:bb/models/rating_model.dart';
import 'package:bb/utils/constants.dart';

class ProductModel<T> extends Model {
  Status? status;
  Product? product;
  String? company;
  String? receipt;
  String? title;
  String? subtitle;
  double? price;
  int? pack;
  String? text;
  ImageModel? image;

  ProductModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    this.status = Status.pending,
    this.product = Product.beer,
    this.company,
    this.receipt,
    this.title,
    this.subtitle,
    this.price,
    this.pack,
    this.text,
    this.image
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator);

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
