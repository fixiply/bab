import 'package:bb/widgets/containers/abstract_container.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/utils/constants.dart';
import 'package:bb/controller/product_page.dart';
import 'package:bb/models/product_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/widgets/custom_image.dart';
import 'package:bb/widgets/modal_bottom_sheet.dart';

// External package
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class SubscriptionContainer extends AbstractContainer {
  SubscriptionContainer({String? company, String? receipt, int? product}) : super(
      company: company,
      receipt: receipt,
      product: product
  );

  _SubscriptionContainerState createState() => new _SubscriptionContainerState();
}


class _SubscriptionContainerState extends AbstractContainerState {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
    );
  }
}