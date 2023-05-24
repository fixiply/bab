
import 'package:flutter/material.dart';

// Internal package+
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/term.dart';
import 'package:bb/widgets/form_decoration.dart';

class PeriodField extends FormField<Term> {
  final void Function(Term)? onChanged;
  String? hintText;
  Widget? icon;

  PeriodField({Key? key, required BuildContext context, required Term value, this.onChanged, this.hintText, this.icon}) : super(
      key: key,
      initialValue: value,
      builder: (FormFieldState<Term> field) {
        return field.build(field.context);
      }
  );

  @override
  _PeriodFieldState createState() => _PeriodFieldState();
}

class _PeriodFieldState extends FormFieldState<Term> {
  
  @override
  void didChange(Term? value) {
    // widget.onChanged?.call(value!);
    super.didChange(value);
  }

  @override
  Widget build(BuildContext context) {
    return  InputDecorator(
      decoration: FormDecoration(
        contentPadding: const EdgeInsets.all(0.0),
        icon: const Icon(Icons.date_range_outlined)
      ),
      child: Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: widget.initialValue!.each.toString(),
                keyboardType: TextInputType.number,
                onChanged: (value) => setState(() {
                  widget.initialValue!.each = int.tryParse(value);
                  didChange(widget.initialValue);
                }),
                decoration: FormDecoration(
                    labelText: AppLocalizations.of(context)!.text('period'),
                    border: InputBorder.none,
                    fillColor: FillColor, filled: true
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<Period>(
                value: widget.initialValue!.period,
                items: Period.values.map((Period period) {
                  return DropdownMenuItem<Period>(
                      value: period,
                      child: Text(AppLocalizations.of(context)!.text(period.toString().toLowerCase())));
                }).toList(),
                onChanged: (value) => setState(() {
                  widget.initialValue!.period = value;
                  didChange(widget.initialValue);
                }),
                decoration: FormDecoration(),
              )
            ),
          ],
      )
    );
  }
}
