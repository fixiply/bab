import 'package:flutter/material.dart';

class FormDecoration extends InputDecoration {

  FormDecoration({
    bool? filled,
    Color? fillColor,
    bool isDense: true,
    InputBorder? border: InputBorder.none,
    Widget? icon,
    String? labelText,
    String? prefixText,
    Widget? prefixIcon,
    Widget? prefix,
    BoxConstraints? prefixIconConstraints,
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
      labelText: labelText,
      prefixText: prefixText,
      prefixIcon: prefixIcon,
      prefix: prefix,
      prefixIconConstraints: prefixIconConstraints,
      suffixText: suffixText,
      suffixIcon: suffixIcon,
      suffix: suffix,
      hintText: hintText,
      contentPadding: contentPadding
  );
}
