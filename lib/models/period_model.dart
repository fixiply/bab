import 'dart:convert';

// Internal package
import 'package:bb/utils/constants.dart';

class PeriodModel<T> {
  Period? period;
  int? each;

  PeriodModel({
    this.period = Period.month,
    this.each = 3,
  });

  void fromMap(Map<String, dynamic> map) {
    this.period = Period.values.elementAt(map['period']);
    this.each = map['each'];
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = {
      'period': this.period!.index,
      'each': this.each,
    };
    return map;
  }

  PeriodModel copy() {
    return PeriodModel(
      period: this.period,
      each: this.each,
    );
  }

  DateTime? getLast() {
    if (this.each != null) {
      DateTime now = DateTime.now();
      switch(this.period!) {
        case Period.day :
          return now.add(Duration(days: this.each!));
        case Period.week :
          return now.add(Duration(days: 7 * this.each!));
        case Period.month :
          return DateTime(now.year, now.month + this.each!, now.day);
        case Period.year :
          return DateTime(now.year, now.month, now.day + this.each!);
      }
    }
    return null;
  }

  static dynamic serialize(dynamic data) {
    if (data != null) {
      if (data is PeriodModel) {
        return data.toMap();
      }
    }
    return null;
  }

  static PeriodModel? deserialize(dynamic data) {
    if (data != null) {
      PeriodModel model = new PeriodModel();
      if (data is Map<String, dynamic>) {
        model.fromMap(data);
      }
      return model;
    }
    return null;
  }
}
