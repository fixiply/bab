import 'dart:math';

class ImageHelper {
    static String size(int bytes, int fractionDigits) {
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(fractionDigits)} ${suffixes[i]}';
  }
}