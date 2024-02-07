// Internal package
import 'package:bab/utils/constants.dart';

class Amount {
  double? amount;
  Measurement? measurement;
  Amount(
      this.amount,
      this.measurement
      );

  // ignore: hash_and_equals
  @override
  bool operator ==(other) {
    return (other is Amount && other.amount == amount && other.measurement == measurement);
  }

  @override
  int get hashCode => amount.hashCode;


  @override
  String toString() {
    return 'class: $amount $measurement';
  }

  Amount copy() {
    return Amount(
        amount,
        measurement
    );
  }
}