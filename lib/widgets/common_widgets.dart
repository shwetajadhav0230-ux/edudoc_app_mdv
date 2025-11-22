// lib/widgets/common_widgets.dart
import '../screens/auth/verify_email_screen.dart'; // <--- Add this
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/auth/lock_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/permissions_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/common/about_screen.dart';
import '../screens/common/help_support_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/library/bookmarks_screen.dart';
import '../screens/library/library_screen.dart';
import '../screens/offers/offer_detail_screen.dart';
import '../screens/offers/offers_screen.dart';
import '../screens/product/product_detail_screen.dart';
import '../screens/product/reading_screen.dart';
import '../screens/profile/activity_screen.dart';
import '../screens/profile/change_password_screen.dart';
import '../screens/profile/email_management_screen.dart';
import '../screens/profile/profile_edit_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/wallet/wallet_screen.dart';
import '../services/payment_service.dart';
import '../state/app_state.dart';
import '../utils/constants.dart';
import 'custom_widgets/bottom_nav.dart';
import 'custom_widgets/profile_avatar.dart';
import 'custom_widgets/wallet_button.dart';

// -----------------------------------------------------
// MAIN APP SCAFFOLD
// Handles the permanent AppBar and BottomNavigationBar
// -----------------------------------------------------

class MainAppScaffold extends StatelessWidget {
  final Widget child;
  final Color backupColor;
  const MainAppScaffold({
    super.key,
    required this.child,
    required this.backupColor,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // Define screens that should NOT have the main AppBar
    final List<AppScreen> screensWithoutMainAppBar = [
      AppScreen.library,
      AppScreen.bookmarks,
      AppScreen.cart,
      AppScreen.profile,
      AppScreen.wallet,
      AppScreen.settings,
      AppScreen.userActivity,
      AppScreen.offers,
      AppScreen.offerDetails,
      AppScreen.productDetails,
      AppScreen.search,
      AppScreen.emailManagement,
      AppScreen.changePassword,
      AppScreen.about,
      AppScreen.helpSupport,
      AppScreen.profileEdit,
    ];

    final bool shouldShowMainAppBar = !screensWithoutMainAppBar.contains(
      appState.currentScreen,
    );

    return Scaffold(
      appBar: shouldShowMainAppBar
          ? AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.colorScheme.surface.withAlpha(210),
        elevation: theme.brightness == Brightness.light ? 1 : 0,
        toolbarHeight: 65,
        leading: null,
        title: Row(
          children: [
            Icon(Icons.school, color: theme.colorScheme.tertiary),
            const SizedBox(width: 8),
            Text(
              'EduDoc',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 24,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => appState.navigate(AppScreen.search),
            color: Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          WalletButton(onTap: () => appState.navigate(AppScreen.wallet)),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SizedBox(
              width: 40,
              height: 40,
              child: ProfileAvatar(
                onTap: () => appState.navigate(AppScreen.profile),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      )
          : null,
      body: child,
      bottomNavigationBar: Builder(
        builder: (context) {
          int currentIndex = 0;

          // Determine active tab index
          switch (appState.currentScreen) {
            case AppScreen.home:
              currentIndex = 0;
              break;
            case AppScreen.library:
            case AppScreen.bookmarks:
              currentIndex = 1;
              break;
            case AppScreen.cart:
              currentIndex = 2;
              break;
            case AppScreen.profile:
            case AppScreen.wallet:
            case AppScreen.userActivity:
            case AppScreen.settings:
            case AppScreen.profileEdit:
              currentIndex = 3;
              break;
            default:
              currentIndex = 0;
          }

          // Only show BottomNav for main tabs
          final bool showBottomNav = [
            AppScreen.home,
            AppScreen.library,
            AppScreen.bookmarks,
            AppScreen.cart,
            AppScreen.profile,
            AppScreen.settings,
            AppScreen.wallet,
            AppScreen.userActivity,
          ].contains(appState.currentScreen);

          if (!showBottomNav) return const SizedBox.shrink();

          return BottomNav(
            currentIndex: currentIndex,
            onTap: (index) {
              switch (index) {
                case 0:
                  appState.navigate(AppScreen.home);
                  break;
                case 1:
                  appState.navigate(AppScreen.library);
                  break;
                case 2:
                  appState.navigate(AppScreen.cart);
                  break;
                case 3:
                  appState.navigate(AppScreen.settings);
                  break;
              }
            },
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------
// MAIN SCREEN ROUTER (FIXED WITH PopScope)
// -----------------------------------------------------

class MainScreenRouter extends StatelessWidget {
  final Color backupColor;
  const MainScreenRouter({super.key, required this.backupColor});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    Widget currentView;
    bool showScaffold = true;

    switch (appState.currentScreen) {
      case AppScreen.welcome:
        currentView = const WelcomeScreen();
        showScaffold = false;
        break;
      case AppScreen.login:
        currentView = const LoginScreen();
        showScaffold = false;
        break;
      case AppScreen.signup:
        currentView = const SignUpScreen();
        showScaffold = false;
        break;
      case AppScreen.permissions:
        currentView = const PermissionsScreen();
        showScaffold = false;
        break;
      case AppScreen.lockUnlock:
        currentView = const LockUnlockScreen();
        showScaffold = false;
        break;
      case AppScreen.reading:
        currentView = const ReadingScreen();
        showScaffold = false;
        break;
      case AppScreen.profileEdit:
        currentView = const ProfileEditScreen();
        showScaffold = false;
        break;

    // Deep Settings Screens
      case AppScreen.emailManagement:
      case AppScreen.changePassword:
      case AppScreen.about:
      case AppScreen.helpSupport:
        currentView = _buildMainAppContent(appState.currentScreen);
        showScaffold = false;
        break;

      default:
        showScaffold = true;
        currentView = _buildMainAppContent(appState.currentScreen);
        break;
    }

    // ⚡ CRITICAL FIX: PopScope
    // This intercepts the Android "Back" button.
    return PopScope(
      // If we are on Home, allow system pop (close app).
      // Otherwise, block it and use our internal navigation.
      canPop: appState.currentScreen == AppScreen.home,
      onPopInvoked: (bool didPop) {
        if (didPop) return; // The system already handled the pop
        appState.navigateBack(); // Go back in our custom stack
      },
      child: showScaffold
          ? MainAppScaffold(backupColor: backupColor, child: currentView)
          : currentView,
    );
  }

  Widget _buildMainAppContent(AppScreen screen) {
    switch (screen) {
      case AppScreen.home:
        return const HomeScreen();
      case AppScreen.cart:
        return const CartScreen();
      case AppScreen.wallet:
        return const WalletScreen();
      case AppScreen.verifyEmail:
        return const VerifyEmailScreen();
      case AppScreen.profile:
        return const ProfileScreen();
      case AppScreen.settings:
        return const SettingsScreen();
      case AppScreen.bookmarks:
        return const BookmarksScreen();
      case AppScreen.library:
        return const LibraryScreen();
      case AppScreen.offers:
        return const OffersScreen();
      case AppScreen.offerDetails:
        return const OfferDetailsScreen();
      case AppScreen.adminDashboard:
      case AppScreen.userActivity:
        return const ActivityScreen();
      case AppScreen.productDetails:
        return const ProductDetailsScreen();
      case AppScreen.search:
        return const SearchScreen();
      case AppScreen.emailManagement:
        return const EmailManagementScreen();
      case AppScreen.changePassword:
        return const ChangePasswordScreen();
      case AppScreen.about:
        return const AboutScreen();
      case AppScreen.helpSupport:
        return const HelpSupportScreen();
      default:
        return const Center(
          child: Text(
            '404 Page Not Found',
            style: TextStyle(color: Colors.white),
          ),
        );
    }
  }
}

class BuyTokensModal extends StatelessWidget {
  const BuyTokensModal({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final theme = Theme.of(context);

    final packages = [100, 500, 1000, 2500];

    return AlertDialog(
      title: Text(
        'Purchase Tokens',
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5,
          ),
          itemCount: packages.length,
          itemBuilder: (context, index) {
            final amount = packages[index];
            return GestureDetector(
              onTap: () {
                final user = appState.currentUser;
                Navigator.of(context).pop();
                PaymentService().payForTokens(
                  context,
                  tokens: amount,
                  contact: user.phoneNumber,
                  email: user.email,
                );
              },
              child: Card(
                color: amount == 500
                    ? theme.colorScheme.secondary.withOpacity(0.1)
                    : theme.cardColor,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$amount',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                      const Text(
                        'Tokens',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${((amount * AppConstants.paisePerToken) / 100).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}