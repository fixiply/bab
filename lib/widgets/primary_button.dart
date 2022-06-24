import 'package:flutter/material.dart';

class CustomPrimaryButton extends StatelessWidget {
  final Color? buttonColor;
  Decoration? decoration;
  final String textValue;
  final Color? textColor;
  final GestureTapCallback? onTap;

  CustomPrimaryButton({this.buttonColor, required this.textValue, this.textColor, this.decoration, this.onTap}) {
    if(decoration == null) decoration = BoxDecoration(
      color: buttonColor,
      borderRadius: BorderRadius.circular(4.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(4.0),
      elevation: 0,
      child: Container(
        height: 42,
        decoration: decoration,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(4.0),
            child: Center(
              child: Text(
                textValue,
                style: TextStyle(color: textColor),
              ),
            ),
          ),
        ),
      ),
    );
    ;
  }
}
