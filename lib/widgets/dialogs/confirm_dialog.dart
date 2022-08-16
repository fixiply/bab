import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as Foundation;

// Internal package
import 'package:bb/utils/app_localizations.dart';

class ConfirmDialog extends StatefulWidget {
  final String? title;
  final Widget content;

  final void Function()? onOk;
  final void Function()? onCancel;

  ConfirmDialog({this.title, required this.content, this.onOk, this.onCancel});

  @override
  State<StatefulWidget> createState() {
    return _ConfirmDialogState();
  }
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  Widget build(BuildContext context) {
    if (!Foundation.kIsWeb && Platform.isIOS) {
      return CupertinoAlertDialog(
        title: widget.title != null ? Text(widget.title!) : null,
        content: widget.content,
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context)!.text('cancel')),
            onPressed: () {
              if (widget.onCancel != null) {
                widget.onCancel?.call();
                return;
              }
              Navigator.pop(context, false);
            },
          ),
          CupertinoDialogAction(
              child: Text(AppLocalizations.of(context)!.text('ok')),
              isDestructiveAction: true,
              onPressed: () {
                if (widget.onOk != null) {
                  widget.onOk?.call();
                  return;
                }
                Navigator.pop(context, true);
              }
          )
        ],
      );
    }
    return AlertDialog(
      title: widget.title != null ? Text(widget.title!) : null,
      content: widget.content,
      actions: <Widget>[
        TextButton(
          child: Text(AppLocalizations.of(context)!.text('cancel')),
          style: TextButton.styleFrom(
            primary: Theme.of(context).primaryColor,
            textStyle: const TextStyle(fontSize: 16),
          ),
          onPressed: () {
            if (widget.onCancel != null) {
              widget.onCancel?.call();
              return;
            }
            Navigator.pop(context, false);
          }
        ),
        TextButton(
          // textColor: Theme.of(context).colorScheme.secondary,
          child: Text(AppLocalizations.of(context)!.text('ok')),
          style: TextButton.styleFrom(
            primary: Theme.of(context).primaryColor,
            textStyle: const TextStyle(fontSize: 16),
          ),
          onPressed: () {
            if (widget.onOk != null) {
              widget.onOk?.call();
              return;
            }
            Navigator.pop(context, true);
          }
        )
      ],
    );
  }
}
