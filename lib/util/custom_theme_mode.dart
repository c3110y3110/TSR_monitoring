import 'package:flutter/material.dart';

class CustomThemeMode {
  static final CustomThemeMode instance = CustomThemeMode._init();
  static ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.dark);
  static ValueNotifier<bool> isDark = ValueNotifier(true);
  factory CustomThemeMode() => instance;
  static void change() {
    isDark.value = !isDark.value;
    themeMode.value = isDark.value ? ThemeMode.dark : ThemeMode.light;
  }
  CustomThemeMode._init();
}