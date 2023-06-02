import 'package:flutter/material.dart';

// Internal package+
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/widgets/duration_picker.dart';
import 'package:bb/widgets/form_decoration.dart';

class DurationField extends FormField<int> {
  final void Function(int? value)? onChanged;
  String? label;
  Icon? icon;
  @override
  final FormFieldValidator<dynamic>? validator;

  DurationField({Key? key, required int value, this.onChanged, this.label, this.icon, this.validator}) : super(
      key: key,
      initialValue: value,
      builder: (FormFieldState<int> field) {
        return field.build(field.context);
      }
  );

  @override
  _DurationFieldState createState() => _DurationFieldState();
}

class _DurationFieldState extends FormFieldState<int> {
  TextEditingController _textController = TextEditingController();

  @override
  DurationField get widget => super.widget as DurationField;

  @override
  void didChange(int? value) {
    widget.onChanged?.call(value);
    super.didChange(value);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      controller: _textController..text = AppLocalizations.of(context)!.numberFormat(widget.initialValue) ?? '',
      decoration: FormDecoration(
        icon: widget.icon ?? Icon(Icons.timer_outlined),
        labelText: widget.label ?? AppLocalizations.of(context)!.text('duration'),
        suffixText: 'minutes',
        border: InputBorder.none,
        fillColor: FillColor, filled: true
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: widget.validator,
      onTap: () async {
        var duration = await showDurationPicker(
          context: context,
          initialTime: Duration(minutes:  widget.initialValue ?? 0),
          // showOkButton: false,
          // onComplete: (duration, context) {
          //   _textController.text = AppLocalizations.of(context)!.numberFormat(duration.inMinutes) ?? '';
          //   didChange(duration.inMinutes);
          //   Navigator.pop(context);
          // }
        );
        if (duration != null)  {
          _textController.text = AppLocalizations.of(context)!.numberFormat(duration.inMinutes) ?? '';
          didChange(duration.inMinutes);
        }
      },
    );
  }
}
