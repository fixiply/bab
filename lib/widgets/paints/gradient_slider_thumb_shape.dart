import 'dart:math' as math;
import 'package:bb/helpers/color_helper.dart';
import 'package:flutter/material.dart';

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

    final Paint strokePaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 12, strokePaint);

    Path path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: 12))
      ..addOval(Rect.fromCircle(center: center, radius: 12 - 1))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, Paint()..color = ringColor);

    final Tween<double> radiusTween = Tween<double>(
      begin: _disabledThumbRadius,
      end: enabledThumbRadius,
    );
    final ColorTween colorTween = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.thumbColor,
    );
    final double radius = radiusTween.evaluate(enableAnimation);
    final Tween<double> elevationTween = Tween<double>(
      begin: elevation,
      end: pressedElevation,
    );

    // Add a stroke of 1dp around the circle if this thumb would overlap
    // the other thumb.
    // if (isOnTop ?? false) {
    //   final Paint strokePaint = Paint()
    //     ..color = ringColor.withOpacity(0.1)
    //     ..strokeWidth = 1.0
    //     ..style = PaintingStyle.stroke;
    //   canvas.drawCircle(center, radius, strokePaint);
    // }

    final Color color = colorTween.evaluate(enableAnimation)!;

    final double evaluatedElevation = isDiscrete ? elevationTween.evaluate(activationAnimation) : elevation;
    final Path shadowPath = Path()
      ..addArc(Rect.fromCenter(center: center, width: 2 * radius, height: 2 * radius), 0, math.pi * 2);
    canvas.drawShadow(shadowPath, Colors.black, evaluatedElevation, true);

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = selectedValue != null ? SRM_COLORS[selectedValue!.toInt()] : color,
    );
  }
}