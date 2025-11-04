import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart'; // Import AppState

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // --- Utility Function: Show Dialog for Legal Documents (With TextAlign.justify) ---
  void _showLegalDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Placeholder content simulating the core document text
                Text(
                  title == 'Privacy Policy'
                      ? 'EduDoc collects data solely to improve your learning experience, ensure account security, and personalize document recommendations. We do not sell your personal data to third parties. Please refer to our full policy on the web for details.'
                      : 'By using the EduDoc application, you agree to the terms outlined, including the proper use of purchased content and adherence to copyright laws. Violations may result in account termination. Full terms apply.',
                  style: Theme.of(context).textTheme.bodySmall,
                  // ✨ FIX: Apply justified alignment here
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // VITAL: Back button linked to the AppState navigation logic
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => appState.navigateBack(),
        ),
        title: const Text('About EduDoc'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Title and Version ---
            Text(
              'EduDoc: Your Digital Library',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Version: 1.2.0',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text('© 2025 EduDoc Corp. All rights reserved.'),
            const Divider(height: 32),

            // --- Mission Statement ---
            Text('Mission Statement', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              'Our mission is to democratize knowledge by providing a vast, easily accessible, and affordable library of educational documents and resources to students worldwide.',
            ),
            const Divider(height: 32),

            // --- Legal Links (Now functional with cleaner Dialogs) ---
            Text('Legal Documents', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),

            Card(
              elevation: 1,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.policy,
                      color: theme.colorScheme.secondary,
                    ),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showLegalDialog(context, 'Privacy Policy');
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.description,
                      color: theme.colorScheme.secondary,
                    ),
                    title: const Text('Terms of Service'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showLegalDialog(context, 'Terms of Service');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
