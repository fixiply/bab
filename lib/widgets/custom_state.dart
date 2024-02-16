import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@optionalTypeArgs
abstract class CustomState<T extends StatefulWidget> extends State<T> {
  showSnackbar(String msg, {SnackBarAction? action, VoidCallback? onClosed, bool success = true}) {
    final snackBar = success
        ? SnackBar(content: Text(msg), action: action)
        : SnackBar(content: Text(msg), action: action, backgroundColor: Colors.red);
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar).closed.then((value) => onClosed?.call());
  }

  String prettyException(String prefix, dynamic e) {
    if (e is PlatformException) {
      return "$prefix ${e.message}";
    }
    return prefix + e.toString();
  }
}
