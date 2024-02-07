import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/helpers/formula_helper.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/widgets/form_decoration.dart';

class CarbonationContainer extends StatefulWidget {
  bool showTitle;
  bool showVolume;
  double? volume;

  CarbonationContainer({this.showTitle = true, this.showVolume = false, this.volume});

  @override
  State<StatefulWidget> createState() {
    return _CarbonationContainerState();
  }
}

class _CarbonationContainerState extends State<CarbonationContainer> {

  double? _co2 = 2.2;
  double? _temp = 18;
  double? _cornSugar;
  double? _tableSugar;
  double? _dme;
  double? _candySyrup;
  double? _candySugar;
  double? _blackTreacle;
  double? _brownSugar;
  double? _cornSyrup;
  double? _honey;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: DeviceHelper.isLargeScreen(context) ? 350: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showTitle) const Text('Refermentation en bouteille'),
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
            initialValue: AppLocalizations.of(context)!.numberFormat(_co2) ?? '',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
            ],
            onChanged: (value) {
              _co2 = AppLocalizations.of(context)!.decimal(value);
              _calculate();
            },
            decoration: FormDecoration(
              labelText: AppLocalizations.of(context)!.text('co2_volume'),
              suffixIcon: Tooltip(
                message: AppLocalizations.of(context)!.text('carbonation'),
                child: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
              ),
              border: InputBorder.none,
              fillColor: FillColor, filled: true
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: AppLocalizations.of(context)!.numberFormat(_temp) ?? '',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
            ],
            onChanged: (value) {
              _temp = AppLocalizations.of(context)!.volume(AppLocalizations.of(context)!.decimal(value));
              _calculate();
            },
            decoration: FormDecoration(
              labelText: AppLocalizations.of(context)!.text('fermentation_temperature'),
              suffixText: AppLocalizations.of(context)!.tempMeasure,
              border: InputBorder.none,
              fillColor: BlendColor, filled: true
            )
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.only(top: 10.0),
            child: Table(
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(),
                1: FixedColumnWidth(10),
                2: FixedColumnWidth(80),
              },
              children: [
                if (_cornSugar != null && _cornSugar! > 0) TableRow(
                  children: [
                    TableCell(child:  Text('Sucre de Maïs (Dextrose)', style: const TextStyle(fontSize: 18))),
                    TableCell(child:  Text(':', style: const TextStyle(fontSize: 18))),
                    TableCell(child: Text(AppLocalizations.of(context)!.weightFormat(_cornSugar) ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
                  ]
                ),
                if (_tableSugar != null && _tableSugar! > 0) TableRow(
                  children: [
                    TableCell(child:  Text('Sucre de table (Saccharose)', style: const TextStyle(fontSize: 18))),
                    TableCell(child:  Text(':', style: const TextStyle(fontSize: 18))),
                    TableCell(child: Text(AppLocalizations.of(context)!.weightFormat(_tableSugar) ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
                  ]
                ),
                if (_dme != null && _dme! > 0) TableRow(
                  children: [
                    TableCell(child:  Text('DME (Extraits de Malt Secs)', style: const TextStyle(fontSize: 18))),
                    TableCell(child:  Text(':', style: const TextStyle(fontSize: 18))),
                    TableCell(child: Text(AppLocalizations.of(context)!.weightFormat(_dme) ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
                  ]
                ),
                if (_candySyrup != null && _candySyrup! > 0) TableRow(
                  children: [
                    TableCell(child:  Text('Sirop Belge', style: const TextStyle(fontSize: 18))),
                    TableCell(child:  Text(':', style: const TextStyle(fontSize: 18))),
                    TableCell(child: Text(AppLocalizations.of(context)!.weightFormat(_candySyrup) ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
                  ]
                ),
                if (_candySugar != null && _candySugar! > 0) TableRow(
                  children: [
                    TableCell(child:  Text('Sucre Belge', style: const TextStyle(fontSize: 18))),
                    TableCell(child:  Text(':', style: const TextStyle(fontSize: 18))),
                    TableCell(child: Text(AppLocalizations.of(context)!.weightFormat(_candySugar) ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
                  ]
                ),
                if (_blackTreacle != null && _blackTreacle! > 0) TableRow(
                  children: [
                    TableCell(child:  Text('Mélasse noire', style: const TextStyle(fontSize: 18))),
                    TableCell(child:  Text(':', style: const TextStyle(fontSize: 18))),
                    TableCell(child: Text(AppLocalizations.of(context)!.weightFormat(_blackTreacle) ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
                  ]
                ),
                if (_brownSugar != null && _brownSugar! > 0) TableRow(
                  children: [
                    TableCell(child:  Text('Sucre Brun (Cassonade, Turbinado, Demerara)', style: const TextStyle(fontSize: 18))),
                    TableCell(child:  Text(':', style: const TextStyle(fontSize: 18))),
                    TableCell(child: Text(AppLocalizations.of(context)!.weightFormat(_brownSugar) ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
                  ]
                ),
                if (_cornSyrup != null && _cornSyrup! > 0) TableRow(
                  children: [
                    TableCell(child:  Text('Sirop de Maïs', style: const TextStyle(fontSize: 18))),
                    TableCell(child:  Text(':', style: const TextStyle(fontSize: 18))),
                    TableCell(child: Text(AppLocalizations.of(context)!.weightFormat(_cornSyrup) ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
                  ]
                ),
                if (_honey != null && _honey! > 0) TableRow(
                  children: [
                    TableCell(child:  Text('Miel', style: const TextStyle(fontSize: 18))),
                    TableCell(child:  Text(':', style: const TextStyle(fontSize: 18))),
                    TableCell(child: Text(AppLocalizations.of(context)!.weightFormat(_honey) ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
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
      _cornSugar = FormulaHelper.primingSugar(widget.volume, _co2, temperature: _temp, attenuation: 0.91);
      _tableSugar = FormulaHelper.primingSugar(widget.volume, _co2, temperature: _temp, attenuation: 1.0);
      _dme = FormulaHelper.primingSugar(widget.volume, _co2, temperature: _temp, attenuation: 0.68);
      _candySyrup = FormulaHelper.primingSugar(widget.volume, _co2, temperature: _temp, attenuation: 0.82);
      _candySugar = FormulaHelper.primingSugar(widget.volume, _co2, temperature: _temp, attenuation: 0.87);
      _blackTreacle = FormulaHelper.primingSugar(widget.volume, _co2, temperature: _temp, attenuation: 0.55);
      _brownSugar = FormulaHelper.primingSugar(widget.volume, _co2, temperature: _temp, attenuation: 0.90);
      _cornSyrup = FormulaHelper.primingSugar(widget.volume, _co2, temperature: _temp, attenuation: 1.0);
      _honey = FormulaHelper.primingSugar(widget.volume, _co2, temperature: _temp, attenuation: 0.78);
    });
  }
}
