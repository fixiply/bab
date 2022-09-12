// Internal package
import 'package:bb/models/image_model.dart';
import 'package:bb/models/model.dart';
import 'package:bb/models/text_format_model.dart';
import 'package:bb/utils/constants.dart';
import 'package:flutter/material.dart';

class EventModel<T> extends Model {
  Status? status;
  Axis? axis;
  bool? sliver;
  TextFormatModel? top_left;
  TextFormatModel? top_right;
  TextFormatModel? bottom_left;
  String? title;
  String? subtitle;
  String? page;
  List<String>? widgets;
  List<ImageModel>? images;

  EventModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    this.status = Status.pending,
    this.axis = Axis.vertical,
    this.sliver = true,
    this.top_left,
    this.top_right,
    this.bottom_left,
    this.title,
    this.subtitle,
    this.page,
    this.widgets,
    this.images,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator) {
    if (top_left == null) top_left = TextFormatModel();
    if (top_right == null) top_right = TextFormatModel();
    if (bottom_left == null) bottom_left = TextFormatModel();
    if (widgets == null) { widgets = []; }
    if (images == null) { images = []; }
  }

  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    if (map.containsKey('axis')) this.axis = Axis.values.elementAt(map['axis']);
    if (map.containsKey('sliver')) this.sliver = map['sliver'];
    this.top_left = TextFormatModel.deserialize(map['top_left']);
    this.top_right = TextFormatModel.deserialize(map['top_right']);
    this.bottom_left = TextFormatModel.deserialize(map['bottom_left']);
    this.title = map['title'];
    this.subtitle = map['subtitle'];
    this.page = map['page'];
    if (map.containsKey('widgets')) this.widgets = map['widgets'].cast<String>();
    this.images = ImageModel.deserialize(map['images']);
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'axis': this.axis!.index,
      'sliver': this.sliver,
      'top_left': TextFormatModel.serialize(this.top_left),
      'top_right': TextFormatModel.serialize(this.top_right),
      'bottom_left': TextFormatModel.serialize(this.bottom_left),
      'title': this.title,
      'subtitle': this.subtitle,
      'page': this.page,
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
      axis: this.axis,
      sliver: this.sliver,
      top_left: this.top_left,
      top_right: this.top_right,
      bottom_left:  this.bottom_left,
      title: this.title,
      subtitle: this.subtitle,
      page: this.page,
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

  String getTitle() {
    if (title != null) {
      return title!;
    }
    if (top_left != null) {
      return top_left!.text!;
    }
    if (bottom_left != null) {
      return bottom_left!.text!;
    }
    return '';
  }
}
