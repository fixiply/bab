import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// External package
import 'package:animated_toggle_switch/animated_toggle_switch.dart';

class CustomDualSwitch<bool> extends AnimatedToggleSwitch {

  CustomDualSwitch.dual({required bool current, required ChangeCallback? onChanged}) : super.dual(
    current: current,
    first: false,
    second: true,
    spacing: 50.0,
    animationDuration: const Duration(milliseconds: 600),
    style: ToggleStyle(
      borderColor: Colors.transparent,
      indicatorColor: Colors.white,
      backgroundColor: Colors.amber,
    ),
    customStyleBuilder: (context, local, global) => ToggleStyle(
        backgroundGradient: LinearGradient(
          colors: [Colors.green, Colors.red],
          stops: [
            global.position -
                (1 - 2 * max(0, global.position - 0.5)) * 0.5,
            global.position + max(0, 2 * (global.position - 0.5)) * 0.5,
          ],
        )),
    borderWidth: 6.0,
    height: 40.0,
    indicatorSize: const Size.fromWidth(28.0),
    loadingIconBuilder: (context, global) =>
        CupertinoActivityIndicator(
            color: Color.lerp(
                Colors.red, Colors.green, global.position)),
    onChanged: onChanged,
    iconBuilder: (value) => value == true
        ? Icon(Icons.power_outlined,
        color: Colors.green, size: 22.0)
        : Icon(Icons.power_settings_new_rounded,
        color: Colors.red, size: 22.0),
    textBuilder: (value) => Center(
      child: Text(
        value == true ? 'On' : 'Off',
        style: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.w600),
      )
    )
  );
}