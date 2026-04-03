import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import 'wallet_button.dart';
import 'profile_avatar.dart';

class BottomNav extends StatelessWidget {
  final int initialIndex;
  final Widget child;

  const BottomNav({
    super.key,
    required this.initialIndex,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // AppBar only on Home (index 0)
    final bool showAppBar = initialIndex == 0;

    return Consumer<AppState>(
      builder: (context, appState, _) => Scaffold(
        appBar: showAppBar
            ? AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: theme.colorScheme.surface.withOpacity(0.95),
                elevation: 0,
                toolbarHeight: 65,
                title: Row(
                  children: [
                    Icon(Icons.school, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'EduDoc',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                actions: [
                  // Search icon — navigates to search screen
                  IconButton(
                    icon: Icon(Icons.search_rounded, color: theme.colorScheme.onSurface),
                    tooltip: 'Search',
                    onPressed: () => appState.navigate(AppScreen.search),
                  ),
                  WalletButton(onTap: () => appState.navigate(AppScreen.wallet)),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: ProfileAvatar(onTap: () => appState.navigate(AppScreen.profile)),
                  ),
                ],
              )
            : null,
        body: child,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: initialIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.cardColor,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            switch (index) {
              case 0: appState.navigate(AppScreen.home); break;
              case 1: appState.navigate(AppScreen.search); break;
              case 2: appState.navigate(AppScreen.library); break;
              case 3: appState.navigate(AppScreen.cart); break;
              case 4: appState.navigate(AppScreen.profile); break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.library_books_rounded), label: 'Library'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_rounded), label: 'Cart'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}