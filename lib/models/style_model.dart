// Internal package
import 'package:bb/models/model.dart';
import 'package:bb/utils/constants.dart';

class StyleModel<T> extends Model {
  Status? status;
  Fermentation? fermentation;
  String? title;
  String? text;
  String? category;
  double? min_abv;
  double? max_abv;
  double? min_ibu;
  double? max_ibu;
  double? min_ebc;
  double? max_ebc;

  StyleModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    this.status = Status.pending,
    this.fermentation = Fermentation.hight,
    this.title,
    this.text,
    this.category,
    this.min_abv,
    this.max_abv,
    this.min_ibu,
    this.max_ibu,
    this.min_ebc,
    this.max_ebc
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator);

  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.fermentation = Fermentation.values.elementAt(map['fermentation']);
    this.title = map['title'];
    this.text = map['text'];
    this.category = map['category'];
    if (map['min_abv'] != null) this.min_abv = map['min_abv'].toDouble();
    if (map['max_abv'] != null) this.max_abv = map['max_abv'].toDouble();
    if (map['min_ibu'] != null) this.min_ibu = map['min_ibu'].toDouble();
    if (map['max_ibu'] != null) this.max_ibu = map['max_ibu'].toDouble();
    if (map['min_ebc'] != null) this.min_ebc = map['min_ebc'].toDouble();
    if (map['max_ebc'] != null) this.max_ebc = map['max_ebc'].toDouble();
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'fermentation': this.fermentation!.index,
      'title': this.title,
      'text': this.text,
      'category': this.category,
      'min_abv': this.min_abv,
      'max_abv': this.max_abv,
      'min_ibu': this.min_ibu,
      'max_ibu': this.max_ibu,
      'min_ebc': this.min_ebc,
      'max_ebc': this.max_ebc
    });
    return map;
  }

  StyleModel copy() {
    return StyleModel(
      uuid: this.uuid,
      inserted_at: this.inserted_at,
      updated_at: this.updated_at,
      creator: this.creator,
      status: this.status,
      fermentation: this.fermentation,
      title: this.title,
      text: this.text,
      category: this.category,
      min_abv: this.min_abv,
      max_abv: this.max_abv,
      min_ibu: this.min_ibu,
      max_ibu: this.max_ibu,
      min_ebc: this.min_ebc,
      max_ebc: this.max_ebc
    );
  }

  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is StyleModel && other.uuid == uuid || other is String && other == uuid);
  }

  @override
  String toString() {
    return 'Style: $title, UUID: $uuid';
  }
}
