import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  String key = "theme";
  SharedPreferences? preferences;

  ThemeMode get mode => _getThemeMode();
  set mode(ThemeMode mode) {
    _saveThemeMode(mode);
    notifyListeners();
  }

  ThemeProvider() {
    _loadSharePreferences();
  }

  _loadSharePreferences() async {
    preferences ??= await SharedPreferences.getInstance();
    notifyListeners();
  }

  ThemeMode _getThemeMode() {
    String modeStr = preferences?.getString(key) ?? "system";
    ThemeMode mode;

    switch (modeStr) {
      case "light":
        mode = ThemeMode.light;
        break;
      case "dark":
        mode = ThemeMode.dark;
        break;
      case "system":
      default:
        mode = ThemeMode.system;
        break;
    }

    return mode;
  }

  void _saveThemeMode(ThemeMode newMode) {
    String mode;

    switch (newMode) {
      case ThemeMode.light:
        mode = "light";
        break;
      case ThemeMode.dark:
        mode = "dark";
        break;
      case ThemeMode.system:
      default:
        mode = "system";
        break;
    }

    preferences?.setString(key, mode);
  }
}
