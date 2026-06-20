import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeViewModel extends ChangeNotifier {
  static const _prefsKey = 'theme_mode';

  ThemeMode _mode = ThemeMode.dark;
  bool _loaded = false;

  ThemeViewModel() {
    _loadFromPrefs();
  }

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;
  bool get isLoaded => _loaded;

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      if (saved == 'light') {
        _mode = ThemeMode.light;
      } else if (saved == 'dark') {
        _mode = ThemeMode.dark;
      }
    } catch (_) {
      // Fall back to default (dark)
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _prefsKey, _mode == ThemeMode.dark ? 'dark' : 'light');
    } catch (_) {}
  }

  void toggle() {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    _save();
  }

  void setDark() {
    _mode = ThemeMode.dark;
    notifyListeners();
    _save();
  }

  void setLight() {
    _mode = ThemeMode.light;
    notifyListeners();
    _save();
  }
}
