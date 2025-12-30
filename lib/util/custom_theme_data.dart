import 'package:flutter/material.dart';

class CustomThemeData {
  static final ThemeData light = ThemeData.light();
  static final ThemeData dark = ThemeData.dark().copyWith(
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Color(0xFF3E3E3E)),
        foregroundColor: MaterialStateProperty.all(Colors.white),
      ),
    ),
  );
}