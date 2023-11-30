import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package+
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart' as constants;
import 'package:intl/intl.dart';


class AmountField extends FormField<Amount> {
  final List<constants.Enums>? enums;
  final void Function(Amount? value)? onChanged;

  AmountField({Key? key, required Amount value, this.enums, this.onChanged}) : super(
      key: key,
      initialValue: value,
      builder: (FormFieldState<Amount> field) {
        return field.build(field.context);
      }
  );

  @override
  _AmountFieldState createState() => _AmountFieldState();
}

class Amount {
  double? amount;
  Enum? measurement;
  Amount(
    this.amount,
    this.measurement
  );

  // ignore: hash_and_equals
  @override
  bool operator ==(other) {
    return (other is Amount && other.amount == amount && other.measurement == measurement);
  }

  @override
  int get hashCode => amount.hashCode;


  @override
  String toString() {
    return 'class: $amount $measurement';
  }

  Amount copy() {
    return Amount(
      amount,
      measurement
    );
  }
}

class _AmountFieldState extends FormFieldState<Amount> {
  TextEditingController _textController = TextEditingController();

  @override
  AmountField get widget => super.widget as AmountField;

  @override
  void didChange(Amount? value) {
    widget.onChanged?.call(value);
    super.didChange(value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Flexible(
            child: TextField(
              autofocus: true,
              controller: _textController..text = value!.amount?.toString() ?? '',
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 16.0)
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp('[0-9.,]') )
              ],
              onChanged: (String text) {
                if (text.isNotEmpty) {
                  try {
                    value!.amount = NumberFormat.decimalPattern(AppLocalizations.of(context)!.locale.toString()).parse(text) as double?;
                  } catch(e) {
                    value!.amount = double.tryParse(text);
                  }
                } else {
                  value!.amount = null;
                }
              },
              onSubmitted: (String text) {
                didChange(value);
              }
            ),
          ),
          if (widget.enums != null && widget.enums!.isNotEmpty) const SizedBox(width: 2),
          if (widget.enums != null && widget.enums!.isNotEmpty) Flexible(
            child: DropdownButton<Enum>(
              value: widget.enums!.contains(value!.measurement) ? value!.measurement : null,
              isDense: true,
              isExpanded: true,
              style: DefaultTextStyle.of(context).style.copyWith(overflow: TextOverflow.ellipsis),
              onChanged: (Enum? e) async {
                value!.measurement = e;
                didChange(value);
              },
              items: widget.enums!.map<DropdownMenuItem<Enum>>((Enum e) {
                return DropdownMenuItem<Enum>(
                  value: e,
                  child: LayoutBuilder(
                    builder: (BuildContext ctx, BoxConstraints constraints) {
                      String text = AppLocalizations.of(context)!.text(e.toString().toLowerCase());
                      if (constraints.maxWidth < 32 && e is constants.Measurement) {
                        text = e.symbol ?? '';
                      }
                      return Text(text);
                    }
                  )
                );
              }).toList()
            )
          ),
        ],
      )
    );
  }
}
