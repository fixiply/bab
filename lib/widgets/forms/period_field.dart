
import 'package:flutter/material.dart';

// Internal package+
import 'package:bb/models/period_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/widgets/form_decoration.dart';

class PeriodField extends FormField<PeriodModel> {
  final void Function(PeriodModel)? onChanged;
  String? hintText;
  Widget? icon;

  PeriodField({Key? key, required BuildContext context, required PeriodModel value, this.onChanged, this.hintText, this.icon}) : super(
      key: key,
      initialValue: value,
      builder: (FormFieldState<PeriodModel> field) {
        return field.build(field.context);
      }
  );

  @override
  _PeriodFieldState createState() => _PeriodFieldState();
}

class _PeriodFieldState extends FormFieldState<PeriodModel> {
  
  @override
  void didChange(PeriodModel? value) {
    // widget.onChanged?.call(value!);
    super.didChange(value);
  }

  @override
  Widget build(BuildContext context) {
    return  InputDecorator(
      decoration: FormDecoration(
        contentPadding: EdgeInsets.all(0.0),
        icon: Icon(Icons.date_range_outlined)
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width / 2.5,
            child: TextFormField(
              initialValue: widget.initialValue!.each != null ? widget.initialValue!.each.toString() : null,
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
          SizedBox(width: 4),
          SizedBox(
            width: MediaQuery.of(context).size.width / 2.5,
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
            ),
          ),
        ]
      )
    );
  }
}
