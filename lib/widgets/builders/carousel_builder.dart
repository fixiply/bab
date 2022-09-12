import 'package:bb/models/event_model.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/widgets/containers/carousel.dart';

// External package
import 'package:child_builder/child_builder.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

class CarouselBuilder extends JsonWidgetBuilder {
  static const type = 'carousel';

  String? company;
  String? receipt;

  CarouselBuilder({
    this.company,
    this.receipt,
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
    );
  }

  @override
  Widget buildCustom({
    ChildWidgetBuilder? childBuilder,
    required BuildContext context,
    required JsonWidgetData data,
    Key? key,
  }) {
    return Carousel(
      company: company,
      receipt: receipt
    );
  }
}