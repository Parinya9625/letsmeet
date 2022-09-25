import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  String key = "theme";
  final ThemeMode defaultMode;
  SharedPreferences? preferences;

  ThemeMode get mode => _getThemeMode();
  set mode(ThemeMode mode) {
    _saveThemeMode(mode);
    notifyListeners();
  }

  ThemeProvider({this.defaultMode = ThemeMode.system}) {
    _loadSharePreferences();
  }

  _loadSharePreferences() async {
    preferences ??= await SharedPreferences.getInstance();
    notifyListeners();
  }

  ThemeMode _getThemeMode() {
    String modeStr =
        preferences?.getString(key) ?? _themeModeToString(defaultMode);

    return _stringToThemeMode(modeStr);
  }

  void _saveThemeMode(ThemeMode newMode) {
    preferences?.setString(key, _themeModeToString(newMode));
  }

  ThemeMode _stringToThemeMode(String mode) {
    ThemeMode themeMode;

    switch (mode) {
      case "light":
        themeMode = ThemeMode.light;
        break;
      case "dark":
        themeMode = ThemeMode.dark;
        break;
      case "system":
      default:
        themeMode = ThemeMode.system;
        break;
    }

    return themeMode;
  }

  String _themeModeToString(ThemeMode mode) {
    String strMode;

    switch (mode) {
      case ThemeMode.light:
        strMode = "light";
        break;
      case ThemeMode.dark:
        strMode = "dark";
        break;
      case ThemeMode.system:
      default:
        strMode = "system";
        break;
    }

    return strMode;
  }
}
