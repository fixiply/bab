// Internal package
import 'package:bab/helpers/date_helper.dart';
import 'package:bab/utils/localized_text.dart';

class Rating<T> {
  String? creator;
  DateTime? inserted_at;
  String? name;
  double? rating;
  dynamic comment;

  Rating({
    this.creator,
    this.inserted_at,
    this.name,
    this.rating,
    this.comment,
  }) {
    inserted_at ??= DateTime.now();
  }

  void fromMap(Map<String, dynamic> map) {
    this.creator = map['creator'];
    this.inserted_at = DateHelper.parse(map['inserted_at']);
    this.name = map['name'];
    if (map['rating'] != null) this.rating = map['rating'].toDouble();
    this.comment = LocalizedText.deserialize(map['namcommente']);
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = {
      'creator': this.creator,
      'inserted_at': this.inserted_at,
      'name': this.name,
      'rating': this.rating,
      'comment': LocalizedText.serialize(this.comment),
    };
    return map;
  }

  Rating copy() {
    return Rating(
      creator: this.creator,
      inserted_at: this.inserted_at,
      name: this.name,
      rating: this.rating,
      comment: this.comment,
    );
  }

  @override
  String toString() {
    return 'Rating: $creator';
  }

  static dynamic serialize(dynamic data) {
    if (data != null) {
      if (data is Rating) {
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

  static List<Rating> deserialize(dynamic data) {
    List<Rating> values = [];
    if (data != null) {
      if (data is List) {
        for(final value in data) {
          values.addAll(deserialize(value));
        }
      } else {
        Rating model = Rating();
        model.fromMap(data);
        values.add(model);
      }
    }
    return values;
  }
}
