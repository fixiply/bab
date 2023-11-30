import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

// Internal package
import 'package:bab/utils/text_format.dart';

// External package
import 'package:firebase_storage/firebase_storage.dart';

class ImageModel<T> {
  String? url;
  Uint8List? bytes;
  String? name;
  DateTime? updated_at;
  TextFormat? left;
  TextFormat? right;
  TextFormat? bottom;
  int? size;
  Rect? rect;
  Reference? reference;

  ImageModel({
    this.url,
    this.bytes,
    this.name,
    this.updated_at,
    this.left,
    this.right,
    this.bottom,
    this.size,
    this.rect,
    this.reference,
  }) {
    left ??= TextFormat();
    right ??= TextFormat();
    bottom ??= TextFormat();
  }

  void fromMap(Map<String, dynamic> map) {
    this.url = map['url'];
    if (map['bytes'] != null) this.bytes = base64.decode(map['bytes']);
    if (map.containsKey('rect')) {
      this.rect = fromRect(map['rect']);
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'url': this.url,
      'bytes': this.bytes != null ? base64.encode(this.bytes!) : null,
    };
    if (rect != null) map.addAll({'rect': toRect(rect!)});
    return map;
  }

  ImageModel copy() {
    return ImageModel(
      url: this.url,
      bytes: this.bytes,
      name: this.name,
      updated_at: this.updated_at,
      left: this.left,
      right: this.right,
      bottom: this.bottom,
      size: this.size,
      rect: this.rect,
    );
  }

  Future<String> getUrl() async {
    if (url != null) {
      return url!;
    }
    if (reference != null) {
      url = await reference!.getDownloadURL();
    }
    return url!;
  }

  Future<DateTime?> getUpdated() async {
    if (updated_at != null) {
      return updated_at;
    }
    if (reference != null) {
      FullMetadata meta = await reference!.getMetadata();
      updated_at = meta.updated;
      size = meta.size;
    }
    return updated_at;
  }

  Future<int?> getSize() async {
    if (size != null) {
      return size;
    }
    if (reference != null) {
      FullMetadata meta = await reference!.getMetadata();
      updated_at = meta.updated;
      size = meta.size;
    }
    return size;
  }

  // ignore: hash_and_equals
  @override
  bool operator ==(other) {
    return (other is ImageModel && other.name == name);
  }

  @override
  int get hashCode => name.hashCode;

  static dynamic fromJson(dynamic data) {
    if (data != null) {
      if (data is String) {
        return ImageModel(url: data);
      } else if (data is Map<String, dynamic>) {
        ImageModel model = ImageModel();
        model.fromMap(data);
        return model;
      }
    }
    return null;
  }

  static dynamic serialize(dynamic data) {
    if (data != null) {
      if (data is ImageModel) {
        return data.toMap();
      }
      if (data is List) {
        List<dynamic> values = [];
        for(final value in data) {
          values.add(serialize(value));
        }
        return values;
      }
    }
    return null;
  }

  static List<ImageModel> deserialize(dynamic data) {
    List<ImageModel> values = [];
    if (data != null) {
      if (data is List) {
        for(final value in data) {
          values.addAll(deserialize(value));
        }
      } else {
        values.add(ImageModel.fromJson(data));
      }
    }
    return values;
  }

  static Rect? fromRect(dynamic data) {
    try {
      return Rect.fromLTRB(
          double.parse(data['left'].toString()),
          double.parse(data['top'].toString()),
          double.parse(data['right'].toString()),
          double.parse(data['bottom'].toString())
      );
    }
    catch(e) {
      return null;
    }
  }

  static Object toRect(Rect rect) {
    var data = {};
    data['left'] = rect.left;
    data['top'] = rect.top;
    data['right'] = rect.right;
    data['bottom'] = rect.bottom;
    return data;
  }
}

