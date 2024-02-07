import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bab/helpers/device_helper.dart';

// External package
import 'package:markdown_editable_textinput/markdown_text_input.dart';

class MarkdownInputDialog extends StatefulWidget {
  String? initialValue;
  final String title;
  final String? hintText;
  final int? maxLines;
  MarkdownInputDialog({this.initialValue, required this.title, this.hintText, this.maxLines = 10});

  @override
  State<StatefulWidget> createState() {
    return _MarkdownInputDialogState();
  }
}

class _MarkdownInputDialogState extends State<MarkdownInputDialog> {
  TextEditingController _textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (DeviceHelper.isIOS) {
      return CupertinoAlertDialog(
        title: Text(widget.title),
        content: MarkdownTextInput(
          (String value) => setState(() {
            widget.initialValue = value;
          }),
          widget.initialValue ?? '',
          maxLines: widget.maxLines,
          controller: _textFieldController,
        ),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context, _textFieldController.text);
            }
          )
        ],
      );
    }
    return AlertDialog(
      title: Text(widget.title),
      content: MarkdownTextInput(
        (String value) => setState(() {
          widget.initialValue = value;
        }),
        widget.initialValue ?? '',
        maxLines: widget.maxLines,
        controller: _textFieldController,
      ),
      actions: <Widget>[
        TextButton(
          // textColor: Theme.of(context).colorScheme.secondary,
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          style: TextButton.styleFrom(
            textStyle: const TextStyle(fontSize: 16),
          ),
          onPressed: () {
            Navigator.pop(context);
          }
        ),
        TextButton(
          // textColor: Theme.of(context).colorScheme.secondary,
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
          style: TextButton.styleFrom(
            textStyle: const TextStyle(fontSize: 16),
          ),
          onPressed: () {
            Navigator.pop(context, widget.initialValue);
          }
        )
      ],
    );
  }
}
