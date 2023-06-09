import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/utils/app_localizations.dart';

class TextInputDialog extends StatefulWidget {
  String? initialValue;
  final String? title;
  final String? hintText;
  final int? maxLines;
  TextInputDialog({this.initialValue, this.title, this.hintText, this.maxLines});

  @override
  State<StatefulWidget> createState() {
    return _TextInputDialogState();
  }
}

class _TextInputDialogState extends State<TextInputDialog> {
  late TextEditingController _textFieldController;

  @override
  void initState() {
    super.initState();
    _textFieldController = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  Widget build(BuildContext context) {
    if (DeviceHelper.isIOS) {
      return CupertinoAlertDialog(
        title: widget.title != null ? Text(widget.title!) : null,
        content: TextField(
          maxLines: widget.maxLines,
          controller: _textFieldController,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0)
            ),
          )
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
      title: widget.title != null ? Text(widget.title!) : null,
      content: TextField(
        maxLines: widget.maxLines,
        controller: _textFieldController,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: const OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0)
          ),
        )
      ),
      actions: <Widget>[
        TextButton(
          // textColor: Theme.of(context).colorScheme.secondary,
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          style: TextButton.styleFrom(
            textStyle: const TextStyle(fontSize: 16),
          ),
          onPressed: () {
            Navigator.pop(context, false);
          }
        ),
        TextButton(
          // textColor: Theme.of(context).colorScheme.secondary,
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
          style: TextButton.styleFrom(
            textStyle: const TextStyle(fontSize: 16),
          ),
          onPressed: () {
            Navigator.pop(context, _textFieldController.text);
          }
        )
      ],
    );
  }
}
