// Internal package
import 'package:bb/helpers/date_helper.dart';
import 'package:bb/utils/constants.dart';

class RatingModel<T> {
  String? uuid;
  DateTime? inserted_at;
  DateTime? updated_at;
  String? creator;
  Status? status;
  double? rating;
  String? comment;

  RatingModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    this.status = Status.pending,
    this.rating,
    this.comment,
  }) {
    if(inserted_at == null) { inserted_at = DateTime.now(); }
  }

  void fromMap(Map<String, dynamic> map) {
    if (map.containsKey('uuid')) this.uuid = map['uuid'];
    this.inserted_at = DateHelper.parse(map['inserted_at']);
    this.updated_at = DateHelper.parse(map['updated_at']);
    this.creator = map['creator'];
    this.status = Status.values.elementAt(map['status']);
    if (map['rating'] != null) this.rating = map['rating'].toDouble();
    this.comment = map['comment'];
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = {
      'inserted_at': this.inserted_at!.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'creator': this.creator,
      'status': this.status!.index,
      'rating': this.rating,
      'comment': this.comment,
    };
    if (persist == true) {
      map.addAll({'uuid': this.uuid});
    }
    return map;
  }

  RatingModel copy() {
    return RatingModel(
      uuid: this.uuid,
      inserted_at: this.inserted_at,
      updated_at: this.updated_at,
      creator: this.creator,
      status: this.status,
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
    return 'Rating: $creator, UUID: $uuid';
  }

  static dynamic serialize(dynamic data) {
    if (data != null) {
      if (data is RatingModel) {
        return data.toMap();
      }
      if (data is List) {
        List<dynamic> values = [];
        for(final value in data) {
          values.add(serialize(value));
        }
        return values;
      }
    }
    return null;
  }

  static List<RatingModel> deserialize(dynamic data) {
    List<RatingModel> values = [];
    if (data != null) {
      if (data is List) {
        for(final value in data) {
          values.addAll(deserialize(value));
        }
      } else {
        RatingModel model = new RatingModel();
        model.fromMap(data);
        values.add(model);
      }
    }
    return values;
  }
}
