import 'package:flutter/material.dart';

class AppTheme {
  // Colors from the desktop app
  static const _primaryGreen = Color(0xFF6baf78);
  static const _darkBg = Color(0xFF1e2629);
  static const _darkSurface = Color(0xFF232a2e);
  static const _darkBorder = Color(0xFF3a4249);
  static const _lightBg = Color(0xFFF2F4F7);
  static const _onLight = Color(0xFF1e2629);

  static final TextTheme _baseTextTheme = const TextTheme(
    bodySmall: TextStyle(fontFamily: 'Lato', fontSize: 12, fontWeight: FontWeight.w300),
    bodyMedium: TextStyle(fontFamily: 'Lato', fontSize: 15, fontWeight: FontWeight.w300),
    bodyLarge: TextStyle(fontFamily: 'Lato', fontSize: 16, fontWeight: FontWeight.w300),
    titleMedium: TextStyle(fontFamily: 'Lato', fontSize: 16, fontWeight: FontWeight.w400),
    titleSmall: TextStyle(fontFamily: 'Lato', fontSize: 14, fontWeight: FontWeight.w400),
  );

  static ThemeData get dark {
    final darkScheme = const ColorScheme.dark(
      primary: _primaryGreen,
      secondary: _primaryGreen,
      surface: _darkBg,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: darkScheme,
      scaffoldBackgroundColor: _darkBg,
      fontFamily: 'Lato',
      iconTheme: const IconThemeData(color: Colors.white70),
      textTheme: _baseTextTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkBg,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all(_primaryGreen),
      ),
      chipTheme: ChipThemeData(
        selectedColor: _primaryGreen,
        labelStyle: const TextStyle(fontFamily: 'Lato'),
        secondaryLabelStyle: const TextStyle(fontFamily: 'Lato', color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) return _primaryGreen;
          return Colors.white54;
        }),
        suffixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) return _primaryGreen;
          return Colors.white54;
        }),
        labelStyle: WidgetStateTextStyle.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return const TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontFamily: 'Lato');
          }
          return const TextStyle(color: Colors.white70, fontWeight: FontWeight.w400, fontFamily: 'Lato');
        }),
        hintStyle: const TextStyle(color: Colors.white38, fontFamily: 'Lato'),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: _darkBorder, width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: _primaryGreen, width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Colors.black87,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }

  static ThemeData get light {
    final lightScheme = const ColorScheme.light(
      primary: _primaryGreen,
      secondary: _primaryGreen,
      surface: _lightBg,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: _onLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: lightScheme,
      scaffoldBackgroundColor: _lightBg,
      fontFamily: 'Lato',
      iconTheme: const IconThemeData(color: _onLight),
      textTheme: _baseTextTheme.copyWith(
        bodySmall: const TextStyle(fontFamily: 'Lato', fontSize: 12, fontWeight: FontWeight.w300, color: _onLight),
        bodyMedium: const TextStyle(fontFamily: 'Lato', fontSize: 15, fontWeight: FontWeight.w300, color: _onLight),
        bodyLarge: const TextStyle(fontFamily: 'Lato', fontSize: 16, fontWeight: FontWeight.w300, color: _onLight),
        titleMedium: const TextStyle(fontFamily: 'Lato', fontSize: 16, fontWeight: FontWeight.w400, color: _onLight),
        titleSmall: const TextStyle(fontFamily: 'Lato', fontSize: 14, fontWeight: FontWeight.w400, color: _onLight),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightBg,
        foregroundColor: _onLight,
        elevation: 0,
        centerTitle: true,
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all(_primaryGreen),
      ),
      chipTheme: ChipThemeData(
        selectedColor: _primaryGreen,
        labelStyle: const TextStyle(fontFamily: 'Lato', color: _onLight),
        secondaryLabelStyle: const TextStyle(fontFamily: 'Lato', color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) return _primaryGreen;
          return _onLight.withValues(alpha: 0.6);
        }),
        suffixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) return _primaryGreen;
          return _onLight.withValues(alpha: 0.6);
        }),
        labelStyle: const TextStyle(color: _onLight, fontWeight: FontWeight.w400, fontFamily: 'SourceCodePro'),
        floatingLabelStyle: const TextStyle(color: _primaryGreen, fontWeight: FontWeight.w400, fontFamily: 'SourceCodePro'),
        hintStyle: const TextStyle(color: Colors.black38, fontFamily: 'SourceCodePro'),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: _primaryGreen, width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Colors.black87,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}
