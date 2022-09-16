import 'package:flutter/material.dart';

// Internal package
import 'package:bb/widgets/containers/parallax.dart';

// External package
import 'package:json_class/json_class.dart';
import 'package:child_builder/child_builder.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

class ParallaxBuilder extends JsonWidgetBuilder {
  static const type = 'parallax';

  String? company;
  String? receipt;

  ParallaxBuilder({
    this.company,
    this.receipt,
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
    );
  }

  @override
  Widget buildCustom({
    ChildWidgetBuilder? childBuilder,
    required BuildContext context,
    required JsonWidgetData data,
    Key? key,
  }) {
    return Parallax(
      company: company,
      receipt: receipt
    );
  }
}