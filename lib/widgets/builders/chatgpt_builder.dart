import 'package:flutter/material.dart';

// Internal package
import 'package:bab/widgets/containers/chatgpt_container.dart';

// External package
import 'package:child_builder/child_builder.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

class ChatGPTBuilder extends JsonWidgetBuilder {
  static const type = 'chatgpt';

  ChatGPTBuilder() : super(numSupportedChildren: 1);

  static ChatGPTBuilder fromDynamic(
    dynamic map, {
      JsonWidgetRegistry? registry,
    }) {
    if (map == null) {
      throw Exception('[ChatGPTBuilder]: map is null');
    }
    return ChatGPTBuilder();
  }

  @override
  Widget buildCustom({
    ChildWidgetBuilder? childBuilder,
    required BuildContext context,
    required JsonWidgetData data,
    Key? key,
  }) {
    return ChatGPTContainer(
    );
  }
}