import 'package:flutter/material.dart';

class SchoolRideColors {
  static const navy = Color(0xFF073B70);
  static const blue = Color(0xFF0878BD);
  static const orange = Color(0xFFFF9800);
  static const green = Color(0xFF2E9D50);
  static const background = Color(0xFFF4F8FC);
  static const ink = Color(0xFF142D4E);
  static const muted = Color(0xFF6D7F93);
  static const border = Color(0xFFE0EAF3);
}

ThemeData buildSchoolRideTheme() => ThemeData(
  useMaterial3: true, scaffoldBackgroundColor: SchoolRideColors.background,
  colorScheme: ColorScheme.fromSeed(seedColor: SchoolRideColors.blue, primary: SchoolRideColors.blue, secondary: SchoolRideColors.orange),
  appBarTheme: const AppBarTheme(backgroundColor: SchoolRideColors.navy, foregroundColor: Colors.white, centerTitle: false),
  cardTheme: CardThemeData(color: Colors.white, elevation: 0, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: SchoolRideColors.border))),
  inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15)),
);
