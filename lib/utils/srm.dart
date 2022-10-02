class SRM {
  double? start;
  double? end;

  SRM({this.start, this.end});

  clear() {
    this.start = 0;
  }

  static int parse(double? ebc) {
    return ebc != null ? (ebc * 0.508).toInt() : 0;
  }

  static double toEBC(double srm) {
    return (srm * 1.97).round().toDouble();
  }
}