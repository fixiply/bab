import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as Foundation;

// Internal package
import 'package:bb/utils/app_localizations.dart';

class DropdownDialog extends StatefulWidget {
  final String title;
  final List<DropdownMenuItem<dynamic>>? items;
  final dynamic? initialValue;
  final String? hintText;
  DropdownDialog({required this.title, required this.items, this.initialValue, this.hintText});

  @override
  State<StatefulWidget> createState() {
    return _DropdownDialogState();
  }
}

class _DropdownDialogState extends State<DropdownDialog> {
  dynamic? _value;

  Widget build(BuildContext context) {
    if (!Foundation.kIsWeb && Platform.isIOS) {
      return CupertinoAlertDialog(
        title: Text(widget.title),
        content:  DropdownButtonFormField<dynamic>(
          value: widget.initialValue,
          items: widget.items,
          decoration: InputDecoration(
              hintText: widget.hintText
          ),
          onChanged: (value) => setState(() {
            _value = value;
          })
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
              Navigator.pop(context, _value);
            },
          )
        ],
      );
    }
    return  AlertDialog(
      title: Text(widget.title),
      content:  DropdownButtonFormField<dynamic>(
        value: widget.initialValue,
        items: widget.items,
        decoration: InputDecoration(
            hintText: widget.hintText
        ),
        onChanged: (value) => setState(() {
          _value = value;
        })
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
            Navigator.pop(context, _value);
          }
        )
      ],
    );
  }
}
