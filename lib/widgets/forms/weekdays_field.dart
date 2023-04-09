import 'package:flutter/material.dart';

// Internal package+
import 'package:bb/utils/constants.dart';
import 'package:bb/widgets/form_decoration.dart';


class WeekdaysField extends FormField<List<dynamic>> {
  final void Function(List<dynamic>)? onChanged;
  String? hintText;
  Widget? icon;

  WeekdaysField({Key? key, required BuildContext context, required List<dynamic> value, this.onChanged, this.hintText, this.icon}) : super(
      key: key,
      initialValue: value,
      builder: (FormFieldState<List<dynamic>> field) {
        return field.build(field.context);
      }
  );

  @override
  _WeekdaysFieldState createState() => _WeekdaysFieldState();
}

class _WeekdaysFieldState extends FormFieldState<List<dynamic>> {
  final labels = ['Lu', 'Ma', 'Me', 'Je', 'Ve', 'Sa', 'Di'];
  final values = [
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
    DateTime.saturday,
    DateTime.sunday,
  ];

  @override
  WeekdaysField get widget => super.widget as WeekdaysField;

  @override
  void didChange(List<dynamic>? values) {
    widget.onChanged?.call(values!);
    super.didChange(values);
  }

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];
    for(int i = 0; i < values.length; i++) {
      widgets.add(
        ChoiceChip(
          label: Text(labels[i]),
          selectedColor: PointerColor,
          labelStyle: TextStyle(color:  Colors.white),
          selected: widget.initialValue!.contains(values[i]),
          onSelected: (bool selected) {
            setState(() {
              widget.initialValue!.remove(values[i]);
              if (selected) {
                widget.initialValue!.add(values[i]);
              }
            });
            didChange(widget.initialValue);
          }
        )
      );
    }
    return  InputDecorator(
      decoration: FormDecoration(
        contentPadding: EdgeInsets.all(0.0),
        icon: Icon(Icons.calendar_view_day)
      ),
      child: Container(
        padding: EdgeInsets.only(top: 4, bottom: 16),
        child: Wrap(
          children: widgets,
        )
      )
    );
  }
}
