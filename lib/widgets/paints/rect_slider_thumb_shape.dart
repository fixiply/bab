import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class RectSliderThumbShape extends SfThumbShape {
  final thumbRadius;
  final thumbHeight;
  final String? Function(double value)? onFormatted;

  const RectSliderThumbShape({
    this.thumbRadius = 8,
    this.thumbHeight = 45,
    this.onFormatted,
  });

  @override
  void paint(PaintingContext context, Offset center,
      {required RenderBox parentBox,
        required RenderBox? child,
        required SfSliderThemeData themeData,
        SfRangeValues? currentValues,
        dynamic currentValue,
        required Paint? paint,
        required Animation<double> enableAnimation,
        required TextDirection textDirection,
        required SfThumb? thumb}) {
    if (currentValue != null) {
      final Canvas canvas = context.canvas;

      final rRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: center, width: thumbHeight * 1.2, height: thumbHeight * .6),
        Radius.circular(thumbRadius * .4),
      );

      final paint = Paint()
        ..color = themeData.activeTrackColor! //Thumb Background Color
        ..style = PaintingStyle.fill;

      TextSpan span = new TextSpan(
          style: new TextStyle(
              fontSize: 12,
              color: Colors.white,
              height: 1),
          text: '${getValue(currentValue)}');
      TextPainter tp = new TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr);
      tp.layout();
      Offset textCenter = Offset(
          center.dx - (tp.width / 2), center.dy - (tp.height / 2));

      canvas.drawRRect(rRect, paint);
      tp.paint(canvas, textCenter);
    }
  }

  String getValue(double value) {
    return onFormatted?.call(value) ?? value.toString();
  }
}