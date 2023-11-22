import 'package:bab/helpers/color_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/helpers/formula_helper.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/widgets/form_decoration.dart';

class UnitContainer extends StatefulWidget {
  final bool showTitle;

  UnitContainer({this.showTitle : true});

  @override
  State<StatefulWidget> createState() {
    return _UnitContainerState();
  }
}

class _UnitContainerState extends State<UnitContainer> {

  double? _color;
  String _colorUnit = 'EBC';
  String? _colorText;
  double? _gravity;
  Gravity _gravityUnit = Gravity.sg;
  String? _gravitySG;
  String? _gravityPlato;
  String? _gravityBrix;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _colorUnit = AppLocalizations.of(context)!.colorUnit;
      _gravityUnit = AppLocalizations.of(context)!.gravity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showTitle) const Text('Convertisseurs d\'unités'),
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: [
            SizedBox(
              width: DeviceHelper.isLargeScreen(context) ? 320: null,
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(AppLocalizations.of(context)!.text('color'), style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextFormField(
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                      ],
                      onChanged: (value) {
                        _color = AppLocalizations.of(context)!.volume(AppLocalizations.of(context)!.decimal(value));
                        _calculate();
                      },
                      decoration: FormDecoration(
                          labelText: AppLocalizations.of(context)!.text('value'),
                          border: InputBorder.none,
                          fillColor: BlendColor, filled: true
                      )
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _colorUnit,
                      style: DefaultTextStyle.of(context).style.copyWith(overflow: TextOverflow.ellipsis),
                      onChanged: (value) {
                        _colorUnit = value!;
                        _calculate();
                      },
                      decoration: FormDecoration(
                        labelText: AppLocalizations.of(context)!.text('unit'),
                        fillColor: BlendColor,
                        filled: true,
                      ),
                      items: ['EBC', 'SRM'].map((String display) {
                        return DropdownMenuItem<String>(
                            value: display,
                            child: Text(display)
                        );
                      }).toList()
                    ),
                    if (_color != null && (_colorText != null && _colorText!.isNotEmpty)) SizedBox(
                        width: 312,
                        child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(_colorText!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                        )
                    ),
                  ]
                ),
              )
            ),
            SizedBox(
              width: DeviceHelper.isLargeScreen(context) ? 320: null,
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(AppLocalizations.of(context)!.text('density'), style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextFormField(
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                      ],
                      onChanged: (value) {
                        _gravity = AppLocalizations.of(context)!.volume(AppLocalizations.of(context)!.decimal(value));
                        _calculate();
                      },
                      decoration: FormDecoration(
                        labelText: AppLocalizations.of(context)!.text('value'),
                        hintText: _gravityUnit == Gravity.sg ? '1.xxx' : null,
                        border: InputBorder.none,
                        fillColor: BlendColor, filled: true
                      )
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<Gravity>(
                      isExpanded: true,
                      value: _gravityUnit,
                      style: DefaultTextStyle.of(context).style.copyWith(overflow: TextOverflow.ellipsis),
                      onChanged: (value) {
                        _gravityUnit = value!;
                        _calculate();
                      },
                      decoration: FormDecoration(
                        labelText: AppLocalizations.of(context)!.text('unit'),
                        fillColor: BlendColor,
                        filled: true,
                      ),
                      items: Gravity.values.map((Gravity display) {
                        return DropdownMenuItem<Gravity>(
                            value: display,
                            child: Text(AppLocalizations.of(context)!.text(display.toString().toLowerCase()))
                        );
                      }).toList()
                    ),
                    if (_gravity != null && ((_gravitySG != null && _gravitySG!.isNotEmpty) ||
                        (_gravityPlato != null && _gravityPlato!.isNotEmpty) ||
                        (_gravityBrix != null && _gravityBrix!.isNotEmpty))) SizedBox(
                      width: 312,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Column(
                          children: [
                            if (_gravitySG != null && _gravitySG!.isNotEmpty) Text('${AppLocalizations.of(context)!.text(Gravity.sg.toString().toLowerCase())} : $_gravitySG', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            if (_gravityPlato != null && _gravityPlato!.isNotEmpty) Text('${AppLocalizations.of(context)!.text(Gravity.plato.toString().toLowerCase())} : $_gravityPlato', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            if (_gravityBrix != null && _gravityBrix!.isNotEmpty) Text('${AppLocalizations.of(context)!.text(Gravity.brix.toString().toLowerCase())} : $_gravityBrix', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                          ]
                        )
                      )
                    ),
                  ]
                ),
              )
            )
          ],
        ),
      ]
    );
  }

  _calculate() async {
    setState(() {
      if (_color != null) {
        switch (_colorUnit) {
          case 'EBC':
            _colorText = 'SRM : ${ColorHelper.toSRM(_color)}';
            break;
          case 'SRM':
            _colorText = 'EBC : ${ColorHelper.toEBC(_color)}';
            break;
        }
      }
      if (_gravity != null) {
        switch(_gravityUnit) {
          case Gravity.sg:
            _gravityPlato = AppLocalizations.of(context)!.gravityFormat(FormulaHelper.convertSGToPlato(_gravity), gravity: Gravity.plato);
            _gravityBrix = AppLocalizations.of(context)!.gravityFormat(FormulaHelper.convertSGToBrix(_gravity), gravity: Gravity.brix);
            break;
          case Gravity.plato:
            _gravitySG = AppLocalizations.of(context)!.gravityFormat(FormulaHelper.convertPlatoToSG(_gravity), gravity: Gravity.sg);
            _gravityBrix = AppLocalizations.of(context)!.gravityFormat(FormulaHelper.convertPlatoToBrix(_gravity), gravity: Gravity.brix);
            break;
          case Gravity.brix:
            _gravitySG = AppLocalizations.of(context)!.gravityFormat(FormulaHelper.convertBrixToSG(_gravity), gravity: Gravity.sg);
            _gravityPlato = AppLocalizations.of(context)!.gravityFormat(FormulaHelper.convertBrixToPlato(_gravity), gravity: Gravity.plato);
            break;
        }
      }
    });
  }
}
