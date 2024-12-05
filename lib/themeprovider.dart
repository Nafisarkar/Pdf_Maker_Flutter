import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme.dart'; // Ensure you have imported your theme definitions

class ThemeProvider with ChangeNotifier {
  late ThemeData _currentTheme;
  late bool isDark;
  final Box<dynamic> _mybox;

  ThemeProvider() : _mybox = Hive.box('themeBox') {
    // Initialize the theme based on the value stored in Hive
    isDark = _mybox.get('isDark', defaultValue: false);
    _currentTheme = isDark ? darkTheme : lightTheme;
  }

  ThemeData get currentTheme => _currentTheme;

  void toggleTheme() {
    isDark = !isDark;
    _mybox.put('isDark', isDark);
    _currentTheme = isDark ? darkTheme : lightTheme;
    notifyListeners();
  }

  void setSystemTheme(Brightness brightness) {
    isDark = brightness == Brightness.dark;
    _mybox.put('isDark', isDark);
    _currentTheme = isDark ? darkTheme : lightTheme;
    notifyListeners();
  }
}
