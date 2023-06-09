import 'package:flutter/material.dart';

// Internal package
import 'package:bab/widgets/paints/rect_slider_thumb_shape.dart';

// External package
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class CustomSlider extends StatelessWidget {
  String label;
  double value;
  double min;
  double max;
  double interval;
  NumberFormat? format;
  String? Function(double value)? onFormatted;

  bool error = false;

  CustomSlider(this.label, this.value, this.min, this.max, this.interval, {this.onFormatted}) {
    if (value < min) {
      error = true;
      value = min;
    }
    if (value > max) {
      error = true;
      value = max;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0)),
        SfSliderTheme(
          data: SfSliderThemeData(
            activeTrackHeight: 4.0,
            inactiveTrackHeight: 2.0,
            activeTrackColor: error ? Colors.red : null,
            inactiveTrackColor: error ? Colors.red : null,
            tooltipBackgroundColor: Theme.of(context).primaryColor,
          ),
          child: SfSlider(
            enableTooltip: false,
            interval: interval,
            min: min,
            max: max,
            thumbShape: RectSliderThumbShape(onFormatted: onFormatted!),
            minorTicksPerInterval: 1,
            value: value,
            onChanged: (dynamic values) {
            },
          )
        )
      ]
    );
  }
}
