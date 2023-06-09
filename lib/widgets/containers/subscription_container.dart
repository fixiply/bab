import 'package:bab/widgets/containers/abstract_container.dart';
import 'package:flutter/material.dart';

// Internal package

// External package

class SubscriptionContainer extends AbstractContainer {
  SubscriptionContainer({String? company, String? receipt, int? product}) : super(
      company: company,
      receipt: receipt,
      product: product
  );

  @override
  _SubscriptionContainerState createState() => _SubscriptionContainerState();
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