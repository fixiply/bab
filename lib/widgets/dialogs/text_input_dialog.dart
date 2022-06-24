import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as Foundation;

// Internal package
import 'package:bb/utils/app_localizations.dart';

class TextInputDialog extends StatefulWidget {
  final String title;
  final String? hintText;
  TextInputDialog({required this.title, this.hintText});

  @override
  State<StatefulWidget> createState() {
    return _TextInputDialogState();
  }
}

class _TextInputDialogState extends State<TextInputDialog> {
  String? _valueText;
  TextEditingController _textFieldController = TextEditingController();

  Widget build(BuildContext context) {
    if (!Foundation.kIsWeb && Platform.isIOS) {
      return CupertinoAlertDialog(
        title: Text(widget.title),
        content: TextField(
            onChanged: (value) {
              setState(() {
                _valueText = value;
              });
            },
            textCapitalization: TextCapitalization.sentences,
            controller: _textFieldController,
            decoration: InputDecoration(
                hintText: widget.hintText
            )
        ),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context)!.text('cancel')),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
              child: Text(AppLocalizations.of(context)!.text('ok')),
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
      content: TextField(
        onChanged: (value) {
          setState(() {
            _valueText = value;
          });
        },
        textCapitalization: TextCapitalization.sentences,
        controller: _textFieldController,
        decoration: InputDecoration(
          hintText: widget.hintText
        )
      ),
      actions: <Widget>[
        TextButton(
          // textColor: Theme.of(context).colorScheme.secondary,
          child: Text(AppLocalizations.of(context)!.text('cancel')),
          style: TextButton.styleFrom(
            textStyle: const TextStyle(fontSize: 16),
          ),
          onPressed: () {
            Navigator.pop(context);
          }
        ),
        TextButton(
          // textColor: Theme.of(context).colorScheme.secondary,
          child: Text(AppLocalizations.of(context)!.text('ok')),
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
