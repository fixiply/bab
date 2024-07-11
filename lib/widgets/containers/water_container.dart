import 'package:bab/widgets/forms/duration_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/helpers/formula_helper.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/widgets/form_decoration.dart';

@immutable
class WaterContainer extends StatefulWidget {
  bool showTitle;
  bool showVolume;
  double? volume;

  WaterContainer({this.showTitle = true, this.showVolume = false, this.volume = 20});

  @override
  State<StatefulWidget> createState() {
    return _WaterContainerState();
  }
}

class _WaterContainerState extends State<WaterContainer> {

  double? _og = 1.050;
  double? _mass;
  int? _boil = 60;
  double? _mash;
  double? _sparge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: DeviceHelper.isLargeScreen ? 320: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showTitle) const Text('Eau d\'empâtage et de rincage'),
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
          TextFormField(
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
          const SizedBox(height: 6),
          DurationField(
            value: _boil ?? 0,
            showIcon: false,
            label: AppLocalizations.of(context)!.text('boiling_time'),
            onChanged: (value) {
              _boil = value;
            },
          ),
          Container(
            padding: const EdgeInsets.only(top: 10.0),
            child: Table(
              columnWidths: const <int, TableColumnWidth>{
                1: FixedColumnWidth(10),
              },
              children: [
                if (_mash != null && _mash! > 0) TableRow(
                  children: [
                    TableCell(child:  Text(AppLocalizations.of(context)!.text('mash_water'), style: const TextStyle(fontSize: 18))),
                    TableCell(child:  Text(':', style: const TextStyle(fontSize: 18))),
                    TableCell(child: Text(AppLocalizations.of(context)!.litterVolumeFormat(_mash) ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
                  ]
                ),
                if (_sparge != null && _sparge! > 0) TableRow(
                  children: [
                    TableCell(child:  Text(AppLocalizations.of(context)!.text('sparge_water'), style: const TextStyle(fontSize: 18))),
                    TableCell(child:  Text(':', style: const TextStyle(fontSize: 18))),
                    TableCell(child: Text(AppLocalizations.of(context)!.litterVolumeFormat(_sparge) ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
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
      double? ratio = FormulaHelper.ratio(widget.volume,  _mass);
      if (ratio != null) {
        _mash = FormulaHelper.mashWater(_mass, ratio, 0);
        var preboil = FormulaHelper.preboilVolume(widget.volume, DEFAULT_BOIL_LOSS, DEFAULT_WORT_SHRINKAGE, duration: _boil!);
        _sparge = FormulaHelper.spargeWater(_mass, preboil, _mash, absorption: _og);
      }
    });
  }
}
