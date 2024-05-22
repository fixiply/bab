import 'package:flutter/material.dart';

// Internal package
import 'package:bab/widgets/containers/list_container.dart';

// External package
import 'package:child_builder/child_builder.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

class ListBuilder extends JsonWidgetBuilder {
  static const name = 'list';

  @override
  String get type => name;

  String? company;
  String? recipe;
  int? product;

  ListBuilder({
    this.company,
    this.recipe,
    this.product,
  }) : super(numSupportedChildren: 1);

  static ListBuilder fromDynamic(
      dynamic map, {
        JsonWidgetRegistry? registry,
      }) {
    if (map == null) {
      throw Exception('[ListBuilder]: map is null');
    }
    return ListBuilder(
      company: map['company'],
      recipe: map['recipe'],
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
    return ListContainer(
      company: company,
      recipe: recipe,
      product: product
    );
  }
}