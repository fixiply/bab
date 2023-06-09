import 'package:flutter/material.dart';

// Internal package
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/widgets/form_decoration.dart';

class DateTimeField extends FormField<DateTime?> {
  DateTime? datetime;
  InputDecoration? decoration;
  bool? hour;
  final void Function(DateTime? value)? onChanged;
  @override
  final FormFieldValidator<dynamic>? validator;

  DateTimeField({Key? key, required BuildContext context, this.datetime, this.decoration, this.onChanged, this.hour = true, AutovalidateMode? autovalidateMode, this.validator}) : super(
      key: key,
      initialValue: datetime,
      autovalidateMode: autovalidateMode,
      validator: validator,
      builder: (FormFieldState<DateTime?> field) {
        return field.build(field.context);
      }
  );

  @override
  _DateTimeFieldState createState() => _DateTimeFieldState();
}

class _DateTimeFieldState extends FormFieldState<DateTime?> {
  TextEditingController dateInput = TextEditingController();

  @override
  DateTimeField get widget => super.widget as DateTimeField;

  @override
  void didChange(DateTime? value) {
    widget.onChanged?.call(value);
    super.didChange(value);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: TextEditingController()..text = format(widget.initialValue) ?? '',
      readOnly: true,
      decoration: widget.decoration ?? FormDecoration(
        contentPadding: const EdgeInsets.all(0.0),
        icon: const Icon(Icons.date_range)
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            //DateTime.now() - not to allow to choose before today.
            lastDate: DateTime(2100)
        );
        if (widget.hour == true) {
          if (pickedDate != null) {
            TimeOfDay? pickedTime = await showTimePicker(
              initialTime: TimeOfDay.now(),
              context: context,
            );
            if (pickedTime != null) {
              pickedDate = pickedDate.copyWith(hour: pickedTime.hour, minute: pickedTime.minute);
            }
          }
        }
        if (pickedDate != null) {
          dateInput.text = format(pickedDate) ?? '';
          didChange(pickedDate);
        }
      },
    );
  }

  String? format(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    }
    if (widget.hour == true) {
      return dateInput.text = AppLocalizations.of(context)!.datetimeFormat(dateTime) ?? '';
    }
    return dateInput.text = AppLocalizations.of(context)!.dateFormat(dateTime) ?? '';
  }
}
