import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppThemes {
  AppThemes._();

  // App colors
  static const Color blurple = Color(0xFF5865F2);
  static const Color neonBlue = Color(0xFF6974F2);
  static const Color blue = Color(0xFF2E3EEF);
  static const Color red = Color(0xFFED4245);
  static const Color white = Color(0xFFFFFFFF);
  static const Color richBlack = Color(0xFF121212);
  static const Color black = Color(0xFF000000);

  // Fonts
  static const String roboto = "Roboto";

  static const Color primaryColor = blurple;
  static const Color lightTextColor = Colors.black;
  static const Color lightSecondarTextColor = Colors.black54;
  static const Color darkTextColor = Colors.white;
  static const Color darkSecondaryTextColor = Colors.white60;

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    brightness: Brightness.light,
    fontFamily: roboto,
    textTheme: _getTextTheme(lightTextColor, lightSecondarTextColor),
    scaffoldBackgroundColor: white,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.resolveWith(
          (states) => white,
        ),
        backgroundColor: MaterialStateProperty.resolveWith(
          (states) => primaryColor,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.resolveWith(
          (states) => primaryColor,
        ),
        textStyle: MaterialStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: primaryColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: white,
      elevation: 0,
      iconTheme: IconThemeData(
        color: lightTextColor,
        size: 25,
      ),
      textTheme: TextTheme(
        headline6: TextStyle(
          fontSize: 18,
          color: lightTextColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      actionsIconTheme: IconThemeData(
        size: 25,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: primaryColor,
    brightness: Brightness.dark,
    fontFamily: roboto,
    textTheme: _getTextTheme(darkTextColor, darkSecondaryTextColor),
    scaffoldBackgroundColor: black,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.resolveWith(
          (states) => white,
        ),
        backgroundColor: MaterialStateProperty.resolveWith(
          (states) => primaryColor,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.resolveWith(
          (states) => primaryColor,
        ),
        textStyle: MaterialStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: primaryColor,
      backgroundColor: richBlack,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: richBlack,
      elevation: 0,
      iconTheme: IconThemeData(
        color: darkTextColor,
        size: 25,
      ),
      textTheme: TextTheme(
        headline6: TextStyle(
          fontSize: 18,
          color: darkTextColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      actionsIconTheme: IconThemeData(
        size: 25,
      ),
    ),
    cupertinoOverrideTheme: CupertinoThemeData(
      brightness: Brightness.dark,
      textTheme: CupertinoTextThemeData(
        pickerTextStyle: TextStyle(
          color: darkTextColor,
        ),
      ),
    ),
  );

  static _getTextTheme(Color headlineColor, Color bodyTextColor) {
    return TextTheme(
      headline1: TextStyle(
        fontSize: 36.0,
        color: headlineColor,
        fontWeight: FontWeight.bold,
        letterSpacing: -2.5,
      ),
      headline2: TextStyle(
        fontSize: 26.0,
        color: headlineColor,
        fontWeight: FontWeight.w700,
      ),
      headline3: TextStyle(
        fontSize: 20.0,
        color: headlineColor,
        fontWeight: FontWeight.w700,
      ),
      headline4: TextStyle(
        fontSize: 18.0,
        color: headlineColor,
        fontWeight: FontWeight.w600,
      ),
      headline5: TextStyle(
        fontSize: 17.0,
        color: headlineColor,
        fontWeight: FontWeight.w500,
      ),
      headline6: TextStyle(
        fontSize: 16.0,
        color: headlineColor,
        fontWeight: FontWeight.w400,
      ),
      bodyText1: TextStyle(
        fontSize: 15.0,
        color: bodyTextColor,
        //letterSpacing: 0.3,
      ),
      bodyText2: TextStyle(
        fontSize: 14.0,
        color: bodyTextColor,
      ),
    );
  }
}
