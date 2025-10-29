// Auto-generated main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'widgets/common_widgets.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const EduDocApp(),
    ),
  );
}

class EduDocApp extends StatelessWidget {
  const EduDocApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // --- Theme Configuration (Mimicking CSS Variables) ---
    const primaryColor = Color(0xFF6366F1); // Indigo 500
    const secondaryColor = Color(0xFFF472B6); // Pink 400
    const tertiaryColor = Color(0xFFFBBF24); // Amber 400
    // FIX: backupColor is defined here as a local constant
    const backupColor = Color(0xFF14B8A6); // Teal 500

    final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
        surface: Color(0xFF1E293B), // Scaffold background
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      cardColor: const Color(0xFF1E293B),
      // Set default font families
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: TextStyle(fontFamily: 'Inter'),
      ),
      useMaterial3: true,
    );

    final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF4F46E5), // Indigo 600
        secondary: Color(0xFFEC4899), // Pink 500
        tertiary: tertiaryColor,
        surface: Color(0xFFFFFFFF),
      ),
      scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      cardColor: const Color(0xFFFFFFFF),
      textTheme: TextTheme(
        headlineSmall: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade900,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade900,
        ),
        bodyMedium: const TextStyle(
          fontFamily: 'Inter',
          color: Color(0xFF111827),
        ),
      ),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'EduDoc Flutter SPA',
      debugShowCheckedModeBanner: false,
      theme: appState.isDarkTheme ? darkTheme : lightTheme,
      home: const MainScreenRouter(backupColor: backupColor),
    );
  }
}
