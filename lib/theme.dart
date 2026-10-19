import 'package:flutter/material.dart';

ThemeData buildWarmTheme() {
  const background = Color(0xFFFFF8F0);
  const ink = Color(0xFF352D29);
  final colors = ColorScheme.fromSeed(
    seedColor: const Color(0xFFA34832),
  ).copyWith(
    primary: const Color(0xFFA34832),
    onPrimary: Colors.white,
    surface: background,
    onSurface: ink,
    secondaryContainer: const Color(0xFFE2EAD9),
    onSecondaryContainer: const Color(0xFF303B2B),
  );
  final rounded = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(24),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colors,
    scaffoldBackgroundColor: background,
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: ink,
      centerTitle: false,
      scrolledUnderElevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: rounded,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colors.primary,
      foregroundColor: colors.onPrimary,
      elevation: 2,
      shape: rounded,
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    ),
  );
}
