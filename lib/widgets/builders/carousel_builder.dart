import 'package:flutter/material.dart';

// Internal package
import 'package:bab/widgets/containers/carousel_container.dart';

// External package
import 'package:child_builder/child_builder.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

class CarouselBuilder extends JsonWidgetBuilder {
  static const type = 'carousel';

  String? company;
  String? receipt;
  int? product;

  CarouselBuilder({
    this.company,
    this.receipt,
    this.product,
  }) : super(numSupportedChildren: 1);

  static CarouselBuilder fromDynamic(
      dynamic map, {
        JsonWidgetRegistry? registry,
      }) {
    if (map == null) {
      throw Exception('[CarouselBuilder]: map is null');
    }
    return CarouselBuilder(
      company: map['company'],
      receipt: map['receipt'],
      product: map['product'],
    );
  }

  @override
  Widget buildCustom({
    ChildWidgetBuilder? childBuilder,
    required BuildContext context,
    required JsonWidgetData data,
    Key? key,
  }) {
    return CarouselContainer(
      company: company,
      receipt: receipt,
      product: product
    );
  }
}