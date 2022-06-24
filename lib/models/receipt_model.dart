// Internal package
import 'package:bb/models/model.dart';
import 'package:bb/models/rating_model.dart';
import 'package:bb/utils/constants.dart';

class ReceiptModel<T> extends Model {
  Status? status;
  String? title;
  String? text;
  String? style;
  double? alcohol;
  double? ibu;
  double? ebc;
  List<RatingModel>? ratings;

  ReceiptModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    this.status = Status.pending,
    this.title,
    this.text,
    this.style,
    this.alcohol,
    this.ibu,
    this.ebc,
    this.ratings,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator) {
    if (ratings == null) { ratings = []; }
  }

  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.title = map['title'];
    this.text = map['text'];
    this.style = map['style'];
    this.alcohol = map['alcohol'].toDouble();
    this.ibu = map['ibu'].toDouble();
    this.ebc = map['ebc'].toDouble();
    this.ratings = RatingModel.deserialize(map['ratings']);
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'title': this.title,
      'text': this.text,
      'style': this.style,
      'alcohol': this.alcohol,
      'ibu': this.ibu,
      'ebc': this.ebc,
      'ratings': RatingModel.serialize(this.ratings),
    });
    return map;
  }

  ReceiptModel copy() {
    return ReceiptModel(
      uuid: this.uuid,
      inserted_at: this.inserted_at,
      updated_at: this.updated_at,
      creator: this.creator,
      status: this.status,
      title: this.title,
      text: this.text,
      style: this.style,
      alcohol: this.alcohol,
      ibu: this.ibu,
      ebc: this.ebc,
      ratings: this.ratings,
    );
  }

  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is ReceiptModel && other.uuid == uuid);
  }

  @override
  String toString() {
    return 'Receipt: $title, UUID: $uuid';
  }

  int getSRM() {
    return (ebc! * 0.508).toInt();
  }

  bool hasRating() {
    return this.ratings != null && this.ratings!.length > 0;
  }

  double rating() {
    double rating = 0;
    if (ratings != null) {
      for(RatingModel model in ratings!) {
        rating += model.rating!;
      }
      rating = rating / ratings!.length;
    }
    return rating;
  }
}
