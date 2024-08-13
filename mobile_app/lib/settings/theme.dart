/// This file sets the theme across the application.
library;
import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.cyanAccent,
    brightness: Brightness.light,
  ),
  brightness: Brightness.light,
  scaffoldBackgroundColor: const ColorScheme.light().surfaceContainerHighest,
  appBarTheme: AppBarTheme(
    backgroundColor: const ColorScheme.light().surfaceContainerHighest,
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontSize: 30,
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.cyan,
    brightness: Brightness.dark,
  ),
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const ColorScheme.dark().surfaceContainerHighest,
  appBarTheme: AppBarTheme(
    backgroundColor: const ColorScheme.dark().surfaceContainerHighest,
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontSize: 30,
    ),
  ),
);
