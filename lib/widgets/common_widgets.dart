// FIX: Assume this entire block is the content of common_widgets.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/auth/lock_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/permissions_screen.dart'; // <--- FIX: Ensure this class exists here
import '../screens/auth/signup_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/library/bookmarks_screen.dart';
import '../screens/library/library_screen.dart';
import '../screens/offers/offer_detail_screen.dart';
import '../screens/offers/offers_screen.dart';
import '../screens/product/product_detail_screen.dart';
import '../screens/product/reading_screen.dart';
import '../screens/profile/activity_screen.dart';
import '../screens/profile/profile_edit_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/wallet/wallet_screen.dart';
import '../state/app_state.dart';
import 'custom_widgets/bottom_nav.dart';
import 'custom_widgets/profile_avatar.dart';
import 'custom_widgets/wallet_button.dart';

// -----------------------------------------------------
// FIX 1: MainAppScaffold now conditionally shows the AppBar
//        The list of screens that use their own app bar is updated.
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

    // Define all secondary/detail screens that should NOT display the persistent 'EduDoc' AppBar.
    // They are expected to provide their own AppBar.
    final List<AppScreen> screensWithoutMainAppBar = [
      AppScreen.library,
      AppScreen.bookmarks,
      AppScreen
          .cart, // Added to fix the double app bar on the Shopping Cart screen
      AppScreen
          .profile, // Added to fix the double app bar on the My Account screen
      AppScreen.wallet,
      AppScreen.settings,
      AppScreen.userActivity,
      AppScreen.offers,
      AppScreen.offerDetails,
      AppScreen.productDetails,
      AppScreen.search,
    ];

    final bool shouldShowMainAppBar = !screensWithoutMainAppBar.contains(
      appState.currentScreen,
    );

    return Scaffold(
      // Conditionally set the AppBar to null for detail screens
      appBar: shouldShowMainAppBar
          ? AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: theme.colorScheme.surface.withOpacity(0.95),
              elevation: theme.brightness == Brightness.light ? 1 : 0,
              toolbarHeight: 72,

              // // Logo/Title placement
              // title: Row(
              //   children: [
              //     Icon(Icons.school, color: theme.colorScheme.tertiary),
              //     const SizedBox(width: 8),
              //     Text(
              //       'EduDoc',
              //       style: theme.textTheme.titleLarge?.copyWith(
              //         fontSize: 24,
              //         color: theme.colorScheme.primary,
              //       ),
              //     ),
              //   ],
              // ),

              // Icon Placements using standard 'actions'
              actions: [
                WalletButton(onTap: () => appState.navigate(AppScreen.wallet)),
                const SizedBox(width: 8),

                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => appState.navigate(AppScreen.search),
                  color: Colors.grey.shade400,
                ),

                ProfileAvatar(
                  onTap: () => appState.navigate(AppScreen.profile),
                ),
                const SizedBox(width: 8),
              ],
            )
          : null, // Set AppBar to null for detail screens
      body: child,
      bottomNavigationBar: Builder(
        builder: (context) {
          int currentIndex = 0;
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
                  appState.navigate(AppScreen.profile);
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
// FIX 2: MainScreenRouter now correctly references MainAppScaffold
// -----------------------------------------------------

class MainScreenRouter extends StatelessWidget {
  final Color backupColor;
  const MainScreenRouter({super.key, required this.backupColor});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    Widget currentView;
    bool showScaffold = true; // Default to showing the full scaffold

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
        // This line is structurally correct, but the PermissionsScreen class
        // definition in its own file is likely missing or misspelled.
        currentView = const PermissionsScreen();
        showScaffold = false;
        break;
      case AppScreen.lockUnlock:
        currentView = const LockUnlockScreen();
        showScaffold = false;
        break;
      case AppScreen.reading:
        currentView = const ReadingScreen();
        showScaffold = false; // Reading screen typically full-screen
        break;
      case AppScreen.profileEdit:
        currentView = const ProfileEditScreen();
        showScaffold = false; // Edit screen typically full-screen
        break;
      default:
        // All other screens will use the MainAppScaffold, but the
        // MainAppScaffold itself now decides whether to show the AppBar.
        showScaffold = true;
        currentView = _buildMainAppContent(appState.currentScreen);
        break;
    }

    // FIX: MainAppScaffold is used correctly as a constructor
    return showScaffold
        ? MainAppScaffold(backupColor: backupColor, child: currentView)
        : currentView;
  }

  Widget _buildMainAppContent(AppScreen screen) {
    switch (screen) {
      case AppScreen.home:
        return const HomeScreen();
      case AppScreen.cart:
        return const CartScreen();
      case AppScreen.wallet:
        return const WalletScreen();
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
  // ... (content of BuyTokensModal remains the same) ...
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
                appState.buyTokens(amount);
                Navigator.of(context).pop();
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
                        '\$${(amount / 100).toStringAsFixed(2)}',
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
