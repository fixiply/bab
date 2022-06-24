// Internal package
import 'package:bb/models/model.dart';
import 'package:bb/utils/constants.dart';

class RatingModel<T> extends Model {
  Status? status;
  String? user;
  double? rating;
  String? text;

  RatingModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    this.status = Status.pending,
    this.rating,
    this.text,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator);

  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    if (map['rating'] != null) this.rating = map['rating'].toDouble();
    this.text = map['text'];
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'rating': this.rating,
      'text': this.text,
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
      rating: this.rating,
      text: this.text,
    );
  }

  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is RatingModel && other.uuid == uuid);
  }

  @override
  String toString() {
    return 'Rating: $user, UUID: $uuid';
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
