import 'dart:async';

import 'package:flutter/material.dart';

// Internal package


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

  void restart(Duration duration) {
    _state?.run(duration);
  }
}

class CountDownTextState extends State<CountDownText> {
  Timer? _timer;
  CountDownTextController? _controller;

  @override
  void initState() {
    _controller = widget.controller ?? CountDownTextController();
    super.initState();
    _setController();
  }

  void _setController() {
    _controller?._state = this;
  }

  void run(Duration duration) {
    widget.duration = duration;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) return;
      setState(() {
        final seconds = widget.duration.inSeconds - 1;
        if (seconds < 0) {
          widget.onComplete?.call();
          timer.cancel();
        } else {
          widget.duration = Duration(seconds: seconds);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    int index = 0;
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final hours = strDigits(widget.duration.inHours.remainder(24));
    final minutes = strDigits(widget.duration.inMinutes.remainder(60));
    final seconds = strDigits(widget.duration.inSeconds.remainder(60));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widget.map.entries.map((e) {
        ++index;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 30, child: index == 1 ? Icon(widget.duration.inSeconds <= 0 ? Icons.check_box_outlined : Icons.check_box_outline_blank_outlined, color: widget.duration.inSeconds <= 0 ? Theme.of(context).primaryColor : Colors.black54) : null),
            Flexible(child: Text('Ajoutez ${e.value} de «${e.key}»' + (widget.duration.inSeconds > 0 && widget.map.length == index ? ' dans $hours:$minutes:$seconds' : ''))),
          ],
        );
      }).toList()
    );
  }
}