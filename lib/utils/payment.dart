import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

// Internal package
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/utils/constants.dart';
import 'package:flutter/material.dart';

class Payment {
  final Payments payment;
  Image? image;
  List<TargetPlatform>? platform;
  Payment(this.payment, {this.image, this.platform}) {
    if (platform == null) platform = [];
  }

  static Payment credit_card = Payment(Payments.credit_card);
  static Payment paypal = Payment(Payments.paypal);
  static Payment apple_pay = Payment(Payments.paypal, platform: [TargetPlatform.iOS]);
  static Payment google_pay = Payment(Payments.google_pay, platform: [TargetPlatform.iOS]);

  static List<Payment> get currentPlatform {
    if (DeviceHelper.isDesktop) {
      return [credit_card, paypal, apple_pay, google_pay];
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return [credit_card, paypal, google_pay];
      case TargetPlatform.iOS:
        return [credit_card, paypal, apple_pay];;
      case TargetPlatform.macOS:
        return [credit_card, paypal, apple_pay];;
      case TargetPlatform.windows:
        return [credit_card, paypal];
      case TargetPlatform.linux:
        return [credit_card, paypal];
      default:
        return [credit_card, paypal];
    }
  }
}