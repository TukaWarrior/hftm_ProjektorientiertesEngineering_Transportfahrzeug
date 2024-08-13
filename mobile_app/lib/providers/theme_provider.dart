import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

// ChangeNotifier for ThemeProvider
ChangeNotifierProvider<ThemeProvider> createThemeProvider() {
  return ChangeNotifierProvider<ThemeProvider>(
    create: (_) => ThemeProvider(),
  );
}
