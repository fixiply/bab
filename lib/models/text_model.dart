import 'package:flutter/material.dart';

class TextModel<T> {
  String? text;
  int? color;
  double? size;

  TextModel({
    this.text,
    this.color,
    this.size = 14.0,
  }) {
    if (color == null) { color = Colors.black.value; }
  }

  void fromMap(Map<String, dynamic> map) {
    this.text = map['text'];
    this.color = map['color'];
    if (map['size'] != null) this.size = map['size'].toDouble();
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = {
      'text': this.text,
      'color': this.color,
      'size': this.size,
    };
    return map;
  }

  TextModel copy() {
    return TextModel(
      text: this.text,
      color: this.color,
      size: this.size,
    );
  }

  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is TextModel && other.text == text);
  }

  @override
  String toString() {
    return 'Text: $text';
  }


  static dynamic serialize(dynamic data) {
    if (data != null) {
      if (data is TextModel) {
        return data.toMap();
      }
    }
    return null;
  }

  static TextModel? deserialize(dynamic data) {
    if (data != null) {
      TextModel model = new TextModel();
      if (data is Map<String, dynamic>) {
        model.fromMap(data);
      } else {
        model.text = data;
      }
      return model;
    }
    return null;
  }
}
