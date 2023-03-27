import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/widgets/form_decoration.dart';

class SwitchField extends FormField<bool> {
  final void Function(bool)? onChanged;
  String? hintText;
  Widget? icon;

  SwitchField({Key? key, required BuildContext context, required bool value, this.onChanged, this.hintText, this.icon}) : super(
      key: key,
      initialValue: value,
      builder: (FormFieldState<bool> field) {
        return field.build(field.context);
      }
  );

  @override
  _SwitchFieldState createState() => _SwitchFieldState();
}

class _SwitchFieldState extends FormFieldState<bool> {
  @override
  SwitchField get widget => super.widget as SwitchField;

  @override
  void didChange(bool? value) {
    widget.onChanged?.call(value!);
    super.didChange(value);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            readOnly: true,
            decoration: FormDecoration(
              icon: widget.icon,
              hintText: widget.hintText
            )
          ),
        ),
        DeviceHelper.isIOS ? CupertinoSwitch(
            value: widget.initialValue!,
            onChanged: (value) => didChange(value)
        ) : Switch(
            value: widget.initialValue!,
            onChanged: (value) => didChange(value)
        )
      ],
    );
  }
}
