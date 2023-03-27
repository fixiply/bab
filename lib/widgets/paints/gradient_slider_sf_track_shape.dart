import 'package:bb/utils/color_units.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class GradientSliderSFTrackShape extends SfTrackShape {
  const GradientSliderSFTrackShape({
    this.gradient = const LinearGradient(
      colors: SRM_COLORS,
    ),
    this.darkenInactive = true,
  });

  final LinearGradient gradient;
  final bool darkenInactive;

  @override
  void paint(PaintingContext context, Offset offset, Offset? thumbCenter,
      Offset? startThumbCenter, Offset? endThumbCenter,
      {required RenderBox parentBox,
        required SfSliderThemeData themeData,
        SfRangeValues? currentValues,
        dynamic currentValue,
        required Animation<double> enableAnimation,
        required Paint? inactivePaint,
        required Paint? activePaint,
        required TextDirection textDirection}) {
    final Radius radius = Radius.circular(themeData.trackCornerRadius!);
    final Rect actualTrackRect = getPreferredRect(parentBox, themeData, offset);

    if (endThumbCenter == null) {
      final Paint paint = Paint()
        ..isAntiAlias = true
        ..strokeWidth = 0
        ..color = themeData.activeTrackColor!;

      Rect trackRect = Rect.fromLTRB(actualTrackRect.left, actualTrackRect.top,
          startThumbCenter!.dx, actualTrackRect.bottom);
      final RRect leftRRect = RRect.fromRectAndCorners(trackRect,
          topLeft: radius, bottomLeft: radius);
      context.canvas.drawRRect(leftRRect, paint);

      paint.color = themeData.inactiveTrackColor!;
      trackRect = Rect.fromLTRB(startThumbCenter.dx, actualTrackRect.top,
          actualTrackRect.right, actualTrackRect.bottom);
      final RRect rightRRect = RRect.fromRectAndCorners(trackRect,
          topRight: radius, bottomRight: radius);
      context.canvas.drawRRect(rightRRect, paint);
    } else {
      final Paint paint = Paint()
        ..isAntiAlias = true
        ..strokeWidth = 0
        ..color = themeData.inactiveTrackColor!;

      // Drawing inactive track.
      Rect trackRect = Rect.fromLTRB(actualTrackRect.left, actualTrackRect.top,
          startThumbCenter!.dx, actualTrackRect.bottom);
      final RRect leftRRect = RRect.fromRectAndCorners(trackRect,
          topLeft: radius, bottomLeft: radius);
      context.canvas.drawRRect(leftRRect, paint);

      // Drawing active track.
      trackRect = Rect.fromLTRB(startThumbCenter.dx, actualTrackRect.top,
          endThumbCenter.dx, actualTrackRect.bottom);
      paint.shader = gradient.createShader(trackRect);
      final RRect centerRRect = RRect.fromRectAndCorners(trackRect);
      context.canvas.drawRRect(centerRRect, paint);

      // Drawing inactive track.
      paint.shader = null;
      paint.color = themeData.inactiveTrackColor!;
      trackRect = Rect.fromLTRB(endThumbCenter.dx, actualTrackRect.top,
          actualTrackRect.width + actualTrackRect.left, actualTrackRect.bottom);
      final RRect rightRRect = RRect.fromRectAndCorners(trackRect,
          topRight: radius, bottomRight: radius);
      context.canvas.drawRRect(rightRRect, paint);
    }
  }
}