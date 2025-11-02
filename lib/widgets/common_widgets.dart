import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/auth/lock_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/permissions_screen.dart';
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
// FIX: Import the new profile edit screen
import '../screens/profile/profile_edit_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/wallet/wallet_screen.dart';
import '../state/app_state.dart';
import 'custom_widgets/bottom_nav.dart';
// Assuming ProfileAvatar is defined in 'custom_widgets/profile_avatar.dart'
import 'custom_widgets/profile_avatar.dart';
import 'custom_widgets/wallet_button.dart';
import 'custom_widgets/cart_icon_badge.dart';


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

    // Replicates the backdrop-blur fixed header
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 50,
        backgroundColor: theme.colorScheme.surface.withAlpha(242),
        elevation: theme.brightness == Brightness.light ? 1 : 0,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
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
                Row(
                  children: [
                    WalletButton(
                      onTap: () => appState.navigate(AppScreen.wallet),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => appState.navigate(AppScreen.search),
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 8),
                    // FIX: Use the imported ProfileAvatar
                    ProfileAvatar(
                      onTap: () => appState.navigate(AppScreen.profile),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
            // FIX: Ensure profile tab is selected when editing
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

class MainScreenRouter extends StatelessWidget {
  final Color backupColor;
  const MainScreenRouter({super.key, required this.backupColor});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // This handles the transition between Auth/Lock screens and the main Scaffold.
    Widget currentView;
    bool showScaffold = false;

    switch (appState.currentScreen) {
      case AppScreen.welcome:
        currentView = const WelcomeScreen();
        break;
      case AppScreen.login:
        currentView = const LoginScreen();
        break;
      case AppScreen.signup:
        currentView = const SignUpScreen();
        break;
      case AppScreen.permissions:
        currentView = const PermissionsScreen();
        break;
      case AppScreen.lockUnlock:
        currentView = const LockUnlockScreen();
        break;
      case AppScreen.reading:
        currentView = const ReadingScreen();
        break;
      // FIX: Add routing for the new ProfileEditScreen
      case AppScreen.profileEdit:
        currentView = const ProfileEditScreen();
        showScaffold = false; // The edit screen has its own Scaffold/AppBar
        break;
      default:
        showScaffold = true;
        currentView = _buildMainAppContent(appState.currentScreen);
        break;
    }

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
        // This is the 404 error you were seeing
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
                appState.buyTokens(amount);
                Navigator.of(context).pop();
              },
              child: Card(
                color: amount == 500
                    ? theme.colorScheme.secondary.withAlpha(25)
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

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Permissions')),
      body: ListView(
        children: const [
          PermissionTile(
            icon: Icons.camera_alt,
            title: 'Camera',
            description: 'Access to camera for scanning documents',
            enabled: true,
          ),
          PermissionTile(
            icon: Icons.notifications,
            title: 'Notifications',
            description: 'Receive alerts and updates',
            enabled: false,
          ),
        ],
      ),
    );
  }
}