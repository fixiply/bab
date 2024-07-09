import 'package:bab/utils/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// External package
import 'package:syncfusion_flutter_gauges/gauges.dart';

class CustomGauge extends SfRadialGauge {
  CustomGauge(BuildContext context,{Key? key, List<GaugeAnnotation>? annotations, List<GaugePointer>? pointers}) : super(
    key: key,
    animationDuration: 1500,
    enableLoadingAnimation: true,
    axes: <RadialAxis>[
      RadialAxis(
        minimum: 0,
        maximum: 100,
        minorTicksPerInterval: 9,
        radiusFactor: 0.9,
        showAxisLine: false,
        axisLabelStyle: GaugeTextStyle(fontSize: 12),
        majorTickStyle: MajorTickStyle(length: 0.25, lengthUnit: GaugeSizeUnit.factor),
        minorTickStyle: MinorTickStyle(length: 0.13, lengthUnit: GaugeSizeUnit.factor, thickness: 1),
        ranges: <GaugeRange>[
          GaugeRange(
            startValue: 0,
            endValue: 10,
            startWidth: 0.265,
            sizeUnit: GaugeSizeUnit.factor,
            endWidth: 0.265,
            color: const Color.fromRGBO(34, 195, 199, 0.75)
          ),
          GaugeRange(
            startValue: 10,
            endValue: 30,
            startWidth: 0.265,
            sizeUnit: GaugeSizeUnit.factor,
            endWidth: 0.265,
            color: const Color.fromRGBO(123, 199, 34, 0.75)
          ),
          GaugeRange(
            startValue: 30,
            endValue: 40,
            startWidth: 0.265,
            sizeUnit: GaugeSizeUnit.factor,
            endWidth: 0.265,
            color: const Color.fromRGBO(238, 193, 34, 0.75)
          ),
          GaugeRange(
            startValue: 40,
            endValue: 70,
            startWidth: 0.265,
            sizeUnit: GaugeSizeUnit.factor,
            endWidth: 0.265,
            color: const Color.fromRGBO(238, 79, 34, 0.65)
          ),
          GaugeRange(
            startValue: 70,
            endValue: 100,
            startWidth: 0.265,
            sizeUnit: GaugeSizeUnit.factor,
            endWidth: 0.265,
            color: const Color.fromRGBO(255, 0, 0, 0.65)
          ),
        ],
        annotations: annotations ?? <GaugeAnnotation>[
          GaugeAnnotation(
              angle: 90,
              positionFactor: 0.35,
              widget: Text(
                  'Temp.${AppLocalizations.of(context)!.tempMeasure}',
                  style: const TextStyle(fontSize: 9))),
          GaugeAnnotation(
            angle: 90,
            positionFactor: 0.8,
            widget: Text('  0  ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          )
        ],
        pointers: pointers ?? <GaugePointer>[
          NeedlePointer(
            value: 0,
            needleStartWidth: 0,
            needleEndWidth: 3,
            knobStyle: KnobStyle(knobRadius: 0.05),
          )
        ]
      )
    ]
  );
}