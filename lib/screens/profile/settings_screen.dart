// lib/screens/settings/settings_screen.dart
// NOTE: This file was likely moved from lib/screens/profile/settings_screen.dart
// to align with the new 'Settings' focus in the bottom navigation.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We use Provider.of<AppState>(context) without listen: false for simplicity
    // in this stateless widget's build method, but generally one should consider
    // using context.read<AppState>() for navigation actions within onTap/onChanged
    // to prevent unnecessary widget rebuilds. For now, we keep the original pattern.
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // FIX: Use the AppState navigation helper directly
          onPressed: () => appState.navigateBack(),
        ),
        title: Text('App Settings', style: theme.textTheme.titleLarge),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Appearance Settings ---
            Text(
              'Appearance',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 2,
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                secondary: Icon(
                  appState.isDarkTheme ? Icons.dark_mode : Icons.light_mode,
                  color: theme.colorScheme.tertiary,
                ),
                title: const Text('Dark Theme'),
                value: appState.isDarkTheme,
                onChanged: (_) => appState.toggleTheme(),
                activeColor: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: 32),

            // --- 2. Security Settings ---
            Text(
              'Security & Account',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 2,
              child: Column(
                children: [
                  // UPDATED: Email Settings - Navigate to Email Management
                  ListTile(
                    leading: const Icon(Icons.email, color: Colors.blueGrey),
                    title: const Text('Email Address'),
                    subtitle: Text(appState.currentUser.email),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      appState.navigate(AppScreen.emailManagement);
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),

                  // UPDATED: Change Password - Navigate to Change Password Screen
                  ListTile(
                    leading: Icon(
                      Icons.lock,
                      color: theme.colorScheme.secondary,
                    ),
                    title: const Text('Change Password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      appState.navigate(AppScreen.changePassword);
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),

                  // UPDATED: Biometric Login
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    secondary: Icon(
                      Icons.fingerprint,
                      color: theme.colorScheme.tertiary,
                    ),
                    title: const Text('Biometric Login'),
                    value: appState.isBiometricEnabled,
                    onChanged: (newValue) =>
                        appState.toggleBiometrics(newValue),
                    activeColor: theme.colorScheme.tertiary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- 3. Notifications Settings ---
            Text(
              'Notifications',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 2,
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    secondary: Icon(
                      Icons.notifications_active,
                      color: theme.colorScheme.secondary,
                    ),
                    title: const Text('App Notifications'),
                    value: appState.areNotificationsEnabled,
                    onChanged: (newValue) =>
                        appState.toggleAppNotifications(newValue),
                    activeColor: theme.colorScheme.secondary,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    secondary: Icon(
                      Icons.receipt_long,
                      color: theme.colorScheme.primary.withOpacity(0.7),
                    ),
                    title: const Text('Promotional Emails'),
                    value: appState.isPromoEmailEnabled,
                    onChanged: (newValue) =>
                        appState.togglePromoEmails(newValue),
                    activeColor: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- 4. General/About Section ---
            Text(
              'General',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 2,
              child: Column(
                children: [
                  // UPDATED: About EduDoc - Navigate to About Screen
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: Colors.grey),
                    title: const Text('About EduDoc'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      appState.navigate(AppScreen.about);
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),

                  // UPDATED: Help & Support - Navigate to Help & Support Screen
                  ListTile(
                    leading: const Icon(Icons.help_outline, color: Colors.grey),
                    title: const Text('Help & Support'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      appState.navigate(AppScreen.helpSupport);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
