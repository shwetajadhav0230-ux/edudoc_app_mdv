// lib/screens/common/help_support_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart'; // Import AppState

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  // --- Data Model for FAQs ---
  final List<Map<String, String>> faqs = const [
    {
      'question': 'Trouble with login?',
      'answer':
          'Please ensure your email and password are correct. If you forgot your password, please check the Login screen for the "Forgot Password" link.',
    },
    {
      'question': 'How to purchase tokens?',
      'answer':
          'You can purchase tokens via the Wallet screen. Tap the wallet icon in the AppBar or navigate to Profile > Wallet to view purchase packages.',
    },
    {
      'question': 'Can I download documents for offline use?',
      'answer':
          'Yes! Once a document is purchased or downloaded (if free), it is saved to your Library and is available for offline viewing via the Library tab.',
    },
    {
      'question': 'Where is my purchase history?',
      'answer':
          'Your transaction history is available in the Wallet section of your Profile page.',
    },
  ];

  // --- Utility Function: Show Dialog for Contact Actions ---
  void _showContactDialog(
    BuildContext context,
    String title,
    String actionDescription,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(
            'Action Simulated: The app would now $actionDescription. This functionality is a placeholder.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
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
        title: const Text('Help & Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How can we help?',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),

            // --- Section 1: FAQs (Single-Page Expansion Panels) ---
            Text(
              'Frequently Asked Questions (FAQ)',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            Card(
              elevation: 1,
              child: Column(
                children: faqs.map((faq) {
                  return Theme(
                    data: theme.copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      key: PageStorageKey(faq['question']),
                      title: Text(
                        faq['question']!,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      // The answer is immediately available below the question
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Text(
                            faq['answer']!,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const Divider(height: 32),

            // --- Section 2: Contact Us (ONLY Email remains) ---
            Text('Contact Us', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),

            Card(
              elevation: 1,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.email,
                      color: theme.colorScheme.secondary,
                    ),
                    title: const Text('Send an email'),
                    subtitle: const Text('support@edudoc.com'),
                    trailing: const Icon(Icons.launch),
                    // FUNCTIONALITY: Use Dialog for external action (Email)
                    onTap: () {
                      _showContactDialog(
                        context,
                        'Email Support',
                        'launch an email to support@edudoc.com',
                      );
                    },
                  ),
                  // NOTE: Live Chat ListTile and the preceding Divider have been removed.
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
