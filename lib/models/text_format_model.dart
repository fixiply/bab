import 'package:flutter/material.dart';

class TextFormatModel<T> {
  String? text;
  double? size;
  bool? bold;
  bool? italic;
  bool? underline;
  int? color;

  TextFormatModel({
    this.text,
    this.size = 14.0,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.color,
  }) {
    if (color == null) { color = Colors.black.value; }
  }

  void fromMap(Map<String, dynamic> map) {
    this.text = map['text'];
    if (map['size'] != null) this.size = map['size'].toDouble();
    this.bold = map['bold'];
    this.italic = map['italic'];
    this.underline = map['underline'];
    this.color = map['color'];
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = {
      'text': this.text,
      'size': this.size,
      'bold': this.bold,
      'italic': this.italic,
      'underline': this.underline,
      'color': this.color,
    };
    return map;
  }

  TextFormatModel copy() {
    return TextFormatModel(
      text: this.text,
      size: this.size,
      bold: this.bold,
      italic: this.italic,
      underline: this.underline,
      color: this.color,
    );
  }

  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is TextFormatModel && other.text == text);
  }

  @override
  String toString() {
    return text ?? '';
  }

  bool get isNotEmpty {
    return text != null && text!.length > 0;
  }

  bool get isEmpty {
    return text == null || text!.length == 0;
  }

  bool get isBold {
    return this.bold != null && this.bold == true;
  }

  bool get isItalic {
    return this.italic != null && this.italic == true;
  }

  bool get isUnderline {
    return this.underline != null && this.underline == true;
  }

  static String? getText(dynamic? model) {
      return model != null && model.isNotEmpty ? model.toString() : null;
  }

  static bool hasText(dynamic? model) {
    return model != null && model.isNotEmpty ? true: false;
  }

  static double? getFontSize(TextFormatModel? model) {
    return model != null && model.size != null ? model.size : null;
  }

  static Color? getColor(TextFormatModel? model) {
    return model != null && model.color != null ? Color(model.color!) : null;
  }

  static bool hasFontBold(TextFormatModel? model) {
    return model != null && model.isBold;
  }

  static bool hasFontItalic(TextFormatModel? model) {
    return model != null && model.isItalic;
  }

  static bool hasFontUnderline(TextFormatModel? model) {
    return model != null && model.isUnderline;
  }

  static dynamic serialize(dynamic data) {
    if (data != null) {
      if (data is TextFormatModel) {
        return data.toMap();
      }
    }
    return null;
  }

  static TextFormatModel? deserialize(dynamic data) {
    if (data != null) {
      TextFormatModel model = new TextFormatModel();
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
