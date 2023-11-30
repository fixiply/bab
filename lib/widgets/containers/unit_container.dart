import 'package:bab/helpers/color_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/helpers/formula_helper.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/widgets/form_decoration.dart';
import 'package:intl/intl.dart';

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
  int? _srm;
  int? _ebc;
  double? _gravity;
  Gravity _gravityUnit = Gravity.sg;
  double? _sg;
  double? _plato;
  double? _brix;
  double? _temp;
  String _tempUnit = '°C';
  double? _celcius;
  double? _farenheit;
  double? _pressure;
  Pressure _pressureUnit = Pressure.bar;
  double? _bar;
  double? _psi;
  double? _pascal;

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
                    Text(AppLocalizations.of(context)!.text('color'), style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextFormField(
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                      ],
                      onChanged: (value) {
                        _color = AppLocalizations.of(context)!.volume(AppLocalizations.of(context)!.decimal(value));
                        _colorCalculation();
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
                        _colorCalculation();
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
                    Container(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Table(
                        columnWidths: const <int, TableColumnWidth>{
                          0: IntrinsicColumnWidth(),
                          1: FixedColumnWidth(10),
                        },
                        children: [
                          if (_srm != null && _srm! > 0) TableRow(
                            children: [
                              TableCell(child:  Text('SRM', style: const TextStyle(fontSize: 18))),
                              TableCell(child:  Text(':', style: const TextStyle(fontSize: 18))),
                              TableCell(child: Text(_srm?.toString() ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
                            ]
                          ),
                          if (_ebc != null && _ebc! > 0) TableRow(
                            children: [
                              TableCell(child:  Text('EBC', style: const TextStyle(fontSize: 18))),
                              TableCell(child:  Text(':', style: const TextStyle(fontSize: 18))),
                              TableCell(child: Text(_ebc?.toString() ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
                            ]
                          ),
                        ]
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
                    Text(AppLocalizations.of(context)!.text('density'), style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextFormField(
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                      ],
                      onChanged: (value) {
                        _gravity = AppLocalizations.of(context)!.volume(AppLocalizations.of(context)!.decimal(value));
                        _gravityCalculation();
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
                        _gravityCalculation();
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
                    Container(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Table(
                        columnWidths: const <int, TableColumnWidth>{
                          0: IntrinsicColumnWidth(),
                          1: FixedColumnWidth(10),
                        },
                        children: [
                          if (_sg != null && _sg! > 0) TableRow(
                            children: [
                              TableCell(child:  Text(AppLocalizations.of(context)!.text(Gravity.sg.toString().toLowerCase()), style: const TextStyle(fontSize: 18))),
                              TableCell(child:  Text(':', style: const TextStyle(fontSize: 18))),
                              TableCell(child: Text(NumberFormat('0.000', 'en').format(_sg) ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
                            ]
                          ),
                          if (_plato != null && _plato! > 0) TableRow(
                            children: [
                              TableCell(child:  Text(AppLocalizations.of(context)!.text(Gravity.plato.toString().toLowerCase()), style: const TextStyle(fontSize: 18))),
                              TableCell(child:  Text(':', style: const TextStyle(fontSize: 18))),
                              TableCell(child: Text(AppLocalizations.of(context)!.numberFormat(_plato, symbol: '°P') ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
                            ]
                          ),
                          if (_brix != null && _brix! > 0) TableRow(
                            children: [
                              TableCell(child:  Text(AppLocalizations.of(context)!.text(Gravity.brix.toString().toLowerCase()), style: const TextStyle(fontSize: 18))),
                              TableCell(child:  Text(':', style: const TextStyle(fontSize: 18))),
                              TableCell(child: Text(AppLocalizations.of(context)!.numberFormat(_plato, symbol: '°Bx') ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
                            ]
                          ),
                        ]
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
                    Text(AppLocalizations.of(context)!.text('temperature'), style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextFormField(
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                      ],
                      onChanged: (value) {
                        _temp = AppLocalizations.of(context)!.volume(AppLocalizations.of(context)!.decimal(value));
                        _tempCalculation();
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
                      value: _tempUnit,
                      style: DefaultTextStyle.of(context).style.copyWith(overflow: TextOverflow.ellipsis),
                      onChanged: (value) {
                        _tempUnit = value!;
                        _tempCalculation();
                      },
                      decoration: FormDecoration(
                        labelText: AppLocalizations.of(context)!.text('unit'),
                        fillColor: BlendColor,
                        filled: true,
                      ),
                      items: ['°C', '°F'].map((String display) {
                        return DropdownMenuItem<String>(
                            value: display,
                            child: Text(display)
                        );
                      }).toList()
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Table(
                        columnWidths: const <int, TableColumnWidth>{
                          0: IntrinsicColumnWidth(),
                          1: FixedColumnWidth(10),
                        },
                        children: [
                          if (_celcius != null && _celcius! > 0) TableRow(
                            children: [
                              TableCell(child:  Text('Celcius', style: const TextStyle(fontSize: 18))),
                              TableCell(child:  Text(':', style: const TextStyle(fontSize: 18))),
                              TableCell(child: Text(AppLocalizations.of(context)!.numberFormat(_celcius, pattern: "#0.#°C") ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
                            ]
                          ),
                          if (_farenheit != null && _farenheit! > 0) TableRow(
                            children: [
                              TableCell(child:  Text('Farenheit', style: const TextStyle(fontSize: 18))),
                              TableCell(child:  Text(':', style: const TextStyle(fontSize: 18))),
                              TableCell(child: Text(AppLocalizations.of(context)!.numberFormat(_farenheit, pattern: "#0.#°F") ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
                            ]
                          ),
                        ]
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
                    Text(AppLocalizations.of(context)!.text('pressure'), style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                        ],
                        onChanged: (value) {
                          _pressure = AppLocalizations.of(context)!.volume(AppLocalizations.of(context)!.decimal(value));
                          _pressureCalculation();
                        },
                        decoration: FormDecoration(
                            labelText: AppLocalizations.of(context)!.text('value'),
                            border: InputBorder.none,
                            fillColor: BlendColor, filled: true
                        )
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<Pressure>(
                      isExpanded: true,
                      value: _pressureUnit,
                      style: DefaultTextStyle.of(context).style.copyWith(overflow: TextOverflow.ellipsis),
                      onChanged: (value) {
                        _pressureUnit = value!;
                        _pressureCalculation();
                      },
                      decoration: FormDecoration(
                        labelText: AppLocalizations.of(context)!.text('unit'),
                        fillColor: BlendColor,
                        filled: true,
                      ),
                      items: Pressure.values.map((Pressure display) {
                        return DropdownMenuItem<Pressure>(
                            value: display,
                            child: Text(AppLocalizations.of(context)!.text(display.toString().toLowerCase()))
                        );
                      }).toList()
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Table(
                        columnWidths: const <int, TableColumnWidth>{
                          0: IntrinsicColumnWidth(),
                          1: FixedColumnWidth(10),
                        },
                        children: [
                          if (_bar != null && _bar! > 0) TableRow(
                            children: [
                              TableCell(child:  Text(AppLocalizations.of(context)!.text(Pressure.bar.toString().toLowerCase()), style: const TextStyle(fontSize: 18))),
                              TableCell(child:  Text(':', style: const TextStyle(fontSize: 18))),
                              TableCell(child: Text(AppLocalizations.of(context)!.numberFormat(_bar) ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
                            ]
                          ),
                          if (_psi != null && _psi! > 0) TableRow(
                            children: [
                              TableCell(child:  Text(AppLocalizations.of(context)!.text(Pressure.psi.toString().toLowerCase()), style: const TextStyle(fontSize: 18))),
                              TableCell(child:  Text(':', style: const TextStyle(fontSize: 18))),
                              TableCell(child: Text(AppLocalizations.of(context)!.numberFormat(_psi) ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
                            ]
                          ),
                          if (_pascal != null && _pascal! > 0) TableRow(
                            children: [
                              TableCell(child:  Text(AppLocalizations.of(context)!.text(Pressure.pascal.toString().toLowerCase()), style: const TextStyle(fontSize: 18))),
                              TableCell(child:  Text(':', style: const TextStyle(fontSize: 18))),
                              TableCell(child: Text(AppLocalizations.of(context)!.numberFormat(_pascal) ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
                            ]
                          ),
                        ]
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

  _colorCalculation() async {
    setState(() {
      if (_color != null) {
        switch (_colorUnit) {
          case 'EBC':
            _srm = ColorHelper.toSRM(_color);
            _ebc = null;
            break;
          case 'SRM':
            _srm = null;
            _ebc = ColorHelper.toEBC(_color);
            break;
        }
      }
    });
  }

  _gravityCalculation() async {
    setState(() {
      if (_gravity != null) {
        switch(_gravityUnit) {
          case Gravity.sg:
            _sg = null;
            _plato = FormulaHelper.convertSGToPlato(_gravity);
            _brix = FormulaHelper.convertSGToBrix(_gravity);
            break;
          case Gravity.plato:
            _sg = FormulaHelper.convertPlatoToSG(_gravity);
            _plato = null;
            _brix = FormulaHelper.convertPlatoToBrix(_gravity);
            break;
          case Gravity.brix:
            _sg = FormulaHelper.convertBrixToSG(_gravity);
            _plato = FormulaHelper.convertBrixToPlato(_gravity);
            _brix = null;
            break;
        }
      }
    });
  }

  _tempCalculation() async {
    setState(() {
      if (_temp != null) {
        switch (_tempUnit) {
          case '°C':
            _celcius = null;
            _farenheit = FormulaHelper.convertCelciusToFarenheit(_temp);
            break;
          case '°F':
            _farenheit = null;
            _celcius = FormulaHelper.convertFarenheitToCelcius(_temp);
            break;
        }
      }
    });
  }

  _pressureCalculation() async {
    setState(() {
      if (_pressure != null) {
        switch(_pressureUnit) {
          case Pressure.bar:
            _bar = null;
            _psi = FormulaHelper.convertBarToPSI(_pressure);
            _pascal = FormulaHelper.convertBarToPascal(_pressure);
            break;
          case Pressure.psi:
            _bar = FormulaHelper.convertPSIToBar(_pressure);
            _psi = null;
            _pascal = FormulaHelper.convertPSIToPascal(_pressure);
            break;
          case Pressure.pascal:
            _bar = FormulaHelper.convertPascalToBar(_pressure);
            _psi = FormulaHelper.convertPascalToPSI(_pressure);
            _pascal = null;
            break;
        }
      }
    });
  }
}
