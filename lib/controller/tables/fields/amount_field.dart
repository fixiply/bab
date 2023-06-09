import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package+
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart' as constants;
import 'package:intl/intl.dart';


class AmountField extends FormField<Unit> {
  final List<constants.Enums>? enums;
  final void Function(Unit? value)? onChanged;

  AmountField({Key? key, required Unit value, this.enums, this.onChanged}) : super(
      key: key,
      initialValue: value,
      builder: (FormFieldState<Unit> field) {
        return field.build(field.context);
      }
  );

  @override
  _AmountFieldState createState() => _AmountFieldState();
}

class Unit {
  double? amount;
  Enum? unit;
  Unit(
    this.amount,
    this.unit
  );

  // ignore: hash_and_equals
  @override
  bool operator ==(other) {
    return (other is Unit && other.amount == amount && other.unit == unit);
  }

  @override
  int get hashCode => amount.hashCode;


  @override
  String toString() {
    return 'class: $amount $unit';
  }

  Unit copy() {
    return Unit(
      amount,
      unit
    );
  }
}

class _AmountFieldState extends FormFieldState<Unit> {
  TextEditingController _textController = TextEditingController();

  @override
  AmountField get widget => super.widget as AmountField;

  @override
  void didChange(Unit? value) {
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
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 16.0)
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
              value: value!.unit,
              isDense: true,
              isExpanded: true,
              style: DefaultTextStyle.of(context).style.copyWith(overflow: TextOverflow.ellipsis),
              onChanged: (Enum? e) async {
                value!.unit = e;
                didChange(value);
              },
              items: widget.enums!.map<DropdownMenuItem<Enum>>((Enum e) {
                return DropdownMenuItem<Enum>(
                  value: e,
                  child: LayoutBuilder(
                    builder: (BuildContext ctx, BoxConstraints constraints) {
                      String text = AppLocalizations.of(context)!.text(e.toString().toLowerCase());
                      if (constraints.maxWidth < 32 && e is constants.Unit) {
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
