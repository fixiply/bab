import 'package:bb/models/event_model.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/models/beer_model.dart';
import 'package:bb/widgets/containers/beers_carousel.dart';

// External package
import 'package:json_class/json_class.dart';
import 'package:child_builder/child_builder.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

class BeersCarouselBuilder extends JsonWidgetBuilder {
  static const type = 'beerscarousel';

  String company;

  BeersCarouselBuilder({
    required this.company,
  }) : super(numSupportedChildren: 1);

  static BeersCarouselBuilder fromDynamic(
      dynamic map, {
        JsonWidgetRegistry? registry,
      }) {
    if (map == null) {
      throw Exception('[BeersCarouselBuilder]: map is null');
    }
    return BeersCarouselBuilder(
      company: map['company'],
    );
  }

  @override
  Widget buildCustom({
    ChildWidgetBuilder? childBuilder,
    required BuildContext context,
    required JsonWidgetData data,
    Key? key,
  }) {
    return BeersCarousel(
      company
    );
  }
}