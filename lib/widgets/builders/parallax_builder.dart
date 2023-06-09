import 'package:flutter/material.dart';

// Internal package
import 'package:bab/widgets/containers/parallax_container.dart';
import 'package:bab/widgets/containers/parallax2_container.dart';

// External package
import 'package:child_builder/child_builder.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

class ParallaxBuilder extends JsonWidgetBuilder {
  static const type = 'parallax';

  String? company;
  String? receipt;
  int? product;

  ParallaxBuilder({
    this.company,
    this.receipt,
    this.product,
  }) : super(numSupportedChildren: 1);

  static ParallaxBuilder fromDynamic(
      dynamic map, {
        JsonWidgetRegistry? registry,
      }) {
    if (map == null) {
      throw Exception('[ParallaxBuilder]: map is null');
    }
    return ParallaxBuilder(
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
    return ParallaxContainer(
      company: company,
      receipt: receipt,
      product: product
    );
  }
}