import 'package:flutter/material.dart';

class AppTextTheme {
  static const String fontFamily = 'SchibstedGrotesk';

  static TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(fontWeight: FontWeight.w700),
    displayMedium: TextStyle(fontWeight: FontWeight.w700),
    displaySmall: TextStyle(fontWeight: FontWeight.w700),

    headlineLarge: TextStyle(fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(fontWeight: FontWeight.w700),
    headlineSmall: TextStyle(fontWeight: FontWeight.w700),

    titleLarge: TextStyle(fontWeight: FontWeight.w700),
    titleMedium: TextStyle(fontWeight: FontWeight.w500),
    titleSmall: TextStyle(fontWeight: FontWeight.w500),

    bodyLarge: TextStyle(fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontWeight: FontWeight.w400),

    labelLarge: TextStyle(fontWeight: FontWeight.w700),
  ).apply(fontFamily: fontFamily);
}
