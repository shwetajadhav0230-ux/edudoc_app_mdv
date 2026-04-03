import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';

// Config & State
import 'state/app_state.dart';
import 'utils/config.dart';
import 'services/notification_service.dart';
import 'widgets/custom_widgets/bottom_nav.dart';

// Screens
import 'screens/auth/lock_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/permissions_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/common/about_screen.dart';
import 'screens/common/help_support_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/library/bookmarks_screen.dart';
import 'screens/library/library_screen.dart';
import 'screens/offers/offer_detail_screen.dart';
import 'screens/offers/offers_screen.dart';
import 'screens/product/product_detail_screen.dart';
import 'screens/profile/change_password_screen.dart';
import 'screens/profile/email_management_screen.dart';
import 'screens/profile/profile_edit_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/profile_setup_screen.dart';
import 'screens/profile/settings_screen.dart';
import 'screens/profile/user_activity_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/wallet/wallet_screen.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
  );

  try {
    await FlutterWindowManagerPlus.clearFlags(FlutterWindowManagerPlus.FLAG_SECURE);
  } catch (e) {
    debugPrint("Failed to clear secure flags: $e");
  }

  await NotificationService().init();

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

class _EduDocAppState extends State<EduDocApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    Provider.of<AppState>(context, listen: false).handleAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // --- Theme Config ---
    final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF4F46E5),
        secondary: Color(0xFF0D9488),
        tertiary: Color(0xFFF59E0B),
        surface: Color(0xFFFFFFFF),
      ),
      scaffoldBackgroundColor: const Color(0xFFF1F5F9),
      useMaterial3: true,
    );

    final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6366F1),
        secondary: Color(0xFFF472B6),
        tertiary: Color(0xFFFBBF24),
        surface: Color(0xFF1E293B),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'EduDoc',
      debugShowCheckedModeBanner: false,
      theme: appState.isDarkTheme ? darkTheme : lightTheme,
      home: _getScreen(appState.currentScreen),
    );
  }

  Widget _getScreen(AppScreen screen) {
    switch (screen) {
      case AppScreen.splash:
      case AppScreen.welcome: return const WelcomeScreen();
      case AppScreen.login: return const LoginScreen();
    // ✅ Restored YOUR exact class name
      case AppScreen.signup: return const SignUpScreen();
      case AppScreen.verifyEmail: return const VerifyEmailScreen();
      case AppScreen.permissions: return const PermissionsScreen();
    // ✅ Restored YOUR exact class name
      case AppScreen.lockUnlock: return const LockUnlockScreen();

    // Tab Screens
      case AppScreen.home: return const BottomNav(initialIndex: 0, child: HomeScreen());
      case AppScreen.search: return const BottomNav(initialIndex: 1, child: SearchScreen());
      case AppScreen.library: return const BottomNav(initialIndex: 2, child: LibraryScreen());
      case AppScreen.profile: return const BottomNav(initialIndex: 3, child: ProfileScreen());

    // Other Screens
    // ✅ Restored YOUR exact class name
      case AppScreen.productDetails: return const ProductDetailsScreen();
      case AppScreen.cart: return const CartScreen();
      case AppScreen.wallet: return const WalletScreen();
      case AppScreen.settings: return const SettingsScreen();
      case AppScreen.bookmarks: return const BookmarksScreen();
      case AppScreen.offers: return const OffersScreen();
    // ✅ Restored YOUR exact class name
      case AppScreen.offerDetails: return const OfferDetailsScreen();
      case AppScreen.userActivity: return const UserActivityScreen();
      case AppScreen.profileEdit: return const ProfileEditScreen();
      case AppScreen.profileSetup: return const ProfileSetupScreen();
      case AppScreen.emailManagement: return const EmailManagementScreen();
      case AppScreen.changePassword: return const ChangePasswordScreen();
      case AppScreen.about: return const AboutScreen();
      case AppScreen.helpSupport: return const HelpSupportScreen();

      default: return const WelcomeScreen();
    }
  }
}