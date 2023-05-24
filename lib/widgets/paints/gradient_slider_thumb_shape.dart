import 'package:flutter/material.dart';

// Internal package
import 'package:bb/helpers/color_helper.dart';

class GradientSliderThumbShape implements SliderComponentShape {

  const GradientSliderThumbShape({
    this.radius = 12.0,
    this.ringColor = Colors.black,
    this.fillColor = Colors.transparent,
    this.strokeWidth = 1,
    this.enabledThumbRadius = 4.0,
    this.disabledThumbRadius,
    this.elevation = 1.0,
    this.pressedElevation = 6.0,
    this.selectedValue,
    this.min = 0,
    this.max = 0,
  });

  /// Outer radius of thumb
  final double radius;

  /// Color of ring
  final Color ringColor;
  final Color fillColor;

  final double strokeWidth;

  final double enabledThumbRadius;
  final double elevation;
  final double? disabledThumbRadius;
  double get _disabledThumbRadius => disabledThumbRadius ?? enabledThumbRadius;
  final double pressedElevation;

  final double? selectedValue;

  final int min;
  final int max;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(radius);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;

    var number = getValue(value);
    if (number > 0) {
      Color color = SRM_COLORS[ColorHelper.toSRM(number)];
      final Paint strokePaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, 16, strokePaint);

      Path path = Path()
        ..addOval(Rect.fromCircle(center: center, radius: 16))..addOval(
            Rect.fromCircle(center: center, radius: 16 - 1))
        ..fillType = PathFillType.evenOdd;

      TextSpan span = TextSpan(
          style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              height: 1),
          text: number.toString());
      TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr);
      tp.layout();
      Offset textCenter = Offset(
          center.dx - (tp.width / 2), center.dy - (tp.height / 2));

      canvas.drawPath(path, Paint()
        ..color = color);
      tp.paint(canvas, textCenter);
    }
  }

  int getValue(double value) {
    return (min+(max-min)*value).round();
  }
}