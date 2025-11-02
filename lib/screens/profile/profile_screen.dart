import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final user = appState.currentUser; // Get the User object
    final Color backupColor = const Color(0xFF14B8A6);

    Widget profileAvatar;
    if (user.profileImageBase64 != null &&
        user.profileImageBase64!.isNotEmpty) {
      final imageBytes = base64Decode(user.profileImageBase64!);
      profileAvatar = CircleAvatar(
        radius: 30,
        backgroundImage: MemoryImage(imageBytes),
      );
    } else {
      profileAvatar = CircleAvatar(
        radius: 30,
        backgroundColor: theme.colorScheme.primary.withAlpha(179),
        child: const Icon(Icons.person, color: Colors.white, size: 30),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Account',
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 16),

          // --- 1. Profile Details Card (Original Layout) ---
          Card(
            child: ListTile(
              leading: profileAvatar,
              title: Text(
                user.fullName, // Use data from User object
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(user.email), // Use data from User object
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                // Navigate to the new edit screen
                onPressed: () => appState.navigate(AppScreen.profileEdit),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // --- 2. Navigation Links Card (Original Layout) ---
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.monetization_on,
                    color: theme.colorScheme.tertiary,
                  ),
                  title: const Text('Token Wallet & History'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => appState.navigate(AppScreen.wallet),
                ),
                ListTile(
                  leading: Icon(
                    Icons.bookmark,
                    color: theme.colorScheme.secondary,
                  ),
                  // FIX: Renamed 'My Bookmarks' to 'My Wishlisted'
                  title: Text(
                    'My Wishlisted (${appState.bookmarkedProductIds.length})',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => appState.navigate(AppScreen.bookmarks),
                ),
                ListTile(
                  leading: Icon(Icons.library_books, color: backupColor),
                  title: const Text('My Digital Library'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => appState.navigate(AppScreen.library),
                ),
                ListTile(
                  leading: Icon(
                    Icons.show_chart,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('My Activity & Purchases'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => appState.navigate(AppScreen.userActivity),
                ),
                ListTile(
                  leading: Icon(Icons.settings, color: Colors.grey),
                  title: const Text('App Settings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => appState.navigate(AppScreen.settings),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- Logout Button ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  appState.navigate(AppScreen.welcome), // Mock Logout
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
