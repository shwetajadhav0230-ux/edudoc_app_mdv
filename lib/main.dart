// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'widgets/common_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/config.dart';

void main() async {
  // Ensure Flutter bindings are initialized for Supabase and Secure Storage
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
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

class EduDocApp extends StatefulWidget {
  const EduDocApp({super.key});

  @override
  State<EduDocApp> createState() => _EduDocAppState();
}

// Added WidgetsBindingObserver to handle Auto-Lock Timer logic
class _EduDocAppState extends State<EduDocApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    // Register the observer to track when the app goes to background/foreground
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Unregister observer to prevent memory leaks
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pass the lifecycle state change to AppState to manage the Auto-Lock timer
    Provider.of<AppState>(context, listen: false).handleAppLifecycleState(state);
  }

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
        surface: Color(0xFF1E293B),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      cardColor: const Color(0xFF1E293B),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
        bodyMedium: TextStyle(fontFamily: 'Inter'),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF0F172A),
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      useMaterial3: true,
    );

    // --- Light Theme Definition ---
    const Color lightPrimary = Color(0xFF4F46E5);
    const Color lightSecondary = Color(0xFF0D9488);
    const Color lightTertiary = Color(0xFFF59E0B);
    const Color lightBackground = Color(0xFFF1F5F9);
    const Color lightSurface = Color(0xFFFFFFFF);
    const Color lightTextMain = Color(0xFF1E293B);
    const Color lightTextSubtle = Color(0xFF64748B);

    final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        secondary: lightSecondary,
        tertiary: lightTertiary,
        surface: lightSurface,
        onSurface: lightTextMain,
        onSurfaceVariant: lightTextSubtle,
      ),
      scaffoldBackgroundColor: lightBackground,
      cardColor: lightSurface,
      textTheme: TextTheme(
        headlineSmall: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, color: lightTextMain),
        titleLarge: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, color: lightTextMain),
        bodyMedium: const TextStyle(fontFamily: 'Inter', color: lightTextMain),
        bodySmall: TextStyle(fontFamily: 'Inter', color: lightTextSubtle),
        labelLarge: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: lightPrimary,
        unselectedItemColor: lightTextSubtle,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'EduDoc Flutter SPA',
      debugShowCheckedModeBanner: false,
      theme: appState.isDarkTheme ? darkTheme : lightTheme,
      // MainScreenRouter handles the internal routing based on appState.currentScreen
      home: const MainScreenRouter(backupColor: backupColor),
    );
  }
}