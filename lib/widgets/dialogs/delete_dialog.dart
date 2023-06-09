import 'package:flutter/material.dart';

// Internal package
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/helpers/class_helper.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/widgets/dialogs/confirm_dialog.dart';

class DeleteDialog extends StatefulWidget {
  final String? title;
  final bool? displayBody;
  final String? okText;
  final String? cancelText;
  DeleteDialog({this.title, this.okText, this.cancelText, this.displayBody = true});

  @override
  State<StatefulWidget> createState() {
    return _DeleteDialogState();
  }

  static Future<bool> model(BuildContext context, dynamic model, {bool forced = false}) async {
    bool archive = ClassHelper.hasStatus(model) && model.status != Status.disabled;
    String title = archive && !forced ? AppLocalizations.of(context)!.text('archive_title') : AppLocalizations.of(context)!.text('delete_item_title');
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteDialog(
          title: title,
          displayBody: archive != true,
          okText: archive ? AppLocalizations.of(context)!.text('archive') : null
        );
      }
    );
    if (confirm) {
      bool deleted = true;
      await Database().delete(model, forced: forced).onError((e, s) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 10)
          )
        );
        deleted = false;
      });
      return deleted;
    }
    return false;
  }
}

class _DeleteDialogState extends State<DeleteDialog> {
  @override
  Widget build(BuildContext context) {
    return ConfirmDialog(
      title: widget.title ?? AppLocalizations.of(context)!.text('delete_item_title'),
      content: SingleChildScrollView(
        child: widget.displayBody == true ? ListBody(
          children: <Widget>[
            Text(AppLocalizations.of(context)!.text('remove_body')),
          ]
        ) : null
      ),
    );
  }
}
