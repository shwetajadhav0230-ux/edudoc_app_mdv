// Auto-generated main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'widgets/common_widgets.dart'; // Assuming MainScreenRouter is in here
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/config.dart';
void main() async {
  // 4. Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 5. Initialize Supabase
  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
  );

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
    const backupColor = Color(0xFF14B8A6); // Teal 500

    // --- Dark Theme Definition ---
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

      // --- FIX FOR BOTTOM NAV (DARK) ---
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF0F172A), // Matches scaffold background
        selectedItemColor: primaryColor, // Use the main primary color
        unselectedItemColor: Colors.grey.shade600, // A visible grey
        type: BottomNavigationBarType.fixed, // Ensures all labels are shown
        showUnselectedLabels: true,
      ),
      // --- END FIX ---

      useMaterial3: true,
    );

    // lib/main.dart
// ... (keep all your existing code above the lightTheme variable) ...

    // --- Light Theme Definition ---
    // DEFINE THE NEW COLORS
    const Color lightPrimary = Color(0xFF4F46E5); // Indigo 600 (Strong, professional)
    const Color lightSecondary = Color(0xFF0D9488); // Teal 600 (Calm, complementary)
    const Color lightTertiary = Color(0xFFF59E0B); // Amber 600 (Rich highlight for tokens)
    const Color lightBackground = Color(0xFFF1F5F9); // Blue-Gray 50 (Soft, cool background)
    const Color lightSurface = Color(0xFFFFFFFF); // White (For cards)
    const Color lightTextMain = Color(0xFF1E293B); // Blue-Gray 900 (Dark text)
    const Color lightTextSubtle = Color(0xFF64748B); // Blue-Gray 500 (Subtle text)

    final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        secondary: lightSecondary,
        tertiary: lightTertiary,
        surface: lightSurface,
        onSurface: lightTextMain, // Main text on cards
        onSurfaceVariant: lightTextSubtle, // Main text on background
      ),
      scaffoldBackgroundColor: lightBackground,
      cardColor: lightSurface,
      textTheme: TextTheme(
        headlineSmall: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
          color: lightTextMain, // Use main text color
        ),
        titleLarge: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
          color: lightTextMain, // Use main text color
        ),
        bodyMedium: const TextStyle(
          fontFamily: 'Inter',
          color: lightTextMain, // Use main text color
        ),
        bodySmall: TextStyle(
          fontFamily: 'Inter',
          color: lightTextSubtle, // Use subtle text color
        ),
        labelLarge: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
      ),

      // --- FIX FOR BOTTOM NAV (LIGHT) ---
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: lightSurface, // A clean white background
        selectedItemColor: lightPrimary, // Use the light primary color
        unselectedItemColor: lightTextSubtle, // Use the subtle gray
        type: BottomNavigationBarType.fixed, // Ensures all labels are shown
        showUnselectedLabels: true,
      ),
      // --- END FIX ---

      useMaterial3: true,
    );

    return MaterialApp(
      // ... (rest of your MaterialApp remains the same) ...
      title: 'EduDoc Flutter SPA',
      debugShowCheckedModeBanner: false,
      theme: appState.isDarkTheme ? darkTheme : lightTheme,
      // The backupColor pass-through is unchanged
      home: const MainScreenRouter(backupColor: backupColor),
    );
  }
}
