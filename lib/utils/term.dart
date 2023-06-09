// Internal package
import 'package:bab/utils/constants.dart';

class Term<T> {
  Period? period;
  int? each;

  Term({
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

  Term copy() {
    return Term(
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
      if (data is Term) {
        return data.toMap();
      }
    }
    return null;
  }

  static Term? deserialize(dynamic data) {
    if (data != null) {
      Term model = Term();
      if (data is Map<String, dynamic>) {
        model.fromMap(data);
      }
      return model;
    }
    return null;
  }
}
