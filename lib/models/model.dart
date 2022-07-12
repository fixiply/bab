// Internal package
import 'package:bb/helpers/date_helper.dart';

class Model<T> {
  String? uuid;
  DateTime? inserted_at;
  DateTime? updated_at;
  String? creator;

  bool isEditMode = false;

  Model({
    this.uuid,
    this.inserted_at,
    this.updated_at,
    this.creator
  }) {
    if(inserted_at == null) { inserted_at = DateTime.now(); }
  }

  void fromMap(Map<String, dynamic> map) {
    if (map.containsKey('uuid')) this.uuid = map['uuid'];
    this.inserted_at = DateHelper.parse(map['inserted_at']);
    this.updated_at = DateHelper.parse(map['updated_at']);
    this.creator = map['creator'];
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = {
      'inserted_at': this.inserted_at!.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'creator': this.creator,
    };
    if (persist == true) {
      map.addAll({'uuid': this.uuid});
    }
    return map;
  }
}
