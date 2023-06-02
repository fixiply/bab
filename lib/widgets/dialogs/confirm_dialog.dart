import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/helpers/device_helper.dart';

class ConfirmDialog extends StatefulWidget {
  final String? title;
  final scrollable;
  final Widget content;
  final void Function()? onOk;
  final void Function()? onCancel;
  final String? ok;
  final String? cancel;
  final bool? showCancel;
  final bool? enabled;
  ConfirmDialog({this.title, this.scrollable = false, required this.content, this.onOk, this.onCancel, this.ok, this.cancel, this.showCancel = true, this.enabled = true});

  @override
  State<StatefulWidget> createState() {
    return _ConfirmDialogState();
  }
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  @override
  Widget build(BuildContext context) {
    if (DeviceHelper.isIOS) {
      return CupertinoAlertDialog(
        title: widget.title != null ? Text(widget.title!) : null,
        content: widget.content,
        actions: <CupertinoDialogAction>[
          if (widget.showCancel == true) CupertinoDialogAction(
            child: Text(widget.cancel ?? MaterialLocalizations.of(context).cancelButtonLabel),
            onPressed: () {
              if (widget.onCancel != null) {
                widget.onCancel?.call();
                return;
              }
              Navigator.pop(context, false);
            },
          ),
          CupertinoDialogAction(
              child: Text(widget.ok ?? MaterialLocalizations.of(context).okButtonLabel),
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
        if (widget.showCancel == true) TextButton(
          child: Text(widget.cancel ?? MaterialLocalizations.of(context).cancelButtonLabel),
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
          child: Text(widget.ok ?? MaterialLocalizations.of(context).okButtonLabel),
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
