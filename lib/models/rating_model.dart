// Internal package
import 'package:bb/models/model.dart';
import 'package:bb/utils/constants.dart';

class RatingModel<T> extends Model {
  Status? status;
  String? name;
  String? beer;
  double? rating;
  String? comment;

  RatingModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    this.status = Status.pending,
    this.name,
    this.beer,
    this.rating,
    this.comment,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator);

  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.name = map['name'];
    this.beer = map['beer'];
    if (map['rating'] != null) this.rating = map['rating'].toDouble();
    this.comment = map['comment'];
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'name': this.name,
      'beer': this.beer,
      'rating': this.rating,
      'comment': this.comment,
    });
    return map;
  }

  RatingModel copy() {
    return RatingModel(
      uuid: this.uuid,
      inserted_at: this.inserted_at,
      updated_at: this.updated_at,
      creator: this.creator,
      status: this.status,
      name: this.name,
      beer: this.beer,
      rating: this.rating,
      comment: this.comment,
    );
  }

  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is RatingModel && other.uuid == uuid);
  }

  @override
  String toString() {
    return 'Rating: $name, UUID: $uuid';
  }
}
