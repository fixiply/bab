const double MAX_IBU = 150;

class IBU {
  double? start;
  double? end;
  double min;
  double max;

  IBU({this.start, this.end, this.min = 0, this.max = 0});

  clear() {
    start = min;
    end = max;
  }

  static String label(double ibu) {
    if (ibu < 20) {
      return 'Peu amer';
    }
    if (ibu >= 20 && ibu <= 40) {
      return 'Modérée';
    }
    if (ibu >= 40 && ibu <= 60) {
      return 'Prononcée';
    }
    if (ibu >= 60 && ibu <= 80) {
      return 'Intense';
    }
    if (ibu > 80) {
      return 'Très intense';
    }
    return '';
  }
}