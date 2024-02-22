import 'package:flutter/material.dart';

// Internal package
import 'package:bab/widgets/containers/registration_container.dart';

// External package
import 'package:child_builder/child_builder.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

class RegistrationBuilder extends JsonWidgetBuilder {
  static const type = 'registration';

  RegistrationBuilder() : super(numSupportedChildren: 1);

  static RegistrationBuilder fromDynamic(
    dynamic map, {
      JsonWidgetRegistry? registry,
    }) {
    if (map == null) {
      throw Exception('[RegistrationBuilder]: map is null');
    }
    return RegistrationBuilder();
  }

  @override
  Widget buildCustom({
    ChildWidgetBuilder? childBuilder,
    required BuildContext context,
    required JsonWidgetData data,
    Key? key,
  }) {
    return RegistrationContainer(
    );
  }
}