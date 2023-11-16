// Internal package
import 'package:bab/models/image_model.dart';
import 'package:bab/models/model.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/text_format.dart';
import 'package:flutter/material.dart';

class EventModel<T> extends Model {
  Status? status;
  Axis? axis;
  bool? sliver;
  TextFormat? top_left;
  TextFormat? top_right;
  TextFormat? bottom_left;
  String? title;
  String? subtitle;
  String? page;
  List<String>? widgets;
  List<ImageModel>? images;
  bool? logged_out;
  List<String>? countries;

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
    this.logged_out,
    this.countries,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator) {
    top_left ??= TextFormat();
    top_right ??= TextFormat();
    bottom_left ??= TextFormat();
    widgets ??= [];
    images ??= [];
    countries ??= [];
  }

  @override
  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    if (map.containsKey('axis')) this.axis = Axis.values.elementAt(map['axis']);
    if (map.containsKey('sliver')) this.sliver = map['sliver'];
    this.top_left = TextFormat.deserialize(map['top_left']);
    this.top_right = TextFormat.deserialize(map['top_right']);
    this.bottom_left = TextFormat.deserialize(map['bottom_left']);
    this.title = map['title'];
    this.subtitle = map['subtitle'];
    this.page = map['page'];
    if (map.containsKey('widgets')) this.widgets = map['widgets'].cast<String>();
    this.images = ImageModel.deserialize(map['images']);
    if (map.containsKey('logged_out')) this.logged_out = map['logged_out'];
    if (map.containsKey('countries')) this.countries = map['countries'];
  }

  @override
  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'axis': this.axis!.index,
      'sliver': this.sliver,
      'top_left': TextFormat.serialize(this.top_left),
      'top_right': TextFormat.serialize(this.top_right),
      'bottom_left': TextFormat.serialize(this.bottom_left),
      'title': this.title,
      'subtitle': this.subtitle,
      'page': this.page,
      'widgets': this.widgets,
      'images': ImageModel.serialize(this.images),
      'logged_out': this.logged_out,
      'countries': this.countries,
    });
    return map;
  }

  EventModel copy() {
    return EventModel(
      uuid: uuid,
      inserted_at: inserted_at,
      updated_at: updated_at,
      creator: creator,
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
      logged_out: this.logged_out,
      countries: this.countries,
    );
  }

  // ignore: hash_and_equals
  @override
  bool operator ==(other) {
    return (other is EventModel && other.uuid == uuid);
  }

  @override
  int get hashCode => uuid.hashCode;

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
