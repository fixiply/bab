import 'dart:async';

import 'package:flutter/material.dart';

// Internal package
import 'package:bab/utils/app_localizations.dart';

class CountDownText extends StatefulWidget {
  Duration duration;
  Map<String, String> map;
  final CountDownTextController? controller;
  Function()? onComplete;

  CountDownText({Key? key, required this.duration, required this.map, this.controller, this.onComplete}): super(key: key);
  @override
  CountDownTextState createState() => CountDownTextState();
}

class CountDownTextController {
  CountDownTextState? _state;

  void start(Duration duration) {
    _state?.run(duration);
  }
}

class TimerDifferenceHandler {
  late DateTime endingTime;

  static final TimerDifferenceHandler _instance = TimerDifferenceHandler();

  static TimerDifferenceHandler get instance => _instance;

  int get remainingSeconds {
    final DateTime dateTimeNow = DateTime.now();
    Duration remainingTime = endingTime.difference(dateTimeNow);
    // Return in seconds
    return remainingTime.inSeconds;
  }

  void setEndingTime(int durationToEnd) {
    final DateTime dateTimeNow = DateTime.now();
    // Ending time is the current time plus the remaining duration.
    endingTime = dateTimeNow.add(
      Duration(
        seconds: durationToEnd,
      ),
    );
  }
}

class CountDownTextState extends State<CountDownText> with WidgetsBindingObserver  {
  Timer? _timer;
  late CountDownTextController _controller;
  late TimerDifferenceHandler _timerHandler;
  int _countDownSeconds = 0;
  bool isTimerRunning = false;


  @override
  void initState() {
    _timerHandler = TimerDifferenceHandler();
    _controller = widget.controller ?? CountDownTextController();
    _countDownSeconds = widget.duration.inSeconds;
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    if (!mounted) return;
    if (state == AppLifecycleState.paused) {
      if (isTimerRunning) {
        _timerHandler.setEndingTime(_countDownSeconds);
      }
    }
    if (state == AppLifecycleState.resumed) {
      if (isTimerRunning) {
        setState(() {
          _countDownSeconds = _timerHandler.remainingSeconds;
        });
      }
    }
  }

  void _setController() {
    _controller._state = this;
  }

  void run(Duration duration) {
    _countDownSeconds = duration.inSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) return;
      setState(() {
        isTimerRunning = true;
        --_countDownSeconds;
      });
      if (_countDownSeconds < 0) {
        widget.onComplete?.call();
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int index = 0;
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final hours = strDigits(Duration(seconds: _countDownSeconds).inHours.remainder(24));
    final minutes = strDigits(Duration(seconds: _countDownSeconds).inMinutes.remainder(60));
    final seconds = strDigits(Duration(seconds: _countDownSeconds).inSeconds.remainder(60));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widget.map.entries.map((e) {
        ++index;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 30, child: Icon(_countDownSeconds < 0 ? Icons.check_box_outlined : Icons.check_box_outline_blank_outlined, color: _countDownSeconds < 0 ? Theme.of(context).primaryColor : Colors.black54)),
            Flexible(child: Text('${AppLocalizations.of(context)!.text('add')} ${e.value} «${e.key}»' + (_countDownSeconds > 0 && index == 1 ? ' dans $hours:$minutes:$seconds' : ''))),
          ],
        );
      }).toList()
    );
  }
}