// lib/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import 'downloads_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final user = appState.currentUser;

    Widget profileAvatar;

    // ✅ FIX: Use NetworkImage for URL, Fallback to Icon
    if (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty) {
      profileAvatar = CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(user.profileImageUrl!),
        onBackgroundImageError: (_, __) {
          // Fallback if URL is invalid/expired
        },
      );
    } else {
      profileAvatar = CircleAvatar(
        radius: 30,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        child: Icon(Icons.person, color: theme.colorScheme.primary, size: 30),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => appState.navigateBack(),
        ),
        title: Text('My Account', style: theme.textTheme.titleLarge),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Profile Details Card ---
            Card(
              child: ListTile(
                leading: profileAvatar,
                title: Text(
                  user.fullName.isNotEmpty ? user.fullName : 'No Name',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(user.email),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => appState.navigate(AppScreen.profileEdit),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- 2. Navigation Links Card ---
            Card(
              child: Column(
                children: [
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
                    leading: const Icon(Icons.download_done_rounded, color: Colors.indigo),
                    title: const Text('Offline Library'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DownloadsScreen())
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- Logout Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => appState.logout(),
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
      ),
    );
  }
}