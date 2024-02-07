// Internal package
import 'package:bab/models/image_model.dart';
import 'package:bab/models/model.dart';
import 'package:bab/helpers/date_helper.dart';
import 'package:bab/utils/constants.dart';

class CompanyModel<T> extends Model {
  Status? status;
  String? name;
  String? text;
  ImageModel? image;

  CompanyModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    this.status = Status.publied,
    this.name,
    this.text,
    this.image,
  });

  @override
  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    inserted_at = DateHelper.parse(map['inserted_at']);
    updated_at = DateHelper.parse(map['updated_at']);
    this.name = map['name'];
    this.text = map['text'];
    this.image = ImageModel.fromJson(map['image']);
  }

  @override
  Map<String, dynamic> toMap({bool persist = false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'name': this.name,
      'text': this.text,
      'image': ImageModel.serialize(this.image),
    });
    return map;
  }

  CompanyModel copy() {
    return CompanyModel(
      uuid: uuid,
      inserted_at: inserted_at,
      updated_at: updated_at,
      creator: creator,
      status: this.status,
      name: this.name,
      text: this.text,
      image: this.image
    );
  }

  // ignore: hash_and_equals
  @override
  bool operator ==(other) {
    return (other is CompanyModel && other.uuid == uuid);
  }

  @override
  int get hashCode => uuid.hashCode;

  @override
  String toString() {
    return 'Company: $name, UUID: $uuid';
  }
}
