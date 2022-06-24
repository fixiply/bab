// Internal package
import 'package:bb/models/image_model.dart';
import 'package:bb/models/model.dart';
import 'package:bb/utils/constants.dart';

class EventModel<T> extends Model {
  Status? status;
  String? title;
  String? subtitle;
  String? text;
  List<ImageModel>? images;

  EventModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    this.status = Status.pending,
    this.title,
    this.subtitle,
    this.text,
    this.images,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator) {
    if(images == null) { images = []; }
  }

  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.title = map['title'];
    this.subtitle = map['subtitle'];
    this.text = map['text'];
    this.images = ImageModel.deserialize(map['images']);
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'title': this.title,
      'subtitle': this.subtitle,
      'text': this.text,
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
      title: this.title,
      subtitle: this.subtitle,
      text: this.text,
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

  Future<List<ImageModel>> getImages() async {
    List<ImageModel> images = [];
    if (images != null) {
      images.forEach((t) async {
        // t.left = model.top_left;
        // t.right = model.top_right;
        // t.bottom = model.bottom_left;
        images.add(t);
      });
    }
    return images;
  }
}
