import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/image_editor_page.dart';

// External package
import 'package:child_builder/child_builder.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';
import 'package:json_class/json_class.dart';

class ImageEditorBuilder extends JsonWidgetBuilder {
  static const type = 'image-editor';

  String assetName;

  ImageEditorBuilder({
    required this.assetName
  }) : super(numSupportedChildren: 1);

  static ImageEditorBuilder fromDynamic(
      dynamic map, {
        JsonWidgetRegistry? registry,
      }) {
    if (map == null) {
      throw Exception('[MarkdownBuilder]: map is null');
    }
    return ImageEditorBuilder(
      assetName: map['assetName'],
    );
  }

  @override
  Widget buildCustom({
    ChildWidgetBuilder? childBuilder,
    required BuildContext context,
    required JsonWidgetData data,
    Key? key,
  }) {
    return ImageEditorPage(assetName);
  }
}