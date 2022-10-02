const double MAX_ABV = 25;

class ABV {
  double? start;
  double? end;
  double min;
  double max;

  ABV({this.start, this.end, this.min = 0, this.max = 0});

  clear() {
    this.start = this.min;
    this.end = this.max;
  }
}