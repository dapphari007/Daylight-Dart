import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static const String _prefShowCenterLine = 'showCenterLine';
  static const String _prefThemeMode = 'themeMode';

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  bool _showCenterLine = true;
  ThemeMode _themeMode = ThemeMode.system;

  bool get isInitialized => _isInitialized;
  bool get showCenterLine => _showCenterLine;
  ThemeMode get themeMode => _themeMode;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    _showCenterLine = _prefs.getBool(_prefShowCenterLine) ?? true;
    
    final themeString = _prefs.getString(_prefThemeMode);
    if (themeString != null) {
      _setThemeFromStringInternal(themeString);
    }
    
    _isInitialized = true;
    notifyListeners();
  }

  set showCenterLine(bool value) {
    _showCenterLine = value;
    _prefs.setBool(_prefShowCenterLine, value);
    notifyListeners();
  }

  set themeMode(ThemeMode value) {
    _themeMode = value;
    _prefs.setString(_prefThemeMode, _themeToString(value));
    notifyListeners();
  }

  String _themeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return 'Light';
      case ThemeMode.dark: return 'Dark';
      case ThemeMode.system: return 'System';
    }
  }

  void _setThemeFromStringInternal(String value) {
    switch (value) {
      case 'Light':
        _themeMode = ThemeMode.light;
        break;
      case 'Dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'System':
      default:
        _themeMode = ThemeMode.system;
        break;
    }
  }

  // Helper for external calls if needed, though direct setter is preferred
  void setThemeFromString(String value) {
    _setThemeFromStringInternal(value);
    _prefs.setString(_prefThemeMode, value);
    notifyListeners();
  }
}
