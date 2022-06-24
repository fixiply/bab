import 'package:flutter/material.dart';

// Internal package
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/widgets/gradient_rect_range_slider_track_shape.dart';

// External package
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class FilterReceiptContainer extends StatefulWidget {
  double? startSRM;
  double? endSRM;
  double minIBU = 0.0;
  double maxIBU = 0.0;
  double minAlcohol = 0.0;
  double maxAlcohol = 0.0;
  double? startIBU;
  double? endIBU;
  double? startAlcohol;
  double? endAlcohol;
  RangeValues? srm;
  SfRangeValues? ibu;
  SfRangeValues? alcohol;
  final Function(double start, double end)? onColorChanged;
  final Function(double start, double end)? onIBUhanged;
  final Function(double start, double end)? onAlcoholhanged;
  final Function()? onReset;

  FilterReceiptContainer({Key? key,
    this.startSRM,
    this.endSRM,
    this.minIBU = 0.0,
    this.maxIBU = 0.0,
    this.minAlcohol = 0.0,
    this.maxAlcohol = 0.0,
    this.startIBU,
    this.endIBU,
    this.startAlcohol,
    this.endAlcohol,
    this.ibu,
    this.alcohol,
    this.onColorChanged,
    this.onIBUhanged,
    this.onAlcoholhanged,
    this.onReset
  }) : super(key: key) {
    if (srm == null) srm = RangeValues(startSRM ?? 0, endSRM ?? SRM.length.toDouble());
    if (ibu == null) ibu = SfRangeValues(startIBU ?? minIBU, endIBU ?? maxIBU);
    if (alcohol == null) alcohol = SfRangeValues(startAlcohol ?? minAlcohol, endAlcohol ?? maxAlcohol);
  }

  _FilterReceiptContainerState createState() => new _FilterReceiptContainerState();
}

class _FilterReceiptContainerState extends State<FilterReceiptContainer> {
  double startColorSliderPosition = 0;
  double endColorSliderPosition = -60;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(AppLocalizations.of(context)!.text('color'), style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16.0)),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0.0),
          child: SliderTheme(
            data: SliderThemeData(
              rangeTrackShape: GradientRectRangeSliderTrackShape(),
              thumbColor: Theme.of(context).primaryColor,
              trackHeight: 10,
              rangeThumbShape: RoundRangeSliderThumbShape(
                enabledThumbRadius: 16.0, disabledThumbRadius: 16.0
              )
            ),
            child: RangeSlider(
              onChanged: (values) {
                setState(() {
                  widget.srm = values;
                });
                widget.onColorChanged?.call(values.start, values.end);
              },
              values: widget.srm!,
              min: 0,
              max: SRM.length.toDouble(),
              divisions: SRM.length
            )
          )
        ),
        Text(AppLocalizations.of(context)!.text('bitterness'), style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16.0)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0.0),
          child: SfRangeSliderTheme(
            data: SfRangeSliderThemeData(thumbRadius: 16),
            child: SfRangeSlider(
              values: widget.ibu!,
              min: widget.minIBU,
              max: widget.maxIBU,
              startThumbIcon: thumb(widget.ibu!.start, true),
              endThumbIcon: thumb(widget.ibu!.end, true),
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Theme.of(context).primaryColor.withOpacity(.4),
              onChanged: (values) {
                setState(() {
                  widget.ibu = values;
                });
                widget.onIBUhanged?.call(values.start, values.end);
              },
            ),
          )
        ),
        Text(AppLocalizations.of(context)!.text('alcohol'), style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16.0)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0.0),
          child: SfRangeSliderTheme(
            data: SfRangeSliderThemeData(thumbRadius: 16),
            child: SfRangeSlider(
              values: widget.alcohol!,
              min: widget.minAlcohol,
              max: widget.maxAlcohol,
              interval: 0.1,
              startThumbIcon: thumb(widget.alcohol!.start, false),
              endThumbIcon: thumb(widget.alcohol!.end, false),
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Theme.of(context).primaryColor.withOpacity(.4),
              onChanged: (values) {
                setState(() {
                  widget.alcohol = values;
                });
                widget.onAlcoholhanged?.call(values.start, values.end);
              },
            ),
          )
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.text('reset')),
              style: TextButton.styleFrom(
                primary: Theme.of(context).primaryColor,
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () {
                widget.onReset?.call();
              }
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.text('more')),
              style: TextButton.styleFrom(
                primary: Theme.of(context).primaryColor,
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () {

              }
            )
          ],
        )
      ],
    );
  }

  Widget thumb(double value, bool truncate) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        truncate ? value.toInt().toString() : value.toStringAsFixed(1),
        style: const TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      )
    );
  }
}

