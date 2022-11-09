import 'package:flutter/material.dart';

class Days {
  final duration = const Duration(milliseconds: 250);
  final  margin = const EdgeInsets.all(6.0);
  final padding = const EdgeInsets.all(0);
  final alignment = Alignment.center;

  static Container buildCalendarDay({
    required String day,
    required Color backColor,
    Color? color,
  }) {
    return Container(
      color: backColor,
      margin: const EdgeInsets.all(6.0),
      padding: const EdgeInsets.all(0),
      alignment: Alignment.center,
      child: Center(
        child: Text(day, style: TextStyle(fontSize: 12, color: color ?? Colors.black)),
      ),
    );
  }

  static AnimatedContainer buildCalendarDayMarker({
    required String text,
    required Color backColor,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.all(6.0),
      padding: const EdgeInsets.all(0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backColor),
      child: Text(text, style: TextStyle(color: const Color(0xFFFAFAFA), fontSize: 16.0,))
    );
  }
}