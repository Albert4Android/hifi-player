import 'package:flutter/material.dart';

class AppTheme {
  static const Color bg = Color(0xFF0B0E12);        // głębokie tło
  static const Color surface = Color(0xFF121722);   // karty/panele
  static const Color surface2 = Color(0xFF161D2A);  // delikatnie jaśniej
  static const Color text = Color(0xFFE6E9EF);      // główny tekst
  static const Color textDim = Color(0xFF9AA3B2);   // drugorzędny tekst
  static const Color accent = Color(0xFF8AA4FF);    // „hi-fi” akcent
  static const Color border = Color(0xFF263044);    // cienkie linie

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);

    const colorScheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: accent,
      onPrimary: Colors.black,
      secondary: accent,
      onSecondary: Colors.black,
      background: bg,
      onBackground: text,
      surface: surface,
      onSurface: text,
      error: Color(0xFFFF5C5C),
      onError: Colors.black,
    );

    final textTheme = base.textTheme.copyWith(
      titleLarge: const TextStyle(
        color: text,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
      titleMedium: const TextStyle(
        color: text,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      bodyLarge: const TextStyle(
        color: text,
        fontSize: 16,
        height: 1.25,
      ),
      bodyMedium: const TextStyle(
        color: text,
        fontSize: 14,
        height: 1.25,
      ),
      bodySmall: const TextStyle(
        color: textDim,
        fontSize: 12,
        height: 1.25,
      ),
      labelLarge: const TextStyle(
        color: text,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      textTheme: textTheme,

      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
      ),

      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),

      // FIX: starszy/inna gałąź Fluttera oczekuje CardThemeData
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: border, width: 1),
        ),
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: textDim,
        textColor: text,
      ),

      iconTheme: const IconThemeData(
        color: text,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: const TextStyle(color: textDim),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accent, width: 1),
        ),
      ),

      snackBarTheme: const SnackBarThemeData(
        backgroundColor: surface2,
        contentTextStyle: TextStyle(color: text),
      ),
    );
  }
}