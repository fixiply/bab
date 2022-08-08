// Internal package
import 'package:bb/models/model.dart';
import 'package:bb/utils/constants.dart';

class StyleModel<T> extends Model {
  Status? status;
  Fermentation? fermentation;
  String? title;
  String? text;

  StyleModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    this.status = Status.pending,
    this.fermentation = Fermentation.hight,
    this.title,
    this.text,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator);

  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.fermentation = Fermentation.values.elementAt(map['fermentation']);
    this.title = map['title'];
    this.text = map['text'];
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'fermentation': this.fermentation!.index,
      'title': this.title,
      'text': this.text,
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
