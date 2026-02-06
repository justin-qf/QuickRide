import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickride/core/constants/app_text_theme.dart';

class AppColors {
  static const Color primary = Color(0xFFFF6D00); // Vibrant Orange
  static const Color primaryLight = Color(0xFFFF9E40);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFFF8F0); // Very light cream
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFF757575);
  static const Color inputFill = Color(0xFFFFFFFF);
  static const Color inputBorder = Color(0xFFE0E0E0);
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    fontFamily: 'fontBold',
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    fontFamily:
        'fontBold', // Using fontBold for w600/SemiBold feel if needed, or fontSemiBold if available. User has fontSemiBold.
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    fontFamily: 'fontSemiBold',
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.textLight,
    fontFamily: 'fontRegular',
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: 'fontBold',
  );
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: AppTextTheme.fontFamily,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),

    scaffoldBackgroundColor: AppColors.background,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Android
        statusBarBrightness: Brightness.light, // iOS
      ),
    ),

    textTheme: AppTextTheme.textTheme,
  );

  /// Global system UI (used in MaterialApp builder if needed)
  static const SystemUiOverlayStyle systemUiStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );
}
