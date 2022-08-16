import 'package:flutter/material.dart';

class CircleClipper extends CustomClipper<Path>{
  double? dx;
  double? dy;
  double? radius;
  CircleClipper({this.dx, this.dy, this.radius});

  @override
  Path getClip(Size size) {
    var path = Path();
    path.addOval(Rect.fromCircle(
      center: Offset(dx ?? size.width / 1.5, dy ?? 130),
      radius: radius ?? 70.0,

    ));
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false; //if new instance have different instance than old instance
    //then you must return true;
  }
}