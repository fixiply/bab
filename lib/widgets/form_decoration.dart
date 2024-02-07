import 'package:flutter/material.dart';

// Internal package
import 'package:bab/utils/constants.dart';

class FormDecoration extends InputDecoration {
  FormDecoration({
    bool? filled,
    Color? fillColor,
    bool isDense = true,
    InputBorder? border = InputBorder.none,
    Widget? icon,
    Color? iconColor,
    String? labelText,
    TextStyle? labelStyle,
    String? prefixText,
    Widget? prefixIcon,
    Widget? prefix,
    BoxConstraints? prefixIconConstraints,
    BoxConstraints? constraints,
    String? suffixText,
    Widget? suffixIcon,
    Widget? suffix,
    String? hintText,
    EdgeInsetsGeometry? contentPadding
  }): super (
      filled: filled,
      fillColor: fillColor,
      isDense: isDense,
      border: border,
      icon: icon,
      iconColor: iconColor ?? MaterialStateColor.resolveWith((Set<MaterialState> states) {
        return states.contains(MaterialState.focused) ? PrimaryColor : Colors.black;
      }),
      labelText: labelText,
      labelStyle: labelStyle ?? MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
        final Color color = states.contains(MaterialState.focused) ? PrimaryColor : Colors.black;
        return TextStyle(color: color);
      }),
      prefixText: prefixText,
      prefixIcon: prefixIcon,
      prefix: prefix,
      prefixIconConstraints: prefixIconConstraints,
      suffixText: suffixText,
      suffixIcon: suffixIcon,
      suffix: suffix,
      hintText: hintText,
      contentPadding: contentPadding,
      constraints: constraints
  );
}
