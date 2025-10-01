import 'package:flutter/material.dart';

import 'package:intern_management_app/utils/constants/app_colors.dart';

class AppTheme {

  // Dark Theme:
  static final darkTheme = ThemeData(
    // Text Selection:
    textSelectionTheme: TextSelectionThemeData(

      selectionColor: AppColors.darkBackground,
      cursorColor: AppColors.primary,
      selectionHandleColor: AppColors.primary,

    ),
    // Brightness
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.darkBackground,

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(

      filled: true,
      fillColor: Colors.transparent,
      hintStyle: TextStyle(
        color: Color(0xffa7a7a7),
        fontWeight: FontWeight.w400,
      ),
      labelStyle:  TextStyle(
        color: Color(0xffa7a7a7),
        fontWeight: FontWeight.w400,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey),
      ),

      errorStyle: const TextStyle(
        color: Colors.red, // error text color
        fontWeight: FontWeight.w400,
      ),

      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey,),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey,),
        borderRadius: BorderRadius.circular(8),
      ),

    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primary,
        textStyle: TextStyle(fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
