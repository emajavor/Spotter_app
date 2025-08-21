import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpotterTheme {
  static ThemeData get darkTheme {
    return FlexColorScheme.dark(
      colors: FlexSchemeColor.from(
        primary: const Color(0xFF00FFBB),
        secondary: const Color(0xFF1E1E1E),
      ),
      surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
      blendLevel: 10,
      appBarStyle: FlexAppBarStyle.background,
      appBarOpacity: 1.0,
      visualDensity: VisualDensity.standard,
      useMaterial3: true,
      textTheme: GoogleFonts.poppinsTextTheme(),
    ).toTheme.copyWith(
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        contentTextStyle: GoogleFonts.poppins(color: Colors.white),
        actionTextColor: const Color(0xFF00FFBB),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixIconColor: const Color(0xFF00FFBB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00FFBB), width: 2),
        ),
      ),
    );
  }
}