// Internal package
import 'package:bb/models/image_model.dart';
import 'package:bb/models/model.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/localized_text.dart';
import 'package:bb/utils/rating.dart';
import 'package:bb/utils/term.dart';

enum Product with Enums { article, booking, other;
  List<Enum> get enums => [ article, booking, other ];
}

class ProductModel<T> extends Model {
  Status? status;
  Product? product;
  String? company;
  String? receipt;
  dynamic? title;
  dynamic? subtitle;
  double? price;
  int? pack;
  int? max;
  int? min;
  List<dynamic>? weekdays;
  Term? term;
  dynamic? text;
  ImageModel? image;
  List<Rating>? ratings;

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
    this.image,
    this.ratings
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator) {
    if(weekdays == null) { weekdays = []; }
    if(term == null) { term = Term(); }
    if (ratings == null) { ratings = []; }
  }

  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.product = Product.values.elementAt(map['product']);
    this.company = map['company'];
    this.receipt = map['receipt'];
    this.title = LocalizedText.deserialize(map['title']);
    this.subtitle = LocalizedText.deserialize(map['subtitle']);
    if (map['price'] != null) this.price = map['price'].toDouble();
    if (map['pack'] != null) this.pack = map['pack'];
    if (map['max'] != null) this.max = map['max'];
    if (map['min'] != null) this.min = map['min'];
    if (map['weekdays'] != null) this.weekdays = map['weekdays'];
    if (map['term'] != null) this.term = Term.deserialize(map['term']);
    this.text = LocalizedText.deserialize(map['text']);
    this.image = ImageModel.fromJson(map['image']);
    this.ratings = Rating.deserialize(map['ratings']);
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'product': this.product!.index,
      'company': this.company,
      'receipt': this.receipt,
      'title': LocalizedText.serialize(this.title),
      'subtitle': LocalizedText.serialize(this.subtitle),
      'price': this.price,
      'pack': this.pack,
      'max': this.max,
      'min': this.min,
      'weekdays': this.weekdays,
      'term': Term.serialize(this.term),
      'text': LocalizedText.serialize(this.text),
      'image': ImageModel.serialize(this.image),
      'ratings': Rating.serialize(this.ratings),
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
      image: this.image,
      ratings: this.ratings
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

  int get notice {
    return this.ratings != null ? this.ratings!.length : 0;
  }

  double get rating {
    double rating = 0;
    if (ratings != null && ratings!.length > 0) {
      for(Rating model in ratings!) {
        rating += model.rating!;
      }
      rating = rating / ratings!.length;
    }
    return rating;
  }
}
