import 'package:flutter/material.dart';

// Internal package
import 'package:bab/models/model.dart';
import 'package:bab/utils/app_localizations.dart';

class CustomDismissible<Object> extends Dismissible {
  CustomDismissible(BuildContext context, {required Widget child, required Key key, Function()? onStart, Function()? onEnd}) : super(
    key: key,
    child: child,
    background: Container(
      color: Colors.blueAccent,
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.edit, color: Colors.white, size: 20),
          const SizedBox(width: 16.0),
          Text(AppLocalizations.of(context)!.text('edit').toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 15))
        ],
      ),
    ),
    secondaryBackground: Container(
      color: Colors.redAccent,
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(AppLocalizations.of(context)!.text('delete').toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 15)),
          const SizedBox(width: 16.0),
          const Icon(Icons.delete, color: Colors.white, size: 20),
        ],
      ),
    ),
    confirmDismiss: (direction) async {
      if (direction == DismissDirection.startToEnd) {
        onStart?.call();
        return false;
      } else if (direction == DismissDirection.endToStart) {
        return await onEnd?.call();
      }
      return false;
    }
  );
}
