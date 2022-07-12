import 'dart:convert';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/widgets/dialogs/text_input_dialog.dart';
import 'package:bb/utils/app_localizations.dart';

// External package
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CustomTextField extends FormField<String> {
  String? initialValue;
  InputDecoration? decoration;
  final int? maxLines;
  final void Function(String? value)? onChanged;
  final FormFieldValidator<String>? validator;

  CustomTextField({Key? key, required BuildContext context, this.initialValue, this.decoration, this.onChanged, this.validator, this.maxLines}) : super(
    key: key,
    initialValue: initialValue,
    builder: (FormFieldState<String> field) {
      return field.build(field.context);
    }
  );

  @override
  _CustomTextState createState() => _CustomTextState();
}

class _CustomTextState extends FormFieldState<String> {
  final GlobalKey<FormFieldState> _key = GlobalKey<FormFieldState>();

  @override
  CustomTextField get widget => super.widget as CustomTextField;

  @override
  void didChange(String? value) {
    widget.onChanged?.call(value);
    super.didChange(value);
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: widget.decoration!,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          widget.initialValue != null ? json.encode(widget.initialValue!) : '',
          maxLines: 1,
          style: TextStyle(overflow: TextOverflow.ellipsis)
        ),
        trailing: IconButton(
          icon:Icon(Icons.chevron_right),
          onPressed: () async {
            _showDialog();
          }
        )
      )
    );
  }

  _showDialog() async {
    dynamic? text = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return TextInputDialog(
            initialValue: widget.initialValue,
            maxLines: widget.maxLines
          );
        }
    );
    if (text != false) {
      didChange(text);
    }
  }
}
