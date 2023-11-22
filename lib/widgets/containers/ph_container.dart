import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/helpers/formula_helper.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/widgets/form_decoration.dart';

@immutable
class PHContainer extends StatefulWidget {
  bool showTitle;
  bool showVolume;
  double? target;
  double? volume;

  PHContainer({this.showTitle : true, this.showVolume : false, this.target, this.volume});

  @override
  State<StatefulWidget> createState() {
    return _PHContainerState();
  }
}

class _PHContainerState extends State<PHContainer> {

  Acid? _acid = Acid.hydrochloric;
  double? _current;
  double? _quantity;
  double? _concentration = 10;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: DeviceHelper.isLargeScreen(context) ? 320: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showTitle) const Text('Ajustement du pH'),
          if (widget.showVolume) TextFormField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
            ],
            onChanged: (value) {
              widget.volume = AppLocalizations.of(context)!.volume(AppLocalizations.of(context)!.decimal(value));
              _calculate();
            },
            decoration: FormDecoration(
              labelText: AppLocalizations.of(context)!.text('mash_volume'),
              suffixText: AppLocalizations.of(context)!.liquid.toLowerCase(),
              suffixIcon: Tooltip(
                message: AppLocalizations.of(context)!.text('final_volume'),
                child: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
              ),
              border: InputBorder.none,
              fillColor: BlendColor, filled: true
            )
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
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
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: widget.target?.toString() ?? '',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
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
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<Acid>(
                  isExpanded: true,
                  value: _acid,
                  style: DefaultTextStyle.of(context).style.copyWith(overflow: TextOverflow.ellipsis),
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
                      child: Text(AppLocalizations.of(context)!.text(display.toString().toLowerCase()))
                    );
                  }).toList()
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: _concentration?.toString() ?? '',
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
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
              padding: const EdgeInsets.only(top: 10.0),
              child: Text('Quantité d\'acide : ${AppLocalizations.of(context)!.numberFormat(_quantity)} ml', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
            )
          ),
        ]
      )
    );
  }

  _calculate() async {
    debugPrint('current: $_current target: ${widget.target} volume: ${widget.volume} acid: $_acid concentration: $_concentration');
    setState(() {
      _quantity = FormulaHelper.pH(_current, widget.target, widget.volume, _acid, _concentration);
    });
  }
}
