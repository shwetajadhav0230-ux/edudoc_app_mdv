// Auto-generated screen from main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App Settings',
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 16),
          // Appearance
          Card(
            child: ListTile(
              leading: Icon(Icons.color_lens, color: theme.colorScheme.primary),
              title: const Text('Dark Theme'),
              trailing: Switch(
                value: appState.isDarkTheme,
                onChanged: (_) => appState.toggleTheme(),
                // Replaced activeColor with activeTrackColor/activeThumbColor for Switch
                activeTrackColor: theme.colorScheme.primary.withOpacity(0.5),
                activeThumbColor: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Security
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.lock, color: theme.colorScheme.secondary),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(
                    Icons.fingerprint,
                    color: theme.colorScheme.tertiary,
                  ),
                  title: const Text('Biometric Login'),
                  trailing: Switch(
                    value: true,
                    onChanged: (_) {},
                    // Replaced activeColor with activeTrackColor/activeThumbColor for Switch
                    activeTrackColor: theme.colorScheme.tertiary.withOpacity(
                      0.5,
                    ),
                    activeThumbColor: theme.colorScheme.tertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
