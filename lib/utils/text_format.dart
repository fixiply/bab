import 'package:flutter/material.dart';

class TextFormat<T> {
  String? text;
  double? size;
  bool? bold;
  bool? italic;
  bool? underline;
  int? color;

  TextFormat({
    this.text,
    this.size = 14.0,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.color,
  }) {
    color ??= Colors.black.value;
  }

  void fromMap(Map<String, dynamic> map) {
    text = map['text'];
    if (map['size'] != null) size = map['size'].toDouble();
    this.bold = map['bold'];
    this.italic = map['italic'];
    this.underline = map['underline'];
    this.color = map['color'];
  }

  Map<String, dynamic> toMap({bool persist = false}) {
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

  TextFormat copy() {
    return TextFormat(
      text: this.text,
      size: this.size,
      bold: this.bold,
      italic: this.italic,
      underline: this.underline,
      color: this.color,
    );
  }

  // ignore: hash_and_equals
  @override
  bool operator ==(other) {
    return (other is TextFormat && other.text == text);
  }

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() {
    return text ?? '';
  }

  bool get isNotEmpty {
    return text != null && text!.isNotEmpty;
  }

  bool get isEmpty {
    return text == null || text!.isEmpty;
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

  static String? getText(dynamic model) {
      return model != null && model.isNotEmpty ? model.toString() : null;
  }

  static bool hasText(dynamic model) {
    return model != null && model.isNotEmpty ? true: false;
  }

  static double? getFontSize(TextFormat? model) {
    return model != null && model.size != null ? model.size : null;
  }

  static Color? getColor(TextFormat? model) {
    return model != null && model.color != null ? Color(model.color!) : null;
  }

  static bool hasFontBold(TextFormat? model) {
    return model != null && model.isBold;
  }

  static bool hasFontItalic(TextFormat? model) {
    return model != null && model.isItalic;
  }

  static bool hasFontUnderline(TextFormat? model) {
    return model != null && model.isUnderline;
  }

  static dynamic serialize(dynamic data) {
    if (data != null) {
      if (data is TextFormat) {
        return data.toMap();
      }
    }
    return null;
  }

  static TextFormat? deserialize(dynamic data) {
    if (data != null) {
      // ignore: unnecessary_new
      TextFormat model = new TextFormat();
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
