// Internal package
import 'package:bb/helpers/date_helper.dart';
import 'package:bb/utils/constants.dart';

class Model<T> {
  String? uuid;
  DateTime? inserted_at;
  DateTime? updated_at;
  String? creator;
  bool? isEdited;
  bool? isSelected;

  Model({
    this.uuid,
    this.inserted_at,
    this.updated_at,
    this.creator,
    this.isEdited = false,
    this.isSelected = false
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

  bool isEditable() {
    if (currentUser != null) {
      if (currentUser!.uuid == creator || currentUser!.isAdmin()) {
        return true;
      }
    }
    return false;
  }

  bool isNumericType(String columnName) {
    return false;
  }

  bool isTextType(String columnName) {
    return false;
  }

  bool isDateType(String columnName) {
    return columnName == 'inserted_at' || columnName == 'updated_at';
  }

  bool isUserType(String columnName) {
    return columnName == 'creator';
  }

  bool isDateTimeType(String columnName) {
    return false;
  }

  List<Enums>? isEnumType(String columnName) {
    return null;
  }
}
