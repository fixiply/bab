import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/utils/app_localizations.dart';

class ConfirmDialog extends StatefulWidget {
  final String? title;
  final scrollable;
  final Widget content;
  final void Function()? onOk;
  final void Function()? onCancel;
  final String? ok;
  final String? cancel;
  final bool? enabled;
  ConfirmDialog({this.title, this.scrollable = false, required this.content, this.onOk, this.onCancel, this.ok, this.cancel, this.enabled = true});

  @override
  State<StatefulWidget> createState() {
    return _ConfirmDialogState();
  }
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  Widget build(BuildContext context) {
    if (DeviceHelper.isIOS) {
      return CupertinoAlertDialog(
        title: widget.title != null ? Text(widget.title!) : null,
        content: widget.content,
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: Text(widget.cancel ?? AppLocalizations.of(context)!.text('cancel')),
            onPressed: () {
              if (widget.onCancel != null) {
                widget.onCancel?.call();
                return;
              }
              Navigator.pop(context, false);
            },
          ),
          CupertinoDialogAction(
              child: Text(widget.ok ?? AppLocalizations.of(context)!.text('ok')),
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
      scrollable: widget.scrollable,
      title: widget.title != null ? Center(child: Text(widget.title!)) : null,
      content: widget.content,
      actions: <Widget>[
        TextButton(
          child: Text(widget.cancel ?? AppLocalizations.of(context)!.text('cancel')),
          style: TextButton.styleFrom(
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
          child: Text(widget.ok ?? AppLocalizations.of(context)!.text('ok')),
          style: TextButton.styleFrom(
            textStyle: const TextStyle(fontSize: 16),
          ),
          onPressed: widget.enabled == true ? () {
            if (widget.onOk != null) {
              widget.onOk?.call();
              return;
            }
            Navigator.pop(context, true);
          } : null
        )
      ],
    );
  }
}
