import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/helpers/formula_helper.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/widgets/form_decoration.dart';

@immutable
class EfficiencyContainer extends StatefulWidget {
  bool showTitle;
  bool showVolume;
  double? target;
  double? volume;

  EfficiencyContainer({this.showTitle = true, this.showVolume = false, this.target, this.volume = 20});

  @override
  State<StatefulWidget> createState() {
    return _EfficiencyContainerState();
  }
}

class _EfficiencyContainerState extends State<EfficiencyContainer> {

  double? _og = 1.050;
  double? _mass;
  double? _yield = 80;
  double? _efficiency;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: DeviceHelper.isLargeScreen ? 320: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showTitle) const Text('Efficacité de l\'empâtage'),
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
          TextFormField(
            initialValue: AppLocalizations.of(context)!.gravityFormat(_og, symbol: false) ?? '',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
            ],
            onChanged: (value) {
              _og = AppLocalizations.of(context)!.decimal(value);
              _calculate();
            },
            decoration: FormDecoration(
              labelText: AppLocalizations.of(context)!.text('oiginal_gravity'),
              hintText: Gravity.sg == AppLocalizations.of(context)!.gravity ? '1.xxx' : null,
              suffixIcon: Tooltip(
                message: AppLocalizations.of(context)!.text('oiginal_gravity_tooltip'),
                child: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
              ),
              border: InputBorder.none,
              fillColor: FillColor, filled: true
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _mass?.toString() ?? '',
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  onChanged: (value) {
                    _mass = AppLocalizations.of(context)!.volume(AppLocalizations.of(context)!.decimal(value));
                    _calculate();
                  },
                  decoration: FormDecoration(
                    labelText: AppLocalizations.of(context)!.text('weight'),
                    suffixText: AppLocalizations.of(context)!.weightSuffix(measurement: Measurement.kilo),
                    suffixIcon: Tooltip(
                      message: AppLocalizations.of(context)!.text('quantity_grains'),
                      child: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
                    ),
                    border: InputBorder.none,
                    fillColor: BlendColor, filled: true
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: _yield?.toString() ?? '',
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  onChanged: (value) {
                    _yield = AppLocalizations.of(context)!.volume(AppLocalizations.of(context)!.decimal(value));
                    _calculate();
                  },
                  decoration: FormDecoration(
                    labelText: AppLocalizations.of(context)!.text('yield'),
                    suffixText: '%',
                    suffixIcon: Tooltip(
                      message: AppLocalizations.of(context)!.text('average_grain_yield'),
                      child: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
                    ),
                    border: InputBorder.none,
                    fillColor: BlendColor, filled: true
                  ),
                )
              )
            ]
          ),
          Container(
            padding: const EdgeInsets.only(top: 10.0),
            child: Table(
              columnWidths: const <int, TableColumnWidth>{
                0: IntrinsicColumnWidth(),
                1: FixedColumnWidth(10),
              },
              children: [
                if (_efficiency != null && _efficiency! > 0) TableRow(
                    children: [
                      TableCell(child:  Text(AppLocalizations.of(context)!.text('efficiency'), style: const TextStyle(fontSize: 18))),
                      TableCell(child:  Text(':', style: const TextStyle(fontSize: 18))),
                      TableCell(child: Text(AppLocalizations.of(context)!.numberFormat(_efficiency, symbol: '%') ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
                    ]
                ),
              ]
            )
          ),
        ]
      )
    );
  }

  _calculate() async {
    setState(() {
      _efficiency = FormulaHelper.efficiency(widget.volume, _og, _mass, _yield);
    });
  }
}
