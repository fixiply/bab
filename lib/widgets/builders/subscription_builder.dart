import 'package:flutter/material.dart';

// Internal package
import 'package:bab/widgets/containers/subscription_container.dart';

// External package
import 'package:child_builder/child_builder.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

class SubscriptionBuilder extends JsonWidgetBuilder {
  static const type = 'subscription';

  SubscriptionBuilder() : super(numSupportedChildren: 1);

  static SubscriptionBuilder fromDynamic(
    dynamic map, {
      JsonWidgetRegistry? registry,
    }) {
    if (map == null) {
      throw Exception('[SubscriptionBuilder]: map is null');
    }
    return SubscriptionBuilder();
  }

  @override
  Widget buildCustom({
    ChildWidgetBuilder? childBuilder,
    required BuildContext context,
    required JsonWidgetData data,
    Key? key,
  }) {
    return SubscriptionContainer(
    );
  }
}