import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/utils/app_localizations.dart';

class DropdownDialog extends StatefulWidget {
  final String title;
  final List<DropdownMenuItem<dynamic>>? items;
  final dynamic initialValue;
  final String? hintText;
  DropdownDialog({required this.title, required this.items, this.initialValue, this.hintText});

  @override
  State<StatefulWidget> createState() {
    return _DropdownDialogState();
  }
}

class _DropdownDialogState extends State<DropdownDialog> {
  dynamic _value;

  @override
  Widget build(BuildContext context) {
    if (DeviceHelper.isIOS) {
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
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
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
            Navigator.pop(context, _value);
          }
        )
      ],
    );
  }
}
