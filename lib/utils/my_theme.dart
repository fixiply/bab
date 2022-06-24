import 'package:flutter/material.dart';

// Internal package
import 'package:bb/utils/constants.dart';

class MyTheme {
  static final ThemeData defaultTheme = _buildTheme();

  static ThemeData _buildTheme() {
    final ThemeData base = ThemeData.light();

    return base.copyWith(
      brightness: Brightness.light,
      primaryColor: PrimaryColor,
      primaryColorBrightness: Brightness.dark,
      primaryColorLight: Color( 0xffccffec ),
      primaryColorDark: Color( 0xff00995f ),
      accentColor: Color( 0xff00ff9e ),
      accentColorBrightness: Brightness.light,
      canvasColor: Color( 0xfffafafa ),
      scaffoldBackgroundColor: Color( 0xfffafafa ),
      bottomAppBarColor: Color( 0xffffffff ),
      cardColor: Color( 0xffffffff ),
      dividerColor: Color( 0x1f000000 ),
      highlightColor: Color( 0x66bcbcbc ),
      splashColor: Color( 0x66c8c8c8 ),
      selectedRowColor: Color( 0xfff5f5f5 ),
      unselectedWidgetColor: Color( 0x8a000000 ),
      disabledColor: Color( 0x61000000 ),
      buttonColor: Color( 0xffe0e0e0 ),
      toggleableActiveColor: Color( 0xff00cc7e ),
      secondaryHeaderColor: Color( 0xffe5fff5 ),
      textSelectionColor: Color( 0xff99ffd8 ),
      cursorColor: Color( 0xff4285f4 ),
      textSelectionHandleColor: Color( 0xff66ffc5 ),
      backgroundColor: Color( 0xff99ffd8 ),
      dialogBackgroundColor: Color( 0xffffffff ),
      indicatorColor: Color( 0xff00ff9e ),
      hintColor: Color( 0x8a000000 ),
      errorColor: Color( 0xffd32f2f ),
    );
  }
}