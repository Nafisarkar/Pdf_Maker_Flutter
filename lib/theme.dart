import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.lightGreen[700], // Primary Blue
  secondaryHeaderColor: Colors.white, // Secondary Purple
  scaffoldBackgroundColor:
      const Color.fromARGB(255, 252, 252, 252), // Dark Scaffold Background
  cardColor: const Color.fromARGB(255, 224, 231, 229), // Dark Card Background
  dividerColor: const Color(0xFF424242), // Dark Gray Divider
  textTheme: const TextTheme(),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color.fromARGB(255, 113, 135, 158), // Primary Blue
  secondaryHeaderColor:
      const Color.fromARGB(255, 248, 248, 248), // Secondary Purple
  scaffoldBackgroundColor: const Color(0xFF121212), // Dark Scaffold Background
  cardColor: const Color.fromARGB(255, 49, 49, 49), // Dark Card Background
  dividerColor: const Color(0xFF424242), // Dark Gray Divider
  textTheme: const TextTheme(),
);
