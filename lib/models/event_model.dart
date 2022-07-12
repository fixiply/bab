// Internal package
import 'package:bb/models/image_model.dart';
import 'package:bb/models/model.dart';
import 'package:bb/models/text_model.dart';
import 'package:bb/utils/constants.dart';

class EventModel<T> extends Model {
  Status? status;
  TextModel? top_left;
  TextModel? top_right;
  TextModel? bottom_left;
  String? title;
  String? subtitle;
  List<String>? widgets;
  List<ImageModel>? images;

  EventModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    this.status = Status.pending,
    this.top_left,
    this.top_right,
    this.bottom_left,
    this.title,
    this.subtitle,
    this.widgets,
    this.images,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator) {
    if (widgets == null) { widgets = []; }
    if (images == null) { images = []; }
  }

  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.top_left = TextModel.deserialize(map['top_left']);
    this.top_right = TextModel.deserialize(map['top_right']);
    this.bottom_left = TextModel.deserialize(map['bottom_left']);
    this.title = map['title'];
    this.subtitle = map['subtitle'];
    if (map.containsKey('widgets')) this.widgets = map['widgets'].cast<String>();
    this.images = ImageModel.deserialize(map['images']);
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'top_left': TextModel.serialize(this.top_left),
      'top_right': TextModel.serialize(this.top_right),
      'bottom_left': TextModel.serialize(this.bottom_left),
      'title': this.title,
      'subtitle': this.subtitle,
      'widgets': this.widgets,
      'images': ImageModel.serialize(this.images),
    });
    return map;
  }

  EventModel copy() {
    return EventModel(
      uuid: this.uuid,
      inserted_at: this.inserted_at,
      updated_at: this.updated_at,
      creator: this.creator,
      status: this.status,
      top_left: this.top_left,
      top_right: this.top_right,
      bottom_left:  this.bottom_left,
      title: this.title,
      subtitle: this.subtitle,
      widgets: this.widgets,
      images: this.images,
    );
  }

  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is EventModel && other.uuid == uuid);
  }

  @override
  String toString() {
    return 'Style: $title, UUID: $uuid';
  }

  List<ImageModel> getImages() {
    List<ImageModel> list = [];
    if (images != null) {
      images!.forEach((t) async {
        t.left = top_left;
        t.right = top_right;
        t.bottom = bottom_left;
        list.add(t);
      });
    }
    return list;
  }
}
