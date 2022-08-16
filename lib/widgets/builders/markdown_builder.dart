import 'package:bb/models/event_model.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/models/beer_model.dart';
import 'package:bb/widgets/containers/beers_carousel.dart';

// External package
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:child_builder/child_builder.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';
import 'package:json_class/json_class.dart';

class MarkdownBuilder extends JsonWidgetBuilder {
  static const type = 'markdown';

  String text;
  double? textScaleFactor;

  MarkdownBuilder({
    required this.text,
    this.textScaleFactor : 1.0
  }) : super(numSupportedChildren: 1);

  static MarkdownBuilder fromDynamic(
      dynamic map, {
        JsonWidgetRegistry? registry,
      }) {
    if (map == null) {
      throw Exception('[MarkdownBuilder]: map is null');
    }
    return MarkdownBuilder(
      text: map['text'],
      textScaleFactor: JsonClass.parseDouble(map['textScaleFactor']),
    );
  }

  @override
  Widget buildCustom({
    ChildWidgetBuilder? childBuilder,
    required BuildContext context,
    required JsonWidgetData data,
    Key? key,
  }) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      child: MarkdownBody(
        data: text,
        fitContent: true,
        softLineBreak: true,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
          .copyWith(textScaleFactor: textScaleFactor, textAlign: WrapAlignment.start),
      )
    );
  }
}