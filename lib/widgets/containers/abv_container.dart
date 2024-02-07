import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/helpers/formula_helper.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/widgets/form_decoration.dart';

class ABVContainer extends StatefulWidget {
  final bool showTitle;

  ABVContainer({this.showTitle = true});

  @override
  State<StatefulWidget> createState() {
    return _ABVContainerState();
  }
}

class _ABVContainerState extends State<ABVContainer> {

  double? _og;
  double? _fg;
  double? _abv;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: DeviceHelper.isLargeScreen(context) ? 320: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showTitle) const Text('ABV - Alcool par volume'),
          TextFormField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
            ],
            onChanged: (value) {
              _og = AppLocalizations.of(context)!.volume(AppLocalizations.of(context)!.decimal(value));
              _calculate();
            },
            decoration: FormDecoration(
                labelText: AppLocalizations.of(context)!.text('oiginal_gravity'),
                hintText: Gravity.sg == AppLocalizations.of(context)!.gravity ? '1.xxx' : null,
                border: InputBorder.none,
                fillColor: BlendColor, filled: true
            )
          ),
          const SizedBox(height: 6),
          TextFormField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
            ],
            onChanged: (value) {
              _fg = AppLocalizations.of(context)!.volume(AppLocalizations.of(context)!.decimal(value));
              _calculate();
            },
            decoration: FormDecoration(
                labelText: AppLocalizations.of(context)!.text('final_gravity'),
                hintText: Gravity.sg == AppLocalizations.of(context)!.gravity ? '1.xxx' : null,
                border: InputBorder.none,
                fillColor: BlendColor, filled: true
            )
          ),
          Container(
            padding: const EdgeInsets.only(top: 10.0),
            child: Table(
              columnWidths: const <int, TableColumnWidth>{
                0: IntrinsicColumnWidth(),
                1: FixedColumnWidth(10),
              },
              children: [
                if (_abv != null && _abv! > 0) TableRow(
                  children: [
                    TableCell(child:  Text('Volume d\'alcool estimé', style: const TextStyle(fontSize: 18))),
                    TableCell(child:  Text(':', style: const TextStyle(fontSize: 18))),
                    TableCell(child: Text(AppLocalizations.of(context)!.numberFormat(_abv, symbol: '%') ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
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
      _abv = FormulaHelper.abv(_og, _fg);
    });
  }
}
