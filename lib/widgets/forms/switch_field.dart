import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' as Foundation;
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/widgets/form_decoration.dart';

class SwitchField extends FormField<bool> {
  SwitchField({required bool value, required ValueChanged<bool> onChanged, required String hintText, required Icon icon}) : super(
    builder: (FormFieldState<bool> field) {
      return Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              readOnly: true,
              decoration: FormDecoration(
                icon: icon,
                hintText: hintText
              )
            ),
          ),
          !Foundation.kIsWeb && Platform.isIOS ? CupertinoSwitch(
            value: value,
            onChanged: onChanged
          ) : Switch(
            value: value,
            onChanged: onChanged
          )
        ],
      );
    }
  );
}
