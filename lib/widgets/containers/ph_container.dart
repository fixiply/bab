import 'package:bb/helpers/formula_helper.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/utils/constants.dart';
import 'package:bb/widgets/form_decoration.dart';
import 'package:bb/utils/app_localizations.dart';

class PHContainer extends StatefulWidget {
  double? target;
  double? volume;
  PHContainer({this.target, this.volume});
  @override
  State<StatefulWidget> createState() {
    return _PHContainerState();
  }
}

class _PHContainerState extends State<PHContainer> {

  Acid? _acid;
  double? _current;
  double? _quantity;
  double? _concentration = 10;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Ajustement du pH'),
        Row(
          children: [
            SizedBox(
              width: 150,
              child: TextFormField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  _current = AppLocalizations.of(context)!.volume(AppLocalizations.of(context)!.decimal(value));
                  _calculate();
                },
                decoration: FormDecoration(
                  labelText: 'pH actuel',
                  border: InputBorder.none,
                  fillColor: BlendColor, filled: true
                )
              ),
            ),
            SizedBox(width: 12),
            SizedBox(
              width: 150,
              child: TextFormField(
                initialValue: widget.target?.toString() ?? '',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  widget.target = AppLocalizations.of(context)!.volume(AppLocalizations.of(context)!.decimal(value));
                  _calculate();
                },
                decoration: FormDecoration(
                  labelText: 'pH cible',
                  border: InputBorder.none,
                  fillColor: BlendColor, filled: true
                )
              )
            )
          ]
        ),
        SizedBox(height: 6),
        Row(
          children: [
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<Acid>(
                style: TextStyle(overflow: TextOverflow.ellipsis),
                onChanged: (value) {
                  _acid = value;
                  _calculate();
                },
                decoration: FormDecoration(
                  labelText: AppLocalizations.of(context)!.text('acids'),
                  fillColor: BlendColor,
                  filled: true,
                ),
                items: Acid.values.map((Acid display) {
                  return DropdownMenuItem<Acid>(
                      value: display,
                      child: Text(AppLocalizations.of(context)!.text(display.toString().toLowerCase())));
                }).toList()
              ),
            ),
            SizedBox(width: 12),
            SizedBox(
              width: 80,
              child: TextFormField(
                initialValue: _concentration?.toString() ?? '',
                keyboardType: TextInputType.numberWithOptions(decimal: false),
                onChanged: (value) {
                  _concentration = AppLocalizations.of(context)!.volume(AppLocalizations.of(context)!.decimal(value));
                  _calculate();
                },
                decoration: FormDecoration(
                  labelText: 'Concentration',
                  suffixText: '%',
                  border: InputBorder.none,
                  fillColor: BlendColor, filled: true
                ),
              )
            )
          ]
        ),
        if (_quantity != null && _quantity! > 0) SizedBox(
          width: 312,
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 10.0),
            child: Text('Quantité d\'acide : ${AppLocalizations.of(context)!.numberFormat(_quantity)} ml', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
          )
        ),
      ]
    );
  }

  _calculate() async {
    setState(() {
      _quantity = FormulaHelper.pH(_current, widget.target, widget.volume, _acid, _concentration);
    });
  }
}
