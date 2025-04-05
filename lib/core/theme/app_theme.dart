import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.teal,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    useMaterial3: true,
    // Customize other properties like text themes, card themes, etc.
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.teal,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    useMaterial3: true,
    // Customize dark theme properties
  );
}