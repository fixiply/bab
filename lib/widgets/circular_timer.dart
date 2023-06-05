import 'package:flutter/material.dart';

// Internal package
import 'package:bb/utils/constants.dart';

// External package
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

class CircularTimer extends CircularCountDownTimer {
  CircularTimer(CountDownController controller, {required int duration, required int index, VoidCallback? onStart, ValueChanged<Duration>? onChange, Function(int index)? onComplete}) : super(
    duration: duration,
    initialDuration: 0,
    controller: controller,
    width: 100,
    height: 100,
    ringColor: Colors.grey[300]!,
    ringGradient: null,
    fillColor: SecondaryColor,
    fillGradient: null,
    backgroundColor: PrimaryColor,
    backgroundGradient: null,
    strokeWidth: 5.0,
    strokeCap: StrokeCap.round,
    textStyle: const TextStyle(fontSize: 14.0, color: Colors.white, fontWeight: FontWeight.bold),
    textFormat: CountdownTextFormat.HH_MM_SS,
    isReverse: true,
    isReverseAnimation: false,
    isTimerTextShown: true,
    autoStart: false,
    onStart: onStart,
    onComplete: () {
      onComplete?.call(index);
    },
    timeFormatterFunction: (defaultFormatterFunction, duration) {
      onChange?.call(duration);
      if (duration.inSeconds == 0) {
        return "Start";
      } else {
        return Function.apply(defaultFormatterFunction, [duration]);
      }
    },
  );
}
