// Auto-generated screen from main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    // Define backupColor locally
    final Color backupColor = const Color(0xFF14B8A6);

    final ownedCount = appState.bookmarkedProductIds.length;
    final user = appState.currentUser;

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
          // Profile Card
          Card(
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: theme.colorScheme.primary,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              title: Text(
                user['name'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(user['email'] as String),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {},
              ), // Mock Edit Profile
            ),
          ),
          const SizedBox(height: 24),
          // Navigation Links
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
                  title: Text('My Bookmarks ($ownedCount)'),
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
